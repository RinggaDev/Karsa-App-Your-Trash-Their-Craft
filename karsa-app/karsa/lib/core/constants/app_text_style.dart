// lib/core/constant/app_text_style.dart
//
// All styles are now `const` → safe to use in const widgets, default
// parameter values, anywhere.
//
// ⚠️ Same notes as before:
//   - Spec name/weight mismatch preserved (Bold→w900, Semibold→w700)
//   - No line-height in spec → uses Satoshi's natural spacing
//   - letterSpacing 0% → Flutter default, not written
//
// Usage:
//   Text('Hello', style: AppTextStyle.display1Bold)
//   const Text('Hello', style: AppTextStyle.display1Bold)  // ✅ now works

import 'package:flutter/material.dart';

abstract final class AppTextStyle {
  static const String font = 'Satoshi';

  // ═══════════════ DISPLAY ═══════════════
  static const TextStyle display1Bold     = TextStyle(fontFamily: font, fontSize: 64, fontWeight: FontWeight.w900);
  static const TextStyle display1Semibold = TextStyle(fontFamily: font, fontSize: 64, fontWeight: FontWeight.w700);
  static const TextStyle display1Medium   = TextStyle(fontFamily: font, fontSize: 64, fontWeight: FontWeight.w500);
  static const TextStyle display1Regular  = TextStyle(fontFamily: font, fontSize: 64, fontWeight: FontWeight.w400);

  static const TextStyle display2Bold     = TextStyle(fontFamily: font, fontSize: 56, fontWeight: FontWeight.w900);
  static const TextStyle display2Semibold = TextStyle(fontFamily: font, fontSize: 56, fontWeight: FontWeight.w700);
  static const TextStyle display2Medium   = TextStyle(fontFamily: font, fontSize: 56, fontWeight: FontWeight.w500);
  static const TextStyle display2Regular  = TextStyle(fontFamily: font, fontSize: 56, fontWeight: FontWeight.w400);

  static const TextStyle display3Bold     = TextStyle(fontFamily: font, fontSize: 48, fontWeight: FontWeight.w900);
  static const TextStyle display3Semibold = TextStyle(fontFamily: font, fontSize: 48, fontWeight: FontWeight.w700);
  static const TextStyle display3Medium   = TextStyle(fontFamily: font, fontSize: 48, fontWeight: FontWeight.w500);
  static const TextStyle display3Regular  = TextStyle(fontFamily: font, fontSize: 48, fontWeight: FontWeight.w400);

  // ═══════════════ HEADING ═══════════════
  static const TextStyle heading1Bold     = TextStyle(fontFamily: font, fontSize: 40, fontWeight: FontWeight.w900);
  static const TextStyle heading1Semibold = TextStyle(fontFamily: font, fontSize: 40, fontWeight: FontWeight.w700);
  static const TextStyle heading1Medium   = TextStyle(fontFamily: font, fontSize: 40, fontWeight: FontWeight.w500);
  static const TextStyle heading1Regular  = TextStyle(fontFamily: font, fontSize: 40, fontWeight: FontWeight.w400);

  static const TextStyle heading2Bold     = TextStyle(fontFamily: font, fontSize: 32, fontWeight: FontWeight.w900);
  static const TextStyle heading2Semibold = TextStyle(fontFamily: font, fontSize: 32, fontWeight: FontWeight.w700);
  static const TextStyle heading2Medium   = TextStyle(fontFamily: font, fontSize: 32, fontWeight: FontWeight.w500);
  static const TextStyle heading2Regular  = TextStyle(fontFamily: font, fontSize: 32, fontWeight: FontWeight.w400);

  static const TextStyle heading3Bold     = TextStyle(fontFamily: font, fontSize: 28, fontWeight: FontWeight.w900);
  static const TextStyle heading3Semibold = TextStyle(fontFamily: font, fontSize: 28, fontWeight: FontWeight.w700);
  static const TextStyle heading3Medium   = TextStyle(fontFamily: font, fontSize: 28, fontWeight: FontWeight.w500);
  static const TextStyle heading3Regular  = TextStyle(fontFamily: font, fontSize: 28, fontWeight: FontWeight.w400);

  static const TextStyle heading4Bold     = TextStyle(fontFamily: font, fontSize: 24, fontWeight: FontWeight.w900);
  static const TextStyle heading4Semibold = TextStyle(fontFamily: font, fontSize: 24, fontWeight: FontWeight.w700);
  static const TextStyle heading4Medium   = TextStyle(fontFamily: font, fontSize: 24, fontWeight: FontWeight.w500);
  static const TextStyle heading4Regular  = TextStyle(fontFamily: font, fontSize: 24, fontWeight: FontWeight.w400);

  // ═══════════════ SUBHEADING ═══════════════
  static const TextStyle subheading1Bold     = TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w900);
  static const TextStyle subheading1Semibold = TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle subheading1Medium   = TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w500);
  static const TextStyle subheading1Regular  = TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w400);

  static const TextStyle subheading2Bold     = TextStyle(fontFamily: font, fontSize: 18, fontWeight: FontWeight.w900);
  static const TextStyle subheading2Semibold = TextStyle(fontFamily: font, fontSize: 18, fontWeight: FontWeight.w700);
  static const TextStyle subheading2Medium   = TextStyle(fontFamily: font, fontSize: 18, fontWeight: FontWeight.w500);
  static const TextStyle subheading2Regular  = TextStyle(fontFamily: font, fontSize: 18, fontWeight: FontWeight.w400);

  // ═══════════════ PARAGRAPH ═══════════════
  static const TextStyle paragraph1Bold     = TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w900);
  static const TextStyle paragraph1Semibold = TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w700);
  static const TextStyle paragraph1Medium   = TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle paragraph1Regular  = TextStyle(fontFamily: font, fontSize: 16, fontWeight: FontWeight.w400);

  static const TextStyle paragraph2Bold     = TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w900);
  static const TextStyle paragraph2Semibold = TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w700);
  static const TextStyle paragraph2Medium   = TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle paragraph2Regular  = TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w400);

  // ═══════════════ LABEL ═══════════════
  static const TextStyle label1Bold     = TextStyle(fontFamily: font, fontSize: 12, fontWeight: FontWeight.w900);
  static const TextStyle label1Semibold = TextStyle(fontFamily: font, fontSize: 12, fontWeight: FontWeight.w700);
  static const TextStyle label1Medium   = TextStyle(fontFamily: font, fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle label1Regular  = TextStyle(fontFamily: font, fontSize: 12, fontWeight: FontWeight.w400);

  static const TextStyle label2Bold     = TextStyle(fontFamily: font, fontSize: 10, fontWeight: FontWeight.w900);
  static const TextStyle label2Semibold = TextStyle(fontFamily: font, fontSize: 10, fontWeight: FontWeight.w700);
  static const TextStyle label2Medium   = TextStyle(fontFamily: font, fontSize: 10, fontWeight: FontWeight.w500);
  static const TextStyle label2Regular  = TextStyle(fontFamily: font, fontSize: 10, fontWeight: FontWeight.w400);

  static get label1SemiBold => null;
}