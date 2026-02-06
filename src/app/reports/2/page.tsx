import pool from '@/lib/db';
import Link from 'next/link';

interface TeacherLoad {
  teacher_id: number;
  teacher_name: string;
  term: string;
  assigned_groups: string;
  total_students_attended: string;
  avg_grading_strictness: string;
}

async function getData(page: number, limit: number) {
  const offset = (page - 1) * limit;
  const query = `SELECT * FROM vw_teacher_load ORDER BY total_students_attended DESC LIMIT $1 OFFSET $2`;
  const result = await pool.query(query, [limit, offset]);
  return result.rows as TeacherLoad[];
}

async function getTotalCount() {
  const result = await pool.query('SELECT COUNT(*) FROM vw_teacher_load');
  return Number(result.rows[0].count);
}

type Props = { searchParams: Promise<{ [key: string]: string | string[] | undefined }> }

export default async function Report2Page(props: Props) {
  const searchParams = await props.searchParams;
  const page = Number(searchParams.page) || 1;
  const LIMIT = 5;
  const data = await getData(page, LIMIT);
  const totalItems = await getTotalCount();
  const hasNextPage = (page * LIMIT) < totalItems;

  return (
    <div className="min-h-screen bg-slate-50">
      <nav className="bg-white border-b border-slate-200 px-8 py-4 shadow-sm">
        <div className="max-w-6xl mx-auto flex items-center text-sm">
          <Link href="/" className="text-slate-500 hover:text-blue-900 font-medium">Inicio</Link>
          <span className="mx-2 text-slate-300">/</span>
          <span className="text-blue-900 font-bold">Claustro Docente</span>
        </div>
      </nav>

      <main className="max-w-6xl mx-auto px-8 py-10">
        <div className="flex justify-between items-end mb-6">
          <div>
            <h1 className="text-3xl font-serif font-bold text-slate-900">Carga Académica</h1>
            <p className="text-slate-600 mt-1">Listado oficial de asignaciones y métricas docentes.</p>
          </div>
          <div className="bg-slate-200 text-slate-700 px-3 py-1 rounded text-xs font-mono font-bold">
            PÁGINA {page}
          </div>
        </div>

        <div className="grid gap-4">
          {data.map((row) => (
            <div key={row.teacher_id} className="bg-white border border-slate-200 p-6 rounded-sm shadow-sm flex flex-col md:flex-row items-center justify-between hover:border-blue-400 transition-colors">
              <div className="flex items-center gap-4 mb-4 md:mb-0">
                <div className="w-12 h-12 bg-slate-100 rounded-full flex items-center justify-center text-2xl border border-slate-300">
                  🎓
                </div>
                <div>
                  <h3 className="font-serif font-bold text-lg text-slate-900">{row.teacher_name}</h3>
                  <p className="text-sm text-slate-500">Periodo Activo: <span className="font-mono text-slate-700">{row.term}</span></p>
                </div>
              </div>
              
              <div className="flex gap-8 text-center">
                <div>
                  <p className="text-xs text-slate-400 uppercase tracking-wider font-bold">Grupos</p>
                  <p className="text-xl font-serif font-bold text-slate-800">{row.assigned_groups}</p>
                </div>
                <div className="border-l border-slate-100 pl-8">
                  <p className="text-xs text-slate-400 uppercase tracking-wider font-bold">Alumnos</p>
                  <p className="text-xl font-serif font-bold text-blue-900">{row.total_students_attended}</p>
                </div>
                <div className="border-l border-slate-100 pl-8">
                  <p className="text-xs text-slate-400 uppercase tracking-wider font-bold">Promedio Clase</p>
                  <p className="text-xl font-mono font-bold text-slate-600">{Number(row.avg_grading_strictness).toFixed(1)}</p>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-8 flex justify-center gap-4">
            <Link href={`/reports/2?page=${page - 1}`} className={`px-6 py-2 border border-slate-300 bg-white text-slate-700 font-medium text-sm rounded-sm hover:bg-slate-50 ${page <= 1 ? 'opacity-50 pointer-events-none' : ''}`}>&larr; Anterior</Link>
            <Link href={`/reports/2?page=${page + 1}`} className={`px-6 py-2 border border-slate-300 bg-white text-slate-700 font-medium text-sm rounded-sm hover:bg-slate-50 ${!hasNextPage ? 'opacity-50 pointer-events-none' : ''}`}>Siguiente &rarr;</Link>
        </div>
      </main>
    </div>
  );
}