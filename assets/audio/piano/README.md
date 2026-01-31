# Piano Audio Assets

This directory should contain piano note audio files for the interactive keyboard.

## Required Files

### Octave 4 (Middle C)
- `C4.mp3` - Middle C
- `C#4.mp3` - C Sharp
- `D4.mp3` - D
- `D#4.mp3` - D Sharp
- `E4.mp3` - E
- `F4.mp3` - F
- `F#4.mp3` - F Sharp
- `G4.mp3` - G
- `G#4.mp3` - G Sharp
- `A4.mp3` - A (440 Hz)
- `A#4.mp3` - A Sharp
- `B4.mp3` - B

### Octave 5
- `C5.mp3` - C
- `C#5.mp3` - C Sharp
- `D5.mp3` - D
- `D#5.mp3` - D Sharp
- `E5.mp3` - E
- `F5.mp3` - F
- `F#5.mp3` - F Sharp
- `G5.mp3` - G
- `G#5.mp3` - G Sharp
- `A5.mp3` - A
- `A#5.mp3` - A Sharp
- `B5.mp3` - B

## Where to Get Piano Samples

### Free Resources
1. **Freesound.org** - https://freesound.org/
   - Search for "piano note C4", "piano note D4", etc.
   - Filter by license (CC0 or CC-BY)

2. **SampleSwap** - https://sampleswap.org/
   - Navigate to Instruments > Piano
   - Download individual notes

3. **University of Iowa Electronic Music Studios**
   - http://theremin.music.uiowa.edu/MIS.html
   - Professional quality piano samples

4. **Philharmonia Orchestra Sound Samples**
   - https://philharmonia.co.uk/resources/sound-samples/
   - High-quality instrument samples

### Alternative: Use Flutter MIDI
Instead of audio files, you can use the `flutter_midi` package to synthesize piano sounds:
```yaml
dependencies:
  flutter_midi: ^1.0.0
```

## File Format
- **Format**: MP3 or WAV
- **Sample Rate**: 44.1 kHz recommended
- **Bit Depth**: 16-bit minimum
- **Duration**: 2-4 seconds (with natural decay)
- **File Size**: Keep under 100KB per file for optimal performance

## Notes
- Ensure all files are named exactly as listed above
- Files should be mono or stereo
- Normalize volume levels across all samples
- Include natural piano decay (don't cut off abruptly)
