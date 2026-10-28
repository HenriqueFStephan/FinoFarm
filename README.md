# FinoFarm

Stylized 3D farming and business simulation, built in Godot 4.7 with GDScript.

The game opens on a 3D main menu. New Game asks for a farm name and one of four fictional regions, then loads that farm. The farm has a modeled barn, a rigged character with a walk cycle, a camera that pans, zooms, and orbits, and one grid plot. Placing the plot starts Verdant Fiber on a timer. The player harvests it, bundles it in the workshop, delivers one order, and buys a barn loft. Recipes are fictional timers and grades. They are not a cultivation guide.

## Play on your machine

Henrique Ferreira Stephan can run the game locally from the default `main` branch:

1. Clone the repository. `main` is the default branch and already contains the game.

   ```bash
   git clone https://github.com/HenriqueFStephan/FinoFarm
   cd FinoFarm
   ```

2. Install Git LFS hooks and download the art files:

   ```bash
   git lfs install && git lfs pull
   ```

3. Install Godot 4.7.2 standard (GDScript, not .NET) from https://godotengine.org/download/archive/4.7.2-stable/

4. Open the project folder in Godot (the folder that contains `project.godot`) and press Play (F5). The main scene is the main menu (`res://scenes/menu/main_menu.tscn`).

5. The farm already shows its controls: place a plot, use the workshop, open the order board, hire crew, and pan, zoom, or orbit the camera.

## Run

```bash
bash .cursor/install.sh
godot --path .
```

From the menu: Continue, My Farms, New Game, Settings, Credits, Exit. Continue stays off until a farm exists.

Controls in the farm scene:

- Right-drag, or Q / E, orbits the camera. R / F changes pitch.
- Middle-drag, or WASD / arrow keys, pans.
- Mouse wheel, or + / -, zooms.
- Left-click places or moves one fiber plot. Click the workshop shed to bundle. The order board and the loft button follow the on-screen steps. X removes the plot. Esc saves and returns to the menu.

## Validate

```bash
bash tools/validate.sh
```

That imports the project headless, parses every gameplay script with `--check-only`, and runs the simulation, region, save, placement, economy, staff, priority, automation, supply, and scene checks. The same command is the GitHub Actions job in `.github/workflows/validate.yml`.

## Desktop export

```bash
bash tools/export_desktop.sh
```

That writes a Linux binary at `builds/linux/FinoFarm.x86_64`. The script downloads the official Godot 4.7.2 export templates when `linux_release.x86_64` is missing, checks the published checksum, and exports the `Linux` preset. `builds/` is gitignored. This is a desktop build. It is not an HTML5 export.

Capture one frame when visuals change (needs a display; software GL is fine):

```bash
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
```

## Docs

- [Charter](docs/charter.md)
- [Game design](docs/game-design.md)
- [Art bible](docs/art-bible.md)
- [Architecture](docs/architecture.md)
- [Roadmap](docs/roadmap.md)
- [Asset registry](docs/asset-registry.md)
- [Interface contracts](docs/interface-contracts.md)
- [Testing strategy](docs/testing-strategy.md)
- [Milestone 1 vertical slice](docs/vertical-slice-m1.md)
- [Backlog](docs/backlog.md)
- [Core loop](docs/flows/core-loop.md)

## Environment bootstrap

`.cursor/install.sh` is the cloud-agent install. It pins Godot 4.7.2 standard (GDScript, not .NET), Blender 5.2.3, and Git LFS. Do not remove it. Large binary art (`glb`, `png`, `blend`, audio) is marked for Git LFS in `.gitattributes`. The glTF models are stored with Git LFS.

The barn, the farmhand, the grove trees, the workshop shed, the plot marker, the packing bench, and the packing clerk are in-engine models, not approved final art. Terrain, the fiber plot, the barn loft, and the shuttle rack are still placeholders. Harvest, loom, and delivery sounds are generated tones. See the art bible before calling any of them finished art.
