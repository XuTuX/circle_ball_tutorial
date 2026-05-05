import 'package:flutter/material.dart';

enum AugmentType {
  speed,
  radius,
  mass,
  multiBall,
  scoreMultiplier,
  timeOnKill,
}

class Augment {
  final String title;
  final String description;
  final AugmentType type;
  final double value;
  final IconData icon;

  Augment({
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.icon,
  });

  static List<Augment> get allPool => [
    Augment(
      title: 'Engine Boost',
      description: 'Player Speed +120',
      type: AugmentType.speed,
      value: 120,
      icon: Icons.speed,
    ),
    Augment(
      title: 'Giant Shell',
      description: 'Ball Radius +5',
      type: AugmentType.radius,
      value: 5,
      icon: Icons.circle_outlined,
    ),
    Augment(
      title: 'Heavy Frame',
      description: 'Mass +0.8 (Knockback Up)',
      type: AugmentType.mass,
      value: 0.8,
      icon: Icons.fitness_center,
    ),
    Augment(
      title: 'Multi-Ball',
      description: 'Add +1 Player Ball',
      type: AugmentType.multiBall,
      value: 1,
      icon: Icons.control_point_duplicate,
    ),
    Augment(
      title: 'Golden Touch',
      description: 'Score Multiplier x1.5',
      type: AugmentType.scoreMultiplier,
      value: 1.5,
      icon: Icons.stars,
    ),
    Augment(
      title: 'Time Siphon',
      description: 'Time gain on kill +0.7s',
      type: AugmentType.timeOnKill,
      value: 0.7,
      icon: Icons.timer,
    ),
  ];
}
