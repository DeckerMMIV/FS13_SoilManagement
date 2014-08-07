--
--  The Soil Management and Growth Control Project
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-05-xx
--
-- @history
--  2014-July
--      0.5.3   - Tweaked soil pH effect on harvest yield.
--      0.5.4   - Fix for calling getDensityMapFileName() with an 'unknown entity id: 0'
--      ------
--  Revision history is now kept in GitHub repository.
--

fmcModifyFSUtils = {}

--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
fmcModifyFSUtils.version = (modItem and modItem.version) and modItem.version or "?.?.?";

-- To control in what growth-state range, that the synthetic fertilizer gets "into the ground".
fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState = 2  -- 2 = second growing state of crops.
fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState  = 4  -- 4 = fourth growing state of crops.

--
function fmcModifyFSUtils.preSetup()
    -- We need a different array of dynamic-foliage-layers, to be used in Utils.updateDestroyCommonArea()
    g_currentMission.fmcDynamicFoliageLayers = {}
    for _,foliageId in ipairs(g_currentMission.dynamicFoliageLayers) do
        fmcModifyFSUtils.addDestructibleFoliageId(foliageId)
    end
end

function fmcModifyFSUtils.addDestructibleFoliageId(foliageId)
    if foliageId ~= nil and foliageId ~= 0 then
        table.insert(g_currentMission.fmcDynamicFoliageLayers, foliageId)
        logInfo(("Included foliage-layer for \"destruction\" by plough/cultivator/seeder: '%s', id=%s, numChnls=%s"):format(getName(foliageId), foliageId, getTerrainDetailNumChannels(foliageId)))
    end
end

--
function fmcModifyFSUtils.setup(simplisticMode)
    fmcModifyFSUtils.simplisticMode = simplisticMode

    -- Remember original functions...
    logInfo("Remembering original functions from 'Utils'")
    fmcModifyFSUtils.origFuncs = {}
    fmcModifyFSUtils.origFuncs["cutFruitArea"]              = Utils.cutFruitArea;
    fmcModifyFSUtils.origFuncs["updateCultivatorArea"]      = Utils.updateCultivatorArea;
    fmcModifyFSUtils.origFuncs["updatePloughArea"]          = Utils.updatePloughArea;
    fmcModifyFSUtils.origFuncs["updateSowingArea"]          = Utils.updateSowingArea;
    fmcModifyFSUtils.origFuncs["updateDestroyCommonArea"]   = Utils.updateDestroyCommonArea;
    fmcModifyFSUtils.origFuncs["updateSprayArea"]           = Utils.updateSprayArea;

    --
    Utils.fmcDensityMapsFirstFruitId = nil
    -- Overwrite functions with custom...
    fmcModifyFSUtils.overwriteCutFruitArea()
    fmcModifyFSUtils.overwriteUpdateCultivatorArea()
    fmcModifyFSUtils.overwriteUpdatePloughArea()
    fmcModifyFSUtils.overwriteUpdateSowingArea()
    fmcModifyFSUtils.overwriteUpdateDestroyCommonArea()
    fmcModifyFSUtils.overwriteUpdateSprayArea()
    --
    fmcModifyFSUtils.setSpraySubFuncs()
end

--
function fmcModifyFSUtils.teardown()
    if fmcModifyFSUtils.origFuncs ~= nil then
        -- Restore functions to original...
        logInfo("Restoring original functions in 'Utils'")
        for funcName,func in pairs(fmcModifyFSUtils.origFuncs) do
            Utils[funcName] = func;
        end
        fmcModifyFSUtils.origFuncs = nil;
    end
end

