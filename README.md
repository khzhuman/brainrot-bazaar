<!-- One job: explain how to play, build, and hand in the official recorded Brainrot Bazaar game. -->
# BRAINROT BAZAAR

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/khzhuman/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/khzhuman/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

A sunny 3D seaside boardwalk where deeply unserious investments print serious money. Twelve part-built brainrots parade past striped stalls; six players each get a safe base with eight collection pads.

Start with **$100**. Touch a parading creature to buy it, or use its proximity prompt to see the price. Carry one creature above your head, then touch a free glowing pad at your own base. Placed creatures pay every second. The big gumball machine sells five rarity bands of random eggs. Every purchase or hatch can roll Golden x5 (10%), Diamond x10 (3%), or Void x25 (0.5%).

Pads 1–4 start open. Pads 5–8 unlock when your cash has reached $1,000, $10,000, $100,000, and $1,000,000 during the current run. Touch your base's lock button to spend $250 on a 60-second shield. A masked raccoon arrives roughly every 150 seconds to steal the lowest-rate printer from an unshielded base; intercept it to drop a free, recoverable pickup.

Every 180 seconds, a tsunami warning gives you ten seconds to get inside any base's safe zone. The wave sweeps the lane and plaza, removes unsafe carried brainrots, and temporarily clears the parade. Your base collection stays safe. The golden rebirth shrine starts at $10,000 and costs five times more each rebirth: it clears your cash and collection, gives you $100 to restart, and compounds your permanent income multiplier by x1.5. Your base sign gains a crown.

The server owns transactions, collection state, income, shields, events, and rebirth. The client displays server attributes and the `ShowBanner` and `FloatingText` remotes. `GameState` holds all mutable gameplay state, and `CharacterCatalog` defines every character, rarity, mutation, and tier. `WorldBuilder` creates the entire environment at startup while preserving the starter Baseplate instance.

Build the Rojo project and produce the kit's reproducible dossier:

```sh
export PATH="$HOME/workspace/tools/rojo:$PATH"
rojo build default.project.json --output game.rbxl
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
ls -l out/
```

Open `game.rbxl` in Roblox Studio and start Play to run the 3D game. Use the normal Roblox movement, jump, and camera controls; the HUD stays centred and leaves the top-left controls clear. `src/server` mounts as the `Server` bootstrap Script with ModuleScript children, `src/client` mounts under `StarterPlayerScripts/Client`, and `src/shared` mounts under `ReplicatedStorage/Shared`.

For this official recorded build, the starter `PLAY.json`, screenshots, and vendored make.fun library are retained. Publish and capture the running game in the later publish step. The kit check must run after committing and pushing because it evaluates HEAD; an initial `play_link` failure is expected until publication.
