# Factorio & Frostpunk Merge Mod (Mod Name = FPF)

this is a mod for Factorio game, and tries to setup environment and rules similar to Frostpunk game.

## Features

player ends up in a frost world and he has to leave the planet but he does not have power options like original game. now he has to explore the map and find special furnaces and build his city around the furnace. win condition is same for first version. there is only one power option in addition to the furnaces mentioned but can produce a very low amount of power. furnaces cannot be mined, deconstructed etc. also furnaces only use burner fuel, so they generate big amount of pollution

the map shall spawn those massive furnaces inside craters, defended by indestructable cliffs.

biters could be one challenge but not necessary since power is a challenge now

## Supplementary Mods

the mod shall put dependency on some mods on mod portal since the ambiance fits a lot.

- **Big Winter:** (*mandatory*) almost absolute must. there is a problem with the mod though. it must prevent water generation for now, and mod provides this with option. either mod shall be replicated inside this mod or leave as an option which might fail in various places. not decided yet.
- **Ice Ore:** (*mandatory*) since water shall not be around map (no lake, all supposed to be frozen), this mod shall be source of the water
- **Cold Biters:** (*optional*) while it makes very good sense, it is not a must. might change
- **Theme Extensions:** (*optional*) this shall be a supplementary mod over this mod, and it shall change some rules of the game to make it more Frostpunk like

## TODO

general priority is the item order seen here

main stuff is done. remaining are theme extension changes. below shall not be forced, but very recommended and maybe by default they shall be activated.

- EASY **More Craters:** right now only one crater exists, more craters are required, at least 8 total
- EASY+LONG **Abandoned Resources:** spawning a single furnace seems weird, maybe I should put some chests around furnace, and even turrets etc? like the Abandoned Ruins mod. if there shall be turrets then probably I need to define a new force which is enemy to player and ally to furnace force, maybe?

below are fully hard to do stuff, maybe not so necessary. I will not focus on these for real, until to a point that I have time besides other stuff

- HARD **Prevent Building:** the main idea is to build stuff around furnaces, not outside, if game engine allows then also implement it, not a big deal if Player wants to avoid this rule since power can always be delivered with poles.

### Done

these are done and hopefully will not be broken

- DONE **Beacon Changes:** I think of updating beacons for some changes. beacons should allow more slots (4) and +2 range but should stall machines if more than one beacon affects a machine. there are mods for this and an existing mod code shall be taken. not decided yet and it is just an idea.. DONE as a seperate mod, not part of this
- DONE **Effectivity Modules:** since power is a big limiter now, they are more important now. the eff-2 and eff-3 modules shall have a bump on their stats, and maybe have speed bonus as well. tied to setting, so can be disabled
- DONE **Oil Cracking:** water recipes for oil processing and cracking shall be changed to steam. tied to setting, so can be disabled
- DONE **Burner Lamp / Torch:** a lamp which has no power requirement because it gets power from burner fuel. copy of Torches mod
- DONE **Enable Power Options:** handled with Disable option. 
- DONE **Disable Power Options:** only disabled building on map, layers shall prevent items put. items can still be crafted (for use of satellite) 
- DONE **Supplementary Burner Generator:** a simple generator for outposts since they also require power. SBG mod looks perfect for that, and it shall be part of this mod (I shall copy code of it)
- NOT NEEDED **Random Seed to Map Seed:** according to what I understood, it is already done, math.random() generates random numbers using game's seed
- DONE **Auto/Manual Proof Check:** both with ticks or with command a proof of crater can be done
- DONE **OnChunk Build Queue:** this is the solution to the bug about built stuff being overwritten. now I have to make a proof check after some ticks. it is not optimal because I have to check each and every cliff but it works and it is done twice only (once on built and second on entire crater complete), also added a command to make the check done upon request
- DONE **Manual Spawn Cliffs:** spawn the FPF cliffs on map, surrounding the furnace
- PARTIAL DONE **Spawn Crater With Script:** this is the code of Abandoned Ruins mod, hopefully taking code shall be easy
- DONE **Define Cliff Maps:** the definition was not so difficult. hopefully it can be used to spawn but it seems doable since I read what is in the game 
- DONE **Random Spawn Furnace:** spawn a furnace on map, randomly, at initial area and also at map randomly
- PARTIAL DONE **Clear Area Before Spawn:** this is the case where there are already many cliffs/trees/biters on the area we want to spawn furnace, a clearance is needed first but will not clear everything, only to enable furnace and maybe remnants. so far it worked very well, without any problem
- DONE **Spawn Infrastructure:** infrastructure about where to spawn what is there, but not the spawning code
- DONE **Check Furnace Distance:** furnaces should be spawned when reaches a certain distance, so I need to be able to understand how to get distances of two entities
- DONE **Claim Tool:** all abandoned entities (furnaces etc) must be claimed by player before usage
- DONE **Furnace Force:** all generated furnaces belong to this force so manipulation is easy
- DONE **Unclaimed Furnace Activation:** prevent player leeching power from furnace without claim
- DONE **Settings for Map Entity Generation:** furnace generation settings
- DONE **Signals:** was not intended but the signals were there in unsorted so added them properly

### Test

test these and if they work then fine but if not then add fixes

- NOT AN ISSUE **Skipping Spawn:** is this even possible? skipping a tick and spawning getting interrupted? if so then in next chunk generated the system should give a 1 as prob to compensate, would not balance but kind of a compensation

### Bugs

some issues I created somehow or realized I need to fix

- FIXED **Pollution:** early (non-upgraded) furnaces have very low pollution. 20 boiler, 40 steam engine produces pollution 600/m with 36MW, furnace will do 480 at 48MW, and a lot lower on lower power or with efficiency upgrades
- FIXED **Pre-Chunk Generation Building:** this is a serious issue. when a furnace is about to be built, code simply rushes forward and builds everything including crater but on un-generated chunks. this behavior causes game re-applying or even re-generating chunks and overwriting the cliffs built etc. so basically a pre-built crater will be overwritten within seconds later. the solution would be to wait until the needed chunks are generated or queue it, and when AFTER chunk is generated then the other stuff can be build, including clearing etc. chunk generation is observable and entity creating is queue-able so it shall not be a big problem I hope

## Won't Work

some ideas will not work due to some game engine etc

- fast replace furnaces did not work, power output was never in full when done so. maybe game bug? workaround was to destroy entity and create new one. UPDATE: seems like it was a bug so it is going to be fixed by devs (Rseding91 mentioned it) in next build

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
- No Lakes by Pithlit
- Don't build on ores by darkfrei
- Torches by Klonan
- Old Boiler by Haq1

and of course Frostpunk and Factorio game copyrights are owned by the developers of those games, I am just a fan of both games

some mods are mentioned besides above list. they are either not used for coding resources or just not yet, they are used for ambiance.

# Help

want to help? contact me, I cannot do everything above or it shall take a long time. also I am not an experienced modder.

# Resources

links etc: 

- [Prototypes](https://wiki.factorio.com/Prototype_definitions)
- [Abandoned Ruins](https://github.com/Bilka2/AbandonedRuins)
- [Factorio Lua](https://lua-api.factorio.com/latest/)
