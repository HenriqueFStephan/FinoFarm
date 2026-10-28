---
name: gameplay-flows
description: Trace a FinoFarm player path from the main menu through automation. Use when adding a step to the core loop, drawing the flow, or checking that a new building still sits on the supply chain.
---

# Gameplay flows

The committed picture of the loop is `docs/flows/core-loop.md`. The rendered diagram is `docs/flows/core-loop.svg`. Rules stay in `scripts/simulation/`. The diagram names the path the player walks. It does not replace the catalog.

## Steps

1. Read `docs/flows/core-loop.md` and `docs/game-design.md` before adding a step.
2. Keep the order Main Menu, region, tutorial, plant, harvest, workshop, second building, order, upgrade, crew, automation. A new step is inserted where the player actually meets it, and both the mermaid source and the SVG are updated in the same change.
3. The second building consumes the workshop's output. Do not let a harvest skip that bench.
4. Research choices stay on separate branches. Buying one does not grant the other. The tutorial stays a hand start.
5. Render the mermaid block to `docs/flows/core-loop.svg` with a real renderer. A hand-drawn substitute is not the diagram.
6. If the picture of the farm changes, capture a frame with `tools/capture_farm.gd` and compare it to `docs/art-bible.md`. First-pass meshes stay labeled first-pass.

## Example

The packing bench is the second building. `wrap_bundle` takes one Fiber Bundle. The crate order pays only after the packing line is owned. The loom rule is the other research branch and still starts Fiber Bundle or Fiber Cord from a ready plot.

## Constraints

- Fictional goods only. No real cultivation, extraction, dosage, or controlled-substance method.
- Do not rewrite `docs/charter.md` to match a slice. The charter stays the vision.
- Mara's step order stays place, grow, harvest, workshop, bundle, order, loft, done. Later systems wait until `done`.
- Schema stays `1` unless a task explicitly versions it. Old saves that omit a new key still load.

## Validation

```bash
bash tools/validate.sh
```

The supply suite must print `7 passed, 0 failed` and the scene check must still find `PackingBench`, `PackingClerk`, and `CuePlayer`.
