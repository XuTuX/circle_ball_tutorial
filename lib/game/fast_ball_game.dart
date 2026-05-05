import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/arena.dart';
import 'components/ball.dart';
import 'components/enemy_ball.dart';
import 'components/buff_orb.dart';
import 'models/augment.dart';
import 'utils/vector_utils.dart';
import 'utils/collection_manager.dart';

class FastBallGame extends FlameGame {
  late Vector2 arenaCenter;
  late double arenaRadius;

  final List<Ball> players = [];

  final Random random = Random();

  final double playerSpeed = 450;
  final double enemySpeed = 180;
  final double angleRandomness = 0.25;

  final double enemyHitCooldownDuration = 0.35;
  final double enemyKnockbackDistance = 18;

  final List<EnemyBall> enemies = [];
  final int enemyCount = 10;

  // --- Phase 1 & 2: Game State ---
  int score = 0;
  int currentStageIndex = 0;
  double timeRemaining = 17.0;
  bool isGameOver = false;
  bool isPaused = false;

  // Augment Stats
  double scoreMultiplier = 1.0;
  double timeGainOnKill = 0.0;
  double playerSpeedBonus = 0.0;
  double playerRadiusBonus = 0.0;
  double playerMassBonus = 0.0;

  List<Augment> currentAugmentOptions = [];

  // Boss & Penalty Stats
  String? currentPenalty;
  double bossPenaltyScoreMultiplier = 1.0;
  int enemyArmorBonus = 0;

  String get stageDisplay => '${(currentStageIndex ~/ 3) + 1}-${(currentStageIndex % 3) + 1}${isBossStage ? " (BOSS)" : ""}';
  bool get isBossStage => (currentStageIndex % 3) == 2;
  
  int get targetScore {
    final stageNumber = currentStageIndex + 1;
    return (500 * pow(2.5, stageNumber - 1)).toInt();
  }

  // Phase 4: Buffs & Orbs
  final List<BuffOrb> orbs = [];
  double orbSpawnTimer = 0;
  
  double activeScoreBuffTimer = 0;
  double activeSpeedBuffTimer = 0;
  
  // Phase 4: Synergies
  final Set<String> activeSynergies = {};
  // ----------------------------

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

