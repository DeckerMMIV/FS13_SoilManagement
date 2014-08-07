--
--  The Soil Management and Growth Control Project
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-08-xx
--

fmcSoilModPlugins = {}

local modItem = ModsUtil.findModItemByModName(g_currentModName);
fmcSoilModPlugins.version = (modItem and modItem.version) and modItem.version or "?.?.?";


-- Register this mod for callback from SoilMod's plugin facility
getfenv(0)["modSoilModPlugins"] = getfenv(0)["modSoilModPlugins"] or {}
table.insert(getfenv(0)["modSoilModPlugins"], fmcSoilModPlugins)

--
-- This function MUST BE named "soilModPluginCallback" and take one argument!
-- It is the callback method, that SoilMod's plugin facility will call, to let this mod add its own plugins to SoilMod.
-- The argument is a 'table of functions' which must be used to add this mod's plugin-functions into SoilMod.
--
function fmcSoilModPlugins.soilModPluginCallback(soilMod)

    -- Gather the required special foliage-layers for Soil Management & Growth Control.
    local allOK = fmcSoilModPlugins.setupFoliageLayers()

    if allOK then
        -- Using SoilMod's plugin facility, we add SoilMod's own effects for each of the particular "Utils." functions
        -- To keep my own sanity, all the plugin-functions for each particular "Utils." function, have their own block:
        fmcSoilModPlugins.pluginsForCutFruitArea(        soilMod)
        fmcSoilModPlugins.pluginsForUpdateCultivatorArea(soilMod)
        fmcSoilModPlugins.pluginsForUpdatePloughArea(    soilMod)
        fmcSoilModPlugins.pluginsForUpdateSowingArea(    soilMod)
        -- And for the 'growth-cycle' plugins:
        fmcSoilModPlugins.pluginsForGrowthCycle(         soilMod)
    end

    -- TODO: Let the ZZZ_ChoppedStraw mod do this itself, once/if it is changed to support SoilMod's plugin feature.
    fmcSoilModPlugins.extra_SupportForChoppedStrawMod(soilMod)  
    
    return allOK
end

--
local function hasFoliageLayer(foliageId)
    return (foliageId ~= nil and foliageId ~= 0);
end

--
function fmcSoilModPlugins.setupFoliageLayers()
    -- Get foliage-layers that contains visible graphics (i.e. has material that uses shaders)
    g_currentMission.fmcFoliageManure = g_currentMission:loadFoliageLayer("fmc_manure",     -5, -1, true, "alphaBlendStartEnd")
    g_currentMission.fmcFoliageSlurry = g_currentMission:loadFoliageLayer("fmc_slurry",     -5, -1, true, "alphaBlendStartEnd")
    g_currentMission.fmcFoliageWeed   = g_currentMission:loadFoliageLayer("fmc_weed",       -5, -1, true, "alphaBlendStartEnd")
    g_currentMission.fmcFoliageLime   = g_currentMission:loadFoliageLayer("fmc_lime",       -5, -1, true, "alphaBlendStartEnd")

    -- Get foliage-layers that are invisible (i.e. has viewdistance=0 and a material that is "blank")
    g_currentMission.fmcFoliageFertilizerOrganic    = getChild(g_currentMission.terrainRootNode, "fmc_fertilizerOrganic")
    g_currentMission.fmcFoliageFertilizerSynthetic  = getChild(g_currentMission.terrainRootNode, "fmc_fertilizerSynthetic")
    g_currentMission.fmcFoliageHerbicide            = getChild(g_currentMission.terrainRootNode, "fmc_herbicide")
    g_currentMission.fmcFoliageSoil_pH              = getChild(g_currentMission.terrainRootNode, "fmc_soil_pH")

    --
    local function verifyFoliage(foliageName, foliageId, reqChannels)
        if hasFoliageLayer(foliageId) then
            local numChannels = getTerrainDetailNumChannels(foliageId)
            if numChannels == reqChannels then
                logInfo(("Foliage-layer check ok: '%s', id=%s, numChnls=%s"):format(tostring(foliageName),tostring(foliageId),tostring(numChannels)))
                return true
            end
        end;
        logInfo(("ERROR! Required foliage-layer '%s' either does not exist (foliageId=%s), or have wrong num-channels (%s)"):format(tostring(foliageName),tostring(foliageId),tostring(numChannels)))
        return false
    end

    local allOK = true
    allOK = verifyFoliage("fmc_manure"              ,g_currentMission.fmcFoliageManure              ,2) and allOK;
    allOK = verifyFoliage("fmc_slurry"              ,g_currentMission.fmcFoliageSlurry              ,1) and allOK;
    allOK = verifyFoliage("fmc_weed"                ,g_currentMission.fmcFoliageWeed                ,3) and allOK;
    allOK = verifyFoliage("fmc_lime"                ,g_currentMission.fmcFoliageLime                ,1) and allOK;
    allOK = verifyFoliage("fmc_fertilizerOrganic"   ,g_currentMission.fmcFoliageFertilizerOrganic   ,2) and allOK;
    allOK = verifyFoliage("fmc_fertilizerSynthetic" ,g_currentMission.fmcFoliageFertilizerSynthetic ,2) and allOK;
    allOK = verifyFoliage("fmc_herbicide"           ,g_currentMission.fmcFoliageHerbicide           ,2) and allOK;
    allOK = verifyFoliage("fmc_soil_pH"             ,g_currentMission.fmcFoliageSoil_pH             ,3) and allOK;
    
    return allOK
