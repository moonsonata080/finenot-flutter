import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RaccoonMascot extends StatelessWidget {
  const RaccoonMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: FutureBuilder(
        future: _tryLoadLottie(context),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done && (snap.data ?? false)) {
            return Lottie.asset('assets/lottie/raccoon.json', repeat: true);
          }
          // Fallback — эмодзи
          return const Center(child: Text('🦝', style: TextStyle(fontSize: 48)));
        },
      ),
    );
  }

  Future<bool> _tryLoadLottie(BuildContext context) async {
    try {
      await DefaultAssetBundle.of(context).loadString('assets/lottie/raccoon.json');
      return true;
    } catch (_) {
      return false;
    }
  }
}
