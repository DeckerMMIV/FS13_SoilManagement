--
--  The Soil Management and Growth Control Project
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-05-xx
--
-- @history
--  2014-May
--      0.1.0   - Initial experiments
--  2014-June
--      0.2.0   - Added to private map and tweaked.
--              - Lime now affects soil pH values.
--      0.2.1   - Event-messages for multiplayer added.
--      0.3.0   - Weed propagation added, so it spreads "randomly" every in-game minute.
--      0.3.1   - Code cleanup.
--      0.4.0   - Refactored, so script files are not embedded into the map-mod.
--                This should ensure patching/upgrading of the mod is easier... I hope.
--  2014-July
--      0.5.2   - Functions for calculating pH value, so it is done at _one_ place, and 
--                hopefully easier to "update/fix" if needed.
--      0.5.3   - Function for setting a fruit's fertilizer-boost and herbicide-affected.
--      0.6.0   - Added update() and draw() functions, needed to be called from SampleModMap's functions.
--      1.0.0   - Some comment blocks added.
--


fmcSoilMod = {}

-- "Register" this object in global environment, so other mods can "see" it.
getfenv(0)["fmcSoilMod"] = fmcSoilMod 

--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
fmcSoilMod.version = (modItem and modItem.version) and modItem.version or "?.?.?";
fmcSoilMod.modDir = g_currentModDirectory;

--
fmcSoilMod.simplisticMode = false
fmcSoilMod.logEnabled     = false

-- For debugging
function log(...)
    if fmcSoilMod.logEnabled 
--[[
       or true
--]]
    then
        local txt = ""
        for idx = 1,select("#", ...) do
            txt = txt .. tostring(select(idx, ...))
        end
        print(string.format("%7ums ", (g_currentMission ~= nil and g_currentMission.time or 0)) .. txt);
    end
end;

--
source(g_currentModDirectory .. 'fmcFilltypes.lua')
source(g_currentModDirectory .. 'fmcModifyFSUtils.lua')
source(g_currentModDirectory .. 'fmcModifySprayers.lua')
source(g_currentModDirectory .. 'fmcGrowthControl.lua')

--
function fmcSoilMod.setup_map_new(mapFilltypeOverlaysDirectory)
    log("fmcSoilMod - setup_map_new(", mapFilltypeOverlaysDirectory, ")")
    fmcSoilMod.enabled = false
    fmcFilltypes.setup(mapFilltypeOverlaysDirectory, fmcSoilMod.simplisticMode)
end

--
function fmcSoilMod.teardown_map_delete()
    log("fmcSoilMod - teardown_map_delete()")
    fmcModifyFSUtils.teardown()
    fmcSoilMod.enabled = false
end

--
function fmcSoilMod.preInit_loadMapFinished()
    log("fmcSoilMod - preInit_loadMapFinished()")
end

--
function fmcSoilMod.postInit_loadMapFinished()
    log("fmcSoilMod - postInit_loadMapFinished()")
    fmcFilltypes.setupFruitFertilizerBoostHerbicideAffected()
    if fmcGrowthControl.setup(fmcSoilMod.simplisticMode) then
        fmcModifyFSUtils.setup(fmcSoilMod.simplisticMode)
        fmcModifySprayers.setup()    
        fmcFilltypes.updateFillTypeOverlays()
        fmcSoilMod.copy_l10n_texts_to_global()
        fmcSoilMod.enabled = true
    else
        print("")
        print("")
        print("ERROR! Problem occurred during SoilMod's initial set-up. - Soil Management will NOT be available!")
        print("")
        print("")
        fmcSoilMod.enabled = false
        fmcSoilMod.logEnabled = true
    end
end

--
function fmcSoilMod.update(dt)
    if fmcSoilMod.enabled then
        fmcGrowthControl.update(fmcGrowthControl, dt)
    end
end

--
function fmcSoilMod.draw()
    if fmcSoilMod.enabled then
        fmcGrowthControl.draw(fmcGrowthControl)
    end
end