--
function fmcModifyFSUtils.overwriteCutFruitArea()

    logInfo("Overwriting Utils.cutFruitArea")
    
    Utils.cutFruitArea = function(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, destroySpray, destroySeedingWidth)
        local ids = g_currentMission.fruits[fruitId];
        if ids == nil or ids.id == 0 then
            return 0;
        end
        -- fruitDesc and the world-location are CONSTANTS! Do NOT modify, not even in the plugins!
        local fruitDesc = FruitUtil.fruitIndexToDesc[fruitId];
        local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
        
        -- dataStore is a 'dictionary'. Plugins can add additional elements (using very unique names) or modify the given ones if needed.
        local dataStore = {}
        dataStore.fruitFoliageId            = ids.id
        dataStore.minHarvestingGrowthState  = fruitDesc.minHarvestingGrowthState+1 -- add 1 since growth state 0 has density value 1
        dataStore.maxHarvestingGrowthState  = fruitDesc.maxHarvestingGrowthState+1 -- add 1 since growth state 0 has density value 1
        dataStore.cutState                  = fruitDesc.cutState+1;                -- add 1 since growth state 0 has density value 1
        dataStore.destroySeedingWidth       = destroySeedingWidth
        dataStore.destroySpray              = destroySpray
        dataStore.spraySum                  = 0
    
        -- Setup phase - If any plugin needs to modify anything in dataStore
        for _,callFunc in pairs(Utils.fmcPluginsCutFruitAreaSetup) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
        
        -- Pre-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, before the default "cutting" occurs.
        for _,callFunc in pairs(Utils.fmcPluginsCutFruitAreaPreFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
        
        -- Default "cutting" phase
        setDensityReturnValueShift(dataStore.fruitFoliageId, -1); -- if no fruit is there, the value is 0 or 1, thus we need to shift by -1, to get values from 0-4, where 0 is no and 4 is full
        setDensityCompareParams(dataStore.fruitFoliageId, "between", dataStore.minHarvestingGrowthState, dataStore.maxHarvestingGrowthState);
        dataStore.pixelsSum, dataStore.numPixels = setDensityParallelogram(dataStore.fruitFoliageId, sx,sz,wx,wz,hx,hz, 0, g_currentMission.numFruitStateChannels, dataStore.cutState);
        setDensityCompareParams(dataStore.fruitFoliageId, "greater", -1);
        setDensityReturnValueShift(dataStore.fruitFoliageId, 0);
    
        dataStore.volume = dataStore.numPixels
        
        -- Post-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, after the default "cutting" have been done.
        for _,callFunc in pairs(Utils.fmcPluginsCutFruitAreaPostFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
    
        --
        return dataStore.volume, dataStore.numPixels, dataStore.spraySum
    end

end  

--
function fmcModifyFSUtils.overwriteUpdateCultivatorArea()

    logInfo("Overwriting Utils.updateCultivatorArea")
  
    Utils.updateCultivatorArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)
        local dataStore = {}
        dataStore.forced        = Utils.getNoNil(forced, true);
        dataStore.commonForced  = Utils.getNoNil(commonForced, true);
        dataStore.angle         = angle
        dataStore.area          = 0;
        
        local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    
        -- Setup phase - If any plugin needs to modify anything in dataStore
        for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaSetup) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end
        
        -- Pre-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, before the default "cultivating" occurs.
        for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaPreFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end
    
        -- Default "cultivating"
        if dataStore.forced then
            dataStore.area = dataStore.area + setDensityParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                2^g_currentMission.cultivatorChannel
            );
            if dataStore.angle ~= nil then
                setDensityParallelogram(
                    g_currentMission.terrainDetailId, 
                    sx,sz,wx,wz,hx,hz, 
                    g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                    dataStore.angle
                );
            end
        else
            dataStore.area = dataStore.area + setDensityMaskedParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                2^g_currentMission.cultivatorChannel
            );
            if dataStore.angle ~= nil then
                setDensityMaskedParallelogram(
                    g_currentMission.terrainDetailId, 
                    sx,sz,wx,wz,hx,hz, 
                    g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                    g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                    dataStore.angle
                );
            end
        end
    
        -- Post-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, after the default "cultivating" have been done.
        for _,callFunc in pairs(Utils.fmcPluginsUpdateCultivatorAreaPostFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end
        
        return dataStore.area;
    end

end

--
function fmcModifyFSUtils.overwriteUpdatePloughArea()

    logInfo("Overwriting Utils.updatePloughArea")

    Utils.updatePloughArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)
        local dataStore = {}
        dataStore.forced        = Utils.getNoNil(forced, true);
        dataStore.commonForced  = Utils.getNoNil(commonForced, true);
        dataStore.angle         = angle
        dataStore.area          = 0;
        
        local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    
        -- Setup phase - If any plugin needs to modify anything in dataStore
        for _,callFunc in pairs(Utils.fmcPluginsUpdatePloughAreaSetup) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end
        
        -- Pre-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, before the default "ploughing" occurs.
        for _,callFunc in pairs(Utils.fmcPluginsUpdatePloughAreaPreFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end

        -- Default "ploughing"
        if dataStore.forced then
            dataStore.area = dataStore.area + setDensityParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                2^g_currentMission.ploughChannel
            );
            if dataStore.angle ~= nil then
                setDensityParallelogram(
                    g_currentMission.terrainDetailId, 
                    sx,sz,wx,wz,hx,hz, 
                    g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                    dataStore.angle
                );
            end
        else
            dataStore.area = dataStore.area + setDensityMaskedParallelogram(
                g_currentMission.terrainDetailId, 
                sx,sz,wx,wz,hx,hz, 
                g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                2^g_currentMission.ploughChannel
            );
            if dataStore.angle ~= nil then
                setDensityMaskedParallelogram(
                    g_currentMission.terrainDetailId, 
                    sx,sz,wx,wz,hx,hz, 
                    g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, 
                    g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                    dataStore.angle
                );
            end
        end
    
        -- Post-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, after the default "ploughing" have been done.
        for _,callFunc in pairs(Utils.fmcPluginsUpdatePloughAreaPostFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, nil)
        end
        
        return dataStore.area;
    end
    
