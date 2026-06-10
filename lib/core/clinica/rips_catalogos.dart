// ─────────────────────────────────────────────────────────────────────────────
// Catálogos RIPS / FEV (Colombia) para la historia clínica.
// Valores estándar usados en consulta de psicología.
// ─────────────────────────────────────────────────────────────────────────────

// Procedimientos CUPS de psicología
const procedimientosCups = <String>[
  '890208 - Consulta de primera vez por psicología',
  '890308 - Consulta de control o de seguimiento por psicología',
  '944200 - Psicoterapia individual por psicología',
  '944201 - Psicoterapia de grupo por psicología',
  '944101 - Intervención en crisis',
  '990108 - Valoración por psicología',
];

// Tipo de diagnóstico
const tiposDiagnostico = <String>[
  'Impresión diagnóstica',
  'Confirmado nuevo',
  'Confirmado repetido',
];

// Finalidad de la consulta (RIPS)
const finalidadesConsulta = <String>[
  'Atención de la enfermedad',
  'Protección específica',
  'Detección temprana de enfermedad general',
  'Detección temprana de enfermedad profesional',
  'Otra (FEV-RIPS)',
];

// Causa externa (RIPS)
const causasExternas = <String>[
  'Enfermedad general (FEV-RIPS)',
  'Enfermedad profesional',
  'Accidente de trabajo',
  'Accidente de tránsito',
  'Accidente rábico',
  'Accidente ofídico',
  'Otro tipo de accidente',
  'Otra',
];

// Demografía
const sexos = <String>['Masculino', 'Femenino', 'Intersexual', 'Otro'];

const estadosCiviles = <String>[
  'Soltero/a',
  'Casado/a',
  'Unión libre',
  'Separado/a',
  'Divorciado/a',
  'Viudo/a',
];

const tiposUsuario = <String>[
  'Contributivo',
  'Subsidiado',
  'Vinculado',
  'Particular',
  'Otro',
];
