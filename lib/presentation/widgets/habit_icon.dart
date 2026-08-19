import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Satu entri icon kurasi untuk `IconPickerSheet` (CLAUDE.md v3 §9) —
/// dikelompokkan per konteks supaya tidak overwhelming (bukan expose semua
/// ribuan icon FA sekaligus).
class CuratedIcon {
  const CuratedIcon({required this.key, required this.icon, required this.group});

  /// Kebab-case, sesuai `habit_templates.json` & value tersimpan di
  /// `Habits.icon`/`Categories.icon`.
  final String key;
  final FaIconData icon;
  final String group;
}

const List<CuratedIcon> curatedHabitIcons = [
  // Health
  CuratedIcon(key: 'heart-pulse', icon: FontAwesomeIcons.heartPulse, group: 'Health'),
  CuratedIcon(key: 'glass-water', icon: FontAwesomeIcons.glassWater, group: 'Health'),
  CuratedIcon(key: 'carrot', icon: FontAwesomeIcons.carrot, group: 'Health'),
  CuratedIcon(key: 'bed', icon: FontAwesomeIcons.bed, group: 'Health'),
  CuratedIcon(key: 'pills', icon: FontAwesomeIcons.pills, group: 'Health'),
  CuratedIcon(key: 'mug-hot', icon: FontAwesomeIcons.mugHot, group: 'Health'),
  CuratedIcon(key: 'candy-cane', icon: FontAwesomeIcons.candyCane, group: 'Health'),
  CuratedIcon(key: 'bread-slice', icon: FontAwesomeIcons.breadSlice, group: 'Health'),
  CuratedIcon(key: 'wind', icon: FontAwesomeIcons.wind, group: 'Health'),
  CuratedIcon(key: 'person', icon: FontAwesomeIcons.person, group: 'Health'),
  // Sports
  CuratedIcon(key: 'person-running', icon: FontAwesomeIcons.personRunning, group: 'Sports'),
  CuratedIcon(key: 'person-walking', icon: FontAwesomeIcons.personWalking, group: 'Sports'),
  CuratedIcon(key: 'dumbbell', icon: FontAwesomeIcons.dumbbell, group: 'Sports'),
  CuratedIcon(key: 'bicycle', icon: FontAwesomeIcons.bicycle, group: 'Sports'),
  CuratedIcon(key: 'person-swimming', icon: FontAwesomeIcons.personSwimming, group: 'Sports'),
  CuratedIcon(key: 'child', icon: FontAwesomeIcons.child, group: 'Sports'),
  CuratedIcon(key: 'fire', icon: FontAwesomeIcons.fire, group: 'Sports'),
  // Finance
  CuratedIcon(key: 'piggy-bank', icon: FontAwesomeIcons.piggyBank, group: 'Finance'),
  CuratedIcon(key: 'receipt', icon: FontAwesomeIcons.receipt, group: 'Finance'),
  CuratedIcon(key: 'wallet', icon: FontAwesomeIcons.wallet, group: 'Finance'),
  CuratedIcon(key: 'coins', icon: FontAwesomeIcons.coins, group: 'Finance'),
  CuratedIcon(key: 'credit-card', icon: FontAwesomeIcons.creditCard, group: 'Finance'),
  // Mindfulness
  CuratedIcon(key: 'spa', icon: FontAwesomeIcons.spa, group: 'Mindfulness'),
  CuratedIcon(key: 'pen', icon: FontAwesomeIcons.pen, group: 'Mindfulness'),
  CuratedIcon(key: 'brain', icon: FontAwesomeIcons.brain, group: 'Mindfulness'),
  CuratedIcon(key: 'moon', icon: FontAwesomeIcons.moon, group: 'Mindfulness'),
  // Social
  CuratedIcon(key: 'people-group', icon: FontAwesomeIcons.peopleGroup, group: 'Social'),
  CuratedIcon(key: 'phone', icon: FontAwesomeIcons.phone, group: 'Social'),
  CuratedIcon(key: 'comments', icon: FontAwesomeIcons.comments, group: 'Social'),
  CuratedIcon(key: 'gift', icon: FontAwesomeIcons.gift, group: 'Social'),
  // Productivity
  CuratedIcon(key: 'list-check', icon: FontAwesomeIcons.listCheck, group: 'Productivity'),
  CuratedIcon(key: 'book', icon: FontAwesomeIcons.book, group: 'Productivity'),
  CuratedIcon(key: 'graduation-cap', icon: FontAwesomeIcons.graduationCap, group: 'Productivity'),
  CuratedIcon(key: 'laptop', icon: FontAwesomeIcons.laptop, group: 'Productivity'),
  CuratedIcon(key: 'clipboard-check', icon: FontAwesomeIcons.clipboardCheck, group: 'Productivity'),
  CuratedIcon(key: 'lightbulb', icon: FontAwesomeIcons.lightbulb, group: 'Productivity'),
  // General
  CuratedIcon(key: 'star', icon: FontAwesomeIcons.star, group: 'General'),
  CuratedIcon(key: 'house', icon: FontAwesomeIcons.house, group: 'General'),
  CuratedIcon(key: 'leaf', icon: FontAwesomeIcons.leaf, group: 'General'),
  CuratedIcon(key: 'calendar-check', icon: FontAwesomeIcons.calendarCheck, group: 'General'),
];

final Map<String, FaIconData> habitIconMap = {
  for (final c in curatedHabitIcons) c.key: c.icon,
};

const String defaultHabitIconKey = 'list-check';
const FaIconData defaultHabitIcon = FontAwesomeIcons.listCheck;

FaIconData resolveHabitIcon(String? key) =>
    habitIconMap[key] ?? defaultHabitIcon;

/// Render icon habit/goal phrase dari icon key (Font Awesome), dengan
/// fallback ke [defaultHabitIcon] kalau key null/tidak dikenal.
class HabitIcon extends StatelessWidget {
  const HabitIcon({super.key, required this.icon, this.size = 16, this.color});

  final String? icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FaIcon(resolveHabitIcon(icon), size: size, color: color);
  }
}
