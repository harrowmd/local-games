# Local Games

A small Godot 4 framework for "guide the local mascot home" games, built
around real towns and real local trivia. The first game is **The Dorking
Squirrel**.

## Running it

Open the project in Godot 4 (4.7+, GDScript) and press Play, or:

```
godot-4 --path . res://games/dorking_squirrel/opening.tscn
```

Controls: swipe (touch) or click-drag (mouse) to move. Walk into a
landmark to get a clue question; answer correctly to calm the squirrel
down and gain an acorn. Collect enough acorns, then walk into the home
marker to win. Letting the fear meter fill up ends the run.

## TODO

- Sound effects (fox hit/explosion, squirrel caught, acorn pickup, quiz
  correct/wrong, footsteps) -- not added yet, visuals only for now.

## The Dorking Squirrel

The famous albino Dorking Squirrel is loose in Dorking. You're the
wildlife ranger guiding it through town -- past Box Hill, St Paul's
Church, the High Street, Denbies Wine Estate, both Dorking stations,
Dorking Halls, the Museum, Sainsbury's, Fat Face, and the tennis club --
back home to Presselly, Deepdene Avenue (RH4 1ST).

The opening screen shows today's date/time and live local weather
(fetched from the free [Open-Meteo](https://open-meteo.com) API, no key
needed) with a matching placeholder photo.

All art in `games/dorking_squirrel/assets/` is **programmatically
generated placeholder art** (see `tools/gen_placeholder_art.py`) so the
game is playable end to end. Swap in real photos/sprites later -- the
filenames are the contract core/ code reads from.

The trivia in `games/dorking_squirrel/data/landmarks.json` was
pre-written from general/Wikipedia-level knowledge of Dorking. Worth a
fact-check pass before sharing widely.

## Architecture: how to add another town

Nothing in `core/` mentions Dorking, squirrels, or any other town --
everything town-specific is data:

```
core/                      <- reusable framework, never edit per-town
  data/TownData.gd         <- town config: map, weather coords, photos, icons, difficulty
  data/ProtagonistData.gd  <- the controllable mascot: sprite, speed, name
  autoload/GameManager.gd  <- fear meter / acorn count / win-lose state
  autoload/WeatherService.gd
  game/                    <- PlayerController, LandmarkMarker, AcornPickup, HomeMarker
  ui/                      <- OpeningScreen, HUD, CluePopup
  scenes/MainGame.gd       <- spawns landmarks/acorns from a town's JSON

games/<your_town>/         <- one folder per game
  town_data.tres           <- instance of TownData, points at your assets/data
  protagonist_data.tres    <- instance of ProtagonistData
  data/landmarks.json      <- landmarks (with quiz Q&A) + acorn trail points
  assets/                  <- map_background.png, sprite, icons, weather photos
  opening.tscn             <- thin: instances core/ui/OpeningScreen.tscn, sets town/protagonist/next_scene
  main.tscn                <- thin: instances core/scenes/MainGame.tscn, sets town/protagonist
```

To build a new town game:

1. Copy the `games/dorking_squirrel/` folder structure.
2. Run `tools/gen_placeholder_art.py <new_assets_dir>` (or drop in real
   art using the same filenames) to get a map, mascot sprite, pin/acorn/
   home icons, and weather-condition photos.
3. Write `data/landmarks.json` with that town's landmarks, one quiz
   question each, and a list of acorn-trail points.
4. Fill in `town_data.tres` (map size, start/home positions, weather
   lat/lon, difficulty) and `protagonist_data.tres` (new mascot sprite,
   speed).
5. Copy `opening.tscn` / `main.tscn`, pointing the `town`/`protagonist`
   exports at your new `.tres` files.
6. Point `run/main_scene` in `project.godot` at the new `opening.tscn`
   (or just open it directly to test both games side by side).