--
function fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected(fruitName, fertilizerName, herbicideName)
    if fmcSoilMod.simplisticMode then
        -- Not used in 'simplistic mode'.
        return
    end
    --
    local fruitDesc = FruitUtil.fruitTypes[fruitName]
    if fruitDesc == nil then
        print("ERROR! Fruit '"..tostring(fruitName).."' is not registered as a fruit-type.")
        return
    end
    --
    local attrsSet = nil
    
    if fertilizerName ~= nil and fertilizerName ~= "" then
        local fillTypeFertilizer  = "FILLTYPE_"  .. tostring(fertilizerName):upper()
        local sprayTypeFertilizer = "SPRAYTYPE_" .. tostring(fertilizerName):upper()
        if Sprayer[sprayTypeFertilizer] == nil or Fillable[fillTypeFertilizer] == nil then
            print("ERROR! Fertilizer '"..tostring(fertilizerName).."' is not registered as a spray-type or fill-type.")
        else
            fruitDesc.fmcBoostFertilizer = Fillable[fillTypeFertilizer];
            attrsSet = ((attrsSet == nil) and "" or attrsSet..", ") .. ("fertilizer-boost:'%s'"):format(fertilizerName)
        end
    end
    --
    if herbicideName ~= nil and herbicideName ~= "" then
        local fillTypeHerbicide  = "FILLTYPE_"  .. tostring(herbicideName):upper()
        local sprayTypeHerbicide = "SPRAYTYPE_" .. tostring(herbicideName):upper()
        if Sprayer[sprayTypeHerbicide] == nil or Fillable[fillTypeHerbicide] == nil then
            print("ERROR! Herbicide '"..tostring(herbicideName).."' is not registered as a spray-type or fill-type.")
        else
            fruitDesc.fmcHerbicideAffected = Fillable[fillTypeHerbicide];
            attrsSet = ((attrsSet == nil) and "" or attrsSet..", ") .. ("herbicide-affected:'%s'"):format(herbicideName)
        end
    end
    --
    print(("Fruit '%s' attributes set; %s."):format(tostring(fruitName), (attrsSet == nil and "(none)" or tostring(attrsSet))))
end


--
-- Utillity functions for calculating pH value.
--
function fmcSoilMod.density_to_pH(sumPixels, numPixels, numChannels)
    if numPixels <= 0 then
        return 0
    end
    local offsetPct = ((sumPixels / ((2^numChannels - 1) * numPixels)) - 0.5) * 2
    return fmcSoilMod.offsetPct_to_pH(offsetPct)
end

function fmcSoilMod.offsetPct_to_pH(offsetPct)
    -- 'offsetPct' should be between -1.0 and +1.0
    local phValue = 7.0 + (3 * math.sin(offsetPct * (math.pi * 0.3)))
    return math.floor(phValue * 10) / 10; -- Return with only one decimal-digit.
end

function fmcSoilMod.pH_to_Denomination(phValue)
    local phDenomination = "phNeutral";
    if phValue < 6.6 then
        if phValue < 5.1 then
            phDenomination = "phExtremeAcidity"
        elseif phValue < 5.6 then
            phDenomination = "phStrongAcidity"
        elseif phValue < 6.1 then
            phDenomination = "phModerateAcidity"
        else
            phDenomination = "phSlightAcidity"
        end
    elseif phValue > 7.3 then
        if phValue > 9.0 then
            phDenomination = "phExtremeAlkalinity"        
        elseif phValue > 8.4 then
            phDenomination = "phStrongAlkalinity"        
        elseif phValue > 7.8 then
            phDenomination = "phModerateAlkalinity"        
        else
            phDenomination = "phSlightAlkalinity"        
        end
    end
    return phDenomination;
end

--
-- Utility function for copying this mod's <l10n> text-entries, into the game's global table.
--
function fmcSoilMod.copy_l10n_texts_to_global()
    -- Copy this mod's localization texts to global table - and hope they are unique enough, so not overwriting existing ones.
    local xmlFile = loadXMLFile("modDesc", fmcSoilMod.modDir .. (Utils.endsWith(fmcSoilMod.modDir, "/") and "" or "/") .. "ModDesc.XML");
    if xmlFile ~= nil then
        local i=0
        while true do
            local textName = getXMLString(xmlFile, ("modDesc.l10n.text(%d)#name"):format(i));
            if nil == textName then
                break
            end
            g_i18n.globalI18N.texts[textName] = g_i18n:getText(textName);
            i=i+1
        end
        delete(xmlFile);
    end
end

--
print(("Script loaded: fmcSoilMod.LUA (v%s) - %s"):format(fmcSoilMod.version, (fmcSoilMod.simplisticMode and "Simplistic mode" or "Advanced mode")))
