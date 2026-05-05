import 'package:shared_preferences/shared_preferences.dart';

class CollectionManager {
  static final CollectionManager _instance = CollectionManager._internal();
  factory CollectionManager() => _instance;
  CollectionManager._internal();

  static const String _discoveredAugmentsKey = 'discovered_augments';
  static const String _discoveredSynergiesKey = 'discovered_synergies';

  Set<String> _discoveredAugments = {};
  Set<String> _discoveredSynergies = {};

  Set<String> get discoveredAugments => _discoveredAugments;
  Set<String> get discoveredSynergies => _discoveredSynergies;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _discoveredAugments = (prefs.getStringList(_discoveredAugmentsKey) ?? []).toSet();
    _discoveredSynergies = (prefs.getStringList(_discoveredSynergiesKey) ?? []).toSet();
  }

  Future<void> discoverAugment(String title) async {
    if (_discoveredAugments.contains(title)) return;
    _discoveredAugments.add(title);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_discoveredAugmentsKey, _discoveredAugments.toList());
  }

  Future<void> discoverSynergy(String name) async {
    if (_discoveredSynergies.contains(name)) return;
    _discoveredSynergies.add(name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_discoveredSynergiesKey, _discoveredSynergies.toList());
  }
}
