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
    --
    fmcFilltypes.setupFillTypes(mapFilltypeOverlaysDirectory)
end

--
function fmcFilltypes.teardown()
end

--
function fmcFilltypes.setupFillTypes(mapFilltypeOverlaysDirectory)
    print("Registering new spray-types and adding more overlay-icons")

    local herbicide1Overlay = "herbicide1.dds"
    local fertilizer1Overlay = "fertilizer1.dds"
    if fmcFilltypes.simplisticMode then
        herbicide1Overlay = "herbicide.dds"
        fertilizer1Overlay = "fertilizer.dds"
    end

    -- Register some new spray types
    -- TODO - Provide some better usage-per-sqm and price-per-liter 
    Sprayer.registerSprayType("kalk",        g_i18n:getText("kalk"),         0.3,  3, true, Utils.getFilename("kalk.dds",        mapFilltypeOverlaysDirectory));
    Sprayer.registerSprayType("herbicide",   g_i18n:getText("herbicide"),    0.3,  5, true, Utils.getFilename(herbicide1Overlay, mapFilltypeOverlaysDirectory));
    if not fmcFilltypes.simplisticMode then
        Sprayer.registerSprayType("herbicide2",  g_i18n:getText("herbicide2"),   0.3,  5, true, Utils.getFilename("herbicide2.dds",  mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("herbicide3",  g_i18n:getText("herbicide3"),   0.3,  5, true, Utils.getFilename("herbicide3.dds",  mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("fertilizer2", g_i18n:getText("fertilizer2"),  0.3,  5, true, Utils.getFilename("fertilizer2.dds", mapFilltypeOverlaysDirectory));
        Sprayer.registerSprayType("fertilizer3", g_i18n:getText("fertilizer3"),  0.3,  5, true, Utils.getFilename("fertilizer3.dds", mapFilltypeOverlaysDirectory));
    end

    -- Set overlay icons for vanilla fill types
    if Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_FERTILIZER  ] ~= nil then Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_FERTILIZER  ].hudOverlayFilename = Utils.getFilename(fertilizer1Overlay,  mapFilltypeOverlaysDirectory); end;
    if Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_MANURE      ] ~= nil then Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_MANURE      ].hudOverlayFilename = Utils.getFilename("manure.dds",        mapFilltypeOverlaysDirectory); end;
    if Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_LIQUIDMANURE] ~= nil then Fillable.fillTypeIndexToDesc[Fillable.FILLTYPE_LIQUIDMANURE].hudOverlayFilename = Utils.getFilename("liquidManure.dds",  mapFilltypeOverlaysDirectory); end;
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
    print("Updating fill-types HUD overlay-icons")
    for _,fillTypeDesc in pairs(Fillable.fillTypeIndexToDesc) do
        if g_currentMission.fillTypeOverlays[fillTypeDesc.index] ~= nil then
            -- remove existing overlay icon, as the graphics may have been changed later.
            g_currentMission.fillTypeOverlays[fillTypeDesc.index]:delete();
            g_currentMission.fillTypeOverlays[fillTypeDesc.index] = nil;
        end
        if fillTypeDesc.hudOverlayFilename ~= nil and fillTypeDesc.hudOverlayFilename ~= "" then
            g_currentMission:addFillTypeOverlay(fillTypeDesc.index, fillTypeDesc.hudOverlayFilename)
        end
    end
end

print(string.format("Script loaded: fmcFilltypes.lua (v%s)", fmcFilltypes.version));
