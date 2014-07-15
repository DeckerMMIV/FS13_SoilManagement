--
-- PdaPlugin_SoilCondition
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-May
--
-- @history
--  2014-May
--      v0.01   - Initial experiment
--      v0.10   - Changed to use modPDAMOD.registerPlugin(...)
--              - Updated calculations and info display
--  2014-June
--      v0.11   - Due to the NON-deterministic way that mods are loaded in multiplayer, the modPDAMOD.registerPlugin(...)
--                is replaced in favor of a hopefully more robust "create object modPDAMODplugins, and add yourself to it" method.
--  2014-July
--      v0.2.1  - Use SoilMod's calculate function for pH value.
--      v0.2.2  - Added "Crops in area"
--      v0.3.0  - Extra subpage added, to show how fruits gains boost effect fro type of fertilizer(synthetic) 
--                and are affected by type of herbicide.
--      v1.0.0  - Initial public version.
--      ------
--  Revision history is now kept in GitHub repository.
--

PdaPlugin_SoilCondition = {}
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
PdaPlugin_SoilCondition.version = (modItem and modItem.version) and modItem.version or "?.?.?";
--
PdaPlugin_SoilCondition.isInitialized = false;


-- Register this PDAMod plugin
getfenv(0)["modPDAMODplugins"] = getfenv(0)["modPDAMODplugins"] or {}
table.insert(getfenv(0)["modPDAMODplugins"], PdaPlugin_SoilCondition);
--


function PdaPlugin_SoilCondition:loadMap(xmlName)
    PdaPlugin_SoilCondition.timeout = 0
end;

function PdaPlugin_SoilCondition:deleteMap()
    PdaPlugin_SoilCondition.isInitialized = false;
end;

function PdaPlugin_SoilCondition.initialize(self, initStep)
    if initStep == 1 then
        modPDAMOD.registerPage(
            "soilCondition", nil, 
            PdaPlugin_SoilCondition.subPageDraw,    g_currentMission.missionPDA, nil,
            nil, nil, nil
        );
        --
        modPDAMOD.registerPage(
            "soilCondition", nil, 
            PdaPlugin_SoilCondition.subPage2Draw,    g_currentMission.missionPDA, nil,
            nil, nil, nil
        );
    end
end;

--
function PdaPlugin_SoilCondition.subPageDraw(self, parm, origMissionPdaDrawFunc)
    -- Note: 'self' is in context of the g_currentMission.missionPDA object.

    --
    self.hudPDABackgroundOverlay:render()
    --
    if PdaPlugin_SoilCondition.timeout < g_currentMission.time then
        PdaPlugin_SoilCondition.timeout = g_currentMission.time + 1000
        local specs = {}
        PdaPlugin_SoilCondition.buildFieldCondition(specs)
        PdaPlugin_SoilCondition.scrollTxts,_ = PdaPlugin_SoilCondition.makeScrollText(specs, self.pdaFontSize, self.pdaWidth)
    end
    
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextColor(1,1,1,1);
    setTextBold(false);
    --
    if PdaPlugin_SoilCondition.scrollTxts ~= nil then
        --local row = (g_currentMission.time - PdaPlugin_SoilCondition.scrollLine)
        local row = 0
        local posY = self.pdaHeadRow - (0 * self.pdaFontSize) + ((row % 1000) / 1000 * self.pdaFontSize)
        
        row = math.floor(row / 1000)
        local maxRows = table.getn(PdaPlugin_SoilCondition.scrollTxts)
        
        row = (row % maxRows) + 1
        while posY > self.pdaMapPosY do
            renderText(self.pdaX, posY, self.pdaFontSize, PdaPlugin_SoilCondition.scrollTxts[row]);
            posY = posY - self.pdaFontSize
            row = (row % maxRows) + 1
        end
    end
    --
    self.hudPDAFrameOverlay:render()
    --
    modPDAMOD.drawTitle(g_i18n:getText("SoilCondition"));
end

