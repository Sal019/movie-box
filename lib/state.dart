import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

/// A local-only profile: name + avatar colour, stored on this device
/// (shared_preferences -> local storage on web). No server, no sign-in.
class LocalProfile {
  String name;
  int colorIndex;
  LocalProfile(this.name, this.colorIndex);

  Map<String, dynamic> toJson() => {'name': name, 'color': colorIndex};
  factory LocalProfile.fromJson(Map<String, dynamic> j) =>
      LocalProfile(j['name'] as String, (j['color'] as num).toInt());
}

const List<List<Color>> kAvatarGradients = [
  [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
  [Color(0xFFFF6A5e), Color(0xFFFFB347)],
  [Color(0xFF00C853), Color(0xFF64DD17)],
  [Color(0xFF2979FF), Color(0xFF7C4DFF)],
  [Color(0xFFFF4081), Color(0xFF7C4DFF)],
  [Color(0xFFFFD740), Color(0xFFFF6A5e)],
];

class AppState extends ChangeNotifier {
  List<LocalProfile> profiles = [LocalProfile('Salman', 0)];
  int activeProfile = 0;
  Set<String> myList = {};
  Map<String, double> progress = {};

  AppState() {
    _load();
  }

  LocalProfile get profile => profiles[activeProfile];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('nova_profiles');
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => LocalProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) profiles = list;
      activeProfile = prefs.getInt('nova_active') ?? 0;
      if (activeProfile >= profiles.length) activeProfile = 0;
    }
    myList = (prefs.getStringList('nova_mylist') ?? []).toSet();
    final praw = prefs.getString('nova_progress');
    if (praw != null) {
      progress = (jsonDecode(praw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
    notifyListeners();
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'nova_profiles', jsonEncode(profiles.map((p) => p.toJson()).toList()));
    await prefs.setInt('nova_active', activeProfile);
  }

  Future<void> addProfile(String name, int colorIndex) async {
    if (profiles.length >= 5) return;
    profiles.add(LocalProfile(name, colorIndex));
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> updateProfile(int index, String name, int colorIndex) async {
    profiles[index].name = name;
    profiles[index].colorIndex = colorIndex;
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> switchProfile(int index) async {
    activeProfile = index;
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> toggleMyList(String id) async {
    if (!myList.remove(id)) myList.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('nova_mylist', myList.toList());
    notifyListeners();
  }

  bool inMyList(String id) => myList.contains(id);

  double progressFor(TitleItem t) => progress[t.id] ?? t.continueProgress;

  Future<void> setProgress(String id, double ratio) async {
    progress[id] = ratio.clamp(0, 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nova_progress', jsonEncode(progress));
    notifyListeners();
  }
}
