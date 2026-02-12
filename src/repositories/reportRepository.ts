import pool from '@/lib/db';
import type {
  AttendanceStat,
  CourseStat,
  RankStat,
  StudentRisk,
  TeacherLoad,
} from '@/types/reportTypes';

export async function getCoursePerformance(term: string): Promise<CourseStat[]> {
  const query = `
    SELECT * FROM vw_course_performance
    WHERE term = $1
    ORDER BY failure_rate DESC
  `;
  const result = await pool.query(query, [term]);
  return result.rows as CourseStat[];
}

export async function getTeacherLoad(page: number = 1): Promise<TeacherLoad[]> {
  const limit = 5;
  const offset = (page - 1) * limit;
  const query = `
  SELECT * FROM vw_teacher_load 
  ORDER BY total_students_taught DESC
  LIMIT $1 OFFSET $2
`;
  
  const result = await pool.query(query, [limit, offset]);
  return result.rows as TeacherLoad[];
}

export async function getTeacherLoadCount(): Promise<number> {
  const result = await pool.query('SELECT COUNT(*) FROM vw_teacher_load');
  return Number(result.rows[0].count);
}

export async function getStudentsAtRisk(search: string, limit: number, offset: number): Promise<StudentRisk[]> {
  const query = `
    SELECT * FROM vw_students_at_risk
    WHERE name ILIKE $1 OR email ILIKE $1
    ORDER BY CASE WHEN risk_status LIKE 'CRITICAL%' THEN 1 ELSE 2 END, current_average ASC
    LIMIT $2 OFFSET $3
  `;
  const result = await pool.query(query, [`%${search}%`, limit, offset]);
  return result.rows as StudentRisk[];
}

export async function getStudentsAtRiskCount(search: string): Promise<number> {
  const query = `
    SELECT COUNT(*) FROM vw_students_at_risk
    WHERE name ILIKE $1 OR email ILIKE $1
  `;
  const result = await pool.query(query, [`%${search}%`]);
  return Number(result.rows[0].count);
}

export async function getAttendanceByGroup(): Promise<AttendanceStat[]> {
  const query = 'SELECT * FROM vw_attendance_by_group ORDER BY attendance_percentage ASC';
  const result = await pool.query(query);
  return result.rows as AttendanceStat[];
}

export async function getRankStudents(program?: string): Promise<RankStat[]> {
  let query = 'SELECT * FROM vw_rank_students';
  const params: string[] = [];

  if (program) {
    query += ' WHERE program = $1';
    params.push(program);
  }

  query += ' ORDER BY program, rank_position ASC';
  const result = await pool.query(query, params);
  return result.rows as RankStat[];
}
