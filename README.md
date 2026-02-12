# SIGA - Sistema Integral de Gestión Académica (Arquitectura SOA)

**Asignatura:** Aplicaciones Web Orientadas a Servicios (AWOS) & Base de Datos Avanzadas
**Arquitectura:** SOA (Service-Oriented Architecture) con Next.js + PostgreSQL + Docker
**Alumno:** Alexander Jesús Jiménez León

---

## 🏗️ Arquitectura del Sistema (SOA)

Este proyecto ha sido diseñado siguiendo estrictamente una **Arquitectura Orientada a Servicios (SOA)** para garantizar el desacoplamiento entre la interfaz de usuario y la lógica de datos.

### Diagrama de Capas
1.  **Capa de Presentación (Frontend):** * Componentes de Next.js (`src/app/reports/*`).
    * Responsabilidad: Renderizado y experiencia de usuario. **Nunca** accede a la base de datos directamente.
2.  **Capa de Servicio/Repositorio (Backend Logic):**
    * Repositorios (`src/repositories/*`).
    * Responsabilidad: Abstracción de datos. Actúa como intermediario que consulta las Vistas SQL y entrega objetos tipados (Interfaces TypeScript).
3.  **Capa de Datos (Database):**
    * PostgreSQL 18.
    * Responsabilidad: Lógica de negocio pesada encapsulada en **Vistas Materializadas Lógicamente**.

---

## ⚖️ Trade-offs: Decisiones de Diseño

### 1. SQL Views vs. Lógica en Código (Node.js)
**Decisión:** Se delegó el cálculo de promedios, rankings y detección de riesgo a **Vistas SQL**.
* **Justificación:** PostgreSQL está optimizado para agregaciones matemáticas (`AVG`, `COUNT`, `RANK`). Hacer esto en JavaScript implicaría traer miles de registros a la memoria del servidor para iterarlos, lo cual es ineficiente (O(n)) comparado con la optimización de base de datos.

### 2. Implementación del Patrón Repository
**Decisión:** Se creó una capa `src/repositories` en lugar de hacer queries en los componentes.
* **Justificación:** Cumple con el principio de **Responsabilidad Única**. Si la base de datos cambia, solo se modifica el repositorio, no la interfaz gráfica. Facilita la creación futura de una API REST pública.

---

## 🛡️ Threat Model (Modelo de Amenazas)

Siguiendo las mejores prácticas de seguridad, se implementaron las siguientes defensas:

1.  **Inyección SQL:**
    * **Mitigación:** Uso estricto de **consultas parametrizadas** (`$1`, `$2`) en los repositorios. Los inputs del usuario (filtros de búsqueda) nunca se concatenan directamente.
2.  **Exposición de Credenciales:**
    * **Mitigación:** Las credenciales NO están en el código. Se inyectan vía variables de entorno (`.env`) que son ignoradas por git.
3.  **Acceso Privilegiado:**
    * **Mitigación:** La aplicación se conecta con el rol `dashboard_user` (creado en `db/05_roles.sql`), el cual tiene permisos **REVOCADOS** para escribir/borrar tablas y solo tiene `GRANT SELECT` sobre las 5 vistas específicas.

---

## 🔎 Evidencia de Performance (EXPLAIN ANALYZE)

Se crearon índices B-Tree (`db/04_indexes.sql`) para optimizar las consultas más pesadas.

### Caso 1: Dashboard de Riesgo (Búsqueda por Texto)
**Consulta:** Filtrar alumnos por email en la vista de riesgo.
**Resultado:** El índice `idx_students_email` reduce la complejidad de la búsqueda de lineal a logarítmica.
```text
Index Scan using idx_students_email on students (cost=0.14..8.16 rows=1 width=128)