end

--
-- TODO: Let the ZZZ_ChoppedStraw mod do this itself, once/if it is changed to support SoilMod's plugin facility
function fmcSoilModPlugins.extra_SupportForChoppedStrawMod(soilMod)
    --
    local function addFruitToDestructiveList(fruitId, layerAttribute)
        local fruitDesc = g_currentMission.fruits[fruitId]
        if fruitDesc ~= nil then
            soilMod.addDestructibleFoliageId(fruitDesc[layerAttribute])
        end
    end

    -- Support for "zzz_ChoppedStraw v1.1.02" by Webalizer
    -- Add the foliage-layer-id's to SoilMod's list of "destructible-foliage-layers by cultivator/plough/seeder"
    addFruitToDestructiveList(FruitUtil.FRUITTYPE_CHOPPEDSTRAW, "preparingOutputId")
    addFruitToDestructiveList(FruitUtil.FRUITTYPE_CHOPPEDMAIZE, "preparingOutputId")
    addFruitToDestructiveList(FruitUtil.FRUITTYPE_CHOPPEDRAPE,  "preparingOutputId")
end

--
function fmcSoilModPlugins.pluginsForCutFruitArea(soilMod)
    --
    -- Additional effects for the Utils.CutFruitArea()
    --

    --
    soilMod.addPlugin_CutFruitArea_after(
        "Volume affected if partial-growth-state for crop",
        1,
        function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
            if fruitDesc.allowsPartialGrowthState then
                dataStore.volume = dataStore.pixelsSum / fruitDesc.maxHarvestingGrowthState
            end
        end
    )
    
    -- Special case; if fertilizerOrganic layer is not there, then add the default "double yield from spray layer" effect.
    if not hasFoliageLayer(g_currentMission.fmcFoliageFertilizerOrganic) then
        soilMod.addPlugin_CutFruitArea_before(
            "Remove spray where min/max-harvesting-growth-state is",
            10,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                if dataStore.destroySpray then
                    setDensityMaskParams(g_currentMission.terrainDetailId, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState);
                    dataStore.spraySum = setDensityMaskedParallelogram(
                        g_currentMission.terrainDetailId, 
                        sx,sz,wx,wz,hx,hz, 
                        g_currentMission.sprayChannel, 1, 
                        dataStore.fruitFoliageId, 0, g_currentMission.numFruitStateChannels, 
                        0 -- value
                    );
                    setDensityMaskParams(g_currentMission.terrainDetailId, "greater", 0);
                end
            end
        )
    end
        
    --
    soilMod.addPlugin_CutFruitArea_before(
        "Set sowing-channel where min/max-harvesting-growth-state is",
        10,
        function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
            if fruitDesc.useSeedingWidth and (dataStore.destroySeedingWidth == nil or dataStore.destroySeedingWidth) then
                setDensityMaskParams(g_currentMission.terrainDetailId, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState); 
                setDensityMaskedParallelogram(
                    g_currentMission.terrainDetailId, 
                    sx,sz,wx,wz,hx,hz, 
                    g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                    dataStore.fruitFoliageId, 0, g_currentMission.numFruitStateChannels, 
                    2^g_currentMission.sowingChannel  -- value
                );
                setDensityMaskParams(g_currentMission.terrainDetailId, "greater", 0);
            end
        end
    )

    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageWeed) then
        soilMod.addPlugin_CutFruitArea_before(
            "Get weed density and cut weed",
            20,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- Get weeds, but only the lower 2 bits (values 0-3), and then set them to zero.
                -- This way weed gets cut, but alive weed will still grow again.
                setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", 0);
                dataStore.weeds = {}
                dataStore.weeds.oldSum, dataStore.weeds.numPixels, dataStore.weeds.newDelta = setDensityParallelogram(
                    g_currentMission.fmcFoliageWeed,
                    sx,sz,wx,wz,hx,hz,
                    0,2,
                    0 -- value
                )
                setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", -1);
            end
        )
        
        soilMod.addPlugin_CutFruitArea_after(
            "Volume is affected by percentage of weeds",
            20,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                if dataStore.weeds.numPixels > 0 then
                    local weedPct = (dataStore.weeds.oldSum / (3 * dataStore.weeds.numPixels)) * (dataStore.weeds.numPixels / dataStore.numPixels)
                    -- Remove some volume that weeds occupy.
                    dataStore.volume = math.max(0, dataStore.volume - (dataStore.volume * weedPct))
                end
            end
        )
    end
    
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageFertilizerOrganic) then
        soilMod.addPlugin_CutFruitArea_before(
            "Get fertilizer(organic) density and reduce",
            20,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- Get fertilizer(organic), and reduce it by one
                setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState);
                dataStore.fertilizerOrganic = {}
                dataStore.fertilizerOrganic.oldSum, dataStore.fertilizerOrganic.numPixels, dataStore.fertilizerOrganic.newDelta = addDensityMaskedParallelogram(
                    g_currentMission.fmcFoliageFertilizerOrganic, 
                    sx,sz,wx,wz,hx,hz,
                    0,2,
                    dataStore.fruitFoliageId,0,g_currentMission.numFruitStateChannels,
                    -1 -- subtract
                )
                setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "greater", -1);
            end
        )
    
        soilMod.addPlugin_CutFruitArea_after(
            "Volume is affected by fertilizer(organic)",
            30,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- SoilManagement does not use spray for "yield".
                dataStore.spraySum = 0
                --
                if dataStore.fertilizerOrganic.numPixels > 0 then
                    local nutrientLevel = dataStore.fertilizerOrganic.oldSum / dataStore.fertilizerOrganic.numPixels
                    -- If nutrition available, then increase volume by 50%-100%
                    if nutrientLevel > 0 then
                        dataStore.volume = dataStore.volume * math.min(2, nutrientLevel+1.5)
                    end
                end
            end
        )
    end
    
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageFertilizerSynthetic) then
        soilMod.addPlugin_CutFruitArea_before(
            "Get fertilizer(synthetic) density and remove",
            20,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- Get fertilizer(synthetic)-A and -B types, and reduce them to zero.
                setDensityMaskParams(g_currentMission.fmcFoliageFertilizerSynthetic, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState);
                dataStore.fertilizerSynthetic1 = {}
                dataStore.fertilizerSynthetic1.oldSum, dataStore.fertilizerSynthetic1.numPixels, dataStore.fertilizerSynthetic1.newDelta = setDensityMaskedParallelogram(
                    g_currentMission.fmcFoliageFertilizerSynthetic, 
                    sx,sz,wx,wz,hx,hz,
                    0,1,
                    dataStore.fruitFoliageId,0,g_currentMission.numFruitStateChannels,
                    0 -- value
                )
                dataStore.fertilizerSynthetic2 = {}
                dataStore.fertilizerSynthetic2.oldSum, dataStore.fertilizerSynthetic2.numPixels, dataStore.fertilizerSynthetic2.newDelta = setDensityMaskedParallelogram(
                    g_currentMission.fmcFoliageFertilizerSynthetic, 
                    sx,sz,wx,wz,hx,hz,
                    1,1,
                    dataStore.fruitFoliageId,0,g_currentMission.numFruitStateChannels,
                    0 -- value
                )
                setDensityMaskParams(g_currentMission.fmcFoliageFertilizerSynthetic, "greater", -1);
            end
        )
    
        soilMod.addPlugin_CutFruitArea_after(
            "Volume is slightly boosted if correct fertilizer(synthetic)",
            40,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                local fertApct = (dataStore.fertilizerSynthetic1.numPixels > 0) and (dataStore.fertilizerSynthetic1.oldSum / dataStore.fertilizerSynthetic1.numPixels) or 0
                local fertBpct = (dataStore.fertilizerSynthetic2.numPixels > 0) and (dataStore.fertilizerSynthetic2.oldSum / dataStore.fertilizerSynthetic2.numPixels) or 0
    
                if fmcSoilModPlugins.simplisticMode then
                    -- Simplistic mode: Fruits get a boost if (any) fertilizer is applied
                    local volumeBoost = 0
                    if fertApct>0 and fertBpct>0 then
                        volumeBoost = (dataStore.numPixels * ((fertApct + fertBpct) / 2)) 
                    elseif fertApct>0 then
                        volumeBoost = (dataStore.numPixels * fertApct)
                    elseif fertBpct>0 then
                        volumeBoost = (dataStore.numPixels * fertBpct)
                    end
                    dataStore.volume = dataStore.volume + volumeBoost
                else
                    -- Advanced mode: Fruits only get a boost from a particular fertilizer
                    local volumeBoost = 0
                    if fertApct>0 and fertBpct>0 then
                        if fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER3 then
                            volumeBoost = (dataStore.numPixels * ((fertApct + fertBpct) / 2)) 
                        end
                    elseif fertApct>0 then
                        if fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER then
                            volumeBoost = (dataStore.numPixels * fertApct)
                        end
                    elseif fertBpct>0 then
                        if fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER2 then
                            volumeBoost = (dataStore.numPixels * fertBpct)
                        end
                    end
                    dataStore.volume = dataStore.volume + volumeBoost
                end
            end
        )
    end

    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageSoil_pH) then
        -- Array of 9 elements... must be sorted! (high, factor)
        fmcSoilModPlugins.fmcSoilpHfactors = {
            {h= 5.1, f=0.05},
            {h= 5.6, f=0.50},
            {h= 6.1, f=0.75},
            {h= 6.6, f=0.95},
            {h= 7.3, f=1.00},   -- neutral
            {h= 7.9, f=0.95},
            {h= 8.5, f=0.90},
            {h= 9.0, f=0.80},
            {h=99.0, f=0.70},
        }
    
        soilMod.addPlugin_CutFruitArea_before(
            "Get soil pH density and reduce",
            20,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- Get soil pH, and reduce by one
                setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState);
                dataStore.soilpH = {}
                dataStore.soilpH.oldSum, dataStore.soilpH.numPixels, dataStore.soilpH.newDelta = addDensityMaskedParallelogram(
                    g_currentMission.fmcFoliageSoil_pH, 
                    sx,sz,wx,wz,hx,hz,
                    0,3,
                    dataStore.fruitFoliageId,0,g_currentMission.numFruitStateChannels,
                    -1 -- subtract
                )
                setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", -1);
            end
        )
    
        soilMod.addPlugin_CutFruitArea_after(
            "Volume is affected by soil pH level",
            50,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                local phValue = 7; -- Default pH value, if setDensity failed to match any pixels or calculation function does not exist.
                if (fmcSoilMod and fmcSoilMod.density_to_pH) then
                    phValue = fmcSoilMod.density_to_pH(dataStore.soilpH.oldSum, dataStore.soilpH.numPixels, 3)
                end
                if fmcSoilModPlugins.simplisticMode then
                    -- Simplistic mode: Soil pH value affects yields, but only when highly acidid.
                    if phValue <= fmcSoilModPlugins.fmcSoilpHfactors[1].h then
                        dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[1].f
                    elseif phValue <= fmcSoilModPlugins.fmcSoilpHfactors[2].h then
                        dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[2].f
                    end
                else
                    -- Advanced mode: Soil pH value affects yields
                    -- TODO - Binary search? Or is that too much for an array of 9 elements?
                    if     phValue <= fmcSoilModPlugins.fmcSoilpHfactors[3].h then
                        if     phValue < fmcSoilModPlugins.fmcSoilpHfactors[1].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[1].f
                        elseif phValue < fmcSoilModPlugins.fmcSoilpHfactors[2].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[2].f
                        else
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[3].f
                        end
                    elseif phValue <= fmcSoilModPlugins.fmcSoilpHfactors[6].h then
                        if     phValue < fmcSoilModPlugins.fmcSoilpHfactors[4].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[4].f
                        elseif phValue < fmcSoilModPlugins.fmcSoilpHfactors[5].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[5].f
                        else
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[6].f
                        end
                    else
                        if     phValue < fmcSoilModPlugins.fmcSoilpHfactors[7].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[7].f
                        elseif phValue < fmcSoilModPlugins.fmcSoilpHfactors[8].h then
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[8].f
                        else
                            dataStore.volume = dataStore.volume * fmcSoilModPlugins.fmcSoilpHfactors[9].f
                        end
                    end
                end
            end
        )
    end
