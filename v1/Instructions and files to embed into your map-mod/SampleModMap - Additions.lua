--
-- SampleModMap
--
-- @author  Stefan Geiger
-- @date  06/08/12
--
-- Copyright (C) GIANTS Software GmbH, Confidential, All Rights Reserved.

SampleModMap = {}

local SampleModMap_mt = Class(SampleModMap, Mission00);


function SampleModMap:new(baseDirectory, customMt)
    local mt = customMt;
    if mt == nil then
        mt = SampleModMap_mt;
    end;
    local self = SampleModMap:superClass():new(baseDirectory, mt);

--#############################################################################
--#### Soil Mod ###############################################################
    if fmcSoilMod ~= nil and fmcSoilMod.setup_map_new ~= nil then
        --fmcSoilMod.setup_map_new(baseDirectory .. "map/fmcSoilManagement/filltypeOverlays")  -- If map provides its own fill-type HUD overlay icons.
        fmcSoilMod.setup_map_new() -- If using icons included with the SoilManagement.ZIP mod.
    end
--#############################################################################
--#############################################################################

    return self;
end;

function SampleModMap:delete()
--#############################################################################
--#### Soil Mod ###############################################################
    if fmcSoilMod ~= nil and fmcSoilMod.teardown_map_delete ~= nil then
        fmcSoilMod.teardown_map_delete()
    end
--#############################################################################
--#############################################################################

    SampleModMap:superClass().delete(self);
end;

function SampleModMap:load()
    self:startLoadingTask();

    self.environment = Environment:new(Utils.getFilename("$data/sky/sky_day_night.i3d", self.baseDirectory), true, 8, true, true);

    self.helpIconsBase = nil;
    self.collectableHorseshoesObject = nil;
    self.fieldDefinitionBase = nil;
    self.vehicleShopBase = nil;

    self:loadMap(Utils.getFilename("map/map01.i3d", self.baseDirectory), true, self.loadMap01Finished, self);
end;

