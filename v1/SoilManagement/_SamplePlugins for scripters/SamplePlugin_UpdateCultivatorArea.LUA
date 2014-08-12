--
-- SamplePlugin_CutFruitArea.LUA - an example of how to use SoilMod's plugin facility.
--
--
-- Our sample plugin expects that the map has a foliage-sub-layer with name "FSL_dust".
-- If this foliage-sub-layer does not exist, the plugin is not added to SoilMod.
--


-- Create a table (or 'object' if you will), as usual.
SamplePlugin_UpdateCultivatorArea = {}

-- As a plain SoilMod-plugin it have no need to call addModEventListener(),
-- but if your own script has the needs, then do so, and then implement the
-- required functions that the base game's script will call.


-- Register this mod for callback from SoilMod's plugin facility.
-- These two lines MUST be like this, where you insert your own 'object'
getfenv(0)["modSoilModPlugins"] = getfenv(0)["modSoilModPlugins"] or {}           -- Get existing or create a new table, and place in global-environment.
table.insert(getfenv(0)["modSoilModPlugins"], SamplePlugin_UpdateCultivatorArea)  -- Add this 'object' to the list of plugins that SoilMod will call-back.


--
-- This function MUST BE named "soilModPluginCallback" and take one argument!
-- Notice that it is a 'dot' and not 'colon' that is used, and there is no 'self' argument!
-- It is the callback method, that SoilMod's plugin facility will call, to let this mod add its own plugins to SoilMod.
-- The argument is a 'table of functions' which must be used to add this mod's plugin-functions into SoilMod.
--
function SamplePlugin_UpdateCultivatorArea.soilModPluginCallback(soilMod)
                          -- this ^ is a 'dot'

    --
    -- We will only affect the 'Utils.UpdateCultivatorArea' function in this sample-plugin.
    --
    
    -- Find the foliage-id value for a foliage-layer with name "FSL_dust".
    SamplePlugin_UpdateCultivatorArea.foliageDustLayerId  = getChild(g_currentMission.terrainRootNode, "FSL_dust")
    
    -- Ensure the foliage-layer exist, as if it does not there is no reason to add the plugin to SoilMod.
    if  SamplePlugin_UpdateCultivatorArea.foliageDustLayerId ~= nil
    and SamplePlugin_UpdateCultivatorArea.foliageDustLayerId ~= 0   then

        -- Set some CONSTANTS, which are used in the plugin-function we're about to add to SoilMod.
        SamplePlugin_UpdateCultivatorArea.foliageDustFirstChannel = 0
        SamplePlugin_UpdateCultivatorArea.foliageDustNumChannels  = getTerrainDetailNumChannels(SamplePlugin_UpdateCultivatorArea.foliageDustLayerId)
    
        -- This plugin sample have no need for a 'setup phase'
        --soilMod.addPlugin_UpdateCultivatorArea_setup()
        
        -- Our plugin here needs to affect the foliage layer _before_ the base-game's normal effect.
        -- So we add a 'before phase' plugin function, which has basically the same argument types as above.
        soilMod.addPlugin_UpdateCultivatorArea_before(
            -- A one-liner description of our 'before' plugin here, which
            -- will be logged to the LOG.TXT when SoilMod adds the plugin.
            "SamplePlugin for UpdateCultivatorArea"

            -- Priority of this 'before' plugin. The higher the number, the later it will be executed during the 'before phase'.
            -- Must be an integer value. Preferably a value of 20 or above, depending on other plugins effects.
            ,70

            -- Our actual 'before' plugin function which UpdateCultivatorArea will call during the 'before phase'.
            ,SamplePlugin_UpdateCultivatorArea.our_sample_UpdateCultivatorArea_before
        )

        -- This plugin sample have no need for an 'after phase'
        --soilMod.addPlugin_UpdateCultivatorArea_after()
    end
end


function SamplePlugin_UpdateCultivatorArea.our_sample_UpdateCultivatorArea_before(
                                       -- ^ not a 'colon'
            -- The start/width/height of the area to affect.
            -- These HAVE ALREADY BEEN calculated by 'Utils.getXZWidthAndHeight'!
            startX,startZ ,widthX,widthZ ,heightX,heightZ
            -- 'dataStore' is a table (or object) that contains some "useful" elements,
            -- and where plugins can add their own very-uniquely-named elements to.
            -- The 'dataStore' may be modified if needed, even the "useful" elements.
            -- Please study SoilMod's fmcModifyFSUtils.LUA script for what it adds of
            -- "useful" elements.
            ,dataStore
        )

    if dataStore.forced then
        -- Remove the "FSL_dust" for the entire parallelogram's coordinates.
        setDensityParallelogram(
            SamplePlugin_UpdateCultivatorArea.foliageDustLayerId, 
            startX,startZ ,widthX,widthZ ,heightX,heightZ, 
            SamplePlugin_UpdateCultivatorArea.foliageDustFirstChannel, SamplePlugin_UpdateCultivatorArea.foliageDustNumChannels, 
            0
        );
    else
        -- Only remove the "FSL_dust" where the parallelogram overlaps cultivated/ploughed/seeded fields ("painted foliage terrain").
        setDensityMaskedParallelogram(
            SamplePlugin_UpdateCultivatorArea.foliageDustLayerId, 
            startX,startZ ,widthX,widthZ ,heightX,heightZ, 
            SamplePlugin_UpdateCultivatorArea.foliageDustFirstChannel, SamplePlugin_UpdateCultivatorArea.foliageDustNumChannels, 
            g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
            0
        );
    end
end