    overlays.add('HUD');
  }

  void _spawnPlayer() {
    final angle = random.nextDouble() * pi * 2;

    final p = Ball(
      position: arenaCenter,
      radius: 16 + playerRadiusBonus,
      velocity: Vector2(cos(angle), sin(angle)) * (playerSpeed + playerSpeedBonus),
      color: Colors.orange,
      fixedSpeed: playerSpeed + playerSpeedBonus,
      isPlayer: true,
    );
    p.mass += playerMassBonus;

    players.add(p);
    add(p);
  }

  void _spawnEnemy() {
    const enemyRadius = 8.0;

    Vector2 position = arenaCenter.clone();
    int tries = 0;

    do {
      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * (arenaRadius - enemyRadius - 10);
      position = arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
      tries++;
      if (tries > 50) break; // 무한 루프 방지 안전장치
    } while (players.any((p) => (position - p.position).length < p.radius + 40));

    final angle = random.nextDouble() * pi * 2;

    final enemy = EnemyBall(
      position: position,
      radius: enemyRadius,
      velocity: Vector2(cos(angle), sin(angle)) * enemySpeed,
      fixedSpeed: enemySpeed,
      hitCooldownDuration: enemyHitCooldownDuration,
    );
    enemy.hp += enemyArmorBonus; // 페널티로 인한 체력 증가

    enemies.add(enemy);
    add(enemy);
  }

  void _spawnBoss() {
    final boss = EnemyBall(
      position: arenaCenter,
      radius: 60, // 거대 보스
      velocity: Vector2(100, 100),
      fixedSpeed: 100,
      hitCooldownDuration: 0.2,
      isBoss: true,
    );
    boss.hp = 20 + (enemyArmorBonus * 5); // 보스는 방어력 보너스를 더 크게 받음
    boss.color = Colors.deepPurpleAccent;

    enemies.add(boss);
    add(boss);
  }

  @override
  void update(double dt) {
    if (isGameOver || isPaused) return;

    super.update(dt);
    final safeDt = dt.clamp(0.0, 1 / 60);

    // 17초 카운트다운
    timeRemaining -= safeDt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      _handleStageEnd();
    }

    for (final enemy in enemies) {
      enemy.tickCooldown(safeDt);
    }

    for (final p in players) {
      p.integrate(safeDt);
      _resolveWallCollision(p);
    }

    for (final enemy in enemies) {
      enemy.integrate(safeDt);
      _resolveWallCollision(enemy);
    }

    _resolveCollisions();
    _checkEnemyHp();
    _updateBuffs(safeDt);
    _handleOrbSpawning(safeDt);
    _applySynergyEffects(safeDt);
  }

  void _applySynergyEffects(double dt) {
    if (activeSynergies.contains('Planet Gravity')) {
      for (final enemy in enemies) {
        if (players.isEmpty) continue;
        // 가장 가까운 플레이어 공 찾기
        Ball nearest = players.first;
        double minDist = (enemy.position - nearest.position).length;
        for (final p in players) {
          double d = (enemy.position - p.position).length;
          if (d < minDist) {
            minDist = d;
            nearest = p;
          }
        }
        
        // 인력 적용 (거리에 반비례)
        final forceDir = (nearest.position - enemy.position).normalized();
        final forceStrength = 150.0; // 중력 세기
        enemy.velocity += forceDir * forceStrength * dt;
      }
    }
  }

  void _updateBuffs(double dt) {
    if (activeScoreBuffTimer > 0) activeScoreBuffTimer -= dt;
    if (activeSpeedBuffTimer > 0) {
      activeSpeedBuffTimer -= dt;
      if (activeSpeedBuffTimer <= 0) {
        // 속도 버프 종료 시 원복
        for (final p in players) {
          p.maintainSpeed();
        }
      }
    }
  }

  void _handleOrbSpawning(double dt) {
    orbSpawnTimer -= dt;
    if (orbSpawnTimer <= 0) {
      _spawnBuffOrb();
      orbSpawnTimer = 5 + random.nextDouble() * 5; // 5~10초 간격
    }
  }

  void _spawnBuffOrb() {
    final angle = random.nextDouble() * pi * 2;
    final distance = random.nextDouble() * (arenaRadius - 20);
    final position = arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
    
    final type = BuffType.values[random.nextInt(BuffType.values.length)];
    final orb = BuffOrb(position: position, type: type);
    
    orbs.add(orb);
    add(orb);
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
    final all = [...players, ...enemies];
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

          if (players.contains(a) && b is EnemyBall) {
            _damageEnemy(b, normal);
          } else if (players.contains(b) && a is EnemyBall) {
            _damageEnemy(a, -normal);
          }
        }
      }
    }

    // 구체와의 충돌 체크 (플레이어 공만 해당)
    for (final p in players) {
      for (final orb in orbs.toList()) {
        final delta = orb.position - p.position;
        if (delta.length < p.radius + orb.radius) {
          _applyBuff(orb.type);
          orb.onHit();
          orbs.remove(orb);
        }
      }
    }
  }

  void _applyBuff(BuffType type) {
    switch (type) {
      case BuffType.speed:
        activeSpeedBuffTimer = 3.0;
        for (final p in players) {
          p.velocity *= 1.8; // 폭발적 가속
        }
        break;
      case BuffType.score:
        activeScoreBuffTimer = 5.0;
        break;
      case BuffType.time:
        timeRemaining += 2.0;
        break;
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
        
        // 적 처치 시 점수 및 시간 획득
        double finalMultiplier = scoreMultiplier * bossPenaltyScoreMultiplier;
        if (activeScoreBuffTimer > 0) finalMultiplier *= 2.0; // 옐로우 버프 적용
        
        score += (100 * finalMultiplier).toInt();
        timeRemaining += timeGainOnKill;
        
        // 보스가 아니면 다시 스폰
        if (!isBossStage) {
          _spawnEnemy();
        } else if (e.isBoss) {
          // 보스 처치!
          _handleBossDeath();
        }
        return true;
      }
      return false;
    });
  }

  void _handleStageEnd() {
    if (score >= targetScore) {
      // 클리어! 다음 스테이지 준비 (Phase 2에서 증강 UI 연결 예정)
      _showUpgradeMenu();
    } else {
      // 실패 - 게임 오버
      isGameOver = true;
      overlays.add('GameOver');
    }
  }

  void _showUpgradeMenu() {
    isPaused = true;
    _generateAugmentOptions();
    overlays.add('UpgradeMenu');
  }

  void _generateAugmentOptions() {
    final pool = Augment.allPool;
    pool.shuffle();
    currentAugmentOptions = pool.take(3).toList();
  }

  void applyAugment(Augment augment) {
    switch (augment.type) {
      case AugmentType.speed:
        playerSpeedBonus += augment.value;
        break;
      case AugmentType.radius:
        playerRadiusBonus += augment.value;
        break;
      case AugmentType.mass:
        playerMassBonus += augment.value;
        break;
      case AugmentType.multiBall:
        _spawnPlayer();
        break;
      case AugmentType.scoreMultiplier:
        scoreMultiplier *= augment.value;
        break;
      case AugmentType.timeOnKill:
        timeGainOnKill += augment.value;
        break;
    }

    // 도감에 기록
    CollectionManager().discoverAugment(augment.title);

    // 기존 공들 스탯 업데이트
    for (final p in players) {
      p.radius = 16 + playerRadiusBonus;
      p.fixedSpeed = playerSpeed + playerSpeedBonus;
      p.mass = (16 + playerRadiusBonus) * (16 + playerRadiusBonus) + playerMassBonus;
      p.maintainSpeed();
    }

    _checkSynergies();
    nextStage();
  }

  void _checkSynergies() {
    // Phase 4: 시너지 체크 로직
    // (간소화를 위해 현재는 스탯 수치를 기반으로 체크하거나 기록용 리스트를 별도로 둘 수 있음)
    // 여기서는 간단한 예시 시너지만 활성화
    if (playerSpeedBonus > 200 && players.length > 1) {
      activeSynergies.add('Afterimage');
      CollectionManager().discoverSynergy('Afterimage');
    }
    if (playerRadiusBonus > 10 && playerMassBonus > 1.0) {
      activeSynergies.add('Planet Gravity');
      CollectionManager().discoverSynergy('Planet Gravity');
    }
  }

  void nextStage() {
    currentStageIndex++;
    timeRemaining = 17.0;
    score = 0;
    isPaused = false;
    
    // 보스 페널티 및 보너스 초기화
    currentPenalty = null;
    bossPenaltyScoreMultiplier = 1.0;
    enemyArmorBonus = 0;
    
    overlays.remove('UpgradeMenu');
    overlays.remove('PenaltyAlert');
    
    // 보스전 준비 (Phase 3에서 구현)
    if (isBossStage) {
      _prepareBossStage();
    }
  }

  void _prepareBossStage() {
    // 모든 일반 적 제거
    for (final e in enemies) {
      e.removeFromParent();
    }
    enemies.clear();

    // 무작위 페널티 부여
    final penalties = ['Score 0.5x', 'Enemy Armor +1', 'Speed -20%'];
    currentPenalty = penalties[random.nextInt(penalties.length)];
    
    _applyPenalty(currentPenalty!);
    
    // 보스 소환
    _spawnBoss();
    
    // 페널티 알림 오버레이 (Phase 3 UI에서 추가 예정)
    overlays.add('PenaltyAlert');
  }

  void _applyPenalty(String penalty) {
    // 페널티 수치 초기화
    bossPenaltyScoreMultiplier = 1.0;
    enemyArmorBonus = 0;

    switch (penalty) {
      case 'Score 0.5x':
        bossPenaltyScoreMultiplier = 0.5;
        break;
      case 'Enemy Armor +1':
        enemyArmorBonus = 1;
        break;
      case 'Speed -20%':
        for (final p in players) {
          p.fixedSpeed *= 0.8;
        }
        break;
    }
  }

  void _handleBossDeath() {
    // 보스 처치 시 화려한 폭발 연출 (Effect 등 추가 가능)
    // 여기서는 간단히 모든 오버레이 제거 후 성공 처리
    overlays.remove('PenaltyAlert');
    _handleStageEnd();
  }

  void resetGame() {
    // 스탯 초기화
    score = 0;
    currentStageIndex = 0;
    timeRemaining = 17.0;
    isGameOver = false;
    isPaused = false;
    
    scoreMultiplier = 1.0;
    timeGainOnKill = 0.0;
    playerSpeedBonus = 0.0;
    playerRadiusBonus = 0.0;
    playerMassBonus = 0.0;

    activeSynergies.clear();
    orbs.clear();

    // 기존 플레이어 공 모두 제거
    for (final p in players) {
      p.removeFromParent();
    }
    players.clear();

    // 오버레이 초기화
    overlays.clear();
    overlays.add('HUD');
    
    // 첫 번째 플레이어 다시 생성
    _spawnPlayer();
  }
}
