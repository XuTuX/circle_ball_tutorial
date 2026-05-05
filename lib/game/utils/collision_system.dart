import 'dart:math';
import 'package:flame/extensions.dart';
import '../components/ball.dart';
import '../components/enemy_ball.dart';
import '../utils/vector_utils.dart';

mixin CollisionSystem {
  void resolveWallCollision(
    Ball ball,
    Vector2 arenaCenter,
    double arenaRadius,
    Random random,
    double angleRandomness,
  ) {
    final toBall = ball.position - arenaCenter;
    final distance = toBall.length;
    final maxDistance = arenaRadius - ball.radius;

    if (distance > maxDistance && distance > 0) {
      final normal = toBall / distance;
      ball.position = arenaCenter + normal * maxDistance;

      final dot = ball.velocity.dot(normal);
      if (dot > 0) {
        ball.velocity = rotateVector(
          ball.velocity - normal * (2 * dot),
          (random.nextDouble() - 0.5) * angleRandomness,
        );
        ball.maintainSpeed();
      }
    } else if (distance <= 0) {
      // 볼이 아레나 중앙에 완전히 겹쳐진 경우 - 랜덤 방향으로 밀어냄
      final angle = random.nextDouble() * pi * 2;
      ball.position =
          arenaCenter + Vector2(cos(angle), sin(angle)) * (maxDistance * 0.5);
      ball.velocity = Vector2(cos(angle), sin(angle)) * ball.fixedSpeed;
    }
  }

  void resolveCollisions(
    List<Ball> players,
    List<EnemyBall> enemies,
    Function(EnemyBall, Vector2) onPlayerEnemyCollision,
  ) {
    // 살아있는(enemies 리스트에 있는) 적만 참조하도록 필터링
    final activeEnemies = enemies.where((e) => !e.isDead).toList();
    final all = <Ball>[...players, ...activeEnemies];

    for (int i = 0; i < all.length; i++) {
      for (int j = i + 1; j < all.length; j++) {
        final a = all[i], b = all[j];
        final delta = b.position - a.position;
        final dist = delta.length;
        final minDist = a.radius + b.radius;

        if (dist > 0.0001 && dist < minDist) {
          final normal = delta / dist;
          final overlap = minDist - dist;
          final totalMass = a.mass + b.mass;

          if (totalMass > 0) {
            final m1Ratio = b.mass / totalMass;
            final m2Ratio = a.mass / totalMass;
            a.position -= normal * overlap * m1Ratio;
            b.position += normal * overlap * m2Ratio;
          }

          final velAlongNormal = (b.velocity - a.velocity).dot(normal);
          if (velAlongNormal < 0) {
            final invMassSum =
                (1 / max(a.mass, 0.01)) + (1 / max(b.mass, 0.01));
            final impulseScalar = (-(2.0) * velAlongNormal) / invMassSum;
            final impulse = normal * impulseScalar;

            a.velocity -= impulse / max(a.mass, 0.01);
            b.velocity += impulse / max(b.mass, 0.01);
            a.maintainSpeed();
            b.maintainSpeed();
          }

          // 충돌 후 적이 죽었으면 onPlayerEnemyCollision 콜백을 스킵
          if (players.contains(a) && b is EnemyBall) {
            if (!b.isDead) {
              onPlayerEnemyCollision(b, normal);
            }
          } else if (players.contains(b) && a is EnemyBall) {
            if (!a.isDead) {
              onPlayerEnemyCollision(a, -normal);
            }
          }
        }
      }
    }
  }
}
