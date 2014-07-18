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
--

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

  -- Array of 9 elements... must be sorted! (high, factor)
  Utils.fmcSoilpHfactors = {
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
  
  --
  Utils.cutFruitArea = function(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, destroySpray, destroySeedingWidth)
    local ids = g_currentMission.fruits[fruitId];
    if ids == nil or ids.id == 0 then
        return 0;
    end
    local id = ids.id;
    local desc = FruitUtil.fruitIndexToDesc[fruitId];
    local value = desc.cutState+1;
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(id, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

    local detailId = g_currentMission.terrainDetailId;
--#### DECKER_MMIV ############################################################
    --local spraySum = 0;
    --if destroySpray then
    --    setDensityMaskParams(detailId, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
    --    spraySum = setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.sprayChannel, 1, id, 0, g_currentMission.numFruitStateChannels, 0);
    --    setDensityMaskParams(detailId, "greater", 0);
    --end
--#############################################################################
    if desc.useSeedingWidth and (destroySeedingWidth == nil or destroySeedingWidth) then
        setDensityMaskParams(detailId, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
        local detailTypeValue = 2^g_currentMission.sowingChannel;
        setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, id, 0, g_currentMission.numFruitStateChannels, detailTypeValue);
        setDensityMaskParams(detailId, "greater", 0);
    end

--#### DECKER_MMIV ############################################################
    -- Get fertilizer(organic), and reduce it by one
    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
    local oldOrganicSum, numOrganicPixels, newOrganicDelta = addDensityMaskedParallelogram(
        g_currentMission.fmcFoliageFertilizerOrganic, 
        x, z, widthX, widthZ, heightX, heightZ,
        0,2,
        id,0,g_currentMission.numFruitStateChannels,
        -1 -- subtract
    )
    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerOrganic, "greater", -1);
    
    -- Get fertilizer(synthetic)-A and -B types, and reduce them to zero.
    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerSynthetic, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
    local oldSynthetic1Sum, numSynthetic1Pixels, newSynthetic1Delta = setDensityMaskedParallelogram(
        g_currentMission.fmcFoliageFertilizerSynthetic, 
        x, z, widthX, widthZ, heightX, heightZ,
        0,1,
        id,0,g_currentMission.numFruitStateChannels,
        0 -- value
    )
    local oldSynthetic2Sum, numSynthetic2Pixels, newSynthetic2Delta = setDensityMaskedParallelogram(
        g_currentMission.fmcFoliageFertilizerSynthetic, 
        x, z, widthX, widthZ, heightX, heightZ,
        1,1,
        id,0,g_currentMission.numFruitStateChannels,
        0 -- value
    )
    setDensityMaskParams(g_currentMission.fmcFoliageFertilizerSynthetic, "greater", -1);
    
    -- Get soil pH, and reduce by one
    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
    local oldSoilphSum, numSoilphPixels, newSoilphDelta = addDensityMaskedParallelogram(
        g_currentMission.fmcFoliageSoil_pH, 
        x, z, widthX, widthZ, heightX, heightZ,
        0,3,
        id,0,g_currentMission.numFruitStateChannels,
        -1 -- subtract
    )
    setDensityMaskParams(g_currentMission.fmcFoliageSoil_pH, "greater", -1);
    
    -- Get weeds, but only the lower 2 bits (values 0-3), and then set them to zero.
    -- This way weed gets cut, but alive weed will still grow again.
    setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", 0);
    local oldWeedSum, numWeedPixels, newWeedDelta = setDensityParallelogram(
        g_currentMission.fmcFoliageWeed,
        x, z, widthX, widthZ, heightX, heightZ,
        0,2,
        0 -- value
    )
    setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", -1);
--#############################################################################
    -- if no fruit is there, the value is 0 or 1, thus we need to shift by -1, to get values from 0-4, where 0 is no and 4 is full
    setDensityReturnValueShift(id, -1);
    setDensityCompareParams(id, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1); -- add 1 since growth state 0 has density value 1
    local pixelsSum, numPixels = setDensityParallelogram(id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitStateChannels, value);
    setDensityCompareParams(id, "greater", -1);
    setDensityReturnValueShift(id, 0);
--#### DECKER_MMIV ############################################################
    --if desc.allowsPartialGrowthState then
    --    return pixelsSum / desc.maxHarvestingGrowthState, numPixels, spraySum;
    --else
    --    return numPixels, numPixels, spraySum;
    --end
    local volume = numPixels
    if desc.allowsPartialGrowthState then
        volume = pixelsSum / desc.maxHarvestingGrowthState
    end
    if volume > 0 then

        local nutrientLevel = (numOrganicPixels    >0) and   (oldOrganicSum    / numOrganicPixels)  or 0
        local fertApct      = (numSynthetic1Pixels >0) and   (oldSynthetic1Sum / numSynthetic1Pixels)  or 0
        local fertBpct      = (numSynthetic2Pixels >0) and   (oldSynthetic2Sum / numSynthetic2Pixels)  or 0
        local weedPct       = (numWeedPixels       >0) and  ((oldWeedSum       / (3*numWeedPixels)) * (numWeedPixels/numPixels))  or 0
        --local phOffsetPct   = (numSoilphPixels     >0) and (((oldSoilphSum     / (7*numSoilphPixels)) - 0.5) * 2)  or 0
        local phValue = 7; -- Default pH value, if setDensity failed to match any pixels or calculation function does not exist.
        if (fmcSoilMod and fmcSoilMod.density_to_pH) then
            phValue = fmcSoilMod.density_to_pH(oldSoilphSum, numSoilphPixels, 3)
        end

        -- Remove some volume that weeds occupy.
        volume = math.max(0, volume - (volume * weedPct))

        -- If nutrition available, then increase volume by 50%-100%
        volume = (nutrientLevel>0) and (volume * math.min(2, nutrientLevel+1.5)) or volume

        if fmcModifyFSUtils.simplisticMode then
            -- Simplistic mode: Fruits get a boost if (any) fertilizer is applied
            local volumeBoost = 0
            if fertApct>0 and fertBpct>0 then
                volumeBoost = (numPixels * ((fertApct + fertBpct) / 2)) 
            elseif fertApct>0 then
                volumeBoost = (numPixels * fertApct)
            elseif fertBpct>0 then
                volumeBoost = (numPixels * fertBpct)
            end
            volume = volume + volumeBoost

            -- Simplistic mode: Soil pH value affects yields, but only when highly acidid.
            if phValue <= Utils.fmcSoilpHfactors[1].h then
                volume = volume * Utils.fmcSoilpHfactors[1].f
            elseif phValue <= Utils.fmcSoilpHfactors[2].h then
                volume = volume * Utils.fmcSoilpHfactors[2].f
            end
        else
            -- Advanced mode: Fruits only get a boost from a particular fertilizer
            local volumeBoost = 0
            if fertApct>0 and fertBpct>0 then
                if desc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER3 then
                    volumeBoost = (numPixels * ((fertApct + fertBpct) / 2)) 
                end
            elseif fertApct>0 then
                if desc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER then
                    volumeBoost = (numPixels * fertApct)
                end
            elseif fertBpct>0 then
                if desc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER2 then
                    volumeBoost = (numPixels * fertBpct)
                end
            end
            volume = volume + volumeBoost

            -- Advanced mode: Soil pH value affects yields
            -- TODO - Binary search? Or is that too much for an array of 9 elements?
            if     phValue <= Utils.fmcSoilpHfactors[3].h then
                if     phValue < Utils.fmcSoilpHfactors[1].h then
                    volume = volume * Utils.fmcSoilpHfactors[1].f
                elseif phValue < Utils.fmcSoilpHfactors[2].h then
                    volume = volume * Utils.fmcSoilpHfactors[2].f
                else
                    volume = volume * Utils.fmcSoilpHfactors[3].f
                end
            elseif phValue <= Utils.fmcSoilpHfactors[6].h then
                if     phValue < Utils.fmcSoilpHfactors[4].h then
                    volume = volume * Utils.fmcSoilpHfactors[4].f
                elseif phValue < Utils.fmcSoilpHfactors[5].h then
                    volume = volume * Utils.fmcSoilpHfactors[5].f
                else
                    volume = volume * Utils.fmcSoilpHfactors[6].f
                end
            else
                if     phValue < Utils.fmcSoilpHfactors[7].h then
                    volume = volume * Utils.fmcSoilpHfactors[7].f
                elseif phValue < Utils.fmcSoilpHfactors[8].h then
                    volume = volume * Utils.fmcSoilpHfactors[8].f
                else
                    volume = volume * Utils.fmcSoilpHfactors[9].f
                end
            end
        end

--[[DEBUG
if g_currentMission.fmcDebugCutFruitArea then        
    print(string.format("#%2d - %5.2f(%3d,%2d) - n%.2f(%2d,%2d), w%.2f(%2d,%2d), pH%.1f(%2d,%2d), fA%.2f(%2d,%2d), fB%.2f(%2d,%2d)"
        ,fruitId
        ,volume,pixelsSum,numPixels
        ,nutrientLevel,oldOrganicSum,numOrganicPixels
        ,weedPct,oldWeedSum,numWeedPixels
        ,phValue,oldSoilphSum,numSoilphPixels
        ,fertApct,oldSynthetic1Sum,numSynthetic1Pixels
        ,fertBpct,oldSynthetic2Sum,numSynthetic2Pixels
    ))
end
--]]
     end
    
    return volume,numPixels,0
--#############################################################################
  end

end  



--#### DECKER_MMIV ############################################################
Utils.fmcTYPE_PLOUGH     = 1
Utils.fmcTYPE_CULTIVATOR = 2
Utils.fmcTYPE_SEEDER     = 3

Utils.fmcUpdateFmcFoliage = function(isForced, implementType, x,z, widthX,widthZ, heightX,heightZ)
    if implementType ~= Utils.fmcTYPE_SEEDER then
        -- Increase fertilizer(organic)...
        setDensityMaskParams(         g_currentMission.fmcFoliageFertilizerOrganic, "greater", 0);
        -- ..where there's manure, by 1(cultivator) or 3(plough)
        addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, x, z, widthX, widthZ, heightX, heightZ, 0, 2, g_currentMission.fmcFoliageManure, 0, 2, (implementType==Utils.fmcTYPE_PLOUGH and 3 or 1));
        -- ..where there's slurry, by 1.
        addDensityMaskedParallelogram(g_currentMission.fmcFoliageFertilizerOrganic, x, z, widthX, widthZ, heightX, heightZ, 0, 2, g_currentMission.fmcFoliageSlurry, 0, 1, 1);
        
        -- Set "moisture" where there's manure - we're cultivating/plouging it into ground.
        setDensityMaskedParallelogram(g_currentMission.terrainDetailId,             x, z, widthX, widthZ, heightX, heightZ, g_currentMission.sprayChannel, 1, g_currentMission.fmcFoliageManure, 0, 2, 1);
        -- Set "moisture" where there's slurry - we're cultivating/plouging it into ground.
        setDensityMaskedParallelogram(g_currentMission.terrainDetailId,             x, z, widthX, widthZ, heightX, heightZ, g_currentMission.sprayChannel, 1, g_currentMission.fmcFoliageSlurry, 0, 1, 1);
        
        -- Increase soil pH where there's lime, by 3 - we're cultivating/plouging it into ground.
        setDensityMaskParams(         g_currentMission.fmcFoliageSoil_pH, "greater", 0)
        addDensityMaskedParallelogram(g_currentMission.fmcFoliageSoil_pH,           x, z, widthX, widthZ, heightX, heightZ, 0, 3, g_currentMission.fmcFoliageLime, 0, 1, 3);
    
        -- Remove the manure/slurry/lime we've just cultivated/ploughed into ground.
        setDensityParallelogram(g_currentMission.fmcFoliageManure,              x, z, widthX, widthZ, heightX, heightZ, 0, 2, 0)
        setDensityParallelogram(g_currentMission.fmcFoliageSlurry,              x, z, widthX, widthZ, heightX, heightZ, 0, 1, 0)
        setDensityParallelogram(g_currentMission.fmcFoliageLime,                x, z, widthX, widthZ, heightX, heightZ, 0, 1, 0)
    end
        
    -- Remove weed plants - where we're cultivating/ploughing/seeding.
    setDensityParallelogram(      g_currentMission.fmcFoliageWeed,              x, z, widthX, widthZ, heightX, heightZ, 0, 3, 0)
