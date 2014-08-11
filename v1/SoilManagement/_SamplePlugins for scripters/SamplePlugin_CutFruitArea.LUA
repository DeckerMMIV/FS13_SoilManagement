--
-- SamplePlugin_CutFruitArea.LUA - an example of how to use SoilMod's plugin facility.
--
--
-- Our sample plugin will add the possibility of harvesting WHEAT and CANOLA, when they
-- are in foliage-layer growth-states #4 (growing/last blue state) through #8 (withered/red state),
-- but at a reduced volume if the crops are not within states #5-#7 (the green states).
--


-- Create a table (or 'object' if you will), as usual.
SamplePlugin_CutFruitArea = {}

-- As a plain SoilMod-plugin it have no need to call addModEventListener(),
-- but if your own script has the needs, then do so, and then implement the
-- required functions that the base game's script will call.


-- Register this mod for callback from SoilMod's plugin facility.
-- These two lines MUST be like this, where you insert your own 'object'
getfenv(0)["modSoilModPlugins"] = getfenv(0)["modSoilModPlugins"] or {}     -- Get existing or create a new table, and place in global-environment.
table.insert(getfenv(0)["modSoilModPlugins"], SamplePlugin_CutFruitArea)    -- Add this 'object' to the list of plugins that SoilMod will call-back.


--
-- This function MUST BE named "soilModPluginCallback" and take one argument!
-- Notice that it is a 'dot' and not 'colon' that is used, and there is no 'self' argument!
-- It is the callback method, that SoilMod's plugin facility will call, to let this mod add its own plugins to SoilMod.
-- The argument is a 'table of functions' which must be used to add this mod's plugin-functions into SoilMod.
--
function SamplePlugin_CutFruitArea.soilModPluginCallback(soilMod)
                          -- this ^ is a 'dot'

    --
    -- We will only affect the 'Utils.cutFruitArea' function in this sample-plugin.
    --

    -- (It is OPTIONAL to have a 'setup' plugin.)
    -- Because this plugin will need to modify/add elements in the 'dataStore', which will
    -- affect other plugins that may also have been added to 'Utils.cutFruitArea', we here
    -- register our plugin-function that is run during the 'setup phase' when calling cutFruitArea.
    soilMod.addPlugin_CutFruitArea_setup(
        -- A one-liner description of our 'setup' plugin here, which
        -- will be logged to the LOG.TXT when SoilMod adds the plugin.
        "SamplePlugin for CutFruitArea"

        -- Priority of this 'setup' plugin. The higher the number, the later it will be executed during the 'setup phase'.
        -- Must be an integer value. Preferably a value of 20 or above, to allow the base-game's setup a change first.
        ,50

        -- Our actual 'setup' plugin function which cutFruitArea will call during the 'setup phase'.
        ,SamplePlugin_CutFruitArea.our_sample_cutFruitArea_setup
    )


    -- (It is OPTIONAL to have a 'before' plugin.)
    -- Our plugin here needs to affect the foliage layer _before_ the base-game's normal effect.
    -- So we add a 'before phase' plugin function, which has basically the same argument types as above.
    soilMod.addPlugin_CutFruitArea_before(
        -- A one-liner description of our 'before' plugin here, which
        -- will be logged to the LOG.TXT when SoilMod adds the plugin.
        "SamplePlugin for CutFruitArea"

        -- Priority of this 'before' plugin. The higher the number, the later it will be executed during the 'before phase'.
        -- Must be an integer value. Preferably a value of 20 or above, depending on other plugins effects.
        ,20

        -- Our actual 'before' plugin function which cutFruitArea will call during the 'before phase'.
        ,SamplePlugin_CutFruitArea.our_sample_cutFruitArea_before
    )


    -- (It is OPTIONAL to have an 'after' plugin.)
    -- Lastly we want our plugin to modify some of the values that cutFruitArea returns, we need
    -- to add to the 'after phase'.
    soilMod.addPlugin_CutFruitArea_after(
        -- A one-liner description of our 'after' plugin here, which
        -- will be logged to the LOG.TXT when SoilMod adds the plugin.
        "SamplePlugin for CutFruitArea"

        -- Priority of this 'after' plugin. The higher the number, the later it will be executed during the 'after phase'.
        -- Must be an integer value. Preferably a value of 20 or above, depending on other plugins effects.
        ,100

        -- Our actual 'after' plugin function which cutFruitArea will call during the 'after phase'.
        ,SamplePlugin_CutFruitArea.our_sample_cutFruitArea_after
    )
end


                          -- that . is still a 'dot'
