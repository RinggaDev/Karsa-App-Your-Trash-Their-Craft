// lib/core/constant/app_color.dart
import 'package:flutter/material.dart';

/// TWO LAYERS:
/// 1. PALETTE — every shade (50–900 scale). For fine-tuning.
/// 2. DECISION TOKENS — friendly job names widgets actually use.
///
/// In widgets, prefer Layer 2:
///   ✅ AppColor.textPrimary       (NOT  AppColor.text900)
///   ✅ AppColor.cardBorder        (NOT  AppColor.background500)
/// Use Layer 1 only when you need a specific tone not in the tokens.

abstract final class AppColor {
  // ═══════════════════════════════════════════════════════════
  // LAYER 1 — PALETTE (raw shades)
  // ═══════════════════════════════════════════════════════════

  // ── Brand: Primary (Fern green) ──
  static const Color primary50 = Color(0xFFF5FAF3);
  static const Color primary100 = Color(0xFFF9FFF7);
  static const Color primary200 = Color(0xFFDDFFD3);
  static const Color primary300 = Color(0xFFC2FFAE);
  static const Color primary400 = Color(0xFFA4DE92);
  static const Color primary500 = Color(0xFF63A156); // ← main brand
  static const Color primary600 = Color(0xFF4A7F3A);
  static const Color primary700 = Color(0xFF3C6530);

  // ── Brand: Secondary ──
  // TODO: ask designer for values, then uncomment:
  // static const Color secondary500 = Color(0xFF______);

  // ── Semantic: Success ──
  static const Color success100 = Color(0xFFF2FBE8);
  static const Color success200 = Color(0xFFE4F8D3);
  static const Color success300 = Color(0xFFC0F6A2);
  static const Color success400 = Color(0xFFA5EB88);
  static const Color success500 = Color(0xFF7DE062); // ← main success
  static const Color success600 = Color(0xFF58C047);
  static const Color success700 = Color(0xFF39A132);
  static const Color success800 = Color(0xFF208120);
  static const Color success900 = Color(0xFF126B19);

  // ── Semantic: Info (Royal blue) ──
  static const Color info100 = Color(0xFFD0ECFE);
  static const Color info200 = Color(0xFFA2D6FE);
  static const Color info300 = Color(0xFF74BCFE);
  static const Color info400 = Color(0xFF52A4FE);
  static const Color info500 = Color(0xFF197CFE); // ← main info
  static const Color info600 = Color(0xFF1260DA);
  static const Color info700 = Color(0xFF0C47B6);
  static const Color info800 = Color(0xFF073193);
  static const Color info900 = Color(0xFF042279);

  // ── Semantic: Warning ──
  static const Color warning100 = Color(0xFFFEF8CB);
  static const Color warning200 = Color(0xFFFEEF98);
  static const Color warning300 = Color(0xFFFEE365);
  static const Color warning400 = Color(0xFFFDD83F);
  static const Color warning500 = Color(0xFFFCC500); // ← main warning
  static const Color warning600 = Color(0xFFD8A400);
  static const Color warning700 = Color(0xFFB58500);
  static const Color warning800 = Color(0xFF926800);
  static const Color warning900 = Color(0xFF785300);

  // ── Semantic: Danger (Persian red) ──
  // TODO: 600 and 800 missing — ask designer
  static const Color danger100 = Color(0xFFFCE5D6);
  static const Color danger200 = Color(0xFFF9C5AD);
  static const Color danger300 = Color(0xFFEF9A82);
  static const Color danger400 = Color(0xFFDF7260);
  static const Color danger500 = Color(0xFFCB3A31); // ← main danger
  static const Color danger700 = Color(0xFF921825);
  static const Color danger900 = Color(0xFF610921);

  // ── Text (Matterhorn grey) ──
  // TODO: 600 and 800 missing — ask designer
  static const Color text100 = Color(0xFFFBFCFE);
  static const Color text200 = Color(0xFFEEF2F5);
  static const Color text300 = Color(0xFFBCC0D0);
  static const Color text400 = Color(0xFF8189A2);
  static const Color text500 = Color(0xFF5D5F61);
  static const Color text700 = Color(0xFF313131);
  static const Color text900 = Color(0xFF13131C);

  // ── Background (Whisper) ──
  // TODO: 600 and 800 missing — ask designer
  static const Color background100 = Color(0xFFF9F9F9);
  static const Color background200 = Color(0xFFF7F7F7);
  static const Color background300 = Color(0xFFF5F5F5);
  static const Color background400 = Color(0xFFF2F2F2);
  static const Color background500 = Color(0xFFEFEFEF);
  static const Color background700 = Color(0xFFEBEBEB);
  static const Color background900 = Color(0xFFE6E6E6);

  // TODO: 600 and 800 missing — ask designer
  // === Surface color palette ===
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surface50 = Color(0xFFF8FAF6);
  static const Color surface100 = Color(0xFFF1F5ED);
  static const Color surface200 = Color(0xFFE8EFE2);
  static const Color surface300 = Color(0xFFDCE7D4);
  static const Color surface400 = Color(0xFFC7D8BC);

  // ═══════════════════════════════════════════════════════════
  // LAYER 2 — DECISION TOKENS (use THESE in widgets)
  // ═══════════════════════════════════════════════════════════
  // Each points to the "right" palette shade.
  // Designer says "make body text a bit darker"?
  // Change ONE line here → whole app updates. 🎯

  // ── Brand ──
  static const Color brand = primary500;
  static const Color brandDark = primary700; // pressed / hover state
  static const Color brandSoft = primary100; // tinted backgrounds

  // ── Semantic (defaults = the 500 shade) ──
  static const Color success = success500;
  static const Color info = info500;
  static const Color warning = warning500;
  static const Color danger = danger500;
  static const Color error = danger500; // alias — use either

  // ── Text ──
  static const Color textPrimary = text900; // main body text
  static const Color textSecondary = text500; // hint / supporting
  static const Color textDisabled = text300; // placeholder / disabled
  static const Color textOnBrand = Color(0xFFFFFFFF); // text on green btn

  // ── Backgrounds & surfaces ──
  static const Color background = background100; // page
  static const Color surface = surface100; // cards
  static const Color surfaceAlt = surface300; // input fields / alt card
  static const Color cardBorder = background500; // subtle outline
  static const Color divider = background500; // horizontal lines
  static const Color skeleton = background300;

  static get brandPrimary => null; // loading shimmer
}