end
--#############################################################################



function fmcModifyFSUtils.overwriteUpdateCultivatorArea()

  logInfo("Overwriting Utils.updateCultivatorArea")

  Utils.updateCultivatorArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)
    forced = Utils.getNoNil(forced, true);
    commonForced = Utils.getNoNil(commonForced, true);
    
    local detailId = g_currentMission.terrainDetailId;
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(detailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

--#### DECKER_MMIV ############################################################
    --Utils.updateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, not commonForced);
    Utils.fmcUpdateDestroyCommonArea(x,z, widthX,widthZ, heightX,heightZ, not commonForced);

    Utils.fmcUpdateFmcFoliage(forced, Utils.fmcTYPE_CULTIVATOR, x,z, widthX,widthZ, heightX,heightZ)
--#############################################################################

    local value = 2^g_currentMission.cultivatorChannel;
    local area = 0;
    if forced then
        area = area + setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value);
        if angle ~= nil then
                      setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, angle);
        end
    else
        area = area + setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value);
        if angle ~= nil then
                      setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, angle);
        end
    end
    return area;
  end
  
end



function fmcModifyFSUtils.overwriteUpdatePloughArea()

  logInfo("Overwriting Utils.updatePloughArea")

  Utils.updatePloughArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, forced, commonForced, angle)
    forced = Utils.getNoNil(forced, true);
    commonForced = Utils.getNoNil(commonForced, true);
    local detailId = g_currentMission.terrainDetailId;
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(detailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

--#### DECKER_MMIV ############################################################
    --Utils.updateDestroyCommonArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, not commonForced);
    Utils.fmcUpdateDestroyCommonArea(x,z, widthX,widthZ, heightX,heightZ, not commonForced);

    Utils.fmcUpdateFmcFoliage(forced, Utils.fmcTYPE_PLOUGH, x,z, widthX,widthZ, heightX,heightZ)
