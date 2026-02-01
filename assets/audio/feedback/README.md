# Feedback Audio Files

This directory contains UI feedback sounds for the piano app.

## Required Files

- `correct.mp3` - Success/correct note sound (0.3-0.5 seconds)
- `incorrect.mp3` - Error/incorrect note sound (0.3-0.5 seconds)

## Placeholder Files

The current files are placeholders. Please replace them with actual audio files:

### Recommended Sources

1. **Freesound.org**
   - Search for "success beep", "correct sound", "error beep"
   - Filter by CC0 license

2. **Generate with Online Tools**
   - https://sfxr.me/ - Generate retro game sounds
   - https://www.bfxr.net/ - Browser-based sound generator

3. **Use System Sounds**
   - macOS: /System/Library/Sounds/
   - Windows: C:\Windows\Media\

### Specifications

- **Format**: MP3
- **Duration**: 0.3-0.5 seconds
- **Sample Rate**: 44.1 kHz
- **File Size**: < 20KB each
- **Volume**: Normalized, not too loud

### Suggested Sounds

**Correct Sound:**
- Pleasant chime or bell
- Rising tone
- Positive "ding" sound

**Incorrect Sound:**
- Gentle buzz or beep
- Descending tone
- Soft "bonk" or "thud"

## Note

The app will gracefully handle missing feedback sounds - they are optional enhancements to the user experience.
