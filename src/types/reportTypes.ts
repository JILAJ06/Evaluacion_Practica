export interface CourseStat {
  course_code: number;
  course_name: string;
  term: string;
  total_students: string;
  average_grade: string;
  failed_students: string;
  failure_rate: string;
}

export interface TeacherLoad {
  teacher_id: number;
  teacher_name: string;
  term: string;
  assigned_groups: string;
  total_students_taught: string;
  avg_grading_strictness: string;
}

export interface StudentRisk {
  student_id: number;
  name: string;
  email: string;
  program: string;
  current_average: string;
  total_absences: string;
  risk_status: string;
}

export interface AttendanceStat {
  group_id: number;
  course_name: string;
  teacher_name: string;
  term: string;
  total_classes_recorded: string;
  attendance_percentage: string;
}

export interface RankStat {
  student_id: number;
  name: string;
  program: string;
  final_average: string;
  rank_position: number;
}
