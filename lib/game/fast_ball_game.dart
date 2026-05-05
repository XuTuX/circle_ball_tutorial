import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flutter/material.dart';
import 'components/arena.dart';
import 'components/ball.dart';
import 'components/enemy_ball.dart';
import 'components/buff_orb.dart';
import 'models/augment.dart';
import 'utils/collection_manager.dart';
import 'utils/collision_system.dart';

class FastBallGame extends FlameGame with CollisionSystem {
  // --- 고정 월드 해상도 (모든 기기에서 동일한 게임 좌표계) ---
  static const double worldWidth = 400;
  static const double worldHeight = 800;

  // --- Constants ---
  static const double playerBaseSpeed = 450;
  static const double enemyBaseSpeed = 180;
  static const double angleRandomness = 0.25;
  static const double enemyHitCooldownDuration = 0.35;
  static const double enemyKnockbackDistance = 18;
  static const double stageTimeLimit = 17.0;

  // --- Core Systems ---
  late Vector2 arenaCenter;
  late double arenaRadius;
  final Random random = Random();

  // --- Game State ---
  int score = 0;
  int currentStageIndex = 0;
  double timeRemaining = stageTimeLimit;
  bool isGameOver = false;
  bool isPaused = false;

  // --- Entities ---
  final List<Ball> players = [];
  final List<EnemyBall> enemies = [];
  final List<BuffOrb> orbs = [];
  final int baseEnemyCount = 10;

  // --- Augments & Stats ---
  double scoreMultiplier = 1.0;
  double timeGainOnKill = 0.0;
  double playerSpeedBonus = 0.0;
  double playerRadiusBonus = 0.0;
  double playerMassBonus = 0.0;
  List<Augment> currentAugmentOptions = [];

  // --- Held Augments & Synergies ---
  final List<String> heldAugmentTitles = [];
  double orbSpawnTimer = 0;
  double activeScoreBuffTimer = 0;
  double activeSpeedBuffTimer = 0;
  final Set<String> activeSynergies = {};
  final Set<String> synergyDisplayTexts = {};

  // --- Boss & Penalty ---
  String? currentPenalty;
  double bossPenaltyScoreMultiplier = 1.0;
  int enemyArmorBonus = 0;