--
function PdaPlugin_SoilCondition.buildFieldCondition(specs)
    
    local layers2 = {
        {
            layerId = g_currentMission.fmcFoliageSoil_pH,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 3)

                local txt = ""
                if numPixels1>0 then
                    local phValue = 0;
                    local phDenomination = g_i18n:getText("NoCalculation")
                    if (fmcSoilMod and fmcSoilMod.density_to_pH and fmcSoilMod.pH_to_Denomination) then
                        phValue         = fmcSoilMod.density_to_pH(sumPixels1, numPixels1, 3)
                        phDenomination  = fmcSoilMod.pH_to_Denomination(phValue)
                        if g_i18n:hasText(phDenomination) then
                            phDenomination = g_i18n:getText(phDenomination)
                        end
                    end
                    txt = (g_i18n:getText("SoilpH_value_denomination")):format(phValue, phDenomination)
                else
                    txt = g_i18n:getText("NotAvailable")
                end
                return (g_i18n:getText("SoilpH")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageFertilizerOrganic,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 2)

                local txt = ""
                if sumPixels1>0 then
                    txt = (g_i18n:getText("FertilizerOrganic_Level")):format(sumPixels1/numPixels1)
                else
                    txt = g_i18n:getText("None")
                end
                return (g_i18n:getText("FertilizerOrganic")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageFertilizerSynthetic,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 1)
                local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 1, 1)

                local txt = ""
                if sumPixels1>0 and sumPixels2>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_TypeC_pct")):format(100 * (sumPixels1/numPixels1+sumPixels2/numPixels2)/2)
                elseif sumPixels1>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_TypeA_pct")):format(100 * sumPixels1/numPixels1)
                elseif sumPixels2>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_TypeB_pct")):format(100 * sumPixels2/numPixels2)
                else
                    txt = g_i18n:getText("None")
                end
                return (g_i18n:getText("FertilizerSynthetic")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageHerbicide,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 1)
                local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 1, 1)
                
                local txt = ""
                if sumPixels1>0 and sumPixels2>0 then
                    txt = (g_i18n:getText("Herbicide_TypeC_pct")):format(100 * (sumPixels1/numPixels1+sumPixels2/numPixels2)/2)
                elseif sumPixels1>0 then
                    txt = (g_i18n:getText("Herbicide_TypeA_pct")):format(100 * sumPixels1/numPixels1)
                elseif sumPixels2>0 then
                    txt = (g_i18n:getText("Herbicide_TypeB_pct")):format(100 * sumPixels2/numPixels2)
                else
                    txt = g_i18n:getText("None")
                end
                return (g_i18n:getText("Herbicide")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageWeed,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 2)
                --local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 2, 1)
                
                local txt = ""
                if numPixels1>0 --[[ and numPixels2>0 ]] then
                    local weedPct = (sumPixels1/(3*numPixels1))
                    --local alivePct = sumPixels2/numPixels2
                    txt = (g_i18n:getText("WeedInfestation_pct")):format(weedPct*100)
                else
                    txt = g_i18n:getText("NotAvailable")
                end
                return (g_i18n:getText("WeedInfestation")):format(txt)
            end,
        },
        {
            layerId = -1,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                return ""; -- Blank line
            end,
        },
        {
            layerId = -1,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                -- Fruits..
                local foundFruits = nil
                for fruitIndex,fruit in pairs(g_currentMission.fruits) do
                    if fruit.id ~= nil and fruit.id ~= 0 then
                        setDensityCompareParams(fruit.id, "between", 1, 7)  -- growing #1-#4, harvest #5-#7
                        local _,numPixels1 = getDensityParallelogram(fruit.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitStateChannels)
                        setDensityCompareParams(fruit.id, "greater", 9) -- defoliaged #10-..
                        local _,numPixels2 = getDensityParallelogram(fruit.id, x, z, widthX, widthZ, heightX, heightZ, 0, g_currentMission.numFruitStateChannels)
                        setDensityCompareParams(fruit.id, "greater", 0)
                        --
                        if numPixels1 > 0 or numPixels2 > 0 then
                            local fruitName = FruitUtil.fruitIndexToDesc[fruitIndex].name
                            if g_i18n:hasText(fruitName) then
                                fruitName = g_i18n:getText(fruitName)
                            end
                            foundFruits = ((foundFruits == nil) and "" or foundFruits..", ") .. fruitName
                        end
                    end
                end
                return ("Crops in area: %s"):format(foundFruits or "(none)")
            end,
        },
    }

    local x,y,z
    if g_currentMission.controlPlayer and g_currentMission.player ~= nil then
        x,y,z = getWorldTranslation(g_currentMission.player.rootNode)
    elseif g_currentMission.controlledVehicle ~= nil then
        x,y,z = getWorldTranslation(g_currentMission.controlledVehicle.rootNode)
    end
    
    if x ~= nil and x==x and z==z then
        local squareSize = 10
        local widthX, widthZ, heightX, heightZ = squareSize-0.5,0, 0,squareSize-0.5
        x = x - squareSize/2
        z = z - squareSize/2
    
        table.insert(specs, ("PlayerLoc=%.1f,%.1f,%.1f - Area=%dx%d"):format(x,y,z,squareSize,squareSize))
        table.insert(specs, "")

        for _,layer in ipairs(layers2) do
            if layer.layerId ~= nil and layer.layerId ~= 0 and layer.func ~= nil then
                table.insert(specs, layer:func(x, z, widthX, widthZ, heightX, heightZ))
            end
        end
    end