--#############################################################################
    
    local value = 2^g_currentMission.ploughChannel;
    local area = 0;
    if forced then
        area = area + setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value);
        if angle ~= nil then
                      setDensityParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, angle);
        end
    else
        area = area + setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value);
        if angle ~= nil then
                      setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, angle);
        end
    end
    
    return area;
  end

end



function fmcModifyFSUtils.overwriteUpdateSowingArea()

  logInfo("Overwriting Utils.updateSowingArea")

  Utils.updateSowingArea = function(fruitId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, angle, useDirectPlanting)
--#### DECKER_MMIV ############################################################
--[[DEBUG
    if g_currentMission.fmcDebugSeederFruitId ~= nil and g_currentMission.fmcDebugSeederFruitId ~= FruitUtil.FRUITTYPE_UNKNOWN then
        fruitId = g_currentMission.fmcDebugSeederFruitId
    end
--]]
--#############################################################################

    local ids = g_currentMission.fruits[fruitId];
    if ids == nil or ids.id == 0 then
        return 0;
    end

    angle = Utils.getNoNil(angle, 0);
    useDirectPlanting = Utils.getNoNil(useDirectPlanting, false);

    local desc = FruitUtil.fruitIndexToDesc[fruitId];

    local detailId = g_currentMission.terrainDetailId;
    local sowingAddChannel;
    if desc.useSeedingWidth then
        sowingAddChannel = g_currentMission.sowingWidthChannel;
    else
        sowingAddChannel = g_currentMission.sowingChannel;
    end
    local excludeMask = 0;
    if not useDirectPlanting then
        excludeMask = 2^g_currentMission.sowingChannel + 2^g_currentMission.sowingWidthChannel;
    end
