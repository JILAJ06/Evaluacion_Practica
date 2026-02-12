# SIGA - Dashboard de Reportes Académicos

**Materia:** Aplicaciones Web Orientadas a Servicios (AWOS) & Base de Datos Avanzadas
**Entrega:** Lab Reportes Next.js + PostgreSQL + Docker
**Alumno:** Alexander Jesús Jiménez León

---

## 📖 Descripción del Proyecto

Este proyecto es un Dashboard de Inteligencia de Negocios (BI) para la coordinación académica. Permite visualizar métricas críticas como rendimiento por materia, carga docente y detección de riesgo estudiantil.

La arquitectura sigue un enfoque **"Database-First"**: toda la lógica de negocio compleja (promedios, rankings, detección de riesgo) se procesa directamente en **PostgreSQL** mediante Vistas Materializadas Lógicamente, mientras que **Next.js** se encarga únicamente de la presentación y el filtrado seguro.

---

## 🧩 Arquitectura SOA Aplicada

El proyecto ahora separa responsabilidades en **servicios** con interfaces claras para consumir datos desde la UI:

- **Capa de Presentación (Next.js UI):** páginas de reportes en `src/app/reports/*/page.tsx`.
- **Capa de Servicios (SOA):** orquesta casos de uso y paginación en `src/services/reportService.ts`.
- **Capa de Repositorio (Data Access):** consultas SQL en `src/repositories/reportRepository.ts`.
- **Capa de Datos (PostgreSQL):** vistas y roles definidos en `db/*.sql`.

Este enfoque permite **reutilizar servicios**, centralizar reglas de acceso y aislar cambios en SQL sin romper la UI.

---

## ⚖️ Trade-offs: Decisiones de Diseño (SQL vs Next.js)

Se decidió delegar la carga de procesamiento a la Base de Datos en lugar del Backend (Node.js) por las siguientes razones:

* **Rendimiento en Agregaciones:** Calcular el promedio de 10,000 calificaciones usando `AVG()` en PostgreSQL es órdenes de magnitud más rápido que traer 10,000 objetos JSON a Next.js y usar `array.reduce()`.
* **Consistencia de Datos:** Al definir "Alumno Reprobado" (< 6.0) en una Vista SQL (`vw_course_performance`), garantizamos que cualquier reporte futuro use la misma regla. Si se hiciera en JS, habría que replicar la lógica en múltiples componentes, aumentando el riesgo de error humano.
* **Seguridad de Acceso:** Al exponer solo Vistas y no Tablas, reducimos la superficie de ataque. Si la aplicación es comprometida, el atacante solo ve datos procesados, no la estructura cruda de la base de datos.

---

## 🛡️ Threat Model (Modelo de Amenazas)

[cite_start]Para cumplir con los requisitos de seguridad, se implementaron las siguientes defensas:

1.  **Prevención de Inyección SQL:**
    * **Riesgo:** Un atacante podría manipular los filtros de búsqueda para borrar tablas.
    * **Mitigación:** Uso estricto de **consultas parametrizadas** en el cliente `pg` (ej. `WHERE term = $1`). Los inputs del usuario nunca se concatenan directamente en el string SQL.
    * **Validación:** Uso de **Zod** para validar que los parámetros de URL (como `page` o `term`) sean del tipo correcto antes de tocar la BD.

2.  **Principio de Menor Privilegio (Least Privilege):**
    * **Riesgo:** Si las credenciales de la app son robadas, el atacante podría modificar calificaciones.
    * **Mitigación:** La aplicación NO se conecta como `postgres` (superusuario). Se creó un rol específico `dashboard_user` que tiene permisos **REVOCADOS** en todas las tablas y solo tiene `GRANT SELECT` sobre las 5 Vistas específicas.

3.  **Gestión de Secretos:**
    * **Riesgo:** Exposición de contraseñas en repositorios públicos.
    * **Mitigación:** Las credenciales se inyectan mediante variables de entorno (`.env`) y no están "hardcodeadas" en el código ni en el `docker-compose.yml`. El archivo `.env` está excluido en `.gitignore`.

---

## 🔎 Evidencia de Performance (EXPLAIN ANALYZE)

[cite_start]A continuación se demuestra la optimización de consultas mediante índices B-Tree[cite: 169].

### Caso 1: Búsqueda de Alumnos (Reporte de Riesgo)
**Consulta:** `SELECT * FROM students WHERE email = 'alex@student.edu';`
**Análisis:** Sin índice, PostgreSQL realiza un *Sequential Scan* (costoso). Con el índice `idx_students_email`, realiza un *Index Scan*.
```text
Index Scan using idx_students_email on students  (cost=0.14..8.16 rows=1 width=128)