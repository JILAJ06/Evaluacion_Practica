CREATE OR REPLACE VIEW vw_course_performance AS
SELECT 
    c.id AS course_id,
    c.name AS course_name,
    g.term,
    COUNT(e.id) AS total_students,
    COALESCE(AVG(gr.final), 0) AS average_grade,
    SUM(CASE WHEN gr.final < 6 THEN 1 ELSE 0 END) AS failed_students,
    (SUM(CASE WHEN gr.final < 6 THEN 1 ELSE 0 END)::DECIMAL / COUNT(e.id)) * 100 AS failure_rate
FROM courses c
JOIN groups g ON c.id = g.course_id
JOIN enrollments e ON g.id = e.group_id
LEFT JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY c.id, c.name, g.term
HAVING COUNT(e.id) > 0;

CREATE OR REPLACE VIEW vw_teacher_load AS
SELECT 
    t.id AS teacher_id,
    t.name AS teacher_name,
    g.term,
    COUNT(DISTINCT g.id) AS assigned_groups,
    COUNT(e.id) AS total_students_attended,
    COALESCE(AVG(gr.final), 0) AS avg_grading_strictness
FROM teachers t
JOIN groups g ON t.id = g.teacher_id
LEFT JOIN enrollments e ON g.id = e.group_id
LEFT JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY t.id, t.name, g.term
HAVING COUNT(DISTINCT g.id) > 0;

CREATE OR REPLACE VIEW vw_students_at_risk AS
WITH StudentStats AS (
    SELECT 
        s.id AS student_id,
        s.name,
        s.email,
        s.program,
        AVG(gr.final) AS current_average,
        (
            SELECT COUNT(*) 
            FROM attendance a 
            JOIN enrollments e2 ON a.enrollment_id = e2.id 
            WHERE e2.student_id = s.id AND a.present = FALSE
        ) AS total_absences
    FROM students s
    JOIN enrollments e ON s.id = e.student_id
    LEFT JOIN grades gr ON e.id = gr.enrollment_id
    GROUP BY s.id, s.name, s.email, s.program
)
SELECT 
    *,
    CASE 
        WHEN current_average < 6 AND total_absences > 3 THEN 'CRITICAL: Academic & Attendance'
        WHEN current_average < 6 THEN 'Academic Risk'
        WHEN total_absences > 3 THEN 'Attendance Risk'
        ELSE 'Safe'
    END AS risk_status
FROM StudentStats
WHERE current_average < 6 OR total_absences > 3;

CREATE OR REPLACE VIEW vw_attendance_by_group AS
SELECT 
    g.id AS group_id,
    c.name AS course_name,
    t.name AS teacher_name,
    g.term,
    COUNT(a.id) AS total_classes_recorded,
    COALESCE(
        (SUM(CASE WHEN a.present = TRUE THEN 1 ELSE 0 END)::DECIMAL / NULLIF(COUNT(a.id), 0)) * 100, 
        0
    ) AS attendance_percentage
FROM groups g
JOIN courses c ON g.course_id = c.id
JOIN teachers t ON g.teacher_id = t.id
JOIN enrollments e ON g.id = e.group_id
LEFT JOIN attendance a ON e.id = a.enrollment_id
GROUP BY g.id, c.name, t.name, g.term;

CREATE OR REPLACE VIEW vw_rank_students AS
SELECT 
    s.id AS student_id,
    s.name,
    s.program,
    ROUND(AVG(gr.final), 2) AS final_average,
    DENSE_RANK() OVER (
        PARTITION BY s.program 
        ORDER BY AVG(gr.final) DESC NULLS LAST
    ) AS rank_in_program
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN grades gr ON e.id = gr.enrollment_id
GROUP BY s.id, s.name, s.program;