--#### DECKER_MMIV ############################################################
    --local cultivatorChannel = g_currentMission.cultivatorChannel;
    --local ploughChannel = g_currentMission.ploughChannel;
--#############################################################################

    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(ids.id, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);

--#### DECKER_MMIV ############################################################
    Utils.fmcUpdateFmcFoliage(false, Utils.fmcTYPE_SEEDER, x,z, widthX,widthZ, heightX,heightZ)
--#############################################################################

    local plantValue = 1;

    -- plant the fruit
    setDensityMaskParams(ids.id, "greater", 0, 0, 0, excludeMask);
    -- change fruit twice, once with values greater than the plant value and once with values smaller than the plant value (==0)
    -- do not change (and count) the already planted areas
    setDensityCompareParams(ids.id, "greater", plantValue);
    -- Note: we plant numFruitDensityMapChannels, to destroy windrows etc.
    local _,numPixels1              = setDensityMaskedParallelogram(ids.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitDensityMapChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, plantValue);
    setDensityCompareParams(ids.id, "equals", 0);
    local _,numPixels2, totalPixels = setDensityMaskedParallelogram(ids.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitDensityMapChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, plantValue);
    setDensityCompareParams(ids.id, "greater", -1);

    local numPixels = numPixels1 + numPixels2;
    setDensityMaskParams(ids.id, "greater", 0);

