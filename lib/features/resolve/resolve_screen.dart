import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../services/gemini_service.dart';

class ResolveScreen extends ConsumerStatefulWidget {
  const ResolveScreen({super.key});

  @override
  ConsumerState<ResolveScreen> createState() => _ResolveScreenState();
}

class _ResolveScreenState extends ConsumerState<ResolveScreen> {
  bool _isLoading = true;
  String _resolveGuide = '';

  @override
  void initState() {
    super.initState();
    _loadResolveGuide();
  }

  Future<void> _loadResolveGuide() async {
    try {
      final guide = await ref.read(geminiServiceProvider).generateResolveGuide('circle_id', 45.0, []);
      setState(() {
        _resolveGuide = guide;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _resolveGuide = 'Failed to generate guide. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolve Mode')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Conflict Resolution Guide', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Text(_resolveGuide),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Finish'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
