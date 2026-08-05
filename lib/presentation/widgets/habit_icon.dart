import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Kunci icon (kebab-case, sesuai `habit_templates.json` & value tersimpan
/// di `Habits.icon`) -> Font Awesome `FaIconData`. Kurasi bertahap — ditambah
/// lagi saat `IconPickerSheet` (CLAUDE.md v3 §9) dibangun.
const Map<String, FaIconData> habitIconMap = {
  'heart-pulse': FontAwesomeIcons.heartPulse,
  'person-running': FontAwesomeIcons.personRunning,
  'list-check': FontAwesomeIcons.listCheck,
  'spa': FontAwesomeIcons.spa,
  'piggy-bank': FontAwesomeIcons.piggyBank,
  'people-group': FontAwesomeIcons.peopleGroup,
  'glass-water': FontAwesomeIcons.glassWater,
  'person-walking': FontAwesomeIcons.personWalking,
  'carrot': FontAwesomeIcons.carrot,
  'bed': FontAwesomeIcons.bed,
  'dumbbell': FontAwesomeIcons.dumbbell,
  'book': FontAwesomeIcons.book,
  'graduation-cap': FontAwesomeIcons.graduationCap,
  'pen': FontAwesomeIcons.pen,
  'receipt': FontAwesomeIcons.receipt,
  'phone': FontAwesomeIcons.phone,
};

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
