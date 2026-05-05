import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/arena.dart';
import 'components/ball.dart';
import 'components/enemy_ball.dart';
import 'utils/vector_utils.dart';

class FastBallGame extends FlameGame {
  late Vector2 arenaCenter;
  late double arenaRadius;

  late Ball player;

  final Random random = Random();

  final double playerSpeed = 450;
  final double enemySpeed = 180;
  final double angleRandomness = 0.25;

  final double enemyHitCooldownDuration = 0.35;
  final double enemyKnockbackDistance = 18;

  final List<EnemyBall> enemies = [];
  final int enemyCount = 10;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    arenaCenter = size / 2;
    arenaRadius = min(size.x, size.y) * 0.42;

    add(ArenaComponent(center: arenaCenter, radius: arenaRadius));

    _spawnPlayer();

    for (int i = 0; i < enemyCount; i++) {
      _spawnEnemy();
    }
  }

  void _spawnPlayer() {
    final angle = random.nextDouble() * pi * 2;

    player = Ball(
      position: arenaCenter,
      radius: 16,
      velocity: Vector2(cos(angle), sin(angle)) * playerSpeed,
      color: Colors.orange,
      fixedSpeed: playerSpeed,
      isPlayer: true,
    );

    add(player);
  }

  void _spawnEnemy() {
    const enemyRadius = 8.0;

    Vector2 position;

    do {
      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * (arenaRadius - enemyRadius - 10);
      position = arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
    } while ((position - player.position).length < player.radius + 60);

    final angle = random.nextDouble() * pi * 2;

    final enemy = EnemyBall(
      position: position,
      radius: enemyRadius,
      velocity: Vector2(cos(angle), sin(angle)) * enemySpeed,
      fixedSpeed: enemySpeed,
      hitCooldownDuration: enemyHitCooldownDuration,
    );

    enemies.add(enemy);
    add(enemy);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final safeDt = dt.clamp(0.0, 1 / 60);

    final allBalls = <Ball>[player, ...enemies];

    for (final enemy in enemies) {
      enemy.tickCooldown(safeDt);
    }

    for (final ball in allBalls) {
      ball.integrate(safeDt);
      _resolveWallCollision(ball);
    }

    _resolveBallCollisions(allBalls);
    _checkEnemyHp();
  }

  void _resolveWallCollision(Ball ball) {
    final toBall = ball.position - arenaCenter;
    final distance = toBall.length;

    final maxDistance = arenaRadius - ball.radius;

    if (distance > maxDistance) {
      final normal = toBall.normalized();

      // 원 밖으로 나간 공을 다시 원 안쪽 경계로 보정
      ball.position = arenaCenter + normal * maxDistance;

      final dot = ball.velocity.dot(normal);

      // 바깥쪽으로 향하고 있을 때만 반사
      if (dot > 0) {
        ball.velocity = ball.velocity - normal * (2 * dot);

        // 너무 같은 경로만 반복하지 않도록 약간의 랜덤 각도 부여
        final randomAngle = (random.nextDouble() - 0.5) * angleRandomness;
        ball.velocity = rotateVector(ball.velocity, randomAngle);

        ball.maintainSpeed();
      }
    }
  }

  void _resolveBallCollisions(List<Ball> balls) {
    for (int i = 0; i < balls.length; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        final a = balls[i];
        final b = balls[j];

        final delta = b.position - a.position;
        final distance = delta.length;
        final minDistance = a.radius + b.radius;

        if (distance == 0 || distance >= minDistance) continue;

        final normal = delta / distance;
        final overlap = minDistance - distance;

        // 겹쳐진 공을 질량 비율에 따라 분리
        final totalMass = a.mass + b.mass;
        a.position -= normal * overlap * (b.mass / totalMass);
        b.position += normal * overlap * (a.mass / totalMass);

        final relativeVelocity = b.velocity - a.velocity;
        final velocityAlongNormal = relativeVelocity.dot(normal);

        // 이미 서로 멀어지고 있으면 충돌 반응은 생략
        if (velocityAlongNormal <= 0) {
          const restitution = 1.0;

          final impulseMagnitude =
              -(1 + restitution) *
              velocityAlongNormal /
              ((1 / a.mass) + (1 / b.mass));

          final impulse = normal * impulseMagnitude;

          a.velocity -= impulse / a.mass;
          b.velocity += impulse / b.mass;

          a.maintainSpeed();
          b.maintainSpeed();
        }

        _handlePlayerEnemyHit(a, b, normal);
      }
    }
  }

  void _handlePlayerEnemyHit(Ball a, Ball b, Vector2 normal) {
    if (a.isPlayer && b is EnemyBall) {
      _damageEnemy(enemy: b, directionFromPlayerToEnemy: normal);
    } else if (b.isPlayer && a is EnemyBall) {
      _damageEnemy(enemy: a, directionFromPlayerToEnemy: -normal);
    }
  }

  void _damageEnemy({
    required EnemyBall enemy,
    required Vector2 directionFromPlayerToEnemy,
  }) {
    if (!enemy.canTakeDamage) return;

    enemy.takeDamage();

    // hp가 0이 되면 넉백 없이 바로 삭제 대상으로 둠
    if (enemy.isDead) {
      return;
    }

    // 살아있는 적만 넉백
    enemy.position += directionFromPlayerToEnemy * enemyKnockbackDistance;
    enemy.velocity = directionFromPlayerToEnemy * enemy.fixedSpeed;

    _resolveWallCollision(enemy);
  }

  void _checkEnemyHp() {
    final deadEnemies = enemies.where((enemy) => enemy.isDead).toList();

    for (final enemy in deadEnemies) {
      enemies.remove(enemy);
      enemy.removeFromParent();

      _spawnEnemy();
    }
  }
}