end

--
function fmcModifyFSUtils.overwriteUpdateSowingArea()

    logInfo("Overwriting Utils.updateSowingArea")
    
    Utils.updateSowingArea = function(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting)
        local ids = g_currentMission.fruits[fruitId];
        if ids == nil or ids.id == 0 then
            return 0;
        end
        
        -- fruitDesc and the world-location are CONSTANTS! Do NOT modify, not even in the plugins!
        local fruitDesc = FruitUtil.fruitIndexToDesc[fruitId];
        local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(ids.id, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    
        -- dataStore is a 'dictionary'. Plugins can add additional elements (using very unique names) or modify the given ones if needed.
        local dataStore = {}
        dataStore.fruitFoliageId    = ids.id
        dataStore.angle             = Utils.getNoNil(angle, 0);
        dataStore.useDirectPlanting = Utils.getNoNil(useDirectPlanting, false);
        dataStore.plantValue        = 1;
    
        if fruitDesc.useSeedingWidth then
            dataStore.sowingAddChannel = g_currentMission.sowingWidthChannel;
        else
            dataStore.sowingAddChannel = g_currentMission.sowingChannel;
        end
    
        if not dataStore.useDirectPlanting then
            dataStore.excludeMask = 2^g_currentMission.sowingChannel + 2^g_currentMission.sowingWidthChannel;
        else
            dataStore.excludeMask = 0;
        end
    
        if fruitId == FruitUtil.FRUITTYPE_GRASS then
            dataStore.value = 0;
        else
            dataStore.value = 2^dataStore.sowingAddChannel;
        end
        
        -- Setup phase - If any plugin needs to modify anything in dataStore
        for _,callFunc in pairs(Utils.fmcPluginsUpdateSowingAreaSetup) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
        
        -- Pre-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, before the default "seeding" occurs.
        for _,callFunc in pairs(Utils.fmcPluginsUpdateSowingAreaPreFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
    
        -- Default "seeding"
        setDensityMaskParams(dataStore.fruitFoliageId, "greater", 0, 0, 0, dataStore.excludeMask);
        -- change fruit twice, once with values greater than the plant value and once with values smaller than the plant value (==0)
        -- do not change (and count) the already planted areas
        setDensityCompareParams(dataStore.fruitFoliageId, "greater", dataStore.plantValue);
        -- Note: we plant numFruitDensityMapChannels, to destroy windrows etc.
        dataStore.pixelsSum1, dataStore.numPixels1, dataStore.totalPixels1 = setDensityMaskedParallelogram(dataStore.fruitFoliageId, sx,sz,wx,wz,hx,hz, 0, g_currentMission.numFruitDensityMapChannels, g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, dataStore.plantValue);
        setDensityCompareParams(dataStore.fruitFoliageId, "equals", 0);
        dataStore.pixelsSum2, dataStore.numPixels2, dataStore.totalPixels2 = setDensityMaskedParallelogram(dataStore.fruitFoliageId, sx,sz,wx,wz,hx,hz, 0, g_currentMission.numFruitDensityMapChannels, g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, dataStore.plantValue);
        setDensityCompareParams(dataStore.fruitFoliageId, "greater", -1);
        setDensityMaskParams(dataStore.fruitFoliageId, "greater", 0);
        -- add the sowing area and remove the other types
        setDensityMaskParams(g_currentMission.terrainDetailId, "greater", 0, 0, 0, dataStore.excludeMask);
        dataStore.pixelsDetailSum, dataStore.numDetailPixels = setDensityMaskedParallelogram(g_currentMission.terrainDetailId, sx,sz,wx,wz,hx,hz, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, dataStore.value);
        setDensityMaskParams(g_currentMission.terrainDetailId, "greater", 0);
        if dataStore.value > 0 then
            setDensityMaskedParallelogram(g_currentMission.terrainDetailId, sx,sz,wx,wz,hx,hz, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, g_currentMission.terrainDetailId, dataStore.sowingAddChannel, 1, dataStore.angle);
        end
        dataStore.numPixels = dataStore.numPixels1 + dataStore.numPixels2;
    
        -- Post-call phase - Give plugins the possibility to affect foliage-layer(s) and dataStore, after the default "seeding" have been done.
        for _,callFunc in pairs(Utils.fmcPluginsUpdateSowingAreaPostFuncs) do
            callFunc(sx,sz,wx,wz,hx,hz, dataStore, fruitDesc)
        end
    
        return dataStore.numPixels, dataStore.numDetailPixels;
    end

end


--#### DECKER_MMIV ############################################################
-- Inspired by BlueTiger's InGameMenuEnhancement mod
Utils.fmcBuildDensityMaps = function()
    Utils.fmcDensityMapsFirstFruitId = {}
    local densityMapFiles = {}
    for _,entry in pairs(g_currentMission.fruits) do
        if entry.id ~= nil and entry.id ~= 0 then
            local densityMapFile = getDensityMapFileName(entry.id)
            if not densityMapFiles[densityMapFile] then
                densityMapFiles[densityMapFile] = true
                table.insert(Utils.fmcDensityMapsFirstFruitId, {id = entry.id})
            end
        end
    end
end

-- A slightly optimized and modified 'updateDestroyCommonArea()', though this function requires different coordinate parameters!
Utils.fmcUpdateDestroyCommonArea = function(sx,sz,wx,wz,hx,hz, limitToField, implementType)
    --
    if Utils.fmcDensityMapsFirstFruitId == nil then
        Utils.fmcBuildDensityMaps(); -- support for multiple foliage-multi-layers (i.e. maps with several FMLs each containing up to 15 fruits/foliage-sub-layers)
    end

    -- destroy all fruits
    for _,entry in pairs(Utils.fmcDensityMapsFirstFruitId) do
        setDensityNewTypeIndexMode(    entry.id, 2) --SET_INDEX_TO_ZERO);
        setDensityTypeIndexCompareMode(entry.id, 2) --TYPE_COMPARE_NONE);

        -- note: this assumes entry.id has the lowest channel offset
        if limitToField == true then
            setDensityMaskedParallelogram(
                entry.id, 
                sx,sz,wx,wz,hx,hz, 
                0, g_currentMission.numFruitDensityMapChannels, 
                g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                0
            );
        else
            setDensityParallelogram(      
                entry.id, 
                sx,sz,wx,wz,hx,hz, 
                0, g_currentMission.numFruitDensityMapChannels, 
                0
            );
        end

        setDensityNewTypeIndexMode(    entry.id, 0) --UPDATE_INDEX);
        setDensityTypeIndexCompareMode(entry.id, 0) --TYPE_COMPARE_EQUAL);
    end

    Utils.fmcUpdateDestroyDynamicFoliageLayers(sx,sz,wx,wz,hx,hz, limitToField, implementType)