end

--
fmcSoilModPlugins.fmcTYPE_UNKNOWN    = 0
fmcSoilModPlugins.fmcTYPE_PLOUGH     = 2^0
fmcSoilModPlugins.fmcTYPE_CULTIVATOR = 2^1
fmcSoilModPlugins.fmcTYPE_SEEDER     = 2^2

--
function fmcSoilModPlugins.fmcUpdateFmcFoliage(sx,sz,wx,wz,hx,hz, isForced, implementType)
    -- Increase fertilizer(organic)...
    setDensityMaskParams(         g_currentMission.fmcFoliageFertilizerOrganic, "greater", 0);
    -- ..where there's manure, by 1(cultivator) or 3(plough)
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, sx,sz,wx,wz,hx,hz, 0, 2, g_currentMission.fmcFoliageManure, 0, 2, (implementType==fmcSoilModPlugins.fmcTYPE_PLOUGH and 3 or 1));
    -- ..where there's slurry, by 1.
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, sx,sz,wx,wz,hx,hz, 0, 2, g_currentMission.fmcFoliageSlurry, 0, 1, 1);
    
    -- Set "moisture" where there's manure - we're cultivating/plouging it into ground.
    setDensityMaskedParallelogram(g_currentMission.terrainDetailId,             sx,sz,wx,wz,hx,hz, g_currentMission.sprayChannel, 1, g_currentMission.fmcFoliageManure, 0, 2, 1);
    -- Set "moisture" where there's slurry - we're cultivating/plouging it into ground.
    setDensityMaskedParallelogram(g_currentMission.terrainDetailId,             sx,sz,wx,wz,hx,hz, g_currentMission.sprayChannel, 1, g_currentMission.fmcFoliageSlurry, 0, 1, 1);
    
    -- Increase soil pH where there's lime, by 3 - we're cultivating/plouging it into ground.
    setDensityMaskParams(         g_currentMission.fmcFoliageSoil_pH, "greater", 0)
    addDensityMaskedParallelogram(g_currentMission.fmcFoliageSoil_pH,           sx,sz,wx,wz,hx,hz, 0, 3, g_currentMission.fmcFoliageLime, 0, 1, 3);

    -- Remove the manure/slurry/lime we've just cultivated/ploughed into ground.
    setDensityParallelogram(g_currentMission.fmcFoliageManure, sx,sz,wx,wz,hx,hz, 0, 2, 0)
    setDensityParallelogram(g_currentMission.fmcFoliageSlurry, sx,sz,wx,wz,hx,hz, 0, 1, 0)
    setDensityParallelogram(g_currentMission.fmcFoliageLime,   sx,sz,wx,wz,hx,hz, 0, 1, 0)
    -- Remove weed plants - where we're cultivating/ploughing.
    setDensityParallelogram(g_currentMission.fmcFoliageWeed,   sx,sz,wx,wz,hx,hz, 0, 3, 0)
