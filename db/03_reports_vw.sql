-- db/reports_vw.sql
-- Vistas materializadas lógicamente para el Dashboard Escolar

-- ==============================================================================
-- VISTA 1: Rendimiento por Curso
-- ==============================================================================
-- DESCRIPCIÓN: Muestra el promedio general y la tasa de reprobación por materia y periodo.
-- GRAIN: 1 fila por Curso + Periodo (Term).
-- MÉTRICAS: 
--   - Promedio Final (AVG)
--   - Total de Alumnos (COUNT)
--   - Tasa de Reprobación (Campo Calculado con CASE)
-- GROUP BY: Agrupa todas las calificaciones de un mismo grupo para sacar el promedio.
-- VERIFY:
--   SELECT * FROM vw_course_performance WHERE term = '2025-A';
--   SELECT average_grade FROM vw_course_performance WHERE course_code = 'MAT101';
-- ==============================================================================
CREATE OR REPLACE VIEW vw_course_performance AS
SELECT 
    c.code AS course_code,
    c.name AS course_name,
    g.term,
    COUNT(e.student_id) as total_students,
    ROUND(AVG(gr.final)::numeric, 2) as average_grade,
    SUM(CASE WHEN gr.final < 6.0 THEN 1 ELSE 0 END) as failed_students,
    ROUND((SUM(CASE WHEN gr.final < 6.0 THEN 1 ELSE 0 END)::numeric / COUNT(e.student_id) * 100), 1) as failure_rate
FROM courses c
JOIN groups g ON c.id = g.course_id
JOIN enrollments e ON g.id = e.group_id
JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY c.code, c.name, g.term;

-- ==============================================================================
-- VISTA 2: Carga y Desempeño Docente
-- ==============================================================================
-- DESCRIPCIÓN: Analiza la carga de trabajo de cada profesor y qué tan "duro" califica.
-- GRAIN: 1 fila por Profesor + Periodo.
-- MÉTRICAS:
--   - Grupos Activos (COUNT DISTINCT)
--   - Promedio que otorga (AVG de todos sus alumnos)
-- GROUP BY / HAVING: 
--   Agrupa por profesor.
--   HAVING filtra a profesores que existen en catálogo pero NO tienen grupos activos este ciclo.
-- VERIFY:
--   SELECT * FROM vw_teacher_load WHERE active_groups > 0;
-- ==============================================================================
CREATE OR REPLACE VIEW vw_teacher_load AS
SELECT 
    t.id AS teacher_id,
    t.name AS teacher_name,
    g.term,
    COUNT(DISTINCT g.id) as active_groups,
    COUNT(e.id) as total_students_taught,
    ROUND(AVG(gr.final)::numeric, 2) as average_grade_given
FROM teachers t
JOIN groups g ON t.id = g.teacher_id
JOIN enrollments e ON g.id = e.group_id
LEFT JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY t.id, t.name, g.term
HAVING COUNT(DISTINCT g.id) > 0;