end

-- Extracted from fmcUpdateDestroyCommonArea, due to support for the zzz_ChoppedStraw mod
Utils.fmcUpdateDestroyDynamicFoliageLayers = function(sx,sz,wx,wz,hx,hz, limitToField, implementType)
    if limitToField == true then
        for _,id in ipairs(g_currentMission.fmcDynamicFoliageLayers) do
            setDensityMaskedParallelogram(
                id, 
                sx,sz,wx,wz,hx,hz, 
                0, getTerrainDetailNumChannels(id), 
                g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 
                0
            );
        end
    else
        for _,id in ipairs(g_currentMission.fmcDynamicFoliageLayers) do
            setDensityParallelogram( 
                id, 
                sx,sz,wx,wz,hx,hz, 
                0, getTerrainDetailNumChannels(id), 
                0
            );
        end
    end
end


function fmcModifyFSUtils.overwriteUpdateDestroyCommonArea()

  logInfo("Overwriting Utils.updateDestroyCommonArea")
  
  Utils.updateDestroyCommonArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, limitToField)
    local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    Utils.fmcUpdateDestroyCommonArea(sx,sz,wx,wz,hx,hz, limitToField)
  end
  
end  
--#############################################################################



function fmcModifyFSUtils.overwriteUpdateSprayArea()

  -- Modified to also take extra argument: 'augmentedFillType'
  logInfo("Overwriting Utils.updateSprayArea")
  
  Utils.updateSprayArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, augmentedFillType)

    local sx,sz,wx,wz,hx,hz = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    local moistureValue = 1
    
    -- If augmentedFillType has custom update-spray-area function, then call it...
    -- ..this "should" be faster instead of having huge if-then-elseif-then-elseif-then-etc. code blocks.
    if augmentedFillType ~= nil and Utils.fmcUpdateSprayAreaFillTypeFuncs[augmentedFillType] ~= nil then
        if not Utils.fmcUpdateSprayAreaFillTypeFuncs[augmentedFillType](sx,sz,wx,wz,hx,hz) then
            moistureValue = 0
        end
    end

    local _, numPixels = addDensityMaskedParallelogram(g_currentMission.terrainDetailId, sx,sz,wx,wz,hx,hz, g_currentMission.sprayChannel, 1, g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, moistureValue);

    return numPixels;
  end

