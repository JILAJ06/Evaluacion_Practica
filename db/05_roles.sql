DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'dashboard_user') THEN
      CREATE ROLE dashboard_user WITH LOGIN PASSWORD 'secure_password_123';
   END IF;
END
$do$;

GRANT CONNECT ON DATABASE postgres TO dashboard_user;
GRANT USAGE ON SCHEMA public TO dashboard_user;

REVOKE ALL ON students FROM dashboard_user;
REVOKE ALL ON teachers FROM dashboard_user;
REVOKE ALL ON courses FROM dashboard_user;
REVOKE ALL ON groups FROM dashboard_user;
REVOKE ALL ON enrollments FROM dashboard_user;
REVOKE ALL ON grades FROM dashboard_user;
REVOKE ALL ON attendance FROM dashboard_user;

GRANT SELECT ON vw_course_performance TO dashboard_user;
GRANT SELECT ON vw_teacher_load TO dashboard_user;
GRANT SELECT ON vw_students_at_risk TO dashboard_user;
GRANT SELECT ON vw_attendance_by_group TO dashboard_user;
GRANT SELECT ON vw_rank_students TO dashboard_user;