function SamplePlugin_CutFruitArea.our_sample_cutFruitArea_setup(
            -- The start/width/height of the area to affect.
            -- These HAVE ALREADY BEEN calculated by 'Utils.getXZWidthAndHeight'!
            startX,startZ ,widthX,widthZ ,heightX,heightZ
            -- 'dataStore' is a table (or object) that contains some "useful" elements,
            -- and where plugins can add their own very-uniquely-named elements to.
            -- The 'dataStore' may be modified if needed, even the "useful" elements.
            -- Please study SoilMod's fmcModifyFSUtils.LUA script for what it adds of
            -- "useful" elements.
            ,dataStore
            -- This 'fruitDesc' contains CONSTANT elements and MUST NOT be modified/changed.
            -- Please study SoilMod's fmcModifyFSUtils.LUA script for what elements
            -- it sets in this 'fruitDesc'.
            ,fruitDesc
        )

    -- Only when cutting WHEAT or CANOLA
    if fruitDesc.index == FruitUtil.FRUITTYPE_WHEAT
    or fruitDesc.index == FruitUtil.FRUITTYPE_RAPE
    then
        -- Modify the min/max harvesting growth-states
        dataStore.minHarvestingGrowthState  = (fruitDesc.minHarvestingGrowthState+1) - 1 -- subtract one, to get growth-state #4 (last blue state)
        dataStore.maxHarvestingGrowthState  = (fruitDesc.maxHarvestingGrowthState+1) + 1 -- add one, to get growth-state #8 (red state)

        -- Add element, to use in our 'before' and 'after' plugin-functions.
        dataStore.MySamplePlugin_active = true
    end
end


function SamplePlugin_CutFruitArea.our_sample_cutFruitArea_before(
                               -- ^ 'dot'
            startX,startZ ,widthX,widthZ ,heightX,heightZ
            ,dataStore
            ,fruitDesc
        )

    -- Did our 'setup phase' determine that we are active?
    if dataStore.MySamplePlugin_active == true then
        -- Gather the density of growth-state #4, which we need to use in 'after phase' calculation
        setDensityCompareParams(dataStore.fruitFoliageId, "equals", dataStore.minHarvestingGrowthState);

        local preHarvestDensitySum, preHarvestDensityTotal = getDensityParallelogram(
            dataStore.fruitFoliageId,
            startX,startZ ,widthX,widthZ ,heightX,heightZ,
            0, g_currentMission.numFruitStateChannels,
        );

        -- Gather the density of growth-state #8, which we need to use in 'after phase' calculation
        setDensityCompareParams(dataStore.fruitFoliageId, "equals", dataStore.maxHarvestingGrowthState);

        local postHarvestDensitySum, postHarvestDensityTotal = getDensityParallelogram(
            dataStore.fruitFoliageId,
            startX,startZ ,widthX,widthZ ,heightX,heightZ,
            0, g_currentMission.numFruitStateChannels,
        );

        -- Restore the compare param
        setDensityCompareParams(dataStore.fruitFoliageId, "greater", -1);

        -- Store the values so 'after phase' plugin can use them for calculation.
        dataStore.MySamplePlugin_values = {
                preHarvestDensitySum    = preHarvestDensitySum,
                preHarvestDensityTotal  = preHarvestDensityTotal,
                postHarvestDensitySum   = postHarvestDensitySum,
                postHarvestDensityTotal = postHarvestDensityTotal,
        }
    end
end


function SamplePlugin_CutFruitArea.our_sample_cutFruitArea_after(
                               -- ^ not a 'colon'
            startX,startZ ,widthX,widthZ ,heightX,heightZ
            ,dataStore
            ,fruitDesc
        )

    -- Did our 'setup phase' determine that we are active?
    if dataStore.MySamplePlugin_active == true then
        -- Studying fmcModifyFSUtils.LUA's changed 'cutFruitArea' function, we know that there
        -- have been added some elements to 'dataStore' now; volume, pixelsSum & numPixels.
        -- Then we can also see that dataStore.volume and dataStore.numPixels are returned from
        -- 'cutFruitArea', which will then be used by the base game's script - so we want to
        -- affect the volume value in our plugin, depending on the findings of our 'before phase'.

        local greenPct, witheredPct = 0, 0

        if dataStore.MySamplePlugin_values.preHarvestDensityTotal > 0 then
            -- How many percent of the area did growth-state #4 cover?
            greenPct = dataStore.MySamplePlugin_values.preHarvestDensitySum / dataStore.MySamplePlugin_values.preHarvestDensityTotal
        end

        if dataStore.MySamplePlugin_values.postHarvestDensityTotal > 0 then
            -- How many percent of the area did growth-state #8 cover?
            witheredPct = dataStore.MySamplePlugin_values.postHarvestDensitySum / dataStore.MySamplePlugin_values.postHarvestDensityTotal
        end

        local modifierPct = (1.0 - (0.33 * greenPct)) + (-1.0 * witheredPct)

        dataStore.volume = dataStore.volume * modifierPct
    end
end
