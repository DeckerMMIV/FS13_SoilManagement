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
--  2014-July
--      0.5.0   - Renamed foliage-sub-layers due to possible conflict with other mod's layers.
--      0.5.4   - MP events can be sent to clients, before clients have begun running update().
--      0.6.0   - Removed addModEventListener() to make sure this mod is ONLY run when the correct
--                changes to SampleModMap.LUA have been made.
--                This should make it NOT conflict with other maps.
--      0.6.1   - Bug fixes and tweaks for growth control.
--      ------
--  Revision history is now kept in GitHub repository.
--


fmcGrowthControl = {}

--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
fmcGrowthControl.version = (modItem and modItem.version) and modItem.version or "?.?.?";
--

fmcGrowthControl.reduceWindrows         = true;
fmcGrowthControl.removeSprayMoisture    = true;
fmcGrowthControl.disableWithering       = false;
fmcGrowthControl.updateDelayMs          = 1000 / 16; -- Maximum number of cells that may be updated per second. Consider network-latency/-updates
fmcGrowthControl.delayGrowthCycleDays   = 0
fmcGrowthControl.startGrowthCycleHour   = 0  -- midnight hour

--
fmcGrowthControl.hudFontSize = 0.025
fmcGrowthControl.hudPosX     = 0.5
fmcGrowthControl.hudPosY     = (1 - fmcGrowthControl.hudFontSize * 1.05)

fmcGrowthControl.active              = false
fmcGrowthControl.canActivate         = false
fmcGrowthControl.lastUpdateDay       = 0
fmcGrowthControl.cellSquaresMethod   = 0
fmcGrowthControl.cellSquareToUpdate  = 0
fmcGrowthControl.pctCompleted        = 0
fmcGrowthControl.weedCell            = 0



