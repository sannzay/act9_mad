import 'package:flutter/material.dart';
import 'services/audio_service.dart';
import 'painters/spooky_background_painter.dart';
import 'widgets/spooky_sprite.dart';
import 'widgets/scary_dialog.dart';

void main() {
  runApp(const SpooktacularApp());
}

class SpooktacularApp extends StatelessWidget {
  const SpooktacularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooktacular Storybook',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/story': (context) => const StoryPage(),
        '/win': (context) => const WinPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'pumpkin-hero',
                  child: Image.asset('assets/images/pumpkin.png',
                      width: 160, height: 160),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Spooktacular Storybook',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find the correct item (the candy). But watch out for traps!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start the Hunt'),
                  onPressed: () async {
                    await AudioService.playBackground();
                    Navigator.of(context).pushNamed('/story');
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await AudioService.playSfx('success.mp3');
                  },
                  child: const Text(''),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoryPage extends StatefulWidget {
  const StoryPage({super.key});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage>
    with TickerProviderStateMixin {
  late final AnimationController _batController;

  @override
  void initState() {
    super.initState();
    _batController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _batController.dispose();
    AudioService.stopBackground();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final spawnPoints = [
            Offset(0.15, 0.25), // Top left - Ghost (trap)
            Offset(0.85, 0.20), // Top right - Bat (trap)  
            Offset(0.50, 0.50), // Center - Candy (target)
            Offset(0.20, 0.75), // Bottom left - Ghost (trap)
            Offset(0.80, 0.80), // Bottom right - Pumpkin (trap)
          ];

          final List<Map<String, dynamic>> spriteConfigs = [
            {'image': 'assets/images/ghost.png', 'isTrap': true},
            {'image': 'assets/images/bat.png', 'isTrap': true},
            {'image': 'assets/images/candy.png', 'isTrap': false, 'isTarget': true},
            {'image': 'assets/images/ghost.png', 'isTrap': true},
            {'image': 'assets/images/pumpkin.png', 'isTrap': true},
          ];

          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _batController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter:
                          SpookyBackgroundPainter(progress: _batController.value),
                    );
                  },
                ),
              ),

              Positioned(
                left: 12,
                top: 12,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              for (var i = 0; i < spriteConfigs.length; i++)
                SpookySprite(
                  key: ValueKey('sprite-$i'),
                  imageAsset: spriteConfigs[i]['image'] as String,
                  basePos: spawnPoints[i],
                  baseSize: (spriteConfigs[i]['isTarget'] == true) ? 84.0 : 64.0,
                  isTrap: spriteConfigs[i]['isTrap'] as bool,
                  isTarget: spriteConfigs[i]['isTarget'] == true,
                  onFoundTarget: () async {
                    await AudioService.playSfx('success.mp3');
                    if (!mounted) return;
                    Navigator.of(context).pushReplacementNamed('/win');
                  },
                  onTriggeredTrap: () async {
                    await AudioService.playSfx('jumpscare.mp3');
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => ScaryDialog(),
                    );
                  },
                ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            'Close you eyes and find the glowing candy!',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.music_note, size: 16),
                        label: const Text('Mute', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: () async {
                          await AudioService.stopBackground();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class WinPage extends StatelessWidget {
  const WinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'pumpkin-hero',
                child: Image.asset('assets/images/candy.png',
                    width: 160, height: 160),
              ),
              const SizedBox(height: 24),
              const Text('You Found It!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Trick or treat — you win!'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                child: const Text('Play Again'),
              )
            ],
          ),
        ),
      ),
    );
  }
}