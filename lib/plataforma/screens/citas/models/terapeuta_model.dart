import 'package:flutter/material.dart';

class Terapeuta {
  final String id;
  final String nombre;
  final String titulo;
  final String especialidad;
  final String descripcion;
  final String iniciales;
  final List<Color> gradiente;
  final double rating;
  final int sesiones;
  final List<String> enfoques;

  const Terapeuta({
    required this.id,
    required this.nombre,
    required this.titulo,
    required this.especialidad,
    required this.descripcion,
    required this.iniciales,
    required this.gradiente,
    required this.rating,
    required this.sesiones,
    required this.enfoques,
  });
}

const terapeutasData = [
  Terapeuta(
    id: 't1',
    nombre: 'Dra. María González',
    titulo: 'Psicóloga Clínica',
    especialidad: 'Ansiedad · Mindfulness',
    descripcion:
        'Especialista en terapia cognitivo-conductual y técnicas de mindfulness para el manejo de la ansiedad y el estrés crónico.',
    iniciales: 'MG',
    gradiente: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
    rating: 4.9,
    sesiones: 312,
    enfoques: ['TCC', 'Mindfulness', 'ACT'],
  ),
  Terapeuta(
    id: 't2',
    nombre: 'Dr. Carlos Mendoza',
    titulo: 'Psicólogo Clínico',
    especialidad: 'TCC · Fobias',
    descripcion:
        'Experto en terapia cognitivo-conductual para el tratamiento de fobias, TOC y trastornos de ansiedad generalizada.',
    iniciales: 'CM',
    gradiente: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    rating: 4.8,
    sesiones: 248,
    enfoques: ['TCC', 'Exposición', 'DBT'],
  ),
  Terapeuta(
    id: 't3',
    nombre: 'Dra. Laura Sánchez',
    titulo: 'Psicoterapeuta',
    especialidad: 'Regulación emocional',
    descripcion:
        'Especializada en regulación emocional, trauma y desarrollo de habilidades de afrontamiento saludables.',
    iniciales: 'LS',
    gradiente: [Color(0xFFBE185D), Color(0xFFEC4899)],
    rating: 4.9,
    sesiones: 401,
    enfoques: ['EMDR', 'DBT', 'Somatic'],
  ),
  Terapeuta(
    id: 't4',
    nombre: 'Dr. Andrés Torres',
    titulo: 'Psicólogo Clínico',
    especialidad: 'Trauma · EMDR',
    descripcion:
        'Con más de 10 años de experiencia en el tratamiento de trauma, estrés postraumático y crisis emocionales.',
    iniciales: 'AT',
    gradiente: [Color(0xFF065F46), Color(0xFF059669)],
    rating: 4.7,
    sesiones: 189,
    enfoques: ['EMDR', 'Trauma', 'TCC'],
  ),
];