end

--
function fmcSoilModPlugins.pluginsForUpdateCultivatorArea(soilMod)
    --
    -- Additional effects for the Utils.UpdateCultivatorArea()
    --

    soilMod.addPlugin_UpdateCultivatorArea_before(
        "Destroy common area",
        30,
        function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
            Utils.fmcUpdateDestroyCommonArea(sx,sz,wx,wz,hx,hz, not dataStore.commonForced, fmcSoilModPlugins.fmcTYPE_CULTIVATOR);
        end
    )

    -- Only add effect, when all required foliage-layers exists
    if  hasFoliageLayer(g_currentMission.fmcFoliageFertilizerOrganic)
    and hasFoliageLayer(g_currentMission.fmcFoliageSoil_pH)
    and hasFoliageLayer(g_currentMission.fmcFoliageManure)
    and hasFoliageLayer(g_currentMission.fmcFoliageSlurry)
    and hasFoliageLayer(g_currentMission.fmcFoliageLime)
    then
        soilMod.addPlugin_UpdateCultivatorArea_before(
            "Update foliage-layer for SoilMod",
            40,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                fmcSoilModPlugins.fmcUpdateFmcFoliage(sx,sz,wx,wz,hx,hz, dataStore.forced, fmcSoilModPlugins.fmcTYPE_CULTIVATOR)
            end
        )
    end