end

--
function PdaPlugin_SoilCondition.subPage2Draw(self, parm, origMissionPdaDrawFunc)
    -- Note: 'self' is in context of the g_currentMission.missionPDA object.

    --
    self.hudPDABackgroundOverlay:render()
    --
    if PdaPlugin_SoilCondition.fruitEffects == nil then
        local specs = {}
        PdaPlugin_SoilCondition.buildFruitEffects(specs)
        PdaPlugin_SoilCondition.fruitEffects = PdaPlugin_SoilCondition.makeScrollText(specs, self.pdaFontSize, self.pdaWidth)
    end
    
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextColor(1,1,1,1);
    setTextBold(false);
    --
    if PdaPlugin_SoilCondition.fruitEffects ~= nil then
        --local row = (g_currentMission.time - PdaPlugin_SoilCondition.scrollLine)
        local row = 0
        local posY = self.pdaHeadRow - (0 * self.pdaFontSize) + ((row % 1000) / 1000 * self.pdaFontSize)
        
        row = math.floor(row / 1000)
        local maxRows = table.getn(PdaPlugin_SoilCondition.fruitEffects)
        
        row = (row % maxRows) + 1
        while posY > self.pdaMapPosY do
            renderText(self.pdaX, posY, self.pdaFontSize, PdaPlugin_SoilCondition.fruitEffects[row]);
            posY = posY - self.pdaFontSize
            row = (row % maxRows) + 1
        end
    end
    --
    self.hudPDAFrameOverlay:render()
    --
    modPDAMOD.drawTitle(g_i18n:getText("FruitEffects"));
end

--
function PdaPlugin_SoilCondition.buildFruitEffects(specs)
    for i = 1, FruitUtil.NUM_FRUITTYPES do
        local fruitDesc = FruitUtil.fruitIndexToDesc[i]
        local fruitLayer = g_currentMission.fruits[fruitDesc.index];
        if fruitLayer ~= nil and fruitLayer.id ~= 0 then
            
            local fertilizerBoost = nil
            if fruitDesc.fmcBoostFertilizer ~= nil then
                if     fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER  then fertilizerBoost = "A";
                elseif fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER2 then fertilizerBoost = "B";
                elseif fruitDesc.fmcBoostFertilizer == Fillable.FILLTYPE_FERTILIZER3 then fertilizerBoost = "C";
                end
            end
            
            local herbicideAffected = nil
            if fruitDesc.fmcHerbicideAffected ~= nil then
                if     fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE  then herbicideAffected = "A";
                elseif fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE2 then herbicideAffected = "B";
                elseif fruitDesc.fmcHerbicideAffected == Fillable.FILLTYPE_HERBICIDE3 then herbicideAffected = "C";
                end
            end
            
            if fertilizerBoost ~= nil or herbicideAffected ~= nil then
                local fruitName = g_i18n:hasText(fruitDesc.name) and g_i18n:getText(fruitDesc.name) or fruitDesc.name;
                fertilizerBoost   = (fertilizerBoost == nil and "-" or (g_i18n:getText("FertilizerType")):format(fertilizerBoost))
                herbicideAffected = (herbicideAffected == nil and "-" or (g_i18n:getText("HerbicideType")):format(herbicideAffected))
                
                local txt = ("%s: %s, %s"):format(fruitName, fertilizerBoost, herbicideAffected)
                table.insert(specs, txt);
            end
        end
    end
end    


--
function PdaPlugin_SoilCondition.makeScrollText(specs, fontSize, maxTextWidth)
    -- Convert to scrollable text-area
    local scrollTxts = {}
    -- scrollLine = g_currentMission.time
    for _,spec in pairs(specs) do
        local line = nil
        local words = Utils.splitString(" ",spec)
        local j = table.getn(words)
        if j > 0 then
            local i = 1
            line = words[i]
            i=i+1
            while i <= j do
                if getTextWidth(fontSize, line.." "..words[i]) > maxTextWidth then
                    table.insert(scrollTxts, line)
                    line = words[i]
                else
                    line = line .. " " .. words[i]
                end
                i=i+1
            end
        end
        if line ~= nil then
            table.insert(scrollTxts, line)
        end
        --
    end
    table.insert(scrollTxts, "")
    table.insert(scrollTxts, "----- -----")
    table.insert(scrollTxts, "")
    while table.getn(scrollTxts) < 15 do
        table.insert(scrollTxts, "")
    end
    
    return scrollTxts, g_currentMission.time
end

print(string.format("Script loaded: PdaPlugin_SoilCondition.LUA (v%s)", PdaPlugin_SoilCondition.version));
