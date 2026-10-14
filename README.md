# Freestyle Frenzy

A freestyle rap practice game for Roblox, inspired by The Rhyme Game.
A beat plays, a ball bounces on every beat, and rhyme words land on beat 4
of each bar (couplets, AABB).

## Option A: Insert files (easiest, no Rojo)

The `studio-import/` folder has ready-made model files:

1. In Studio's Explorer, right-click **ReplicatedStorage** → **Insert from File…** →
   pick `studio-import/ReplicatedStorage_Items.rbxmx`.
2. Right-click **StarterPlayer › StarterPlayerScripts** → **Insert from File…** →
   pick `studio-import/StarterPlayerScripts_Items.rbxmx`.
3. Press **Play**.

When a new version comes out, delete the old `Beats`, `FreestyleModules` and
`FreestyleClient` first, then insert the new files.
(Maintainers: rebuild these with `python3 tools/build-studio-import.py`.)

## Option B: Live sync with Rojo

The code lives on GitHub, so it must be on your computer first:
download this branch as a ZIP from GitHub (Code → Download ZIP) or `git clone` it.

1. Install Rojo: the **Rojo** plugin in Roblox Studio (Plugins tab → search "Rojo"
   in the Creator Store) and the Rojo CLI (`aftman add rojo-rbx/rojo@7.4.4`, or
   download from https://github.com/rojo-rbx/rojo/releases).
2. In this folder run: `rojo serve`
3. In Studio, open your place → Plugins → Rojo → **Connect**.
4. Press **Play**.

Rojo only manages the items listed below; it leaves the rest of your place alone.

## Where things go

| File | In Studio |
| --- | --- |
| `src/ReplicatedStorage/Beats.luau` | ReplicatedStorage › Beats (ModuleScript) |
| `src/ReplicatedStorage/FreestyleModules/` | ReplicatedStorage › FreestyleModules (Folder of ModuleScripts) |
| `src/StarterPlayerScripts/FreestyleClient.client.luau` | StarterPlayer › StarterPlayerScripts › FreestyleClient (LocalScript) |

## Tuning a beat's timing

Open `Beats.luau`. For each beat:
- `BPM` – tempo of the track.
- `FirstBeatOffset` – seconds from the start of the audio to the first downbeat.
  Ball feels **early** → increase it. Ball feels **late** → decrease it.
