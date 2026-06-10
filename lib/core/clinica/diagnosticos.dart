// ─────────────────────────────────────────────────────────────────────────────
// Catálogo de diagnósticos (DSM-5 / CIE-10).
// Curado a partir de la Clasificación del DSM-5 entregada por el cliente.
// Cada entrada: código CIE-10 (F/G/Z...) + nombre del diagnóstico + categoría.
// Ampliable: agrega más entradas siguiendo el mismo formato.
// ─────────────────────────────────────────────────────────────────────────────

class Diagnostico {
  final String codigo; // CIE-10 (ej. F41.1)
  final String nombre;
  final String categoria;
  const Diagnostico(this.codigo, this.nombre, this.categoria);

  String get etiqueta => '$codigo · $nombre';
}

const catalogoDiagnosticos = <Diagnostico>[
  // ── Trastornos del neurodesarrollo ──────────────────────────────────────────
  Diagnostico('F70', 'Discapacidad intelectual leve', 'Neurodesarrollo'),
  Diagnostico('F71', 'Discapacidad intelectual moderada', 'Neurodesarrollo'),
  Diagnostico('F72', 'Discapacidad intelectual grave', 'Neurodesarrollo'),
  Diagnostico('F73', 'Discapacidad intelectual profunda', 'Neurodesarrollo'),
  Diagnostico('F79', 'Discapacidad intelectual no especificada', 'Neurodesarrollo'),
  Diagnostico('F80.2', 'Trastorno del lenguaje', 'Neurodesarrollo'),
  Diagnostico('F80.0', 'Trastorno fonológico', 'Neurodesarrollo'),
  Diagnostico('F80.81', 'Trastorno de fluidez de inicio en la infancia (tartamudeo)', 'Neurodesarrollo'),
  Diagnostico('F80.89', 'Trastorno de la comunicación social (pragmático)', 'Neurodesarrollo'),
  Diagnostico('F84.0', 'Trastorno del espectro autista', 'Neurodesarrollo'),
  Diagnostico('F90.2', 'TDAH, presentación combinada', 'Neurodesarrollo'),
  Diagnostico('F90.0', 'TDAH, presentación con falta de atención', 'Neurodesarrollo'),
  Diagnostico('F90.1', 'TDAH, presentación hiperactiva/impulsiva', 'Neurodesarrollo'),
  Diagnostico('F90.9', 'TDAH no especificado', 'Neurodesarrollo'),
  Diagnostico('F81.0', 'Trastorno específico del aprendizaje (lectura)', 'Neurodesarrollo'),
  Diagnostico('F81.81', 'Trastorno específico del aprendizaje (expresión escrita)', 'Neurodesarrollo'),
  Diagnostico('F81.2', 'Trastorno específico del aprendizaje (matemáticas)', 'Neurodesarrollo'),
  Diagnostico('F82', 'Trastorno del desarrollo de la coordinación', 'Neurodesarrollo'),
  Diagnostico('F98.4', 'Trastorno de movimientos estereotipados', 'Neurodesarrollo'),
  Diagnostico('F95.2', 'Trastorno de la Tourette', 'Neurodesarrollo'),
  Diagnostico('F95.1', 'Trastorno de tics motores o vocales persistente', 'Neurodesarrollo'),
  Diagnostico('F95.0', 'Trastorno de tics transitorio', 'Neurodesarrollo'),

  // ── Espectro de la esquizofrenia y trastornos psicóticos ────────────────────
  Diagnostico('F21', 'Trastorno esquizotípico (de la personalidad)', 'Psicóticos'),
  Diagnostico('F22', 'Trastorno delirante', 'Psicóticos'),
  Diagnostico('F23', 'Trastorno psicótico breve', 'Psicóticos'),
  Diagnostico('F20.81', 'Trastorno esquizofreniforme', 'Psicóticos'),
  Diagnostico('F20.9', 'Esquizofrenia', 'Psicóticos'),
  Diagnostico('F25.0', 'Trastorno esquizoafectivo, tipo bipolar', 'Psicóticos'),
  Diagnostico('F25.1', 'Trastorno esquizoafectivo, tipo depresivo', 'Psicóticos'),
  Diagnostico('F06.1', 'Catatonía debida a otra afección médica', 'Psicóticos'),
  Diagnostico('F29', 'Trastorno psicótico no especificado', 'Psicóticos'),

  // ── Trastorno bipolar y relacionados ────────────────────────────────────────
  Diagnostico('F31.11', 'Trastorno bipolar I, episodio maníaco leve', 'Bipolar'),
  Diagnostico('F31.12', 'Trastorno bipolar I, episodio maníaco moderado', 'Bipolar'),
  Diagnostico('F31.13', 'Trastorno bipolar I, episodio maníaco grave', 'Bipolar'),
  Diagnostico('F31.31', 'Trastorno bipolar I, episodio depresivo leve', 'Bipolar'),
  Diagnostico('F31.4', 'Trastorno bipolar I, episodio depresivo grave', 'Bipolar'),
  Diagnostico('F31.81', 'Trastorno bipolar II', 'Bipolar'),
  Diagnostico('F34.0', 'Trastorno ciclotímico', 'Bipolar'),
  Diagnostico('F31.9', 'Trastorno bipolar no especificado', 'Bipolar'),

  // ── Trastornos depresivos ───────────────────────────────────────────────────
  Diagnostico('F34.8', 'Trastorno de desregulación disruptiva del estado de ánimo', 'Depresivos'),
  Diagnostico('F32.0', 'Trastorno de depresión mayor, episodio único leve', 'Depresivos'),
  Diagnostico('F32.1', 'Trastorno de depresión mayor, episodio único moderado', 'Depresivos'),
  Diagnostico('F32.2', 'Trastorno de depresión mayor, episodio único grave', 'Depresivos'),
  Diagnostico('F33.0', 'Trastorno de depresión mayor, recurrente leve', 'Depresivos'),
  Diagnostico('F33.1', 'Trastorno de depresión mayor, recurrente moderado', 'Depresivos'),
  Diagnostico('F33.2', 'Trastorno de depresión mayor, recurrente grave', 'Depresivos'),
  Diagnostico('F34.1', 'Trastorno depresivo persistente (distimia)', 'Depresivos'),
  Diagnostico('N94.3', 'Trastorno disfórico premenstrual', 'Depresivos'),
  Diagnostico('F32.9', 'Trastorno depresivo no especificado', 'Depresivos'),

  // ── Trastornos de ansiedad ──────────────────────────────────────────────────
  Diagnostico('F93.0', 'Trastorno de ansiedad por separación', 'Ansiedad'),
  Diagnostico('F94.0', 'Mutismo selectivo', 'Ansiedad'),
  Diagnostico('F40.218', 'Fobia específica (animal)', 'Ansiedad'),
  Diagnostico('F40.230', 'Fobia específica (sangre-inyección-herida)', 'Ansiedad'),
  Diagnostico('F40.10', 'Trastorno de ansiedad social (fobia social)', 'Ansiedad'),
  Diagnostico('F41.0', 'Trastorno de pánico', 'Ansiedad'),
  Diagnostico('F40.00', 'Agorafobia', 'Ansiedad'),
  Diagnostico('F41.1', 'Trastorno de ansiedad generalizada', 'Ansiedad'),
  Diagnostico('F06.4', 'Trastorno de ansiedad debido a otra afección médica', 'Ansiedad'),
  Diagnostico('F41.9', 'Trastorno de ansiedad no especificado', 'Ansiedad'),

  // ── TOC y relacionados ──────────────────────────────────────────────────────
  Diagnostico('F42', 'Trastorno obsesivo-compulsivo', 'TOC'),
  Diagnostico('F45.22', 'Trastorno dismórfico corporal', 'TOC'),
  Diagnostico('F63.3', 'Tricotilomanía (arrancarse el cabello)', 'TOC'),
  Diagnostico('L98.1', 'Trastorno de excoriación (rascarse la piel)', 'TOC'),

  // ── Trauma y factores de estrés ─────────────────────────────────────────────
  Diagnostico('F94.1', 'Trastorno de apego reactivo', 'Trauma'),
  Diagnostico('F94.2', 'Trastorno de relación social desinhibido', 'Trauma'),
  Diagnostico('F43.10', 'Trastorno de estrés postraumático (TEPT)', 'Trauma'),
  Diagnostico('F43.0', 'Trastorno de estrés agudo', 'Trauma'),
  Diagnostico('F43.21', 'Trastorno de adaptación con estado de ánimo deprimido', 'Trauma'),
  Diagnostico('F43.22', 'Trastorno de adaptación con ansiedad', 'Trauma'),
  Diagnostico('F43.23', 'Trastorno de adaptación mixto (ansiedad y ánimo deprimido)', 'Trauma'),
  Diagnostico('F43.24', 'Trastorno de adaptación con alteración de la conducta', 'Trauma'),
  Diagnostico('F43.20', 'Trastorno de adaptación sin especificar', 'Trauma'),

  // ── Trastornos disociativos ─────────────────────────────────────────────────
  Diagnostico('F44.81', 'Trastorno de identidad disociativo', 'Disociativos'),
  Diagnostico('F44.0', 'Amnesia disociativa', 'Disociativos'),
  Diagnostico('F48.1', 'Trastorno de despersonalización/desrealización', 'Disociativos'),

  // ── Síntomas somáticos ──────────────────────────────────────────────────────
  Diagnostico('F45.1', 'Trastorno de síntomas somáticos', 'Somáticos'),
  Diagnostico('F45.21', 'Trastorno de ansiedad por enfermedad', 'Somáticos'),
  Diagnostico('F44.4', 'Trastorno de conversión (síntomas neurológicos funcionales)', 'Somáticos'),
  Diagnostico('F68.10', 'Trastorno facticio', 'Somáticos'),

  // ── Conducta alimentaria ────────────────────────────────────────────────────
  Diagnostico('F98.3', 'Pica (en niños)', 'Alimentaria'),
  Diagnostico('F98.21', 'Trastorno de rumiación', 'Alimentaria'),
  Diagnostico('F50.8', 'Trastorno de evitación/restricción de la ingesta', 'Alimentaria'),
  Diagnostico('F50.01', 'Anorexia nerviosa, tipo restrictivo', 'Alimentaria'),
  Diagnostico('F50.02', 'Anorexia nerviosa, tipo con atracones/purgas', 'Alimentaria'),
  Diagnostico('F50.2', 'Bulimia nerviosa', 'Alimentaria'),
  Diagnostico('F50.8', 'Trastorno de atracones', 'Alimentaria'),

  // ── Sueño-vigilia ───────────────────────────────────────────────────────────
  Diagnostico('F51.01', 'Trastorno de insomnio', 'Sueño'),
  Diagnostico('F51.11', 'Trastorno por hipersomnia', 'Sueño'),
  Diagnostico('G47.419', 'Narcolepsia', 'Sueño'),
  Diagnostico('G47.33', 'Apnea e hipopnea obstructiva del sueño', 'Sueño'),
  Diagnostico('F51.3', 'Sonambulismo (despertar del sueño no REM)', 'Sueño'),
  Diagnostico('F51.4', 'Terrores nocturnos', 'Sueño'),
  Diagnostico('F51.5', 'Trastorno de pesadillas', 'Sueño'),

  // ── Disruptivos, control de impulsos y conducta ─────────────────────────────
  Diagnostico('F91.3', 'Trastorno negativista desafiante', 'Disruptivos'),
  Diagnostico('F63.81', 'Trastorno explosivo intermitente', 'Disruptivos'),
  Diagnostico('F91.1', 'Trastorno de la conducta, inicio infantil', 'Disruptivos'),
  Diagnostico('F91.2', 'Trastorno de la conducta, inicio adolescente', 'Disruptivos'),
  Diagnostico('F63.1', 'Piromanía', 'Disruptivos'),
  Diagnostico('F63.2', 'Cleptomanía', 'Disruptivos'),

  // ── Relacionados con sustancias ─────────────────────────────────────────────
  Diagnostico('F10.20', 'Trastorno por consumo de alcohol', 'Sustancias'),
  Diagnostico('F10.10', 'Intoxicación por alcohol', 'Sustancias'),
  Diagnostico('F12.20', 'Trastorno por consumo de cannabis', 'Sustancias'),
  Diagnostico('F14.20', 'Trastorno por consumo de cocaína', 'Sustancias'),
  Diagnostico('F11.20', 'Trastorno por consumo de opiáceos', 'Sustancias'),
  Diagnostico('F13.20', 'Trastorno por consumo de sedantes/hipnóticos/ansiolíticos', 'Sustancias'),
  Diagnostico('F15.20', 'Trastorno por consumo de estimulantes', 'Sustancias'),
  Diagnostico('F17.200', 'Trastorno por consumo de tabaco', 'Sustancias'),
  Diagnostico('F63.0', 'Juego patológico (ludopatía)', 'Sustancias'),

  // ── Neurocognitivos ─────────────────────────────────────────────────────────
  Diagnostico('F05', 'Delirium', 'Neurocognitivos'),
  Diagnostico('F02.81', 'Trastorno neurocognitivo mayor con alteración del comportamiento', 'Neurocognitivos'),
  Diagnostico('F02.80', 'Trastorno neurocognitivo mayor sin alteración del comportamiento', 'Neurocognitivos'),
  Diagnostico('G31.84', 'Trastorno neurocognitivo leve', 'Neurocognitivos'),
  Diagnostico('R41.9', 'Trastorno neurocognitivo no especificado', 'Neurocognitivos'),

  // ── Trastornos de la personalidad ───────────────────────────────────────────
  Diagnostico('F60.0', 'Trastorno de la personalidad paranoide', 'Personalidad'),
  Diagnostico('F60.1', 'Trastorno de la personalidad esquizoide', 'Personalidad'),
  Diagnostico('F21', 'Trastorno de la personalidad esquizotípica', 'Personalidad'),
  Diagnostico('F60.2', 'Trastorno de la personalidad antisocial', 'Personalidad'),
  Diagnostico('F60.3', 'Trastorno de la personalidad límite', 'Personalidad'),
  Diagnostico('F60.4', 'Trastorno de la personalidad histriónica', 'Personalidad'),
  Diagnostico('F60.81', 'Trastorno de la personalidad narcisista', 'Personalidad'),
  Diagnostico('F60.6', 'Trastorno de la personalidad evitativa', 'Personalidad'),
  Diagnostico('F60.7', 'Trastorno de la personalidad dependiente', 'Personalidad'),
  Diagnostico('F60.5', 'Trastorno de la personalidad obsesivo-compulsiva', 'Personalidad'),
  Diagnostico('F60.9', 'Trastorno de la personalidad no especificado', 'Personalidad'),

  // ── Disforia de género ──────────────────────────────────────────────────────
  Diagnostico('F64.2', 'Disforia de género en niños', 'Género'),
  Diagnostico('F64.1', 'Disforia de género en adolescentes y adultos', 'Género'),

  // ── Otros / atención clínica ────────────────────────────────────────────────
  Diagnostico('Z63.0', 'Relación conflictiva con el cónyuge o la pareja', 'Otros'),
  Diagnostico('Z63.5', 'Ruptura familiar por separación o divorcio', 'Otros'),
  Diagnostico('Z63.4', 'Duelo no complicado', 'Otros'),
  Diagnostico('Z62.820', 'Problema de relación entre padres e hijos', 'Otros'),
  Diagnostico('Z56.9', 'Problema laboral', 'Otros'),
  Diagnostico('Z55.9', 'Problema académico o educativo', 'Otros'),
  Diagnostico('F99', 'Trastorno mental no especificado', 'Otros'),
];

/// Busca diagnósticos por código o nombre (sin distinguir mayúsculas/acentos).
List<Diagnostico> buscarDiagnosticos(String query) {
  final q = _normalizar(query);
  if (q.isEmpty) return catalogoDiagnosticos;
  return catalogoDiagnosticos
      .where((d) =>
          _normalizar(d.nombre).contains(q) ||
          _normalizar(d.codigo).contains(q) ||
          _normalizar(d.categoria).contains(q))
      .toList();
}

String _normalizar(String s) {
  s = s.toLowerCase();
  const acentos = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  acentos.forEach((k, v) => s = s.replaceAll(k, v));
  return s.trim();
}
