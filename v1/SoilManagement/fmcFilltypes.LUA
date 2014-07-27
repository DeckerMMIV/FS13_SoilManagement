--
--  The Soil Management and Growth Control Project
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-05-xx
--
-- @history
--  2014-July
--      0.5.3   - Function for setting a fruit's fertilizer-boost and herbicide-affected.
--      ------
--  Revision history is now kept in GitHub repository.
--

fmcFilltypes = {}
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
fmcFilltypes.version = (modItem and modItem.version) and modItem.version or "?.?.?";
--
fmcFilltypes.modDir = g_currentModDirectory;

--
function fmcFilltypes.setup(mapFilltypeOverlaysDirectory, simplisticMode)

    fmcFilltypes.simplisticMode = simplisticMode;

    if mapFilltypeOverlaysDirectory == nil then
        mapFilltypeOverlaysDirectory = fmcFilltypes.modDir .. "filltypeOverlays/"; -- Use SoilMod's own HUD overlay icons.
    end
    if not Utils.endsWith(mapFilltypeOverlaysDirectory, "/") then
        mapFilltypeOverlaysDirectory = mapFilltypeOverlaysDirectory .. "/"
    end
    fmcFilltypes.mapFilltypeOverlaysDirectory = mapFilltypeOverlaysDirectory

    fmcFilltypes.setupFillTypes(mapFilltypeOverlaysDirectory)
end

--
function fmcFilltypes.teardown()
end

--
function fmcFilltypes.setupFillTypes()
    logInfo("Registering new spray-types")

    local herbicide1Overlay = "herbicide1.dds"
    local fertilizer1Overlay = "fertilizer1.dds"
    if fmcFilltypes.simplisticMode then
        herbicide1Overlay = "herbicide.dds"
        fertilizer1Overlay = "fertilizer.dds"
    else
        -- Update the internationalized name for vanilla fill-type fertilizer.
        Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_FERTILIZER].nameI18N = g_i18n:getText("fertilizer")
    end

    -- Register some new spray types
    -- TODO - Provide some better usage-per-sqm and price-per-liter
    Sprayer.registerSprayType("kalk",        g_i18n:getText("kalk"),         0.3,  3, true, Utils.getFilename("kalk.dds",        fmcFilltypes.mapFilltypeOverlaysDirectory));
    Sprayer.registerSprayType("herbicide",   g_i18n:getText("herbicide"),    0.3,  5, true, Utils.getFilename(herbicide1Overlay, fmcFilltypes.mapFilltypeOverlaysDirectory));
    if not fmcFilltypes.simplisticMode then
        Sprayer.registerSprayType("herbicide2",  g_i18n:getText("herbicide2"),   0.3,  5, true, Utils.getFilename("herbicide2.dds",  fmcFilltypes.mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("herbicide3",  g_i18n:getText("herbicide3"),   0.3,  5, true, Utils.getFilename("herbicide3.dds",  fmcFilltypes.mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("fertilizer2", g_i18n:getText("fertilizer2"),  0.3,  5, true, Utils.getFilename("fertilizer2.dds", fmcFilltypes.mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("fertilizer3", g_i18n:getText("fertilizer3"),  0.3,  5, true, Utils.getFilename("fertilizer3.dds", fmcFilltypes.mapFilltypeOverlaysDirectory));
    end
end

function fmcFilltypes.addMoreFillTypeOverlayIcons()
    logInfo("Adding overlay-icons for specific fill-types that has none")

    local herbicide1Overlay = "herbicide1.dds"
    local fertilizer1Overlay = "fertilizer1.dds"
    if fmcFilltypes.simplisticMode then
        herbicide1Overlay = "herbicide.dds"
        fertilizer1Overlay = "fertilizer.dds"
    end

    -- Set overlay icons for fill types, if they do not already have one
    local function addFillTypeHudOverlayIcon(fillType, overlayFilename, force)
        if fillType ~= nil and Fillable.fillTypeIndexToDesc[fillType] ~= nil then
            if force or Fillable.fillTypeIndexToDesc[fillType].hudOverlayFilename == nil then
                Fillable.fillTypeIndexToDesc[fillType].hudOverlayFilename = overlayFilename;
            end
            if force and g_currentMission.fillTypeOverlays[fillType] ~= nil then
                -- Remove filltype overlay icon, so it can be correctly updated later.
                g_currentMission.fillTypeOverlays[fillType]:delete();
                g_currentMission.fillTypeOverlays[fillType] = nil;
            end
        end
    end

    addFillTypeHudOverlayIcon(Fillable.FILLTYPE_FERTILIZER  , Utils.getFilename(fertilizer1Overlay,  fmcFilltypes.mapFilltypeOverlaysDirectory), not fmcFilltypes.simplisticMode);
    addFillTypeHudOverlayIcon(Fillable.FILLTYPE_MANURE      , Utils.getFilename("manure.dds",        fmcFilltypes.mapFilltypeOverlaysDirectory), false);
    addFillTypeHudOverlayIcon(Fillable.FILLTYPE_LIQUIDMANURE, Utils.getFilename("liquidManure.dds",  fmcFilltypes.mapFilltypeOverlaysDirectory), false);
    --
    addFillTypeHudOverlayIcon(Fillable.FILLTYPE_KALK        , Utils.getFilename("kalk.dds",          fmcFilltypes.mapFilltypeOverlaysDirectory), false);
end

--
function fmcFilltypes.setupFruitFertilizerBoostHerbicideAffected()
    if (not fmcFilltypes.simplisticMode) then
        -- Set which fertilizer-fill-type that boosts what fruit-type
        -- Set which herbicide-fill-type that will affect what fruit-type
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("wheat"      ,"fertilizer"   ,"herbicide" )
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("barley"     ,"fertilizer"   ,"herbicide2")
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("rape"       ,"fertilizer3"  ,"herbicide3")
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("maize"      ,"fertilizer3"  ,"herbicide" )
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("sugarBeet"  ,"fertilizer2"  ,"herbicide2")
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("potato"     ,"fertilizer2"  ,"herbicide3")
        fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("grass"      ,"fertilizer"   ,nil         )
    end
end

--
function fmcFilltypes.updateFillTypeOverlays()
    logInfo("Updating fill-types HUD overlay-icons")
    for _,fillTypeDesc in pairs(Fillable.fillTypeIndexToDesc) do
        if g_currentMission.fillTypeOverlays[fillTypeDesc.index] == nil and fillTypeDesc.hudOverlayFilename ~= nil and fillTypeDesc.hudOverlayFilename ~= "" then
            g_currentMission:addFillTypeOverlay(fillTypeDesc.index, fillTypeDesc.hudOverlayFilename)
        end
    end
end

print(string.format("Script loaded: fmcFilltypes.lua (v%s)", fmcFilltypes.version));