-- ==============================================================================
-- VISTA 3: Alumnos en Riesgo (CTE + Lógica Compleja)
-- ==============================================================================
-- DESCRIPCIÓN: Identifica alumnos con promedio bajo O inasistencias altas.
-- GRAIN: 1 fila por Alumno.
-- MÉTRICAS:
--   - Promedio Actual (AVG de parciales)
--   - Total Faltas (COUNT FALSE)
--   - Estado de Riesgo (CASE complejo)
-- USO DE CTE (WITH): Se usa para pre-calcular asistencias y notas por separado antes de unir.
-- VERIFY:
--   SELECT * FROM vw_students_at_risk WHERE risk_status LIKE 'CRITICAL%';
-- ==============================================================================
CREATE OR REPLACE VIEW vw_students_at_risk AS
WITH StudentStats AS (
    SELECT 
        s.id as student_id,
        s.name,
        s.email,
        s.program,
        -- Promedio ponderado simple de lo que lleva cursado
        AVG((COALESCE(gr.partial1, 0) + COALESCE(gr.partial2, 0) + COALESCE(gr.final, 0)) / 3) as current_average
    FROM students s
    JOIN enrollments e ON s.id = e.student_id
    JOIN grades gr ON e.id = gr.enrollment_id
    GROUP BY s.id, s.name, s.email, s.program
),
AttendanceStats AS (
    SELECT 
        s.id as student_id,
        COUNT(*) filter (where a.present = false) as total_absences
    FROM students s
    JOIN enrollments e ON s.id = e.student_id
    JOIN attendance a ON e.id = a.enrollment_id
    GROUP BY s.id
)
SELECT 
    ss.student_id,
    ss.name,
    ss.email,
    ss.program,
    ROUND(ss.current_average::numeric, 1) as current_average,
    COALESCE(ast.total_absences, 0) as total_absences,
    CASE 
        WHEN ss.current_average < 6.0 AND COALESCE(ast.total_absences, 0) > 5 THEN 'CRITICAL: Academic + Attendance'
        WHEN ss.current_average < 6.0 THEN 'High Risk: Academic Failure'
        WHEN COALESCE(ast.total_absences, 0) > 5 THEN 'Medium Risk: Attendance'
        ELSE 'Low Risk'
    END as risk_status
FROM StudentStats ss
LEFT JOIN AttendanceStats ast ON ss.student_id = ast.student_id
WHERE ss.current_average < 7.0 OR COALESCE(ast.total_absences, 0) > 3;

-- ==============================================================================
-- VISTA 4: Asistencia por Grupo (Manejo de Nulos)
-- ==============================================================================
-- DESCRIPCIÓN: Porcentaje de asistencia promedio por grupo.
-- GRAIN: 1 fila por Grupo.
-- MÉTRICAS: % Asistencia.
-- USO DE COALESCE: 
--   Evita errores de división por cero si un grupo no tiene asistencias registradas.
-- VERIFY:
--   SELECT attendance_percentage FROM vw_attendance_by_group WHERE course_name LIKE 'Física%';
-- ==============================================================================
CREATE OR REPLACE VIEW vw_attendance_by_group AS
SELECT 
    g.id as group_id,
    c.name as course_name,
    t.name as teacher_name,
    g.term,
    ROUND(
        (COUNT(*) FILTER (WHERE a.present = TRUE)::numeric / 
        NULLIF(COUNT(*), 0) * 100), 
    1) as attendance_percentage
FROM groups g
JOIN courses c ON g.course_id = c.id
JOIN teachers t ON g.teacher_id = t.id
LEFT JOIN enrollments e ON g.id = e.group_id
LEFT JOIN attendance a ON e.id = a.enrollment_id
GROUP BY g.id, c.name, t.name, g.term;

-- ==============================================================================
-- VISTA 5: Cuadro de Honor (Window Function)
-- ==============================================================================
-- DESCRIPCIÓN: Ranking de mejores promedios particionado por carrera.
-- GRAIN: 1 fila por Alumno.
-- MÉTRICAS: Rank (Posición 1, 2, 3...).
-- USO DE WINDOW FUNCTION: 
--   DENSE_RANK() OVER (PARTITION BY program...): Reinicia el ranking para cada carrera.
--   Esto permite comparar "Peras con Peras" (Ingenieros vs Ingenieros).
-- VERIFY:
--   SELECT * FROM vw_rank_students WHERE rank_position <= 3;
-- ==============================================================================
CREATE OR REPLACE VIEW vw_rank_students AS
SELECT 
    s.id as student_id,
    s.name,
    s.program,
    ROUND(AVG(gr.final)::numeric, 2) as final_average,
    DENSE_RANK() OVER (
        PARTITION BY s.program 
        ORDER BY AVG(gr.final) DESC
    ) as rank_position
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY s.id, s.name, s.program
HAVING AVG(gr.final) >= 8.5; -- Solo alumnos destacados