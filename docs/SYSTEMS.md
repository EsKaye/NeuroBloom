# Core Systems Documentation

This document provides detailed information about the core systems in NeuroBloom.

## Plant System

### Overview
The plant system is the heart of NeuroBloom, allowing players to cultivate emotional plants that respond to their feelings and actions.

### Components

#### PlantVisuals Module
- **Location**: `ServerScriptService/Modules/PlantVisuals.lua`
- **Purpose**: Handles visual representation of plants
- **Features**:
  - Growth stage animations
  - Emotional state visualization
  - Particle effects
  - Bioluminescence

#### Plant Types
1. **Joy Plants**
   - Bright, vibrant colors
   - Upward growth patterns
   - Gentle particle effects

2. **Grief Plants**
   - Deep, rich colors
   - Flowing, downward patterns
   - Soft, misty particles

3. **Hope Plants**
   - Light, airy appearance
   - Spiral growth patterns
   - Sparkling effects

### Growth Mechanics
- **Stages**:
  1. Seed
  2. Sprout
  3. Bud
  4. Bloom
  5. Mature

- **Growth Factors**:
  - Emotional input
  - Ritual completion
  - Time spent
  - Environmental conditions

## Sound System

### Overview
The sound system provides an immersive audio experience that adapts to the player's actions and emotional state.

### Components

#### SoundSystem Module
- **Location**: `ServerScriptService/Modules/SoundSystem.lua`
- **Purpose**: Manages all game audio
- **Features**:
  - Dynamic music system
  - Ambient soundscapes
  - Interactive sound effects
  - Volume controls

#### Sound Categories
1. **Ambient Sounds**
   - Biome-specific backgrounds
   - Weather effects
   - Environmental sounds

2. **Music**
   - Dynamic soundtrack
   - Emotional themes
   - Transition effects

3. **Effects**
   - Plant interactions
   - Ritual sounds
   - UI feedback

### Volume Control
- Master volume
- Music volume
- Ambient volume
- Effects volume

## Ritual System

### Overview
The ritual system provides structured emotional exercises and interactions with the garden.

### Components

#### GardenRituals Module
- **Location**: `ServerScriptService/Modules/GardenRituals.lua`
- **Purpose**: Manages ritual mechanics
- **Features**:
  - Guided exercises
  - Progress tracking
  - Emotional input
  - Visual feedback

#### Ritual Types
1. **Breathing Ritual**
   - Guided breathing exercises
   - Visual feedback
   - Sound integration

2. **Whisper Ritual**
   - Plant communication
   - Emotional sharing
   - Memory creation

### UI Integration
- Progress tracking
- Visual guides
- Emotional input
- Completion rewards

## Settings System

### Overview
The settings system provides user control over various game aspects.

### Components

#### SettingsUI Module
- **Location**: `StarterGui/SettingsUI.lua`
- **Purpose**: Manages user preferences
- **Features**:
  - Sound controls
  - Graphics settings
  - Accessibility options
  - User preferences

#### Settings Categories
1. **Audio Settings**
   - Volume controls
   - Sound categories
   - Mute options

2. **Graphics Settings**
   - Quality levels
   - Visual effects
   - Performance options

3. **Accessibility**
   - Subtitles
   - Color options
   - Input preferences

## Resonance Warfare System

### Overview
Allows players to engage in battles driven by emotional resonance.

### Components
- **ResonanceWarfareSystem Module**
- Battle initiation events
- Winner calculation based on emotions

## Garden Expansion System

### Overview
Expands the playable garden with new plots and special features.

### Components
- **GardenExpansionSystem Module**
- Expansion history tracking
- Visual updates through `GardenScene`

## Grand Theft Lux Integration System

### Overview
Bridges lux heist mechanics with Grand Theft Lux.

### Components
- **GrandTheftLuxIntegration Module**
- Remote events `StartLuxHeist` and `CompleteLuxHeist`

## Technical Implementation

### Service Structure
```
ServerScriptService/
├── Modules/
│   ├── PlantVisuals.lua
│   ├── SoundSystem.lua
│   └── GardenRituals.lua
├── init.server.lua
└── GardenScene.lua

StarterGui/
├── MainMenu.lua
├── RitualUI.lua
└── SettingsUI.lua

StarterPlayerScripts/
└── init.client.lua
```

### Module Dependencies
- PlantVisuals → SoundSystem
- GardenRituals → PlantVisuals
- SettingsUI → SoundSystem

### Event System
- Plant growth events
- Ritual completion events
- Settings change events
- Emotional state events

## Performance Considerations

### Optimization
- Particle effect limits
- Sound instance management
- UI element pooling
- Event connection cleanup

### Memory Management
- Asset loading/unloading
- Instance cleanup
- Event disconnection
- Cache management

## Security

### Data Protection
- Player data encryption
- Secure communication
- Access control
- Input validation

### Anti-Exploit
- Script injection prevention
- Resource protection
- Rate limiting
- Validation checks

## Future Development

### Planned Features
- Advanced plant genetics
- More ritual types
- Enhanced sound system
- Additional biomes

### Technical Improvements
- Performance optimization
- Memory management
- Network efficiency
- Code modularity 