end
  

--#### DECKER_MMIV ############################################################
function fmcModifyFSUtils.setSpraySubFuncs()

    local function hasFoliageLayer(foliageId)
        return (foliageId ~= nil and foliageId ~= 0);
    end

    Utils.fmcUpdateSprayAreaFillTypeFuncs = {}

    if hasFoliageLayer(g_currentMission.fmcFoliageManure) then
        if Fillable.FILLTYPE_MANURE ~= nil then
            local foliageId       = g_currentMission.fmcFoliageManure
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2^numChannels - 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURE] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_MANURESOLID ~= nil then
            local foliageId       = g_currentMission.fmcFoliageManure
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2^numChannels - 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURESOLID] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_SOLIDMANURE ~= nil then
            local foliageId       = g_currentMission.fmcFoliageManure
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2^numChannels - 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_SOLIDMANURE] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return false -- No moisture!
            end
        end
    end

    if hasFoliageLayer(g_currentMission.fmcFoliageSlurry) then
        if Fillable.FILLTYPE_LIQUIDMANURE ~= nil then
            local foliageId       = g_currentMission.fmcFoliageSlurry
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_LIQUIDMANURE] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_MANURELIQUID ~= nil then
            local foliageId       = g_currentMission.fmcFoliageSlurry
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURELIQUID] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
    end

    if hasFoliageLayer(g_currentMission.fmcFoliageLime) then
        if Fillable.FILLTYPE_LIME ~= nil then
            local foliageId       = g_currentMission.fmcFoliageLime
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2^numChannels - 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_LIME] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_KALK ~= nil then
            local foliageId       = g_currentMission.fmcFoliageLime
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2^numChannels - 1
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_KALK] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return false -- No moisture!
            end
        end
    end

    if hasFoliageLayer(g_currentMission.fmcFoliageHerbicide) then
        if Fillable.FILLTYPE_HERBICIDE ~= nil then
            local foliageId       = g_currentMission.fmcFoliageHerbicide
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 1 -- type-A
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_HERBICIDE2 ~= nil then
            local foliageId       = g_currentMission.fmcFoliageHerbicide
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 2 -- type-B
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE2] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_HERBICIDE3 ~= nil then
            local foliageId       = g_currentMission.fmcFoliageHerbicide
            local numChannels     = getTerrainDetailNumChannels(foliageId)
            local value           = 3 -- type-C
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE3] = function(sx,sz,wx,wz,hx,hz)
                setDensityParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
    end

    if hasFoliageLayer(g_currentMission.fmcFoliageFertilizerSynthetic) then
        local fruitLayer = g_currentMission.fruits[1]
        -- TODO - add support for multiple FMLs
        if fruitLayer ~= nil and fruitLayer.id ~= 0 then
            if Fillable.FILLTYPE_FERTILIZER ~= nil then
                local fruitLayerId = g_currentMission.fruits[1].id
                local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                local numChannels  = getTerrainDetailNumChannels(foliageId)
                local value        = 1 -- type-A
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
                
                -- Support for URF-seeders, using a special "augmented fill-type" value (i.e. "<fillType> + 128").
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER + 128] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 0, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
            end
            if Fillable.FILLTYPE_FERTILIZER2 ~= nil then
                local fruitLayerId = g_currentMission.fruits[1].id
                local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                local numChannels  = getTerrainDetailNumChannels(foliageId)
                local value        = 2 -- type-B
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER2] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end

                -- Support for URF-seeders, using a special "augmented fill-type" value (i.e. "<fillType> + 128").
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER2 + 128] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 0, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
            end
            if Fillable.FILLTYPE_FERTILIZER3 ~= nil then
                local fruitLayerId = g_currentMission.fruits[1].id
                local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                local numChannels  = getTerrainDetailNumChannels(foliageId)
                local value        = 3 -- type-C
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER3] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
                
                -- Support for URF-seeders, using a special "augmented fill-type" value (i.e. "<fillType> + 128").
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER3 + 128] = function(sx,sz,wx,wz,hx,hz)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 0, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
                    setDensityMaskedParallelogram(foliageId, sx,sz,wx,wz,hx,hz, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end                
            end
        end
    end

    --
    local msg = nil
    for fillType,func in pairs(Utils.fmcUpdateSprayAreaFillTypeFuncs) do
        if func ~= nil and Fillable.fillTypeIntToName[fillType] ~= nil then
            msg = (msg==nil and "" or (msg..", ")) .. Fillable.fillTypeIntToName[fillType]
        end
    end
    if msg ~= nil then
        logInfo("Additional updateSprayArea sub-functions added for fillTypes: "..msg)
    end
end
--#############################################################################

print(string.format("Script loaded: fmcModifyFSUtils.lua (v%s)", fmcModifyFSUtils.version));
