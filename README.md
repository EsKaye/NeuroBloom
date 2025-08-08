# NeuroBloom: Ritual Garden 🌸

A sensory-emotive simulation game where players cultivate a garden reflecting their emotions. Built in Roblox Studio.

## 🔮 VRChat Refactor

The project now includes an experimental Unity scaffold for a future VRChat version. A minimal UdonSharp script (`GeminiOrb.cs`) lives under `Assets/GameDinVR/Scripts`, and `vpm-manifest.json` defines the VRChat Creator Companion dependencies. Backend and Discord bridge work references our [Serafina](https://github.com/mkworldwide/serafina), [shadow-nexus](https://github.com/mkworldwide/shadow-nexus), and [AthenaCore](https://github.com/mkworldwide/athenacore) repositories.

### ShadowFlower Council Proof-of-Concept

Unity now contains a lightweight ops bus and three guardian examples—`Athena`, `Serafina`, and `ShadowFlowers`—under
`Assets/GameDinVR/Scripts`. Each guardian listens for in‑world whispers routed through `LilybearController`, giving us a
foundation for VRChat <-> Discord message bridging. A placeholder `OSCTextBridge` is included for future external text updates
via OSC.

Companion Node scripts in `serafina/src` provide a Discord bot with a nightly "council report" and a `/council report now`
slash command for manual triggering. Messages in the council channel prefixed with `!` (e.g. `!athena status`) are relayed to
the VR world via an MCP `/osc` endpoint, letting in‑world guardians react. Environment variables live in `.env.example`.

### VRChat Setup

1. Install the [VRChat Creator Companion](https://vcc.docs.vrchat.com/) and Unity 2022.3 LTS.
2. Run `git lfs install` to enable Git LFS for large assets.
3. Open this folder as a project in VCC; dependencies from `vpm-manifest.json` will auto-install.
4. Load `Assets/GameDinVR` in Unity, add the `GeminiOrb` script to a GameObject, then build and publish a test world.

## 🌟 Features

- **Emotional Garden System**: Cultivate plants that reflect and respond to your emotional state
- **Dynamic Biomes**: Three unique biomes (LightMeadow, ShadowGarden, VoidBasin) with distinct atmospheres
- **Ritual System**: Engage in meaningful rituals to nurture your garden and emotional well-being
- **Sound Design**: Immersive audio system with dynamic music and ambient soundscapes
- **Accessibility**: Comprehensive settings for sound, graphics, and accessibility options

## 🚀 Getting Started

### Prerequisites

- Roblox Studio (Latest Version)
- Basic understanding of Roblox development

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/NeuroBloom.git
```

2. Open Roblox Studio and create a new place

3. Import the project files:
   - Copy the contents of `src/roblox` into your Roblox place
   - Ensure the folder structure matches the source

4. Configure the project:
   - Set up the necessary services in Roblox Studio
   - Configure any required settings in the Settings UI

## 📁 Project Structure

```
src/
├── roblox/
│   ├── ServerScriptService/
│   │   ├── Modules/
│   │   │   ├── PlantVisuals.lua
│   │   │   ├── SoundSystem.lua
│   │   │   └── GardenRituals.lua
│   │   ├── init.server.lua
│   │   └── GardenScene.lua
│   ├── StarterGui/
│   │   ├── MainMenu.lua
│   │   ├── RitualUI.lua
│   │   └── SettingsUI.lua
│   └── StarterPlayerScripts/
│       └── init.client.lua
```

## 🎮 Game Systems

### Plant System
- Emotional plant growth and interaction
- Dynamic visual effects and animations
- Plant memory system

### Sound System
- Dynamic music system
- Ambient soundscapes
- Interactive sound effects
- Volume controls and settings

### Ritual System
- Guided emotional exercises
- Visual and audio feedback
- Progress tracking

### Settings System
- Sound controls
- Graphics quality settings
- Accessibility options
- User preferences

## 🛠️ Development

### Adding New Features

1. Create your feature branch:
```bash
git checkout -b feature/AmazingFeature
```

2. Commit your changes:
```bash
git commit -m 'Add some AmazingFeature'
```

3. Push to the branch:
```bash
git push origin feature/AmazingFeature
```

### Code Style

- Follow Roblox Lua style guidelines
- Use descriptive variable and function names
- Include comments for complex logic
- Maintain consistent indentation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Roblox Studio team for the development platform
- All contributors who have helped shape this project

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Made with 💖 by the NeuroBloom team 