--
function fmcGrowthControl.preSetup()
    if g_currentMission ~= nil and g_currentMission:getIsServer() then
        local fileName = g_currentMission.missionInfo.savegameDirectory .. "/careerSavegame.xml"

        local xmlFile = loadXMLFile("xml", fileName);
        if xmlFile ~= nil then
            local xmlKey = "careerSavegame"
            fmcGrowthControl.lastUpdateDay        = Utils.getNoNil(getXMLInt( xmlFile, xmlKey..".customGrowthControl#day")    ,0)
            fmcGrowthControl.cellSquareToUpdate   = Utils.getNoNil(getXMLInt( xmlFile, xmlKey..".customGrowthControl#cell")   ,0)
            fmcGrowthControl.cellSquaresMethod    = Utils.getNoNil(getXMLInt( xmlFile, xmlKey..".customGrowthControl#method") ,0)
            fmcGrowthControl.weedCell             = Utils.getNoNil(getXMLInt( xmlFile, xmlKey..".customGrowthControl#cell2")  ,0)

            fmcSettings.onLoadCareerSavegame(xmlFile, xmlKey..".modSoilManagement")

            delete(xmlFile);

            -- 'Growth cycle' is active, if cell-square-to-update is not zero.
            fmcGrowthControl.active = fmcGrowthControl.cellSquareToUpdate > 0

            log("fmcGrowthControl -",
                " lastUpdateDay=",          fmcGrowthControl.lastUpdateDay,
                ", cellSquareToUpdate=",    fmcGrowthControl.cellSquareToUpdate,
                ", cellSquaresMethod=",     fmcGrowthControl.cellSquaresMethod,
                ", weedCell=",              fmcGrowthControl.weedCell,
                ", active=",                fmcGrowthControl.active
            )
        end
    end

    fmcGrowthControl.delayGrowthCycleDays   = fmcSettings.getKeyValue("delayGrowthCycle#days",  fmcGrowthControl.delayGrowthCycleDays)
    fmcGrowthControl.startGrowthCycleHour   = fmcSettings.getKeyValue("startGrowthCycle#hour",  fmcGrowthControl.startGrowthCycleHour)
    fmcGrowthControl.updateDelayMs          = fmcSettings.getKeyValue("updateDelayMs",          fmcGrowthControl.updateDelayMs       )
    fmcGrowthControl.reduceWindrows         = fmcSettings.getKeyValue("reduceWindrows",         fmcGrowthControl.reduceWindrows      )
    fmcGrowthControl.removeSprayMoisture    = fmcSettings.getKeyValue("removeSprayMoisture",    fmcGrowthControl.removeSprayMoisture )
    fmcGrowthControl.disableWithering       = fmcSettings.getKeyValue("disableWithering",       fmcGrowthControl.disableWithering    )
    fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState = fmcSettings.getKeyValue("fertilizerSynthetic#firstGrowthState", fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState)
    fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState  = fmcSettings.getKeyValue("fertilizerSynthetic#lastGrowthState",  fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
    
    -- Valid ranges...
    fmcGrowthControl.updateDelayMs        = math.max(10, fmcGrowthControl.updateDelayMs)
    fmcGrowthControl.delayGrowthCycleDays = math.max(0,  fmcGrowthControl.delayGrowthCycleDays)
    fmcGrowthControl.startGrowthCycleHour = math.max(0,  math.min(23, fmcGrowthControl.startGrowthCycleHour))

    -- Growth state ranges allowed: 0-4 (0=nothing, 1=seeded, 4=third growth state)
    fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState  = math.max(0, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)
    fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState = math.max(0, fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState)
    fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState  = math.min(fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState,  4)
    fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState = math.min(fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState, fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState)

    log("fmcGrowthControl -",
        " updateDelayMs=",          fmcGrowthControl.updateDelayMs,
        ", reduceWindrows=",        fmcGrowthControl.reduceWindrows,
        ", removeSprayMoisture=",   fmcGrowthControl.removeSprayMoisture,
        ", disableWithering=",      fmcGrowthControl.disableWithering,
        ", delayGrowthCycleDays=",  fmcGrowthControl.delayGrowthCycleDays,
        ", startGrowthCycleHour=",  fmcGrowthControl.startGrowthCycleHour,
        ", fertSyntFirst=",         fmcModifyFSUtils.fertilizerSynthetic_spray_firstGrowthState,
        ", fertSyntLast=",          fmcModifyFSUtils.fertilizerSynthetic_spray_lastGrowthState
    )
end

--
function fmcGrowthControl.setup(simplisticMode)

    fmcGrowthControl.simplisticMode = simplisticMode

    fmcGrowthControl.detectFruitSprayFillTypeConflicts()

    fmcGrowthControl.setupFoliageGrowthLayers()
    fmcGrowthControl.initialized = false;

    --return allOK
end

--
function fmcGrowthControl.detectFruitSprayFillTypeConflicts()
--[[
    Fill-type can all be transported

    Fruit-type is also a fill-type
    Spray-type is also a fill-type

    Fruit-type should ONLY be used for crop foliage-layers, that can be seeded and harvested!
    - Unfortunately some mods register new fruit-types, which basically should ONLY have been a fill-type!
--]]

    -- Issue warnings if a fruit-type has no usable foliage-layer ids
    for fruitType,fruitDesc in pairs(FruitUtil.fruitIndexToDesc) do
        local fruitLayer = g_currentMission.fruits[fruitType]
        if fruitLayer == nil or fruitLayer == 0 then
            if fruitType == Fillable.FILLTYPE_CHAFF then
                -- Ignore, as FILLTYPE_CHAFF is one from the base scripts.
            else
                logInfo("WARNING. Fruit-type '"..tostring(fruitDesc.name).."' has no usable foliage-layer. If this type is still needed, consider registering '"..tostring(fruitDesc.name).."' only as a Fill-type or Spray-type!")
            end
        end
    end
end


--
FSCareerMissionInfo.saveToXML = Utils.prependedFunction(FSCareerMissionInfo.saveToXML, function(self)
    if self.isValid and self.xmlKey ~= nil then
        log("fmcGrowthControl saving -",
            " lastUpdateDay=", fmcGrowthControl.lastUpdateDay,
            " cellSquareToUpdate=", fmcGrowthControl.cellSquareToUpdate,
            " cellSquaresMethod=", fmcGrowthControl.cellSquaresMethod,
            " weedCell=", fmcGrowthControl.weedCell
        )
        setXMLInt( self.xmlFile, self.xmlKey..".customGrowthControl#day"                 ,fmcGrowthControl.lastUpdateDay)
        setXMLInt( self.xmlFile, self.xmlKey..".customGrowthControl#cell"                ,fmcGrowthControl.cellSquareToUpdate)
        setXMLInt( self.xmlFile, self.xmlKey..".customGrowthControl#method"              ,fmcGrowthControl.cellSquaresMethod)
        setXMLInt( self.xmlFile, self.xmlKey..".customGrowthControl#cell2"               ,fmcGrowthControl.weedCell)

        --
        fmcSettings.onSaveCareerSavegame(self.xmlFile, self.xmlKey..".modSoilManagement")
    end
end);

--
function fmcGrowthControl.setupFoliageGrowthLayers()
    log("fmcGrowthControl.setupFoliageGrowthLayers()")

    g_currentMission.fmcFoliageGrowthLayers = {}
    for i = 1, FruitUtil.NUM_FRUITTYPES do
      local fruitDesc = FruitUtil.fruitIndexToDesc[i]
      local fruitLayer = g_currentMission.fruits[fruitDesc.index];
      if fruitLayer ~= nil and fruitLayer.id ~= 0 and fruitDesc.minHarvestingGrowthState >= 0 then
        -- Disable growth as this mod will take control of it!
        setEnableGrowth(fruitLayer.id, false);
        --
        local entry = {
          fruitId         = fruitLayer.id,
          windrowId       = fruitLayer.windrowId,
          minSeededValue  = 1,
          minMatureValue  = (fruitDesc.minPreparingGrowthState>=0 and fruitDesc.minPreparingGrowthState or fruitDesc.minHarvestingGrowthState) + 1,
          maxMatureValue  = (fruitDesc.maxPreparingGrowthState>=0 and fruitDesc.maxPreparingGrowthState or fruitDesc.maxHarvestingGrowthState) + 1,
        }

        ---- Can be withered?
        --local witheredState = (fruitDesc.maxPreparingGrowthState>=0 and fruitDesc.maxPreparingGrowthState or fruitDesc.maxHarvestingGrowthState) + 1
        --if witheredState ~= fruitDesc.cutState and witheredState ~= fruitDesc.preparedGrowthState and witheredState ~= fruitDesc.minPreparingGrowthState then
        --    if getGrowthNumStates(fruitLayer.id) == witheredState + 1 then
        --        entry.witheredValue = witheredState + 1
        --    end
        --end

        -- Needs preparing?
        if fruitDesc.maxPreparingGrowthState >= 0 then
          -- ...and can be withered?
          if fruitDesc.minPreparingGrowthState < fruitDesc.maxPreparingGrowthState then -- Assumption that if there are multiple stages for preparing, then it can be withered too.
            entry.witheredValue = entry.maxMatureValue + 1  -- Assumption that 'withering' is just after max-harvesting.
          end
        else
          -- Can be withered?
          if fruitDesc.cutState > fruitDesc.maxHarvestingGrowthState then -- Assumption that if 'cutState' is after max-harvesting, then fruit can be withered.
            entry.witheredValue = entry.maxMatureValue + 1  -- Assumption that 'withering' is just after max-harvesting.
          end
        end

        entry.herbicideAvoidance = nil
        if (not fmcGrowthControl.simplisticMode) and fruitDesc.fmcHerbicideAffected ~= nil then
          if     fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE  then entry.herbicideAvoidance = 1
          elseif fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE2 then entry.herbicideAvoidance = 2
          elseif fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE3 then entry.herbicideAvoidance = 3
          end
        end

        log(fruitDesc.name,"=", i,
            ",id=", entry.fruitId,
            ",windrowId=", entry.windrowId,
            ",minSeededValue=", entry.minSeededValue,
            ",minMatureValue=", entry.minMatureValue,
            ",maxMatureValue=", entry.maxMatureValue,
            ",cutState=", fruitDesc.cutState,
            ",witheredValue=", entry.witheredValue,
            ",herbicideAvoidance=", entry.herbicideAvoidance
        )

        table.insert(g_currentMission.fmcFoliageGrowthLayers, entry);
      end
    end

    fmcGrowthControl.cells = 32
    --fmcGrowthControl.cellWH = math.floor(g_currentMission.fruitMapSize / fmcGrowthControl.cells);
    --fmcGrowthControl.cellWH = math.floor(g_currentMission.terrainDetailMapSize / fmcGrowthControl.cells);
    fmcGrowthControl.cellWH = math.floor(g_currentMission.terrainSize / fmcGrowthControl.cells);

    log("fmcGrowthControl -",
        " cellWH=",                 fmcGrowthControl.cellWH,
        ", updateDelayMs=",         fmcGrowthControl.updateDelayMs,
        ", terrainSize=",           g_currentMission.terrainSize,
        ", terrainDetailMapSize=",  g_currentMission.terrainDetailMapSize,
        ", fruitMapSize=",          g_currentMission.fruitMapSize
    )

end

function fmcGrowthControl:update(dt)
    if g_currentMission:getIsServer() then
      if not fmcGrowthControl.initialized then
          fmcGrowthControl.initialized = true;
      
          fmcGrowthControl.nextUpdateTime = g_currentMission.time + 0
          g_currentMission.environment:addHourChangeListener(self);
      
          if g_currentMission.fmcFoliageWeed ~= nil then
              g_currentMission.environment:addMinuteChangeListener(self);
          end
      end
    
      if not fmcGrowthControl.active then
        if InputBinding.hasEvent(InputBinding.SOILMOD_GROWNOW) or fmcGrowthControl.canActivate then
          fmcGrowthControl.canActivate = false
          fmcGrowthControl.lastUpdateDay = g_currentMission.environment.currentDay;
          fmcGrowthControl.cellSquareToUpdate = (fmcGrowthControl.cells * fmcGrowthControl.cells);
          fmcGrowthControl.nextUpdateTime = g_currentMission.time + 0
          fmcGrowthControl.pctCompleted = 0
          fmcGrowthControl.active = true;
          log("fmcGrowthControl - Growth: Started")
        end

        if fmcGrowthControl.weedPropagation and g_currentMission.fmcFoliageWeed ~= nil then
            fmcGrowthControl.weedPropagation = false
            --
            fmcGrowthControl.weedCell = (fmcGrowthControl.weedCell + 1) % (fmcGrowthControl.cells * fmcGrowthControl.cells);
            fmcGrowthControl.updateWeedFoliage(self, fmcGrowthControl.weedCell)
        end
      else
        if g_currentMission.time > fmcGrowthControl.nextUpdateTime then
          fmcGrowthControl.nextUpdateTime = g_currentMission.time + fmcGrowthControl.updateDelayMs;
          --
          local totalCells = (fmcGrowthControl.cells*fmcGrowthControl.cells)
          local pctCompleted = ((totalCells - fmcGrowthControl.cellSquareToUpdate) / totalCells) + 0.01 -- Add 1% to get clients to render "Growth: %"
          local cellToUpdate = fmcGrowthControl.cellSquareToUpdate

          -- TODO - implement different methods (i.e. patterns) so the cells will not be updated in the same straight pattern every time.
          if fmcGrowthControl.cellSquaresMethod == 0 then
            -- North-West to South-East
            cellToUpdate = totalCells - cellToUpdate
          elseif fmcGrowthControl.cellSquaresMethod == 1 then
            -- South-East to North-West
            cellToUpdate = cellToUpdate - 1
          end

          fmcGrowthControl.updateFoliageCell(self, cellToUpdate, pctCompleted)
          --
          fmcGrowthControl.cellSquareToUpdate = fmcGrowthControl.cellSquareToUpdate - 1
          if fmcGrowthControl.cellSquareToUpdate <= 0 then
            fmcGrowthControl.active = false;
            fmcGrowthControl.updateFoliageCellXZWH(self, 0,0, 0, 0) -- Send "finished"
            log("fmcGrowthControl - Growth: Finished")
          end
        end
      end
    end
end;

--
function fmcGrowthControl:minuteChanged()
    fmcGrowthControl.weedCounter = Utils.getNoNil(fmcGrowthControl.weedCounter,0) + 1
    -- Set speed of weed propagation relative to how often 'growth cycle' occurs.
    if (0 == (fmcGrowthControl.weedCounter % (fmcGrowthControl.delayGrowthCycleDays + 1))) then
        fmcGrowthControl.weedPropagation = true
    end
end

--
function fmcGrowthControl:hourChanged()
    -- Apparently 'currentDay' is NOT incremented _before_ calling the hourChanged() callbacks
    -- This should fix the "midnight problem".
    local currentDay = g_currentMission.environment.currentDay
    if g_currentMission.environment.currentHour == 0 then
        currentDay = currentDay + 1 
    end

    --
    if  not fmcGrowthControl.active -- Must not already be running
    and g_currentMission.environment.currentHour == fmcGrowthControl.startGrowthCycleHour
    and currentDay ~= fmcGrowthControl.lastUpdateDay -- must be a different day
    then
        log("Current in-game day/hour: ", currentDay, "/", g_currentMission.environment.currentHour,
            ". Growth-cycle activates after day: ", (fmcGrowthControl.lastUpdateDay + fmcGrowthControl.delayGrowthCycleDays),
            " (delayGrowthCycleDays=",fmcGrowthControl.delayGrowthCycleDays,")",
            " at hour: ", fmcGrowthControl.startGrowthCycleHour
        )
        if currentDay > (fmcGrowthControl.lastUpdateDay + fmcGrowthControl.delayGrowthCycleDays) then
            fmcGrowthControl.canActivate = true
        end
    end
end

--
function fmcGrowthControl:updateWeedFoliage(cellSquareToUpdate)
  local weedPlaced = 0
  local tries = 5
  local x = math.floor(fmcGrowthControl.cellWH * math.floor(cellSquareToUpdate % fmcGrowthControl.cells))
  local z = math.floor(fmcGrowthControl.cellWH * math.floor(cellSquareToUpdate / fmcGrowthControl.cells))
  local sx,sz = (x-(g_currentMission.terrainSize/2)),(z-(g_currentMission.terrainSize/2))

  -- Repeat until a spot was found (weed seeded) or maximum-tries reached.
  repeat
    local xOff = fmcGrowthControl.cellWH * math.random()
    local zOff = fmcGrowthControl.cellWH * math.random()
    local r = 1 + 3 * math.random()
    -- Place 4 "patches" of weed.
    for i=0,3 do
        weedPlaced = weedPlaced + fmcGrowthControl.createWeedFoliage(self, math.ceil(sx + xOff), math.ceil(sz + zOff), math.ceil(r))
        if weedPlaced <= 0 then
            -- If first "patch" failed (i.e. "not in a field"), then do not bother with the rest.
            break
        end
        -- Pick a new spot that is a bit offset from the previous spot.
        local r2 = 1 + 3 * math.random()
        xOff = xOff + (Utils.sign(math.random()-0.5) * (r + r2) * 0.9)
        zOff = zOff + (Utils.sign(math.random()-0.5) * (r + r2) * 0.9)
        r = r2
    end
    tries = tries - 1
  until weedPlaced > 0 or tries <= 0
end

--
function fmcGrowthControl:createWeedFoliage(centerX,centerZ,radius, noEventSend)
    --local sx,sz,  wx,wz,  hx,hz = centerX-radius,centerZ-radius,  radius*2,0,  0,radius*2
 
    local function rotXZ(offX,offZ,x,z,angle)
        x = x * math.cos(angle) - z * math.sin(angle)
        z = x * math.sin(angle) + z * math.cos(angle)
        return offX + x, offZ + z
    end

    -- Attempt making a more "round" look
    local parallelograms = {}
    for _,angle in pairs({0,30,60}) do
        angle = Utils.degToRad(angle)
        local p = {}
        p.sx,p.sz = rotXZ(centerX,centerZ, -radius,-radius, angle)
        p.wx,p.wz = rotXZ(0,0,             radius*2,0,      angle)
        p.hx,p.hz = rotXZ(0,0,             0,radius*2,      angle)
        table.insert(parallelograms, p)
        --log("weed ", angle, ":", p.sx,"/",p.sz, ",", p.wx,"/",p.wz, ",", p.hx,"/",p.hz)
    end
 
    local includeMask   = 2^g_currentMission.sowingChannel
                        + 2^g_currentMission.sowingWidthChannel
                        + 2^g_currentMission.cultivatorChannel
                        + 2^g_currentMission.ploughChannel;

    setDensityCompareParams(g_currentMission.fmcFoliageWeed, "equal", 0)
    setDensityMaskParams(g_currentMission.fmcFoliageWeed, "greater", -1,-1, includeMask, 0)
    local pixelsMatch = 0
    for _,p in pairs(parallelograms) do
        --log("weed place ", p.sx,"/",p.sz, ",", p.wx,"/",p.wz, ",", p.hx,"/",p.hz)
        local _, pixMatch, _ = setDensityMaskedParallelogram(
            g_currentMission.fmcFoliageWeed,
            p.sx,p.sz,p.wx,p.wz,p.hx,p.hz,
            0, 3,
            g_currentMission.terrainDetailId, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels, -- mask
            4 -- set
        )
        pixelsMatch = pixelsMatch + pixMatch
        if pixelsMatch <= 0 then
            break
        end
    end
    setDensityMaskParams(g_currentMission.fmcFoliageWeed, "greater", -1)
    setDensityCompareParams(g_currentMission.fmcFoliageWeed, "greater", -1)

    --
    if pixelsMatch > 0 then
        CreateWeedEvent.sendEvent(centerX,centerZ,radius,noEventSend)
    end

    return pixelsMatch
end

--
function fmcGrowthControl:updateFoliageCell(cellSquareToUpdate, pctCompleted, noEventSend)
    local x = math.floor(fmcGrowthControl.cellWH * math.floor(cellSquareToUpdate % fmcGrowthControl.cells))
    local z = math.floor(fmcGrowthControl.cellWH * math.floor(cellSquareToUpdate / fmcGrowthControl.cells))
    local sx,sz = (x-(g_currentMission.terrainSize/2)),(z-(g_currentMission.terrainSize/2))

    fmcGrowthControl:updateFoliageCellXZWH(sx,sz, fmcGrowthControl.cellWH, pctCompleted, noEventSend)
end

function fmcGrowthControl:updateFoliageCellXZWH(x,z, wh, pctCompleted, noEventSend)
    fmcGrowthControl.pctCompleted = pctCompleted
    fmcGrowthControlEvent.sendEvent(x,z, wh, pctCompleted, noEventSend)

    -- Test for "magic number" indicating finished.
    if wh <= 0 then
        return
    end

    local sx,sz,wx,wz,hx,hz = x,z,  wh-0.5,0,  0,wh-0.5

    -- For each fruit foliage-layer (increase growth)
    for _,fruitEntry in pairs(g_currentMission.fmcFoliageGrowthLayers) do
        for _,callFunc in pairs(fmcGrowthControl.pluginsGrowthCycleFruits) do
            callFunc(sx,sz,wx,wz,hx,hz,fruitEntry)
        end
    end

    -- For other foliage-layers
    for _,callFunc in pairs(fmcGrowthControl.pluginsGrowthCycle) do
        callFunc(sx,sz,wx,wz,hx,hz)
    end
end

--
function fmcGrowthControl:renderTextShaded(x,y,fontsize,txt,foreColor,backColor)
    if backColor ~= nil then
        setTextColor(unpack(backColor));
        renderText(x + (fontsize * 0.075), y - (fontsize * 0.075), fontsize, txt)
    end
    if foreColor ~= nil then
        setTextColor(unpack(foreColor));
    end
    renderText(x, y, fontsize, txt)
end

--
function fmcGrowthControl:draw()
    if fmcGrowthControl.pctCompleted > 0.00 and g_gui.currentGui == nil then
        local txt = (g_i18n:getText("GrowthPct")):format(fmcGrowthControl.pctCompleted * 100)
        setTextAlignment(RenderText.ALIGN_CENTER);
        setTextBold(false);
        self:renderTextShaded(fmcGrowthControl.hudPosX, fmcGrowthControl.hudPosY, fmcGrowthControl.hudFontSize, txt, {1,1,1,0.8}, {0,0,0,0.8})
        setTextAlignment(RenderText.ALIGN_LEFT);
        setTextColor(1,1,1,1)
    end

--[[
    -- Code for showing days countdown to growth cycle.
    local growthCycleDaysCountdown = (fmcGrowthControl.lastUpdateDay + fmcGrowthControl.delayGrowthCycleDays) - g_currentMission.environment.currentDay
    self:renderTextShaded(  -- Custom renderText() method
      0.002, 0.002,  -- Screen X,Y position (Percentage of screen width/height. Range 0.000 - 1.000)
      0.02,  -- Font size (percentage of screen height)
      tostring(growthCycleDaysCountdown),  -- Text to render
      {1.0, 1.0, 1.0, 0.8}, -- Foreground color (R,G,B,A. Range 0.0 - 1.0)
      {0.0, 0.0, 0.0, 0.8}  -- Background/shade color (R,G,B,A. Range 0.0 - 1.0)
    )
--]]
end;

-------
-------
-------

fmcGrowthControlEvent = {};
fmcGrowthControlEvent_mt = Class(fmcGrowthControlEvent, Event);

InitEventClass(fmcGrowthControlEvent, "GrowthControlEvent");

function fmcGrowthControlEvent:emptyNew()
    local self = Event:new(fmcGrowthControlEvent_mt);
    self.className="fmcGrowthControlEvent";
    return self;
end;

function fmcGrowthControlEvent:new(x,z, wh, pctCompleted)
    local self = fmcGrowthControlEvent:emptyNew()
    self.x = x
    self.z = z
    self.wh = wh
    self.pctCompleted = pctCompleted
    return self;
end;

function fmcGrowthControlEvent:readStream(streamId, connection)
    local pctCompleted  = streamReadUInt8(streamId) / 100
    local x             = streamReadInt16(streamId)
    local z             = streamReadInt16(streamId)
    local wh            = streamReadInt16(streamId)
    fmcGrowthControl.updateFoliageCellXZWH(fmcGrowthControl, x,z, wh, pctCompleted, true);
end;

function fmcGrowthControlEvent:writeStream(streamId, connection)
    streamWriteUInt8(streamId, math.floor(self.pctCompleted * 100))
    streamWriteInt16(streamId, self.x)
    streamWriteInt16(streamId, self.z)
    streamWriteInt16(streamId, self.wh)
end;

function fmcGrowthControlEvent.sendEvent(x,z, wh, pctCompleted, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(fmcGrowthControlEvent:new(x,z, wh, pctCompleted), nil, nil, nil);
        end;
    end;
end;

-------
-------
-------

CreateWeedEvent = {};
CreateWeedEvent_mt = Class(CreateWeedEvent, Event);

InitEventClass(CreateWeedEvent, "CreateWeedEvent");

function CreateWeedEvent:emptyNew()
    local self = Event:new(CreateWeedEvent_mt);
    self.className="CreateWeedEvent";
    return self;
end;

function CreateWeedEvent:new(x,z,r)
    local self = CreateWeedEvent:emptyNew()
    self.centerX = x
    self.centerZ = z
    self.radius  = r
    return self;
end;

function CreateWeedEvent:readStream(streamId, connection)
    local centerX = streamReadIntN(streamId, 16)
    local centerZ = streamReadIntN(streamId, 16)
    local radius  = streamReadIntN(streamId, 4)
    fmcGrowthControl:createWeedFoliage(centerX,centerZ,radius, true)
end;

function CreateWeedEvent:writeStream(streamId, connection)
    streamWriteIntN(streamId, self.centerX, 16)
    streamWriteIntN(streamId, self.centerZ, 16)
    streamWriteIntN(streamId, self.radius,  4)
end;

function CreateWeedEvent.sendEvent(x,z,r,noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(CreateWeedEvent:new(x,z,r), nil, nil, nil);
        end;
    end;
end;


print(string.format("Script loaded: fmcGrowthControl.lua (v%s)", fmcGrowthControl.version));
