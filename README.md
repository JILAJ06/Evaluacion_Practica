## 📖 ¿De qué trata este proyecto?

**SIGA** es una plataforma web diseñada para modernizar la forma en que una escuela toma decisiones.

Imagina que eres el Coordinador Académico. En lugar de revisar cientos de listas en Excel para saber qué pasa en la escuela, este sistema te ofrece un **Tablero de Control (Dashboard)** visual e inteligente.

El objetivo es resolver problemas reales:
1.  **Detectar Alumnos en Riesgo:** El sistema cruza datos de calificaciones y faltas para avisarte automáticamente quién podría reprobar.
2.  **Evaluar el Rendimiento:** Muestra qué materias son las más difíciles y cuál es el promedio general.
3.  **Monitoreo Docente:** Permite ver la carga de trabajo de los profesores y cómo evalúan a sus grupos.
4.  **Reconocer la Excelencia:** Genera automáticamente el "Cuadro de Honor" con los mejores promedios por carrera.

Es tecnología aplicada para mejorar la educación, pasando de "datos sueltos" a "información útil".

---

## ✅ Cumplimiento de Requisitos (Para Evaluación)

Aunque el sistema es fácil de usar, por dentro cumple estrictamente con todos los requisitos técnicos avanzados solicitados en la práctica:

| Requisito Técnico | ¿Dónde está aplicado? | Explicación sencilla |
| :--- | :--- | :--- |
| **Window Functions** | `db/03_reports_vw.sql` (Vista 5) | Se usó para crear el **Ranking** (1°, 2°, 3° lugar) reiniciando la cuenta por cada carrera. |
| **CTE (Tablas Temporales)** | `db/03_reports_vw.sql` (Vista 3) | Permite calcular asistencias y promedios en memoria antes de filtrar a los alumnos en riesgo. |
| **HAVING (Filtros Avanzados)** | `db/03_reports_vw.sql` (Vistas 1 y 2) | Sirve para ignorar grupos vacíos o maestros sin alumnos al calcular promedios. |
| **Manejo de Nulos (COALESCE)** | `db/03_reports_vw.sql` (Vista 4) | Evita errores matemáticos si un grupo no tiene asistencias registradas (pone 0 en vez de error). |
| **Lógica Condicional (CASE)** | `db/03_reports_vw.sql` (Vista 1) | Clasifica automáticamente si un alumno está "Aprobado" o "Reprobado" según su nota. |
| **Seguridad (Roles)** | `db/05_roles.sql` | La aplicación usa un usuario restringido que **solo puede leer reportes**, protegiendo los datos originales. |

---

## 🛠️ Tecnologías que lo hacen funcionar

* **La Cara del Proyecto (Frontend):** Next.js 16 (lo más nuevo en React) con diseño adaptable a celulares (Tailwind CSS).
* **El Cerebro (Base de Datos):** PostgreSQL 18.
* **El Motor (Infraestructura):** Docker Compose (para que funcione en cualquier computadora con un solo clic).

---

## 🚀 Guía de Instalación (Paso a Paso)

Este proyecto usa **Docker**, lo que garantiza que funcionará en tu máquina sin instalar nada extra.

### Paso 1: Configurar la Seguridad
Las contraseñas no deben viajar en el código.
1.  Busca el archivo llamado `.env.example` en la carpeta principal.
2.  Haz una copia de ese archivo y cámbiale el nombre a `.env`.
    * *(En Windows: Copiar y Pegar -> Renombrar a `.env`)*.
3.  Listo, el sistema ya tiene las credenciales seguras configuradas.

### Paso 2: Arrancar el Sistema
Abre una terminal en la carpeta del proyecto y escribe:

```bash
docker compose up --build
```
Si deseas borrar todo y volver a cargar los datos de prueba originales, ejecuta 
```bash
docker compose down -v 
```
y vuelve a construir.