--#### DECKER_MMIV ############################################################
--  local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(detailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
--#############################################################################

    -- add the sowing area and remove the other types
    local value = 2^sowingAddChannel;
    if fruitId == FruitUtil.FRUITTYPE_GRASS then
        value = 0;
    end
    setDensityMaskParams(detailId, "greater", 0, 0, 0, excludeMask);
    local _, numDetailPixels = setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, value);
    setDensityMaskParams(detailId, "greater", 0);
    if value > 0 then
                               setDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.terrainDetailAngleFirstChannel, g_currentMission.terrainDetailAngleNumChannels, detailId, sowingAddChannel, 1, angle);
    end

    return numPixels, numDetailPixels;
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
Utils.fmcUpdateDestroyCommonArea = function(x,z, widthX,widthZ, heightX,heightZ, limitToField)
    limitToField = Utils.getNoNil(limitToField, false);
    -- destroy all fruits
    if Utils.fmcDensityMapsFirstFruitId == nil then
        Utils.fmcBuildDensityMaps(); -- support for multiple foliage-multi-layers (i.e. maps with several FMLs each containing up to 15 fruits/foliage-sub-layers)
    end
    for _,entry in pairs(Utils.fmcDensityMapsFirstFruitId) do
        setDensityNewTypeIndexMode(    entry.id, 2) --SET_INDEX_TO_ZERO);
        setDensityTypeIndexCompareMode(entry.id, 2) --TYPE_COMPARE_NONE);

        -- note: this asumes entry.id has the lowest channel offset
        if limitToField then
            setDensityMaskedParallelogram(entry.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitDensityMapChannels, g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 0);
        else
            setDensityParallelogram(      entry.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitDensityMapChannels, 0);
        end

        setDensityNewTypeIndexMode(    entry.id, 0) --UPDATE_INDEX);
        setDensityTypeIndexCompareMode(entry.id, 0) --TYPE_COMPARE_EQUAL);
    end

    if limitToField then
        for _,id in ipairs(g_currentMission.fmcDynamicFoliageLayers) do
            setDensityMaskedParallelogram(id, x, z, widthX, widthZ, heightX, heightZ, 0, getTerrainDetailNumChannels(id), g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, 0);
        end
    else
        for _,id in ipairs(g_currentMission.fmcDynamicFoliageLayers) do
            setDensityParallelogram(      id, x, z, widthX, widthZ, heightX, heightZ, 0, getTerrainDetailNumChannels(id), 0);
        end
    end
end


