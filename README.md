# FinoFarm

Stylized 3D farming and business simulation, built in Godot 4.7 with GDScript.

The game opens on a 3D main menu. New Game asks for a farm name and one of four fictional regions, then loads that farm. The farm has a modeled barn, a rigged character with a walk cycle, a camera that pans, zooms, and orbits, and one grid marker. Production rules in code are fictional timers, grades, and recipes. They are not a cultivation guide.

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
- Left-click places or moves one plot marker. X removes it. Esc saves and returns to the menu.

## Validate

```bash
bash tools/validate.sh
```

That imports the project headless, parses every gameplay script with `--check-only`, and runs the simulation, region, save, placement, and scene checks. The same command is the GitHub Actions job in `.github/workflows/validate.yml`.

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

## Environment bootstrap

`.cursor/install.sh` is the cloud-agent install. It pins Godot 4.7.2 standard (GDScript, not .NET), Blender 5.2.3, and Git LFS. Do not remove it. Large binary art (`glb`, `png`, `blend`, audio) is marked for Git LFS in `.gitattributes`. No LFS objects are committed yet.

The barn and the farmhand are in-engine models, not approved final art. Terrain, trees, and the plot marker are still placeholders. See the art bible before calling any of them finished art.
