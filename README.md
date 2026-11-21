# Loʻi Kalo — playable prototype (Godot 4.7)

A co-op, Overcooked-style level set in a loʻi kalo. All art is placeholder shapes built in code.

## Play it

**In Godot:** open `project.godot` in Godot 4.7 and press **F5**.

**In a browser:** export (Project → Export → Web), or from a terminal in this folder:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/web/index.html
```

```bash
cd build/web && python3 -m http.server 8060
```

Then open http://localhost:8060. The export uses the no-threads web template, so it runs on any static host with no special headers.

## Controls

| | Move | Grab / place | Hold to work | Dash |
|---|---|---|---|---|
| Player 1 | WASD or arrows | E | Q or F | Space |
| Player 2 (press O to join) | IJKL | O | U or H | Enter |
| Gamepad | Left stick | A | X | B |

G opens the glossary of Hawaiian words. Esc pauses. R replays from the end screen.

## The level

Four minutes. Feed the ʻohana at the ʻaha ʻāina and keep the ʻāina healthy.

**Areas, from mauka (mountains) to makai (sea)**
- **Kahawai and poʻo wai:** the stream along the west edge, and the diversion gate where water enters the ʻauwai.
- **ʻAuwai:** a ditch that feeds three loʻi terraces stepping downhill. Water flows from loʻi to loʻi and back into the kahawai.
- **Loʻi 1–3:** nine planting spots. Mud slows you down.
- **Hale area:** the imu, the papa kuʻi ʻai, the wai (water) stand, the ʻumeke table, the kī (ti) plants, side tables and Tūtū.
- **ʻAha ʻāina:** where orders are served.

**Recipes** (each unlocks over time and is shown on the order cards)
- **Poi:** harvest kalo → cook in the imu → pound on the papa (uses wai) → mix with wai at the ʻumeke.
- **Lūʻau:** pick lau (leaves) from a half-grown kalo → cook in the imu.
- **Paʻiʻai in lāʻī:** cooked kalo → pound → wrap at the kī plants.

**Teaching through the rules**
- **Huli loop:** harvesting leaves a huli behind, and you must replant it. The huli pile starts with only 2.
- **Raw kalo is refused** at the papa ("maneʻo", itchy). It must be cooked first.
- **Water has to keep moving.** Plants grow only while water flows. Still water turns murky and growth nearly stops.
- **Sharing water.** Hold work at the poʻo wai to *take ALL the water*. Kalo grows 40% faster, but the kahawai below dries up, the ʻoʻopu disappear, the ʻāina health bar falls, and the upper ipu-filling spot stops working.
- **ʻŌpala** (debris) randomly blocks the ʻauwai. Clear it to restore flow.
- **Mauʻu** (weeds) pop up and stop growth until pulled.
- **Floods** (around 1:35 and 3:05): a 12-second warning to close the poʻo wai. Leave it open and a kuāuna (bank) breaks, the loʻi drains, and someone has to rebuild it.
- **Co-op:** two players pounding or rebuilding at once work twice as fast. One player running ipu from the stream while another cooks is the natural split.
- **Score:** order points plus an ʻāina health bonus. A greedy, high-speed run can earn fewer stars than a careful one.
- **Tūtū:** talk to her for short moʻolelo and facts. Contextual tips appear the first time each thing happens.

## Files

- `scripts/main.gd`: terrain, water, level layout, rules (flow, floods, health, orders) and HUD. **Tuning numbers are at the top.**
- `scripts/station.gd`: every interactive spot, one `kind` each.
- `scripts/player.gd`: movement, targeting and prompts.
- `scripts/item.gd`: carryable items.
- `tests/selftest.gd`: headless smoke test of every chain. Run it with:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s tests/selftest.gd
```

- `CONTENT_REVIEW.md`: every cultural or educational statement in the game, for advisor review.
- `fonts/`: Montserrat (SIL OFL). Godot's built-in web font cannot display the ʻokina.

## Next steps for real art

Replace the placeholder meshes in `station.gd` and `item.gd` with `.glb` models from Blender. Each visual is built in one `_build_*` function or one `match` branch, so you can swap them one at a time.