function fmcModifyFSUtils.overwriteUpdateDestroyCommonArea()

  logInfo("Overwriting Utils.updateDestroyCommonArea")
  
  Utils.updateDestroyCommonArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, limitToField)
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(nil, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    Utils.fmcUpdateDestroyCommonArea(x,z, widthX,widthZ, heightX,heightZ, limitToField)
  end
  
end  
--#############################################################################



function fmcModifyFSUtils.overwriteUpdateSprayArea()

  -- Modified to also take extra argument: 'fillType'
  logInfo("Overwriting Utils.updateSprayArea")
  
  Utils.updateSprayArea = function(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, fillType)
--#### DECKER_MMIV ############################################################
--[[DEBUG
    if g_currentMission.fmcDebugSprayerFillType ~= nil and g_currentMission.fmcDebugSprayerFillType ~= Fillable.FILLTYPE_UNKNOWN then
        fillType = g_currentMission.fmcDebugSprayerFillType
    end
--]]

    local detailId = g_currentMission.terrainDetailId;
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(detailId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ);
    local moistureValue = 1
    
    -- If fillType has custom update-spray-area function, then call it...
    -- ..this "should" be faster instead of having huge if-then-elseif-then-elseif-then-etc. code blocks.
    if fillType ~= nil and Utils.fmcUpdateSprayAreaFillTypeFuncs[fillType] ~= nil then
        if not Utils.fmcUpdateSprayAreaFillTypeFuncs[fillType](x,z, widthX,widthZ, heightX,heightZ) then
            moistureValue = 0
        end
    end

    local _, numPixels = addDensityMaskedParallelogram(detailId, x, z, widthX, widthZ, heightX, heightZ, g_currentMission.sprayChannel, 1, detailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, moistureValue);
--#############################################################################
    return numPixels;
  end

end
  

--#### DECKER_MMIV ############################################################
function fmcModifyFSUtils.setSpraySubFuncs()

    --logInfo("Creating custom spray-area subfunctions for fill-/spray-types");

    Utils.fmcUpdateSprayAreaFillTypeFuncs = {}
    --
    if g_currentMission.fmcFoliageManure ~= nil and g_currentMission.fmcFoliageManure ~= 0 then
        if Fillable.FILLTYPE_MANURE ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURE] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageManure
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2^numChannels - 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_MANURESOLID ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURESOLID] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageManure
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2^numChannels - 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_SOLIDMANURE ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_SOLIDMANURE] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageManure
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2^numChannels - 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return false -- No moisture!
            end
        end
    end
    --
    if g_currentMission.fmcFoliageSlurry ~= nil and g_currentMission.fmcFoliageSlurry ~= 0 then
        if Fillable.FILLTYPE_LIQUIDMANURE ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_LIQUIDMANURE] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageSlurry
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_MANURELIQUID ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_MANURELIQUID] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageSlurry
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
    end
    --
    if g_currentMission.fmcFoliageLime ~= nil and g_currentMission.fmcFoliageLime ~= 0 then
        if Fillable.FILLTYPE_LIME ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_LIME] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageLime
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2^numChannels - 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return false -- No moisture!
            end
        end
        if Fillable.FILLTYPE_KALK ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_KALK] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageLime
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2^numChannels - 1
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return false -- No moisture!
            end
        end
    end
    --
    if g_currentMission.fmcFoliageHerbicide ~= nil and g_currentMission.fmcFoliageHerbicide ~= 0 then
        if Fillable.FILLTYPE_HERBICIDE ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageHerbicide
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 1 -- type-A
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_HERBICIDE2 ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE2] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageHerbicide
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 2 -- type-B
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
        if Fillable.FILLTYPE_HERBICIDE3 ~= nil then
            Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_HERBICIDE3] = function(x,z, widthX,widthZ, heightX,heightZ)
                local foliageId       = g_currentMission.fmcFoliageHerbicide
                local numChannels     = getTerrainDetailNumChannels(foliageId)
                local value           = 3 -- type-C
                setDensityParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0, numChannels, value);
                return true -- Place moisture!
            end
        end
    end
    --
    if g_currentMission.fmcFoliageFertilizerSynthetic ~= nil and g_currentMission.fmcFoliageFertilizerSynthetic ~= 0 then
        local fruitLayer = g_currentMission.fruits[1]
        -- TODO - add support for multiple FMLs
        if fruitLayer ~= nil and fruitLayer.id ~= 0 then
            if Fillable.FILLTYPE_FERTILIZER ~= nil then
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER] = function(x,z, widthX,widthZ, heightX,heightZ)
                    local fruitLayerId = g_currentMission.fruits[1].id
                    local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                    local numChannels  = getTerrainDetailNumChannels(foliageId)
                    local value        = 1 -- type-A
                    -- Fertilizer is only effective, when fruit is visible and growing (i.e. between 2 and 4)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 2, 4)
                    setDensityMaskedParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
            end
            if Fillable.FILLTYPE_FERTILIZER2 ~= nil then
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER2] = function(x,z, widthX,widthZ, heightX,heightZ)
                    local fruitLayerId = g_currentMission.fruits[1].id
                    local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                    local numChannels  = getTerrainDetailNumChannels(foliageId)
                    local value        = 2 -- type-B
                    -- Fertilizer is only effective, when fruit is visible and growing (i.e. between 2 and 4)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 2, 4)
                    setDensityMaskedParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
            end
            if Fillable.FILLTYPE_FERTILIZER3 ~= nil then
                Utils.fmcUpdateSprayAreaFillTypeFuncs[Fillable.FILLTYPE_FERTILIZER3] = function(x,z, widthX,widthZ, heightX,heightZ)
                    local fruitLayerId = g_currentMission.fruits[1].id
                    local foliageId    = g_currentMission.fmcFoliageFertilizerSynthetic
                    local numChannels  = getTerrainDetailNumChannels(foliageId)
                    local value        = 3 -- type-C
                    -- Fertilizer is only effective, when fruit is visible and growing (i.e. between 2 and 4)
                    -- TODO - add support for multiple FMLs
                    setDensityTypeIndexCompareMode(fruitLayerId, 2) -- COMPARE_NONE
                    setDensityMaskParams(foliageId, "between", 2, 4)
                    setDensityMaskedParallelogram(foliageId, x, z, widthX, widthZ, heightX, heightZ, 0,numChannels, fruitLayerId,0,g_currentMission.numFruitStateChannels, value);
                    setDensityTypeIndexCompareMode(fruitLayerId, 0) -- COMPARE_EQUAL
                    setDensityMaskParams(foliageId, "greater", -1)
                    return true -- Place moisture!
                end
            end
        end
    end
    --
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