end

--
function fmcSoilModPlugins.pluginsForUpdatePloughArea(soilMod)
    --
    -- Additional effects for the Utils.UpdatePloughArea()
    --

    soilMod.addPlugin_UpdatePloughArea_before(
        "Destroy common area",
        30,function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
            Utils.fmcUpdateDestroyCommonArea(sx,sz,wx,wz,hx,hz, not dataStore.commonForced, fmcSoilModPlugins.fmcTYPE_PLOUGH);
        end
    )

    -- Only add effect, when all required foliage-layers exists
    if  hasFoliageLayer(g_currentMission.fmcFoliageFertilizerOrganic)
    and hasFoliageLayer(g_currentMission.fmcFoliageSoil_pH)
    and hasFoliageLayer(g_currentMission.fmcFoliageManure)
    and hasFoliageLayer(g_currentMission.fmcFoliageSlurry)
    and hasFoliageLayer(g_currentMission.fmcFoliageLime)
    then
        soilMod.addPlugin_UpdatePloughArea_before(
            "Update foliage-layer for SoilMod",
            40,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                fmcSoilModPlugins.fmcUpdateFmcFoliage(sx,sz,wx,wz,hx,hz, dataStore.forced, fmcSoilModPlugins.fmcTYPE_PLOUGH)
            end
        )
    end
        
