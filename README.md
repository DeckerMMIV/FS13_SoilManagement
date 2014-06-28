Soil Management & Growth Control
================================

A mod for Farming Simulator 2013 which attempts to add;
- custom control of growth, so it is following the in-game time,
- a proper use for lime/kalk, as soil pH is now included,
- manure must be ploughed/cultivated to take effect,
- automatic weed propagation and usage of herbicide.


# What?! Why?

There has always been some small things in FS13, and the previous versions, which annoyed me a bit.
Like how come it is possible to fertilize right in front of the working harvester and get double the yield, and unrealistic things like that.

What I'm attempting with this mod, are several things:

- Control of growth, so it is the in-game scaled time that determines when growth should happen, and not some value in the foliage-sub-layer.
- Manure has to be ploughed or cultivated into the ground to take effect. Else it will slowly dissipate, and you would not get the expected result in yield when harvesting.
- Different kinds of fertilizer; organic and synthetic. Manure and slurry are organic fertilizers, where the other(s) are synthetic and not as effective.
- Swaths/windrows when left alone will also slowly dissipate. The reason for this, is to "clean up" the fields over time.
- When lime (kalk) was introduced as a mod, I always wondered why it acted just like fertilizer. With this mod I have added 'soil pH', so spreading lime now have a proper purpose.
- The 'soil pH' will also have a severe effect on harvest yields. If the pH value isn't within the "neutral" interval, the yield can be as low as 5%.
- Automatic propagation of weeds. Wind will spread the seeds, so weeds can appear in all fields.
- Herbicide is used to kill weeds, but this won't happen instantly.


# Details

_Growth control_
Why is it, that the map-maker decides how long it takes for a crop to grow? And why is the growth interval bound to real-time instead of the in-game scaled time?

Using this mod, it will completely ignore the map-makers settings, and instead use a "growth cycle" that occurs at midnight in-game time. This means that at every in-game day,
when the clock passes midnight, all crops will grow one step. Other things also take effect at this time.

Players could probably use this as a kind of "seasons", as it is more obvious now *when* the growth happens.

_Manure & slurry (organic fertilizer)_
When spreading solid manure there will be visible "lumps of poo" on the ground, just as it is known from the 'manure mod'. However this will not fertilize the ground,
and when left untouched the manure will dissipate during 3 days.

You will have to plough or cultivate it to get better harvest yields later. Ploughing solid manure into the ground will increase the organic nutrition values for three harvest seasons,
where cultivating the manure will only add organic nutrition for one extra harvest season.

Spreading slurry acts a bit similar to manure. However if left untouched, it will automatically settle into the ground, and give organic nutrition for at least one harvest.
Ploughing or cultivating slurry will increase the organic nutrition by one extra.

There is a limit to how much organic nutrition the ground can hold. In this version of the mod, it is a maximum of 3 levels.
So it will be futile to apply more, if the ground is already at max.

_Fertilizer (synthetic)_
The synthetic fertilizer is not as good as the organic. Also synthetic fertilizer can only be effectively sprayed when the crop is visibly growing.
If sprayed earlier or later, it has no effect on the crops.

In the "advanced version" of this mod there are three types of synthetic fertilizers, and each crop will only give extra yield when the correct fertilizer is used.
For the "simplistic version" there will only be one synthetic fertilizer type, as known from the default game.

_Lime & soil pH_
Introduction of lime (kalk) to the game was a new fresh idea. However lime is not a fertilizer as such, as it is normally used to increase soil pH value when too acid.
It is not possible to visibily "see" the soil's pH value, so a plugin to PDA MOD has been made, that can show this value within an area of 10x10 sqm centered around the
player's current location.

Spreading lime will - as with the above - not immediately take effect. If left alone, it will only increase the soil pH value by a small amount.
To get a higher increase (which is x3), you need to plough or cultivate it into the ground.

For the "advanced version" of this mod, you should keep an eye on the soil pH, as it is not too good if it gets into the 'alkalinity' range.
The "simplistic version" is more generous, whereas as long the soil has a pH value above 'acidity' the harvest yields will not be affected.

Note that soil pH will decrease with each harvest.

_Weeds & herbicide_
(t.b.d.)
