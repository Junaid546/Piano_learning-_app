import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../piano/widgets/piano_keyboard.dart';
import '../piano/models/note.dart';

class PianoTestScreen extends StatefulWidget {
  const PianoTestScreen({super.key});

  @override
  State<PianoTestScreen> createState() => _PianoTestScreenState();
}

class _PianoTestScreenState extends State<PianoTestScreen> {
  Note? _lastPlayedNote;
  bool _showLabels = true;
  bool _enableSound = true;
  int _numberOfOctaves = 1;
  final List<Note> _highlightedNotes = [];

  void _handleNotePlayed(Note note) {
    setState(() {
      _lastPlayedNote = note;
    });
  }

  void _toggleHighlight(Note note) {
    setState(() {
      if (_highlightedNotes.contains(note)) {
        _highlightedNotes.remove(note);
      } else {
        _highlightedNotes.add(note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Piano Keyboard Demo'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info Panel
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Piano Keyboard',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _lastPlayedNote != null
                      ? 'Last played: ${_lastPlayedNote!.fullName} (${_lastPlayedNote!.frequency.toStringAsFixed(2)} Hz)'
                      : 'Tap any key to play',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                // Controls
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _showLabels,
                          onChanged: (value) {
                            setState(() => _showLabels = value ?? true);
                          },
                        ),
                        const Text('Show Labels'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _enableSound,
                          onChanged: (value) {
                            setState(() => _enableSound = value ?? true);
                          },
                        ),
                        const Text('Enable Sound'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Octaves: '),
                        DropdownButton<int>(
                          value: _numberOfOctaves,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1')),
                            DropdownMenuItem(value: 2, child: Text('2')),
                          ],
                          onChanged: (value) {
                            setState(() => _numberOfOctaves = value ?? 1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Highlight Notes:',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildNoteChip(Note.c4),
                    _buildNoteChip(Note.e4),
                    _buildNoteChip(Note.g4),
                    _buildNoteChip(Note.a4),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Piano Keyboard
          PianoKeyboard(
            numberOfOctaves: _numberOfOctaves,
            showLabels: _showLabels,
            highlightedNotes: _highlightedNotes.isEmpty
                ? null
                : _highlightedNotes,
            onNotePlayed: _handleNotePlayed,
            enableSound: _enableSound,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteChip(Note note) {
    final isHighlighted = _highlightedNotes.contains(note);
    return FilterChip(
      label: Text(note.fullName),
      selected: isHighlighted,
      onSelected: (_) => _toggleHighlight(note),
      selectedColor: AppColors.primaryPurple.withOpacity(0.3),
    );
  }
}
