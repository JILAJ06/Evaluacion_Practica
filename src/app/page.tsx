import Link from 'next/link';

export default function DashboardHome() {
  const reports = [
    {
      id: 1,
      title: "Rendimiento Académico",
      subtitle: "Análisis por Materia",
      desc: "Tasas de aprobación y promedios generales por asignatura.",
      icon: "📊",
      color: "border-blue-800"
    },
    {
      id: 2,
      title: "Claustro Docente",
      subtitle: "Carga y Asignaciones",
      desc: "Gestión de grupos y alumnado por profesor.",
      icon: "👨‍🏫",
      color: "border-emerald-700"
    },
    {
      id: 3,
      title: "Alumnos en Riesgo",
      subtitle: "Detección Temprana",
      desc: "Identificación de reprobación y ausentismo crítico.",
      icon: "⚠️",
      color: "border-red-700"
    },
    {
      id: 4,
      title: "Control de Asistencia",
      subtitle: "Reporte de Grupos",
      desc: "Métricas de cumplimiento de asistencia por clase.",
      icon: "calendar_today",
      icon_char: "📅",
      color: "border-indigo-700"
    },
    {
      id: 5,
      title: "Cuadro de Honor",
      subtitle: "Excelencia Académica",
      desc: "Ranking de estudiantes destacados por programa.",
      icon: "🏆",
      color: "border-amber-600"
    }
  ];

  return (
    <div className="min-h-screen bg-slate-50">
      <header className="bg-slate-900 text-white py-6 shadow-md border-b-4 border-amber-500">
        <div className="max-w-7xl mx-auto px-6 flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-serif font-bold tracking-wide">SIGA</h1>
            <p className="text-slate-400 text-xs uppercase tracking-widest">Sistema Integral de Gestión Académica</p>
          </div>
          <div className="text-right hidden md:block">
            <p className="text-sm font-medium">Ciclo Escolar 2025-2026</p>
            <p className="text-xs text-slate-400">Panel Administrativo</p>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-10">
        <div className="mb-8 border-b border-slate-200 pb-4">
          <h2 className="text-2xl font-serif text-slate-800 font-bold">Resumen Ejecutivo</h2>
          <p className="text-slate-600 mt-1">Seleccione un módulo para consultar los indicadores detallados.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {reports.map((report) => (
            <Link 
              key={report.id} 
              href={`/reports/${report.id}`}
              className="group"
            >
              <div className={`bg-white rounded-lg shadow-sm hover:shadow-md transition-all duration-300 overflow-hidden border-t-4 ${report.color} h-full flex flex-col`}>
                <div className="p-6">
                  <div className="flex justify-between items-start mb-4">
                    <span className="text-4xl">{report.icon || report.icon_char}</span>
                    <span className="text-xs font-bold text-slate-400 uppercase tracking-wider bg-slate-100 px-2 py-1 rounded">
                      Módulo 0{report.id}
                    </span>
                  </div>
                  <h3 className="text-lg font-serif font-bold text-slate-800 group-hover:text-blue-900 transition-colors">
                    {report.title}
                  </h3>
                  <p className="text-sm text-blue-800 font-medium mb-2">{report.subtitle}</p>
                  <p className="text-slate-600 text-sm leading-relaxed">
                    {report.desc}
                  </p>
                </div>
                <div className="mt-auto bg-slate-50 px-6 py-3 border-t border-slate-100 flex justify-between items-center">
                  <span className="text-xs font-medium text-slate-500 group-hover:text-blue-800 uppercase">Consultar Reporte</span>
                  <span className="text-slate-400 group-hover:translate-x-1 transition-transform">&rarr;</span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </main>
    </div>
  );
}