function SampleModMap:loadMap01Finished(node, arguments)

    self:loadMapXMLFile(Utils.getFilename("SampleModMap.xml", self.baseDirectory));

    self.missionPDA:loadMap(Utils.getFilename("pda_map.png", self.baseDirectory), 2048, 2048);

    g_inGameMenu:setMapViewsMap(Utils.getFilename("pda_map.png", self.baseDirectory));

    local iconSize = self.missionPDA.pdaMapWidth / 15;

    -- ATMs
    self.missionPDA:createMapHotspot("Bank", Utils.getFilename("$dataS2/missions/hud_pda_spot_bank.png", self.baseDirectory), -230, 439.5, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Bank", Utils.getFilename("$dataS2/missions/hud_pda_spot_bank.png", self.baseDirectory), -144.65, -352.25, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Bank", Utils.getFilename("$dataS2/missions/hud_pda_spot_bank.png", self.baseDirectory), 513.75, 202, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Bank", Utils.getFilename("$dataS2/missions/hud_pda_spot_bank.png", self.baseDirectory), 723.9, 608.25, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Bank", Utils.getFilename("$dataS2/missions/hud_pda_spot_bank.png", self.baseDirectory), -162, -679.51, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- Vehicle Shop
    self.missionPDA:createMapHotspot("Shop", Utils.getFilename("$dataS2/missions/hud_pda_spot_shop.png", self.baseDirectory), -130, -383, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- Phone Booths
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), 89.6, -417.9, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), -603.4, -834, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), -94, 20.1, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), -560, -7.5, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), -172.25, -678.9, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Phone", Utils.getFilename("$dataS2/missions/hud_pda_spot_phone.png", self.baseDirectory), 241.1, 438, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- egg sellpoints
    self.missionPDA:createMapHotspot("Eggs", Utils.getFilename("$dataS/missions/hud_pda_spot_eggs.png", self.baseDirectory), 113.2, -392, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Eggs", Utils.getFilename("$dataS/missions/hud_pda_spot_eggs.png", self.baseDirectory), -195.85, -706.45, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- farm silos
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlace.png", self.baseDirectory), 43.5, -128.3, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    -- bga
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlace.png", self.baseDirectory), 395.1, -693.7, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    
    -- Grass Heaps
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlaceGreen.png", self.baseDirectory), 888.8 , 569.6, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlaceGreen.png", self.baseDirectory), 753.5 , 864.9, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlaceGreen.png", self.baseDirectory), 640.4 , 787.2, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("TipPlace", Utils.getFilename("$dataS2/missions/hud_pda_spot_tipPlaceGreen.png", self.baseDirectory), 692.7 , -842.7, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- livestock
    self.missionPDA:createMapHotspot("Cows", Utils.getFilename("$dataS2/missions/hud_pda_spot_cows.png", self.baseDirectory), 256, 655, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Sheep", Utils.getFilename("$dataS2/missions/hud_pda_spot_sheep.png", self.baseDirectory), -600, 585, iconSize, iconSize * (4 / 3), false, false, false, 0, true);
    self.missionPDA:createMapHotspot("Chickens", Utils.getFilename("$dataS2/missions/hud_pda_spot_chickens.png", self.baseDirectory), -12, -93, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    -- spinnery
    g_currentMission.missionPDA:createMapHotspot("woolDeliveryHotspot", Utils.getFilename("$dataS/missions/hud_pda_spot_spinnery.png", self.baseDirectory), 223, 405.2, iconSize, iconSize * (4 / 3), false, false, false, 0, true);

    SampleModMap:superClass().load(self);

    if not self.missionDynamicInfo.isMultiplayer then
        self:updateFoundHorseshoes();
        self:updateFoundHelpIcons();
        self:updateMeteoriteCrash();
        self:updateRainbow();
    else
        self:removeAllHorseshoes();
        self:removeAllHelpIcons();
    end;

--#############################################################################
--#### Soil Mod ###############################################################
    if fmcSoilMod ~= nil and fmcSoilMod.postInit_loadMapFinished ~= nil then
        if fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected ~= nil then
            -- If needed, set up this map's custom fruit-types fertilizer-boost and herbicide-affected attributes.
            
            -- <<Examples>>
            -- fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("tomato"   ,"fertilizer"   ,"herbicide3")
            -- fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("soybean"  ,"fertilizer2"  ,"herbicide" )
            -- fmcSoilMod.setFruit_FertilizerBoost_HerbicideAffected("pumpkin"  ,"fertilizer3"  ,"herbicide2")
        end
        --
        fmcSoilMod.postInit_loadMapFinished()
    end
--#############################################################################
--#############################################################################

    self:finishLoadingTask();
end;

function SampleModMap:onStartMission()
    SampleModMap:superClass().onStartMission(self);
end;

function SampleModMap:mouseEvent(posX, posY, isDown, isUp, button)
    SampleModMap:superClass().mouseEvent(self, posX, posY, isDown, isUp, button);
end;

function SampleModMap:keyEvent(unicode, sym, modifier, isDown)
    SampleModMap:superClass().keyEvent(self, unicode, sym, modifier, isDown);
end;

function SampleModMap:update(dt)
    SampleModMap:superClass().update(self, dt);
    
--#############################################################################
--#### Soil Mod ###############################################################
    if fmcSoilMod ~= nil and fmcSoilMod.update ~= nil then
        fmcSoilMod.update(dt)
    end
--#############################################################################
--#############################################################################
end;

function SampleModMap:draw()
    SampleModMap:superClass().draw(self);

--#############################################################################
--#### Soil Mod ###############################################################
    if fmcSoilMod ~= nil and fmcSoilMod.draw ~= nil then
        fmcSoilMod.draw()
    end
--#############################################################################
--#############################################################################
end;
