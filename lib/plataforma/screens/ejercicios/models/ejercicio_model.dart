import 'package:flutter/material.dart';

class VideoEjercicio {
  final String id;
  final String titulo;
  final String duracion;
  final String descripcion;
  final String youtubeId;

  const VideoEjercicio({
    required this.id,
    required this.titulo,
    required this.duracion,
    required this.descripcion,
    this.youtubeId = 'i4dwATyTcCk',
  });
}

class Modulo {
  final String id;
  final String titulo;
  final String descripcion;
  final String etiqueta;
  final IconData icono;
  final List<Color> gradiente;
  final Color bgSuave;
  final List<VideoEjercicio> videos;
  final double progreso;

  const Modulo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.etiqueta,
    required this.icono,
    required this.gradiente,
    required this.bgSuave,
    required this.videos,
    this.progreso = 0.0,
  });

  int get videosCompletados => (progreso * videos.length).round();
}

// ── Data ────────────────────────────────────────────────────────────────────

const modulosData = [
  Modulo(
    id: 'mindfulness',
    titulo: 'Mindfulness',
    descripcion: 'Aprende a vivir el presente con plena conciencia y atención.',
    etiqueta: 'Atención plena',
    icono: Icons.self_improvement,
    gradiente: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
    bgSuave: Color(0xFFF5F3FF),
    progreso: 0.4,
    videos: [
      VideoEjercicio(
        id: 'mf1',
        titulo: '¿Qué es el Mindfulness?',
        duracion: '8:30',
        descripcion: 'Introducción al concepto de mindfulness y cómo puede transformar tu relación con el presente.',
      ),
      VideoEjercicio(
        id: 'mf2',
        titulo: 'Técnicas de Atención Plena',
        duracion: '12:45',
        descripcion: 'Aprende las técnicas fundamentales para cultivar la atención plena en tu vida diaria.',
      ),
      VideoEjercicio(
        id: 'mf3',
        titulo: 'Regulación Emocional',
        duracion: '10:20',
        descripcion: 'Cómo usar el mindfulness para regular tus emociones de forma efectiva y compasiva.',
      ),
      VideoEjercicio(
        id: 'mf4',
        titulo: 'Presencia y Conciencia Corporal',
        duracion: '9:15',
        descripcion: 'Conecta con tu cuerpo y desarrolla una mayor conciencia de las sensaciones físicas.',
      ),
      VideoEjercicio(
        id: 'mf5',
        titulo: 'Práctica Diaria de Mindfulness',
        duracion: '15:00',
        descripcion: 'Cómo integrar el mindfulness en tu rutina diaria para resultados duraderos.',
      ),
    ],
  ),

  Modulo(
    id: 'respiracion',
    titulo: 'Ejercicios de Respiración',
    descripcion: 'Regula tu sistema nervioso a través de técnicas de respiración consciente.',
    etiqueta: 'Respiración',
    icono: Icons.air_rounded,
    gradiente: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    bgSuave: Color(0xFFF0FEFF),
    progreso: 0.2,
    videos: [
      VideoEjercicio(
        id: 'resp1',
        titulo: 'Respiración 4-7-8',
        duracion: '6:30',
        descripcion: 'La técnica de respiración más efectiva para calmar el sistema nervioso en minutos.',
      ),
      VideoEjercicio(
        id: 'resp2',
        titulo: 'Respiración Diafragmática',
        duracion: '8:15',
        descripcion: 'Aprende a respirar desde el diafragma para una relajación profunda y duradera.',
      ),
      VideoEjercicio(
        id: 'resp3',
        titulo: 'Relajación por Respiración',
        duracion: '10:00',
        descripcion: 'Sesión guiada de relajación profunda usando técnicas de respiración consciente.',
      ),
      VideoEjercicio(
        id: 'resp4',
        titulo: 'Regulación del Sistema Nervioso',
        duracion: '11:30',
        descripcion: 'Cómo la respiración activa el sistema parasimpático y reduce el estrés crónico.',
      ),
      VideoEjercicio(
        id: 'resp5',
        titulo: 'Técnicas Avanzadas de Respiración',
        duracion: '14:20',
        descripcion: 'Técnicas de respiración avanzadas para meditadores con experiencia previa.',
      ),
    ],
  ),

  Modulo(
    id: 'sentir',
    titulo: 'Sentir y Enfrentar',
    descripcion: 'Aprende a tolerar y enfrentar las sensaciones difíciles sin evitarlas.',
    etiqueta: 'Exposición',
    icono: Icons.favorite_rounded,
    gradiente: [Color(0xFFBE185D), Color(0xFFEC4899)],
    bgSuave: Color(0xFFFFF1F2),
    progreso: 0.0,
    videos: [
      VideoEjercicio(
        id: 'sent1',
        titulo: 'Entendiendo la Evitación Emocional',
        duracion: '9:45',
        descripcion: 'Por qué evitar las sensaciones amplifica la ansiedad y cómo romper ese ciclo.',
      ),
      VideoEjercicio(
        id: 'sent2',
        titulo: 'Exposición Gradual a Sensaciones',
        duracion: '12:00',
        descripcion: 'Un enfoque paso a paso para exponerte gradualmente a las sensaciones que temes.',
      ),
      VideoEjercicio(
        id: 'sent3',
        titulo: 'Tolerando Síntomas Físicos',
        duracion: '11:15',
        descripcion: 'Técnicas para permanecer presente cuando el cuerpo siente malestar físico.',
      ),
      VideoEjercicio(
        id: 'sent4',
        titulo: 'Reduciendo el Miedo a las Sensaciones',
        duracion: '13:30',
        descripcion: 'Cómo cambiar tu relación con las sensaciones físicas para reducir el miedo.',
      ),
      VideoEjercicio(
        id: 'sent5',
        titulo: 'Práctica de Exposición Emocional',
        duracion: '16:00',
        descripcion: 'Sesión práctica guiada de exposición emocional con técnicas de aceptación.',
      ),
    ],
  ),

  Modulo(
    id: 'regulacion',
    titulo: 'Regulación Emocional',
    descripcion: 'Herramientas prácticas para gestionar emociones intensas con calma.',
    etiqueta: 'Regulación',
    icono: Icons.balance_rounded,
    gradiente: [Color(0xFF065F46), Color(0xFF059669)],
    bgSuave: Color(0xFFF0FDF4),
    progreso: 0.6,
    videos: [
      VideoEjercicio(
        id: 'reg1',
        titulo: 'Técnicas de Calma Inmediata',
        duracion: '7:30',
        descripcion: 'Herramientas de emergencia para calmarte cuando la ansiedad es muy intensa.',
      ),
      VideoEjercicio(
        id: 'reg2',
        titulo: 'Grounding: Ancla al Presente',
        duracion: '9:00',
        descripcion: 'Técnicas de anclaje para salir del modo de alarma y volver al momento presente.',
      ),
      VideoEjercicio(
        id: 'reg3',
        titulo: 'Relajación Muscular Progresiva',
        duracion: '14:00',
        descripcion: 'Técnica de relajación corporal que reduce la tensión acumulada en el cuerpo.',
      ),
      VideoEjercicio(
        id: 'reg4',
        titulo: 'Manejo del Sobrepensamiento',
        duracion: '11:45',
        descripcion: 'Estrategias cognitivas para salir de los bucles de pensamiento rumiativos.',
      ),
      VideoEjercicio(
        id: 'reg5',
        titulo: 'Estrategias de Regulación Diaria',
        duracion: '13:15',
        descripcion: 'Cómo construir una rutina diaria de regulación emocional sostenible.',
      ),
    ],
  ),

  Modulo(
    id: 'ansiedad',
    titulo: 'Entendiendo la Ansiedad',
    descripcion: 'Comprende cómo funciona la ansiedad para dejar de temerle.',
    etiqueta: 'Educación',
    icono: Icons.lightbulb_rounded,
    gradiente: [Color(0xFFB45309), Color(0xFFD97706)],
    bgSuave: Color(0xFFFFFBEB),
    progreso: 0.8,
    videos: [
      VideoEjercicio(
        id: 'ans1',
        titulo: '¿Qué es la Ansiedad?',
        duracion: '8:00',
        descripcion: 'Una explicación clara y sin alarmas de qué es la ansiedad y por qué existe.',
      ),
      VideoEjercicio(
        id: 'ans2',
        titulo: 'Cómo Funciona el Sistema Nervioso',
        duracion: '10:30',
        descripcion: 'Entiende el sistema nervioso autónomo y su rol en la respuesta de ansiedad.',
      ),
      VideoEjercicio(
        id: 'ans3',
        titulo: 'La Respuesta de Alarma',
        duracion: '9:45',
        descripcion: 'Por qué el cerebro activa la alarma y cómo esta respuesta te protege.',
      ),
      VideoEjercicio(
        id: 'ans4',
        titulo: 'Interpretando Síntomas de Ansiedad',
        duracion: '12:15',
        descripcion: 'Aprende a leer tus síntomas físicos como señales del cuerpo, no como peligro.',
      ),
      VideoEjercicio(
        id: 'ans5',
        titulo: 'Ansiedad vs. Peligro Real',
        duracion: '11:00',
        descripcion: 'Cómo distinguir entre una amenaza real y una respuesta de ansiedad falsa.',
      ),
    ],
  ),
];
