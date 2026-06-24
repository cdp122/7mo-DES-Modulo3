import 'package:flutter/material.dart';

class AppColors {
  // ── Paleta Águilas (exacta, imagen de referencia) ──────────────
  static const Color primary        = Color(0xFF16305B); // Navy profundo
  static const Color primaryAccent  = Color(0xFF2C86A0); // Teal (corregido)
  static const Color sage           = Color(0xFF4E9A6B); // Verde Sage
  static const Color amber          = Color(0xFFDFA235); // Dorado Mostaza
  static const Color secondary      = Color(0xFFD2693E); // Terracota Quemada

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color backgroundLight     = Color(0xFFF5F1E8); // Marfil cálido
  static const Color backgroundDark      = Color(0xFF0C1322); // Azul medianoche
  static const Color backgroundDarkSoft  = Color(0xFF0F1923); // Variante más suave

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color surfaceLight        = Color(0xFFFFFFFF);
  static const Color surfaceDark         = Color(0xFF131D31); // Azul oscuro profundo
  static const Color surfaceDarkElevated = Color(0xFF1A2535); // Elevado

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimaryLight    = Color(0xFF16253F);
  static const Color textSecondaryLight  = Color(0xFF5A6982);
  static const Color textPrimaryDark     = Color(0xFFF5F1E8);
  static const Color textSecondaryDark   = Color(0xFF8B9BB4);

  // ── Borders ──────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE2D9C4);
  static const Color borderDark  = Color(0xFF202F4A);

  // ── Status ───────────────────────────────────────────────────
  static const Color success = Color(0xFF4E9A6B); // mismo que sage
  static const Color error   = Color(0xFFBF3929); // Rojo terracota
  static const Color warning = Color(0xFFDFA235); // mismo que amber
  static const Color info    = Color(0xFF2C86A0); // mismo que teal
}
