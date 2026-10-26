---
name: visual-regression-testing
description: Capture and review a FinoFarm scene frame. Use when lighting, meshes, camera, or materials change and someone needs proof of the picture.
---

# Visual regression testing

There is no pixel-diff tool yet. A capture plus a written comparison to `docs/art-bible.md` is the check. Do not invent a pass by skipping the capture.

## Steps

1. Run `bash tools/validate.sh` first so a broken scene is not photographed.
2. Capture with the tool script, which loads `first_farm.tscn`, advances the walker a short step, and writes a PNG:

```bash
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
```

3. If there is no GPU, set `DISPLAY` to the live X server and `LIBGL_ALWAYS_SOFTWARE=1`. llvmpipe is valid for "does it draw". It is not FF-8's GPU review.
4. Open the PNG. Confirm terrain, the building, the walker, and the control hint are visible. Confirm the walker is not a T-pose stuck in the ground.
5. Write down what is still placeholder. A pretty frame of primitive meshes is still placeholder art.
6. When a baseline is worth locking, store it outside the import cache and compare by eye or with a later diff tool. Do not commit a new baseline for every camera nudge.

## Example

Milestone 0 saved a llvmpipe frame after the sun energy was lowered from a pass that clipped grass to 255. The art bible records that lighting constraint. A future capture that is a white field fails the review even if `validate.sh` passed.

## Constraints

- `tools/capture_farm.gd` exits 2 when the viewport image is empty and 3 when `save_png` fails.
- ALSA errors on a headless VM are expected. Godot falls back to the dummy audio driver. Do not treat that as a render failure.
- Do not use `--headless` for the capture. The headless display driver does not draw this scene into a PNG.
- User args belong after `--`, as `--output=/absolute/path.png`.

## Validation

```bash
godot --path . --display-driver x11 --rendering-driver opengl3 \
  -s res://tools/capture_farm.gd -- --output=/tmp/finofarm-first-farm.png
file /tmp/finofarm-first-farm.png
```

The file command should report a PNG. Width and height in the script's log line should be `1280x720` at the default window size. Then look at the image.
