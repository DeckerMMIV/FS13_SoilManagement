SoilMod - Soil Management & Growth Control (v1.1.0)


Mod description

'SoilMod' is a mod, for maps that have been correctly prepared, which attempts to add;
- custom control of growth, so it is following the in-game time,
- a proper use for lime/kalk, as soil pH is now included,
- manure must be ploughed/cultivated to take effect,
- automatic weed propagation and usage of herbicide,
- and a few other effects.

PLEASE NOTE! This mod may prehaps not be exactly what you expect or are thinking it is supposed to do. So please be open minded and give constructive critism and/or suggestions, for how to improve future versions of it.


How to 'prepare' the map  -- REQUIRED READING! --

(NOTE: You can skip this, if you have already done this for v1.0.0 of SoilMod.)

The 'SoilManagement.ZIP' mod will ONLY work on maps that have been prepared for it. There are required additions to be made in a map's .I3D and .LUA files, and these can be found in the download when you unpack it.

It is expected that you know how to use a plain-text editor, like Notepad++ ("Notepad Plus Plus") or similar editor, and are able to navigate in text-files like the .I3D and .LUA files.

Preparing your Map.I3D for SoilMod

The most difficult part is to add the required and correct lines to your own map.I3D file. How to do that is written in the file 'map - Instructions.txt', which you can find in the folder containing instructions.

Remember BEFORE you start editing your map, to MAKE A BACKUP of it. So if anything goes wrong you can revert to the last known good working version of it, and try again.

Be aware that the normal map size is 'x1' (i.e. have density files of 4096 x 4096 pixels.) Included in the download there are also density files for x.25 (small) and x4 (large) map sizes, where you much explicitly remember to use the correct density file if your map is not normal sized.

Preparing your SampleModMap.LUA for SoilMod

The second change you need to make to your map, is adding code statements to your SampleModMap.LUA (or whatever you have renamed it to.)

In the instructions folder you can find a 'SampleModMap - Additions.LUA' file, which has 5 clearly indicated blocks of code, that you must copy and paste into the exact same relative position of the enclosing function in your own map's SampleModMap.LUA script file.


How to use it in-game

ATTENTION! Since there exist may other mods, that modify the internal functions for how spreading/cultivating/harvesting works in Farming Simulator 2013, there MAY BE possible mod conflicts when used together with this 'SoilMod'.

So it is highly advisable to remove or disable any mods, which potentially could affect the proper operation of 'SoilMod'.

Once you have prepared the map for 'SoilMod', then place the mods in your MODS folder; SoilManagement.ZIP and PDAModPlugin_SoilCondition.ZIP.
Also remember to get PDAMod.ZIP (or newer) if you do not already have it. - http://fs-uk.com/mods/view/34554

Go into the game and start the map you have prepared for 'SoilMod'. Note that it is probably possible to continue on an existing savegame, but please experiment with it first, to see if it works for you.

When the map is loading, the Soil Management & Growth Control scripts will print miscellaneous information to the in-game console and LOG.TXT file, which is needed in case a problem occurs.


Soil Condition - a PDA MOD plugin

The first thing you should ensure is working, is the 'Soil Condition' screen in the PDA. If this screen is not available (forgot PDA MOD?) or is not showing something similar to what is illustrated in the screenshots, the map may not have been correctly prepared for 'SoilMod', which in that case you need to look into the LOG.TXT file to determine the problem.

When the 'Soil Condition' screen works, it will show some information of the ground within a 10x10 sqm area centered around the player's current position. This is continuously updated every 2nd second.

A sub-page called 'Fruit Effects' is primarly some static information about which crops that gains a yield boost from a particular synthetic fertilizer type, and what herbicide type they are negativly affected by (i.e. grows slower or becomes withered).


Growth, withering included - happens at midnight every in-game day

The whole point of making this mod, was for me to know when the next growth cycle would happen, and be able to affect it in ways yet to determined.

As it is now, growth for all crops will start every day at midnight in-game time.

A progress indicator shows how much have been processed, as the growth update stage affects a predetermined sized square of the map, which is needed to reduce potential 'game freeze' and network-latency (lag) issues.

Withering is activated! ... and there is currently no "easy way" to deactivate it, other than finding and changing the hardcoded setting in the SoilMod scripts.

During the growth cycle, the following things happen:
- Crops grow one stage, unless affected by a particular herbicide type which would either pause the growth or make the crop go withered.
- Swaths/windrows and unprocessed manure will be reduced with one level (i.e. slowly dissipate.)
- Unprocessed lime and slurry becomes embedded into the soil, but at a reduced efficiency compared to cultivating it.
- Herbicide will make weed plants wither, and then dissipate.
- Moisture from spraying/fertilizing will vaporize.


Soil pH & lime - will affect harvest yields

