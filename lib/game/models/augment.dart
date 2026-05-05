import 'package:flutter/material.dart';

enum AugmentType { speed, radius, mass, multiBall, scoreMultiplier, timeOnKill }

class Augment {
  final String title;
  final String description;
  final AugmentType type;
  final double value;
  final IconData icon;

  const Augment({
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.icon,
  });

  static List<Augment> get allPool => [
    const Augment(
      title: '엔진 부스트',
      description: '플레이어 속도 +120',
      type: AugmentType.speed,
      value: 120,
      icon: Icons.speed,
    ),
    const Augment(
      title: '거대 껍질',
      description: '공 반지름 +5',
      type: AugmentType.radius,
      value: 5,
      icon: Icons.circle_outlined,
    ),
    const Augment(
      title: '무거운 프레임',
      description: '질량 +0.8 (넉백 증가)',
      type: AugmentType.mass,
      value: 0.8,
      icon: Icons.fitness_center,
    ),
    const Augment(
      title: '멀티볼',
      description: '플레이어 공 +1 추가',
      type: AugmentType.multiBall,
      value: 1,
      icon: Icons.control_point_duplicate,
    ),
    const Augment(
      title: '황금 손길',
      description: '점수 배율 x1.5',
      type: AugmentType.scoreMultiplier,
      value: 1.5,
      icon: Icons.stars,
    ),
    const Augment(
      title: '시간 흡수',
      description: '처치 시 시간 +0.7초',
      type: AugmentType.timeOnKill,
      value: 0.7,
      icon: Icons.timer,
    ),
  ];

  /// 증강 아이콘 배경색
  Color get color {
    switch (type) {
      case AugmentType.speed:
        return const Color(0xFF4FC3F7); // 밝은 파랑
      case AugmentType.radius:
        return const Color(0xFF81C784); // 밝은 초록
      case AugmentType.mass:
        return const Color(0xFFFF8A65); // 주황
      case AugmentType.multiBall:
        return const Color(0xFFBA68C8); // 보라
      case AugmentType.scoreMultiplier:
        return const Color(0xFFFFD54F); // 노랑
      case AugmentType.timeOnKill:
        return const Color(0xFF4DB6AC); // 청록
    }
  }
}

/// 시너지 정보
class SynergyInfo {
  final String name;
  final String description;
  final String condition;

  const SynergyInfo({
    required this.name,
    required this.description,
    required this.condition,
  });

  static const List<SynergyInfo> all = [
    SynergyInfo(
      name: '잔상',
      description: '속도가 매우 빠를 때 공이 잔상을 남깁니다',
      condition: '속도 보너스 200 이상 + 멀티볼',
    ),
    SynergyInfo(
      name: '행성 중력',
      description: '적들이 가장 가까운 플레이어 공 쪽으로 끌려옵니다',
      condition: '반지름 보너스 10 이상 + 질량 보너스 1.0 이상',
    ),
  ];
}
