import 'dart:math';
import 'package:flame/extensions.dart';
import '../components/ball.dart';
import '../components/enemy_ball.dart';
import '../utils/vector_utils.dart';

mixin CollisionSystem {
  void resolveWallCollision(Ball ball, Vector2 arenaCenter, double arenaRadius, Random random, double angleRandomness) {
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
    }
  }

  void resolveCollisions(
    List<Ball> players,
    List<EnemyBall> enemies,
    Function(EnemyBall, Vector2) onPlayerEnemyCollision,
  ) {
    final all = [...players, ...enemies];
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
            final invMassSum = (1 / (a.mass > 0 ? a.mass : 1)) +
                (1 / (b.mass > 0 ? b.mass : 1));
            final impulseScalar = (-(2.0) * velAlongNormal) / invMassSum;
            final impulse = normal * impulseScalar;

            a.velocity -= impulse / (a.mass > 0 ? a.mass : 1);
            b.velocity += impulse / (b.mass > 0 ? b.mass : 1);
            a.maintainSpeed();
            b.maintainSpeed();
          }

          if (players.contains(a) && b is EnemyBall) {
            onPlayerEnemyCollision(b, normal);
          } else if (players.contains(b) && a is EnemyBall) {
            onPlayerEnemyCollision(a, -normal);
          }
        }
      }
    }
  }
}
