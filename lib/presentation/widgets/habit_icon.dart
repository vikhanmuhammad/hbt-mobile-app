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
  // Kesehatan
  CuratedIcon(key: 'heart-pulse', icon: FontAwesomeIcons.heartPulse, group: 'Kesehatan'),
  CuratedIcon(key: 'glass-water', icon: FontAwesomeIcons.glassWater, group: 'Kesehatan'),
  CuratedIcon(key: 'carrot', icon: FontAwesomeIcons.carrot, group: 'Kesehatan'),
  CuratedIcon(key: 'bed', icon: FontAwesomeIcons.bed, group: 'Kesehatan'),
  CuratedIcon(key: 'pills', icon: FontAwesomeIcons.pills, group: 'Kesehatan'),
  // Olahraga
  CuratedIcon(key: 'person-running', icon: FontAwesomeIcons.personRunning, group: 'Olahraga'),
  CuratedIcon(key: 'person-walking', icon: FontAwesomeIcons.personWalking, group: 'Olahraga'),
  CuratedIcon(key: 'dumbbell', icon: FontAwesomeIcons.dumbbell, group: 'Olahraga'),
  CuratedIcon(key: 'bicycle', icon: FontAwesomeIcons.bicycle, group: 'Olahraga'),
  CuratedIcon(key: 'person-swimming', icon: FontAwesomeIcons.personSwimming, group: 'Olahraga'),
  // Keuangan
  CuratedIcon(key: 'piggy-bank', icon: FontAwesomeIcons.piggyBank, group: 'Keuangan'),
  CuratedIcon(key: 'receipt', icon: FontAwesomeIcons.receipt, group: 'Keuangan'),
  CuratedIcon(key: 'wallet', icon: FontAwesomeIcons.wallet, group: 'Keuangan'),
  CuratedIcon(key: 'coins', icon: FontAwesomeIcons.coins, group: 'Keuangan'),
  CuratedIcon(key: 'credit-card', icon: FontAwesomeIcons.creditCard, group: 'Keuangan'),
  // Mindfulness
  CuratedIcon(key: 'spa', icon: FontAwesomeIcons.spa, group: 'Mindfulness'),
  CuratedIcon(key: 'pen', icon: FontAwesomeIcons.pen, group: 'Mindfulness'),
  CuratedIcon(key: 'brain', icon: FontAwesomeIcons.brain, group: 'Mindfulness'),
  CuratedIcon(key: 'moon', icon: FontAwesomeIcons.moon, group: 'Mindfulness'),
  // Sosial
  CuratedIcon(key: 'people-group', icon: FontAwesomeIcons.peopleGroup, group: 'Sosial'),
  CuratedIcon(key: 'phone', icon: FontAwesomeIcons.phone, group: 'Sosial'),
  CuratedIcon(key: 'comments', icon: FontAwesomeIcons.comments, group: 'Sosial'),
  CuratedIcon(key: 'gift', icon: FontAwesomeIcons.gift, group: 'Sosial'),
  // Produktivitas
  CuratedIcon(key: 'list-check', icon: FontAwesomeIcons.listCheck, group: 'Produktivitas'),
  CuratedIcon(key: 'book', icon: FontAwesomeIcons.book, group: 'Produktivitas'),
  CuratedIcon(key: 'graduation-cap', icon: FontAwesomeIcons.graduationCap, group: 'Produktivitas'),
  CuratedIcon(key: 'laptop', icon: FontAwesomeIcons.laptop, group: 'Produktivitas'),
  // Umum
  CuratedIcon(key: 'star', icon: FontAwesomeIcons.star, group: 'Umum'),
  CuratedIcon(key: 'house', icon: FontAwesomeIcons.house, group: 'Umum'),
  CuratedIcon(key: 'leaf', icon: FontAwesomeIcons.leaf, group: 'Umum'),
  CuratedIcon(key: 'calendar-check', icon: FontAwesomeIcons.calendarCheck, group: 'Umum'),
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
