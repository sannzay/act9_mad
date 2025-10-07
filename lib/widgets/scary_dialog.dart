import 'package:flutter/material.dart';

class ScaryDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/jumpscare.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 16,
              top: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Phew!'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
