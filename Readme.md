# Factorio & Frostpunk Merge Mod (Mod Name = FPF)

this is a mod for Factorio game, and tries to setup environment and rules similar to Frostpunk game.

## Features

player ends up in a frost world and he has to leave the planet but he does not have power options like original game. now he has to explore the map and find special furnaces and build his city around the furnace. win condition is same for first version. there is only one power option in addition to the furnaces mentioned but can produce a very low amount of power. furnaces cannot be mined, deconstructed etc. also furnaces only use burner fuel, so they generate big amount of pollution

the map shall spawn those massive furnaces inside craters, defended by indestructable cliffs.

biters could be one challenge but not necessary since power is a challenge now

## Supplementary Mods

the mod shall put dependency on some mods on mod portal since the ambiance fits a lot.

- *Big Winter:* (**mandatory**) almost absolute must. there is a problem with the mod though. it must prevent water generation for now, and mod provides this with option. either mod shall be replicated inside this mod or leave as an option which might fail in various places. not decided yet.
- *Ice Ore:* (**mandatory**) since water shall not be around map (no lake, all supposed to be frozen), this mod shall be source of the water
- *Cold Biters:* (**optional**) while it makes very good sense, it is not a must. might change
- *Theme Extensions:* (**optional**) this shall be a supplementary mod over this mod, and it shall change some rules of the game to make it more Frostpunk like

## TODO

todo list for the mod

- MEDIUM *Furnace Upgrades:* furnace must be upgradable within progression of game. entities shall be replaced by code. also infinite research is an option as well (partially infinite)
- MEDIUM *Random Furnace Generation:* on map furnaces shall spawn with exploration, plus one close to rocket crash site
  - HARD *Cliff Generation:* cliffs have to be generated manually by code since game can never make such a structure. maybe skipped for initial versions?
- HARD *Prevent Building:* the main idea is to build stuff around furnaces, not outside, if game engine allows then also implement it, not a big deal if Player wants to avoid this rule since power can always be delivered with poles.
- EASY *Supplementary Burner Generator:* a simple generator for outposts since they also require power. SBG mod looks perfect for that, and it shall be part of this mod (I shall copy code of it)

theme extension changes planned. below shall not be forced, but very recommended and maybe by default they shall be activated.
- EASY *Burner Lamp / Torch:* a lamp which has no power requirement because it gets power from burner fuel
- EASY *Beacon Changes:* I think of updating beacons for some changes. beacons should allow more slots (4) and +2 range but should stall machines if more than one beacon affects a machine. there are mods for this and an existing mod code shall be taken. not decided yet and it is just an idea.
- EASY *Effectivity Modules:* since power is a big limiter now, they are more important now. the eff-2 and eff-3 modules shall have a bump on their stats, and maybe have speed bonus as well
- EASY *Oil Cracking:* water recipes for oil processing and cracking shall be changed to steam
- EASY *Disable Power Options:* while in Factorio they have good use, in the Frostpunk theme they are absolutely cheating and against the idea of the theme. Steam Engine, Solar Panel and nuclear power (Nuclear Reactor, Steam Turbine, Heat Pipe, Heat Exchanger) shall be disabled. 

# Second Version (fluffy)

everything is fully fluffy for now, and it may change. below is the main idea of the mod but first version shall focus on Factorio style gaming.

this version shall make the mod more like Frostpunk. below rules are in addition to first version. 

- game shall start with logistic network entities enabled and Player shall have a bunch of these. 
- mod shall change sprites of bots, to make them look like human (player?) and they shall represent Worker/Engineer/Child like Frostpunk. so basically everything is bot based in this version. Workers are logistic bots, Engineers are construction bots, Children are neither of them (look at win condition). also roboports shall look like a special heater, where workers warm themselves (sth like that)
- since game starts with logistic network elements now, the belts are removed completely. instead the Workers shall be like belts. 
- Workers are not recipes, they are not created by *Player* instead Player must explore the map and find more survivors. so game shall spawn bunkers (just like abandoned vaults) and inside those bunkers these workers/engineers/children shall be found. (coding idea is already done by The Ruins mod)
- plus, every tech research might provide one more worker/engineer/child. or maybe more than one, maybe none. depends.
- due to game engine, assemblers, inserters have to stay for now, but no belts. also since the workers are not flying anymore, they shall be forced to walk on map (slowed always?) and carry capasity shall be lower (and no speed upgrade, cargo upgrade?) but maybe no/low cost on power (maybe?)
- Automatons: well, we have them and they are called spidertrons but in this version I think of a special logistic entity which can do things like a logistic bot, and maybe have huge storage (cargo) but reduced speed. Automatons require Steam Core in Frostpunk and they cannot be crafted, so exploration shall be idea to find them, and of course these Automatons do not require to be sent to space for win condition.
- Miners are a problem here as Workers would be the ones for those but Klonan has a mod for this and maybe I can use that. depends
- *Player* shall explore map more and find survivors, or within research he shall gain more workers with each tech research. 
- Workers and Engineers can be converted into each other by a recipe (only by Player, no machine?) but Children cannot be converted. Engineer>>Worker should be simple and easy but Worker>>Engineer should be costly
- *Win Condition:* Player shall eventually build rocket silo but the sending rocket to space shall not make game won. the main condition is to send EVERYONE (Worker/Engineer/Children) to safe haven, to space. that requires balance or storage handling. the satellite recipe shall be changed and it shall take X amounts of survivors into it, as a recipe. maybe there shall be a bunker recipe. when the capsule/satellite is sent to space, mod shall count how many are sent (saved). once all workers/engineers/children are sent then game is won

as first version, game shall encourage Player to explore more, find more survivors (and most probably with some items stashed inside bunkers), reveal more furnaces and build facilities inside them etc. 

# Mod Code Credits

I am not a good modder but there are an abundant number of good mods with code available. I look at them continuously and take their code. below is my credits and reference to those modders. all rights belong to them

- Repair Turret by Klonan
- The Ruins by Bilka
- KS_Power by Klonan
- Alternative Steam by Degraine
- SBG by Ondra4260
- Burner Fuel Bonus by DaveMcW

and of course Frostpunk and Factorio game copyrights are owned by the developers of those games, I am just a fan of both games

some mods are mentioned besides above list. they are either not used for coding resources or just not yet, they are used for ambiance.

# Help

want to help? contact me, I cannot do everything above or it shall take a long time. also I am not an experienced modder.