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

    for (final enemy in enemies) {
      enemy.tickCooldown(safeDt);
    }

    player.integrate(safeDt);
    _resolveWallCollision(player);

    for (final enemy in enemies) {
      enemy.integrate(safeDt);
      _resolveWallCollision(enemy);
    }

    _resolveCollisions();
    _checkEnemyHp();
  }

  void _resolveWallCollision(Ball ball) {
    final toBall = ball.position - arenaCenter;
    final distance = toBall.length;
    final maxDistance = arenaRadius - ball.radius;

    if (distance > maxDistance) {
      final normal = toBall.normalized();
      ball.position = arenaCenter + normal * maxDistance;

      if (ball.velocity.dot(normal) > 0) {
        ball.velocity = rotateVector(ball.velocity - normal * (2 * ball.velocity.dot(normal)), (random.nextDouble() - 0.5) * angleRandomness);
        ball.maintainSpeed();
      }
    }
  }

  void _resolveCollisions() {
    final all = [player, ...enemies];
    for (int i = 0; i < all.length; i++) {
      for (int j = i + 1; j < all.length; j++) {
        final a = all[i], b = all[j];
        final delta = b.position - a.position;
        final dist = delta.length;
        final minDist = a.radius + b.radius;

        if (dist > 0 && dist < minDist) {
          final normal = delta / dist;
          final overlap = minDist - dist;
          final totalMass = a.mass + b.mass;
          a.position -= normal * overlap * (b.mass / totalMass);
          b.position += normal * overlap * (a.mass / totalMass);

          final velAlongNormal = (b.velocity - a.velocity).dot(normal);
          if (velAlongNormal <= 0) {
            final impulse = normal * (-(2.0) * velAlongNormal / ((1 / a.mass) + (1 / b.mass)));
            a.velocity -= impulse / a.mass;
            b.velocity += impulse / b.mass;
            a.maintainSpeed();
            b.maintainSpeed();
          }

          if (a.isPlayer && b is EnemyBall) _damageEnemy(b, normal);
          else if (b.isPlayer && a is EnemyBall) _damageEnemy(a, -normal);
        }
      }
    }
  }

  void _damageEnemy(EnemyBall enemy, Vector2 dir) {
    if (!enemy.canTakeDamage) return;
    enemy.takeDamage();
    if (enemy.isDead) return;
    enemy.position += dir * enemyKnockbackDistance;
    enemy.velocity = dir * enemy.fixedSpeed;
    _resolveWallCollision(enemy);
  }

  void _checkEnemyHp() {
    enemies.removeWhere((e) {
      if (e.isDead) {
        e.removeFromParent();
        _spawnEnemy();
        return true;
      }
      return false;
    });
  }
}
