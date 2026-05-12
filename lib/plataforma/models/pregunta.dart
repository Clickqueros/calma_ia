class Pregunta {
  final String titulo;
  final String? descripcion;
  final String emoji;
  final List<String> opciones;
  final bool multiSelect;

  const Pregunta({
    required this.titulo,
    this.descripcion,
    required this.emoji,
    required this.opciones,
    this.multiSelect = false,
  });
}

const List<Pregunta> preguntas = [
  Pregunta(
    titulo: '¿Cómo te has sentido emocionalmente esta semana?',
    descripcion: 'No hay respuesta correcta o incorrecta.',
    emoji: '💙',
    opciones: ['Muy bien', 'Bien', 'Regular', 'Mal', 'Muy mal'],
  ),
  Pregunta(
    titulo: '¿Con qué frecuencia has sentido nerviosismo, ansiedad o tensión?',
    emoji: '🌊',
    opciones: ['Nunca', 'Raramente', 'A veces', 'Con frecuencia', 'Casi siempre'],
  ),
  Pregunta(
    titulo: '¿Has tenido dificultades para dejar de preocuparte o controlar tu preocupación?',
    emoji: '💭',
    opciones: ['Nunca', 'Raramente', 'A veces', 'Con frecuencia', 'Casi siempre'],
  ),
  Pregunta(
    titulo: '¿Cómo ha sido la calidad de tu sueño últimamente?',
    emoji: '🌙',
    opciones: ['Excelente', 'Buena', 'Regular', 'Difícil', 'Muy difícil'],
  ),
  Pregunta(
    titulo: '¿Has podido disfrutar de las actividades que normalmente te gustan?',
    emoji: '✨',
    opciones: [
      'Sí, igual que siempre',
      'Casi igual que antes',
      'Un poco menos',
      'Bastante menos',
      'No he podido',
    ],
  ),
  Pregunta(
    titulo: '¿Cómo describes tu nivel de energía general?',
    emoji: '⚡',
    opciones: [
      'Lleno/a de energía',
      'Con buena energía',
      'Normal',
      'Con poca energía',
      'Sin energía',
    ],
  ),
  Pregunta(
    titulo: '¿Qué tan fácil te resulta concentrarte en tus tareas diarias?',
    emoji: '🧠',
    opciones: ['Muy fácil', 'Fácil', 'Regular', 'Difícil', 'Muy difícil'],
  ),
  Pregunta(
    titulo: '¿Qué aspectos de tu bienestar quieres trabajar?',
    descripcion: 'Puedes seleccionar todos los que quieras.',
    emoji: '🌱',
    opciones: [
      'Manejo del estrés',
      'Calidad del sueño',
      'Autoestima',
      'Relaciones interpersonales',
      'Productividad',
      'Equilibrio emocional',
      'Mindfulness',
      'Ansiedad',
    ],
    multiSelect: true,
  ),
];
