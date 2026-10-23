// Logo animé : il respire en continu, sauf en animations réduites.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maketpeyizan/shared/widgets/logo_anime.dart';

void main() {
  testWidgets('le logo est animé en continu', (tester) async {
    await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: LogoAnime(taille: 100))));
    await tester.pump(const Duration(seconds: 10));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('immobile si le téléphone demande moins d\'animations', (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: LogoAnime(taille: 100))),
    ));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