  // --- Getters ---
  String get stageDisplay =>
      '${(currentStageIndex ~/ 3) + 1}-${(currentStageIndex % 3) + 1}${isBossStage ? " (BOSS)" : ""}';
  bool get isBossStage => (currentStageIndex % 3) == 2;
  int get targetScore => (500 * pow(2.5, currentStageIndex)).toInt();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 고정 해상도 뷰포트 설정 - 모든 기기에서 동일한 게임 좌표계 사용
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(worldWidth, worldHeight),
    );

    // 월드 좌표는 고정 (size와 무관)
    arenaCenter = Vector2(worldWidth / 2, worldHeight / 2);
    arenaRadius = 170;

    add(ArenaComponent(center: arenaCenter, radius: arenaRadius));

    _spawnPlayer();

    for (int i = 0; i < baseEnemyCount; i++) {
      _spawnEnemy();
    }

    overlays.add('HUD');
  }

  // --- Spawning Logic ---

  void _spawnPlayer() {
    final angle = random.nextDouble() * pi * 2;
    final speed = playerBaseSpeed + playerSpeedBonus;

    final p = Ball(
      position: arenaCenter,
      radius: 16 + playerRadiusBonus,
      velocity: Vector2(cos(angle), sin(angle)) * speed,
      color: Colors.orange,
      fixedSpeed: speed,
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

    // Avoid spawning on top of players
    do {
      final angle = random.nextDouble() * pi * 2;
      final distance = random.nextDouble() * (arenaRadius - enemyRadius - 10);
      position = arenaCenter + Vector2(cos(angle), sin(angle)) * distance;
      tries++;
      if (tries > 50) break;
    } while (players.any(
      (p) => (position - p.position).length < p.radius + 40,
    ));

    final angle = random.nextDouble() * pi * 2;
    final enemy = EnemyBall(
      position: position,
      radius: enemyRadius,
      velocity: Vector2(cos(angle), sin(angle)) * enemyBaseSpeed,
      fixedSpeed: enemyBaseSpeed,
      hitCooldownDuration: enemyHitCooldownDuration,
    );
    enemy.hp += enemyArmorBonus;

    enemies.add(enemy);
    add(enemy);
  }

  void _spawnBoss() {
    final boss = EnemyBall(
      position: arenaCenter,
      radius: 60,
      velocity: Vector2(100, 100),
      fixedSpeed: 100,
      hitCooldownDuration: 0.2,
      isBoss: true,
    );
    boss.hp = 20 + (enemyArmorBonus * 5);
    boss.color = Colors.deepPurpleAccent;

    enemies.add(boss);
    add(boss);
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

  // --- Game Loop ---

  @override
  void update(double dt) {
    if (isGameOver || isPaused) return;

    final safeDt = dt.clamp(0.0, 1 / 60);

    // Update Timers
    timeRemaining -= safeDt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      _handleStageEnd();
      return;
    }

    _updateBuffs(safeDt);
    _handleOrbSpawning(safeDt);
    _applySynergyEffects(safeDt);

    // Update Entities
    for (final enemy in enemies) {
      enemy.tickCooldown(safeDt);
      enemy.integrate(safeDt);
      resolveWallCollision(
        enemy,
        arenaCenter,
        arenaRadius,
        random,
        angleRandomness,
      );
    }

    for (final p in players) {
      p.integrate(safeDt);
      resolveWallCollision(
        p,
        arenaCenter,
        arenaRadius,
        random,
        angleRandomness,
      );
    }

    // 죽은 적 먼저 정리 (이미 삭제된 객체 참조 방지)
    _checkEnemyHp();

    // Collisions (살아있는 적만 참조하도록 collision_system에서 처리)
    resolveCollisions(players, enemies, _damageEnemy);
    _checkOrbCollisions();

    // 충돌로 인해 새로 죽은 적들 정리
    _checkEnemyHp();

    super.update(safeDt);
  }

  void _updateBuffs(double dt) {
    if (activeScoreBuffTimer > 0) activeScoreBuffTimer -= dt;
    if (activeSpeedBuffTimer > 0) {
      activeSpeedBuffTimer -= dt;
      if (activeSpeedBuffTimer <= 0) {
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
      orbSpawnTimer = 5 + random.nextDouble() * 5;
    }
  }

  void _applySynergyEffects(double dt) {
    if (activeSynergies.contains('행성 중력')) {
      for (final enemy in enemies) {
        if (players.isEmpty) continue;
        Ball nearest = players.first;
        double minDist = (enemy.position - nearest.position).length;
        for (final p in players) {
          double d = (enemy.position - p.position).length;
          if (d < minDist) {
            minDist = d;
            nearest = p;
          }
        }

        final forceDir = (nearest.position - enemy.position).normalized();
        const forceStrength = 150.0;
        enemy.velocity += forceDir * forceStrength * dt;
      }
    }
  }

  // --- Collision Callbacks ---

  void _damageEnemy(EnemyBall enemy, Vector2 dir) {
    if (!enemy.canTakeDamage) return;
    enemy.takeDamage();
    if (enemy.isDead) return;
    enemy.position += dir * enemyKnockbackDistance;
    enemy.velocity = dir * enemy.fixedSpeed;
    resolveWallCollision(
      enemy,
      arenaCenter,
      arenaRadius,
      random,
      angleRandomness,
    );
  }

  void _checkOrbCollisions() {
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
          p.velocity *= 1.8;
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

  void _checkEnemyHp() {
    final deadEnemies = enemies.where((e) => e.isDead).toList();
    if (deadEnemies.isEmpty) return;

    for (final e in deadEnemies) {
      enemies.remove(e);
      e.removeFromParent();

      double finalMultiplier = scoreMultiplier * bossPenaltyScoreMultiplier;
      if (activeScoreBuffTimer > 0) finalMultiplier *= 2.0;

      score += (100 * finalMultiplier).toInt();
      timeRemaining += timeGainOnKill;

      if (e.isBoss) {
        _handleBossDeath();
      } else {
        // 일반 적이 죽으면 항상 새 적 리스폰 (보스전 포함)
        _spawnEnemy();
      }
    }
  }

  // --- Stage Management ---

  void _handleStageEnd() {
    if (isBossStage) {
      // 보스 스테이지: 보스가 살아있으면 게임오버, 죽었으면 클리어
      final bossAlive = enemies.any((e) => e.isBoss && !e.isDead);
      if (bossAlive) {
        isGameOver = true;
        overlays.add('GameOver');
      } else {
        _showUpgradeMenu();
      }
    } else if (score >= targetScore) {
      _showUpgradeMenu();
    } else {
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

    heldAugmentTitles.add(augment.title);
    CollectionManager().discoverAugment(augment.title);

    for (final p in players) {
      p.radius = 16 + playerRadiusBonus;
      p.fixedSpeed = playerBaseSpeed + playerSpeedBonus;
      p.mass =
          (16 + playerRadiusBonus) * (16 + playerRadiusBonus) + playerMassBonus;
      p.maintainSpeed();
    }

    _checkSynergies();
    nextStage();
  }

  void _checkSynergies() {
    synergyDisplayTexts.clear();
    if (playerSpeedBonus > 200 && players.length > 1) {
      activeSynergies.add('잔상');
      synergyDisplayTexts.add('잔상: 속도 극대화!');
      CollectionManager().discoverSynergy('잔상');
    }
    if (playerRadiusBonus > 10 && playerMassBonus > 1.0) {
      activeSynergies.add('행성 중력');
      synergyDisplayTexts.add('행성 중력: 적을 끌어당깁니다');
      CollectionManager().discoverSynergy('행성 중력');
    }
  }

  void nextStage() {
    currentStageIndex++;
    timeRemaining = stageTimeLimit;
    score = 0;
    isPaused = false;

    currentPenalty = null;
    bossPenaltyScoreMultiplier = 1.0;
    enemyArmorBonus = 0;

    overlays.remove('UpgradeMenu');
    overlays.remove('PenaltyAlert');

    if (isBossStage) {
      _prepareBossStage();
    } else {
      // 일반 스테이지로 전환: 적이 부족하면 채워넣기
      _refillEnemies();
    }
  }

  void _refillEnemies() {
    final currentCount = enemies.length;
    if (currentCount < baseEnemyCount) {
      for (int i = 0; i < baseEnemyCount - currentCount; i++) {
        _spawnEnemy();
      }
    }
  }

  void _prepareBossStage() {
    for (final e in enemies) {
      e.removeFromParent();
    }
    enemies.clear();

    final penalties = ['점수 절반', '적 방어 +1', '속도 -20%'];
    currentPenalty = penalties[random.nextInt(penalties.length)];

    _applyPenalty(currentPenalty!);
    _spawnBoss();

    // 보스 스테이지에도 일반 적들 등장 (보스 집중 공략을 방해)
    for (int i = 0; i < baseEnemyCount ~/ 2; i++) {
      _spawnEnemy();
    }

    overlays.add('PenaltyAlert');
  }

  void _applyPenalty(String penalty) {
    bossPenaltyScoreMultiplier = 1.0;
    enemyArmorBonus = 0;

    switch (penalty) {
      case '점수 절반':
        bossPenaltyScoreMultiplier = 0.5;
        break;
      case '적 방어 +1':
        enemyArmorBonus = 1;
        break;
      case '속도 -20%':
        for (final p in players) {
          p.fixedSpeed *= 0.8;
          p.maintainSpeed();
        }
        break;
    }
  }

  void _handleBossDeath() {
    overlays.remove('PenaltyAlert');
    _handleStageEnd();
  }

  void resetGame() {
    score = 0;
    currentStageIndex = 0;
    timeRemaining = stageTimeLimit;
    isGameOver = false;
    isPaused = false;

    scoreMultiplier = 1.0;
    timeGainOnKill = 0.0;
    playerSpeedBonus = 0.0;
    playerRadiusBonus = 0.0;
    playerMassBonus = 0.0;

    heldAugmentTitles.clear();
    activeSynergies.clear();
    synergyDisplayTexts.clear();
    orbs.clear();

    for (final p in players) {
      p.removeFromParent();
    }
    players.clear();

    for (final e in enemies) {
      e.removeFromParent();
    }
    enemies.clear();

    overlays.clear();
    overlays.add('HUD');

    _spawnPlayer();
    for (int i = 0; i < baseEnemyCount; i++) {
      _spawnEnemy();
    }
  }
}
