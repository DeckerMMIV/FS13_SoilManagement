--
-- SamplePlugin_UpdateSprayArea.LUA - an example of how to use SoilMod's plugin facility.
--
-- 
-- This sample will add a spray plugin for the spray-/fill-type WATER. It requires a foliage-layer
-- named 'layer_water' to be present in the map.i3d, else the plugin will not be added to SoilMod.
--

-- Create a table (or 'object' if you will), as usual.
SamplePlugin_UpdateSprayArea = {}

-- As a plain SoilMod-plugin it have no need to call addModEventListener(),
-- but if your own script has the needs, then do so, and then implement the
-- required functions that the base game's script will call.


-- Register this mod for callback from SoilMod's plugin facility.
-- These two lines MUST be like this, where you insert your own 'object'
getfenv(0)["modSoilModPlugins"] = getfenv(0)["modSoilModPlugins"] or {}      -- Get existing or create a new table, and place in global-environment.
table.insert(getfenv(0)["modSoilModPlugins"], SamplePlugin_UpdateSprayArea)  -- Add this 'object' to the list of plugins that SoilMod will call-back.


--
-- This function MUST BE named "soilModPluginCallback" and take one argument!
-- Notice that it is a 'dot' and not 'colon' that is used, and there is no 'self' argument!
-- It is the callback method, that SoilMod's plugin facility will call, to let this mod add its own plugins to SoilMod.
-- The argument is a 'table of functions' which must be used to add this mod's plugin-functions into SoilMod.
--
function SamplePlugin_UpdateSprayArea.soilModPluginCallback(soilMod)
                             -- this ^ is a 'dot'

    -- A local helper function.
    local function getFoliageLayerIdByName(foliageLayerName)
        local foliageId = getChild(g_currentMission.terrainRootNode, foliageLayerName)
        
        if (foliageId ~= nil and foliageId ~= 0) then
            return foliageId
        end
        
        return nil;
    end

    -- Get the foliage-layer-id for 'layer_water'
    SamplePlugin_UpdateSprayArea.foliageLayerId_Water = getFoliageLayerIdByName("layer_water")
    
    -- Only add the spray-plugin, if the foliage-layer was found.
    if SamplePlugin_UpdateSprayArea.foliageLayerId_Water ~= nil then
        local foliageId       = SamplePlugin_UpdateSprayArea.foliageLayerId_Water
        local numChannels     = getTerrainDetailNumChannels(foliageId)
        local value           = 2^numChannels - 1
        
        soilMod.addPlugin_UpdateSprayArea_fillType(
            -- A one-liner description of our 'spray' plugin here, which
            -- will be logged to the LOG.TXT when SoilMod adds the plugin.
            "Spraying water",

            -- Priority of this 'spray' plugin. Must be an integer value.
            10,
            
            -- What 'fill-type' will activate this 'spray' plugin.
            Fillable.FILLTYPE_WATER,
            
            -- Our actual 'spray' plugin function which will be called when the fill-type matches in 'Utils.updateSprayArea'.
            function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Returning true will apply the default moisture, i.e. "darken the ground"/"make it wet".
            end
        )
    end

    return true  -- Tell SoilMod that everything is ok.
end