The soil pH condition is a new aspect of this mod, which will severely affect harvesting yields if the soil becomes too acid.

The 'Soil Condition' screen will show what the average soil pH value is for the area - which is NOT the entire field - so keep a close eye on this.

For optimal yields, the soil pH value must be within the 'neutral' range. Anything below or above will affect outcome, according to the following table, where 100% equals normal yields:

  - 5.1 - 5.6 - 6.1 - 6.6 -  7.3 - 7.9 - 8.5 - 9.0 -
  5%   50%   75%   95%   100%   95%   90%   80%   70%

Spreading lime will increase the soil pH level, and if ploughed/cultivated into the ground the lime's efficiency will be higher, than when left unprocessed for the next growth cycle.

Due to technical game limitations and the way the script works, pH levels will jump at greater intervals than what may seem realistic.

Using the standard equipment for spreading solid fertilizer (not manure though), it is possible to switch spray type to lime. The F1 helpbox will show what key to press for that.


Manure & slurry - organic fertilizer

Some players have expressed they would like to actually be able to first spread manure/slurry and then plough/cultivate it into the ground.

This is also something that 'SoilMod' introduces, as spread manure and slurry will not instantly take effect, but have to be "mixed into the ground" to increase the nutrition of the soil, and thereby give better crop yields during harvest.

The tasks for using manure and slurry in 'SoilMod' are as follows:

1. Spread manure or slurry on the field.
2a. For best results, manure has to be ploughed into ground, as it will increase nutrition levels by 3 (up to a max of 3)
2c. Cultivating manure is less effective, as it will only increase by 1.
2b. For slurry, either ploughing or cultivating, will increase nutrition levels by 1 (up to a max of 3.)
2d. Slurry can also be "left unprocessed" awaiting for the next growth cycle, but will then be even less effective, as only up to a max of 1 nutrition level is settled into the soil.

Note that manure which is left unprocessed on the terrain, will dissipate over time (3 days), and will in this case NOT increase nutrition levels.


Fertilizer - the synthetic kind, only when growing

Using organic fertilizer is best, but the synthetic kind could help in situations where just a bit more would be useful.

However, spreading synthetic fertilizer will only be effective when the crops are in their early growing stages. If synthetic fertilizer is spread at a different time, the crops will not accept it.

In SoilMod's advanced mode (which is default) there are 3 types of synthetic fertilizers; type-A, type-B & type-C. Each crop (fruit-type) will only accept one specific type of synthetic fertilizer (or none at all), which can be seen in the 'Fruit Effects' PDA screen.

Using the standard equipment for spreading liquid fertilizer (not slurry though), it is possible to switch spray type to each of the 3 synthetic fertilizer types. The F1 helpbox will show what key to press for that.


Weed plants & herbicide - randomly appears in fields

Patches of weed plants will continuously appear in fields, as their seeds are spread with the winds. Ploughing, cultivating or seeding will remove them, but sometimes using these methods are not possible, so you need to spray herbicide.

In SoilMod's advanced mode (which is default) there are 3 types of herbicides; type-A, type-B & type-C. Any of these herbicides will kill weed plants. However some crops will be affected by a specific type of herbicide, so make sure you check the 'Fruit Effects' PDA screen. In the worst case, crops becomes withered due to being exposed to the specific herbicide type.

When weed plants have been affected by herbicide, they will wither and die some days after. - However by then new weed plants may have appeared closed by.

Using the standard equipment for spreading liquid fertilizer (not slurry though), it is possible to switch spray type to each of the 3 herbicide types. The F1 helpbox will show what key to press for that.


Problems or bugs?

If you encounter problems or bugs using the 'SoilMod' mod, please use the support-thread at http://fs-uk.com - Find the mod (and correct version) in the mods section, in category 'Other - Game Scripts'.

Known defects/bugs:
- Only English texts in ModDesc.XML.
- Spraying a different kind of fertilizer/herbicide on the field, will replace any other type of fertilizer/herbicide there may have already been there.
- It is possible to spread slurry a day before harvest, and get the organic fertilizer effect.
- Switching to 'simplistic mode' can only be done by editing fmcSoilMod.LUA script.
- Modifying growth control parameters can only be done by editing fmcGrowthControl.LUA script.


Restrictions

The mod files SoilManagement.ZIP, PDAMod.zip and PDAModPlugin_SoilCondition.ZIP MUST NOT be embedded in any other mod. - However it is accepted if they are included in a mod-pack, when the mod's original hash-values are kept intact.

Please do NOT upload this mod to any other hosting site - I can do that myself, when needed!

Keep the original download link!


Credits:
Script: Decker_MMIV.
Graphics: KaosKnite, JakobT, GIANTS, Decker_MMIV and others.
Translations: JakobT, Gonimy_Vetrom, VAHA.