end

--
function fmcSoilModPlugins.pluginsForUpdateSowingArea(soilMod)
    --
    -- Additional effects for the Utils.UpdateSowingArea()
    --

    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageWeed) then
        soilMod.addPlugin_UpdateSowingArea_before(
            "Destroy weed plants when sowing",
            30,
            function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
                -- Remove weed plants - where we're seeding.
                setDensityParallelogram(g_currentMission.fmcFoliageWeed, sx,sz,wx,wz,hx,hz, 0, 3, 0)
            end
        )
    end
    
    soilMod.addPlugin_UpdateSowingArea_before(
        "Destroy dynamic foliage-layers",
        40,
        function(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
            Utils.fmcUpdateDestroyDynamicFoliageLayers(sx,sz,wx,wz,hx,hz, true, fmcSoilModPlugins.fmcTYPE_SEEDER)
        end
    )
    
end


--
function fmcSoilModPlugins.pluginsForGrowthCycle(soilMod)
--[[
Growth states

   Density value (from channels/bits)
   |  RegisterFruit value (for RegisterFruit)
   |  |
   0  -  nothing
   1  0  growth-1 (just seeded)
   2  1  growth-2
   3  2  growth-3
   4  3  growth-4
   5  4  harvest-1 / prepare-1
   6  5  harvest-2 / prepare-2
   7  6  harvest-3 / prepare-3
   8  7  withered
   9  8  cutted
  10  9  harvest (defoliaged)
  11 10  <unused>
  12 11  <unused>
  13 12  <unused>
  14 13  <unused>
  15 14  <unused>
--]]
    
    soilMod.addPlugin_GrowthCycleFruits(
        "Increase crop growth",
        10, 
        function(sx,sz,wx,wz,hx,hz,fruitEntry)
            -- Increase growth by 1
            setDensityMaskParams(fruitEntry.fruitId, "between", fruitEntry.minSeededValue, fruitEntry.maxMatureValue - ((fmcGrowthControl.disableWithering or fruitEntry.witheredValue == nil) and 1 or 0))
            addDensityMaskedParallelogram(
              fruitEntry.fruitId,
              sx,sz,wx,wz,hx,hz,
              0, g_currentMission.numFruitStateChannels,
              fruitEntry.fruitId, 0, g_currentMission.numFruitStateChannels, -- mask
              1 -- add one
            )
            setDensityMaskParams(fruitEntry.fruitId, "greater", 0)
        end
    )

    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageHerbicide) then
        soilMod.addPlugin_GrowthCycleFruits(
            "Herbicide affect crop",
            20, 
            function(sx,sz,wx,wz,hx,hz,fruitEntry)
                -- Herbicide may affect growth or cause withering...
                if fruitEntry.herbicideAvoidance ~= nil and fruitEntry.herbicideAvoidance >= 1 and fruitEntry.herbicideAvoidance <= 3 then
                  -- Herbicide affected fruit
                  setDensityMaskParams(fruitEntry.fruitId, "equals", fruitEntry.herbicideAvoidance)
                  -- When growing and affected by wrong herbicide, pause one growth-step
                  setDensityCompareParams(fruitEntry.fruitId, "between", fruitEntry.minSeededValue+1, fruitEntry.minMatureValue)
                  addDensityMaskedParallelogram(
                    fruitEntry.fruitId,
                    sx,sz,wx,wz,hx,hz,
                    0, g_currentMission.numFruitStateChannels,
                    g_currentMission.fmcFoliageHerbicide, 0, 2, -- mask
                    -1 -- subtract one
                  )
                  -- When mature and affected by wrong herbicide, change to withered if possible.
                  if fruitEntry.witheredValue ~= nil then
                    setDensityMaskParams(fruitEntry.fruitId, "equals", fruitEntry.herbicideAvoidance)
                    setDensityCompareParams(fruitEntry.fruitId, "between", fruitEntry.minMatureValue, fruitEntry.maxMatureValue)
                    setDensityMaskedParallelogram(
                        fruitEntry.fruitId,
                        sx,sz,wx,wz,hx,hz,
                        0, g_currentMission.numFruitStateChannels,
                        g_currentMission.fmcFoliageHerbicide, 0, 2, -- mask
                        fruitEntry.witheredValue  -- value
                    )
                  end
                  --
                  setDensityCompareParams(fruitEntry.fruitId, "greater", -1)
                  setDensityMaskParams(fruitEntry.fruitId, "greater", 0)
                end
            end
        )
    end

    if fmcGrowthControl.reduceWindrows then
        soilMod.addPlugin_GrowthCycleFruits(
            "Reduce crop windrows/swath",
            30, 
            function(sx,sz,wx,wz,hx,hz,fruitEntry)
                -- Reduce windrow (gone with the wind)
                if fruitEntry.windrowId ~= nil and fruitEntry.windrowId ~= 0 then
                    setDensityMaskParams(fruitEntry.windrowId, "greater", 0)
                    addDensityMaskedParallelogram(
                        fruitEntry.windrowId,
                        sx,sz,wx,wz,hx,hz,
                        0, g_currentMission.numWindrowChannels,
                        fruitEntry.windrowId, 0, g_currentMission.numWindrowChannels,  -- mask
                        -1  -- subtract one
                    );
                    setDensityMaskParams(fruitEntry.windrowId, "greater", -1)
                end
            end
        )
    end

    
    -- Spray moisture
    if fmcGrowthControl.removeSprayMoisture then
        soilMod.addPlugin_GrowthCycle(
            "Remove spray moisture",
            10, 
            function(sx,sz,wx,wz,hx,hz)
                -- Remove moistness (spray)
                setDensityParallelogram(
                    g_currentMission.terrainDetailId,
                    sx,sz,wx,wz,hx,hz,
                    g_currentMission.sprayChannel, 1,
                    0  -- value
                );
            end
        )
    end

    --Lime/Kalk and soil pH
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageLime) then
        if hasFoliageLayer(g_currentMission.fmcFoliageSoil_pH) then
            soilMod.addPlugin_GrowthCycle(
                "Increase soil pH where there is lime",
                20 - 1, 
                function(sx,sz,wx,wz,hx,hz)
                    -- Increase soil-pH, where lime is
                    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", 0);
                    addDensityMaskedParallelogram(
                        g_currentMission.fmcFoliageSoil_pH,
                        sx,sz,wx,wz,hx,hz,
                        0, 3,
                        g_currentMission.fmcFoliageLime, 0, 1,
                        2  -- increase
                    );
                    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", -1);
                end
            )
        end

        soilMod.addPlugin_GrowthCycle(
            "Remove lime",
            20, 
            function(sx,sz,wx,wz,hx,hz)
                -- Remove lime
                setDensityParallelogram(
                    g_currentMission.fmcFoliageLime,
                    sx,sz,wx,wz,hx,hz,
                    0, 1,
                    0  -- value
                );
            end
        )
    end

    -- Manure
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageManure) then
        soilMod.addPlugin_GrowthCycle(
            "Reduce manure",
            30, 
            function(sx,sz,wx,wz,hx,hz)
                -- Decrease solid manure
                addDensityParallelogram(
                    g_currentMission.fmcFoliageManure,
                    sx,sz,wx,wz,hx,hz,
                    0, 2,
                    -1  -- subtract one
                );
            end
        )
    end

    -- Slurry/LiquidManure
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageSlurry) then
        if hasFoliageLayer(g_currentMission.fmcFoliageFertilizerOrganic) then
            soilMod.addPlugin_GrowthCycle(
                "Set fertilizer(organic) where there is slurry",
                40 - 1, 
                function(sx,sz,wx,wz,hx,hz)
                    -- Set fertilizer(organic) at level-1 only.
                    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "greater", 0);
                    setDensityMaskedParallelogram(
                        g_currentMission.fmcFoliageFertilizerOrganic,
                        sx,sz,wx,wz,hx,hz,
                        0, 1,
                        g_currentMission.fmcFoliageSlurry, 0, 1,  -- mask
                        1 -- value
                    );
                    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "greater", -1);
                end
            )
        end
        
        soilMod.addPlugin_GrowthCycle(
            "Remove slurry",
            40, 
            function(sx,sz,wx,wz,hx,hz)
                -- Remove liquid manure
                setDensityParallelogram(
                    g_currentMission.fmcFoliageSlurry,
                    sx,sz,wx,wz,hx,hz,
                    0, 1,
                    0
                );
            end
        )
    end

    -- Weed and herbicide
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageWeed) then
        soilMod.addPlugin_GrowthCycle(
            "Reduce withered weed",
            50 - 2, 
            function(sx,sz,wx,wz,hx,hz)
                -- Decrease "dead" weed
                setDensityCompareParams(g_currentMission.fmcFoliageWeed, "between", 1, 3)
                addDensityParallelogram(
                    g_currentMission.fmcFoliageWeed,
                    sx,sz,wx,wz,hx,hz,
                    0, 3,
                    -1  -- subtract
                );
            end
        )

        --
        if hasFoliageLayer(g_currentMission.fmcFoliageHerbicide) then
            soilMod.addPlugin_GrowthCycle(
                "Change weed to withered where there is herbicide",
                50 - 1, 
                function(sx,sz,wx,wz,hx,hz)
                    -- Change to "dead" weed
                    setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", 0)
                    setDensityMaskParams(g_currentMission.fmcFoliageWeed, "greater", 0)
                    setDensityMaskedParallelogram(
                        g_currentMission.fmcFoliageWeed,
                        sx,sz,wx,wz,hx,hz,
                        2, 1, -- affect only Most-Significant-Bit
                        g_currentMission.fmcFoliageHerbicide, 0, 2, -- mask
                        0 -- reset bit
                    )
                    setDensityMaskParams(g_currentMission.fmcFoliageWeed, "greater", -1)
                end
            )
        end

        soilMod.addPlugin_GrowthCycle(
            "Increase weed growth",
            50, 
            function(sx,sz,wx,wz,hx,hz)
                -- Increase "alive" weed
                setDensityCompareParams(g_currentMission.fmcFoliageWeed, "between", 4, 6)
                addDensityParallelogram(
                    g_currentMission.fmcFoliageWeed,
                    sx,sz,wx,wz,hx,hz,
                    0, 3,
                    1  -- increase
                );
                setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", -1)
            end
        )
    end

    -- Herbicide and soil pH
    -- Only add effect, when required foliage-layer exist
    if hasFoliageLayer(g_currentMission.fmcFoliageHerbicide) then
        if hasFoliageLayer(g_currentMission.fmcFoliageSoil_pH) then
            soilMod.addPlugin_GrowthCycle(
                "Reduce soil pH where there is herbicide",
                60 - 1, 
                function(sx,sz,wx,wz,hx,hz)
                    -- Decrease soil-pH, where herbicide is
                    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", 0)
                    addDensityMaskedParallelogram(
                        g_currentMission.fmcFoliageSoil_pH,
                        sx,sz,wx,wz,hx,hz,
                        0, 3,
                        g_currentMission.fmcFoliageHerbicide, 0, 2, -- mask
                        -1  -- decrease
                    );
                    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", -1)
                end
            )
        end

        soilMod.addPlugin_GrowthCycle(
            "Remove herbicide",
            60, 
            function(sx,sz,wx,wz,hx,hz)
                -- Remove herbicide
                setDensityParallelogram(
                    g_currentMission.fmcFoliageHerbicide,
                    sx,sz,wx,wz,hx,hz,
                    0, 2,
                    0  -- value
                );
            end
        )
    end

end

--
print(string.format("Script loaded: fmcSoilModPlugins.lua (v%s)", fmcSoilModPlugins.version));
