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
        --
        if g_i18n:hasText("SoilHelpText") and g_i18n:getText("SoilHelpText") ~= "" then
          modPDAMOD.registerPage(
              "soilCondition", nil, 
              PdaPlugin_SoilCondition.subPage3Draw,    g_currentMission.missionPDA, nil,
              nil, nil, nil
          );
        end
    end
end;

--
function PdaPlugin_SoilCondition.subPage3Draw(self, parm, origMissionPdaDrawFunc)
    -- Note: 'self' is in context of the g_currentMission.missionPDA object.
    --
    if PdaPlugin_SoilCondition.page3Text == nil then
        local helpLines = Utils.splitString("\n", g_i18n:getText("SoilHelpText"))
        PdaPlugin_SoilCondition.page3Text = PdaPlugin_SoilCondition.makeScrollText(helpLines, self.pdaFontSize, self.pdaWidth)
    end
    --
    self.hudPDABackgroundOverlay:render()
    --
    if PdaPlugin_SoilCondition.page3Text ~= nil then
        setTextAlignment(RenderText.ALIGN_LEFT);
        setTextColor(1,1,1,1);
        setTextBold(false);

        local row = g_currentMission.time
        local posY = self.pdaHeadRow - (0 * self.pdaFontSize) + ((row % 1000) / 1000 * self.pdaFontSize)
        
        row = math.floor(row / 1000)
        local maxRows = table.getn(PdaPlugin_SoilCondition.page3Text)
        
        row = (row % maxRows) + 1
        while posY > self.pdaMapPosY do
            renderText(self.pdaX, posY, self.pdaFontSize, PdaPlugin_SoilCondition.page3Text[row]);
            posY = posY - self.pdaFontSize
            row = (row % maxRows) + 1
        end
    end
    --
    self.hudPDAFrameOverlay:render()
    --
    modPDAMOD.drawTitle(g_i18n:getText("SoilHelpTitle"));
end

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
        PdaPlugin_SoilCondition.scrollTxts = PdaPlugin_SoilCondition.makeScrollText(specs, self.pdaFontSize, self.pdaWidth)
    end
    
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextColor(1,1,1,1);
    setTextBold(false);
    --
    if PdaPlugin_SoilCondition.scrollTxts ~= nil then
        local row = 0
        --if PdaPlugin_SoilCondition.scrollLine ~= nil then
        --    row = (g_currentMission.time - PdaPlugin_SoilCondition.scrollLine)
        --end
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

                local txt = "-"
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
                end
                return (g_i18n:getText("SoilpH")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageFertilizerOrganic,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 2)

                local txt = "-"
                if sumPixels1>0 then
                    txt = (g_i18n:getText("FertilizerOrganic_Level")):format(sumPixels1/numPixels1)
                end
                return (g_i18n:getText("FertilizerOrganic")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageFertilizerSynthetic,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 1)
                local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 1, 1)

                local txt = "-"
                if sumPixels1>0 and sumPixels2>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_Type_pct")):format("C", 100 * (sumPixels1/numPixels1+sumPixels2/numPixels2)/2)
                elseif sumPixels1>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_Type_pct")):format("A", 100 * sumPixels1/numPixels1)
                elseif sumPixels2>0 then
                    txt = (g_i18n:getText("FertilizerSynthetic_Type_pct")):format("B", 100 * sumPixels2/numPixels2)
                end
                return (g_i18n:getText("FertilizerSynthetic")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageHerbicide,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 1)
                local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 1, 1)
                
                local txt = "-"
                if sumPixels1>0 and sumPixels2>0 then
                    txt = (g_i18n:getText("Herbicide_Type_pct")):format("C", 100 * (sumPixels1/numPixels1+sumPixels2/numPixels2)/2)
                elseif sumPixels1>0 then
                    txt = (g_i18n:getText("Herbicide_Type_pct")):format("A", 100 * sumPixels1/numPixels1)
                elseif sumPixels2>0 then
                    txt = (g_i18n:getText("Herbicide_Type_pct")):format("B", 100 * sumPixels2/numPixels2)
                end
                return (g_i18n:getText("Herbicide")):format(txt)
            end,
        },
        {
            layerId = g_currentMission.fmcFoliageWeed,
            func = function(self, x, z, widthX, widthZ, heightX, heightZ)
                local sumPixels1,numPixels1 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 0, 2)
                --local sumPixels2,numPixels2 = getDensityParallelogram(self.layerId, x, z, widthX, widthZ, heightX, heightZ, 2, 1)
                
                local txt = "-"
                if numPixels1>0 --[[ and numPixels2>0 ]] then
                    local weedPct = (sumPixels1/(3*numPixels1))
                    --local alivePct = sumPixels2/numPixels2
                    txt = (g_i18n:getText("WeedInfestation_pct")):format(weedPct*100)
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
                            local fillTypeIndex = FruitUtil.fruitTypeToFillType[fruitIndex]
                            local fillTypeName = Fillable.fillTypeIndexToDesc[fillTypeIndex].nameI18N
                            if fillTypeName == nil then
                                fillTypeName = Fillable.fillTypeIndexToDesc[fillTypeIndex].name
                                if g_i18n:hasText(fillTypeName) then
                                    fillTypeName = g_i18n:getText(fillTypeName)
                                end
                            end
                            foundFruits = ((foundFruits == nil) and "" or foundFruits..", ") .. fillTypeName
                        end
                    end
                end
                return (g_i18n:getText("CropsInArea")):format(foundFruits or "-")
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
    
        local pdaMapX, pdaMapZ = x + g_currentMission.missionPDA.worldCenterOffsetX, z + g_currentMission.missionPDA.worldCenterOffsetZ
        table.insert(specs, (g_i18n:getText("CurrentLocationScanSize")):format(pdaMapX,pdaMapZ,squareSize,squareSize))
        table.insert(specs, "") -- Blank line

        local widthX, widthZ, heightX, heightZ = squareSize-0.5,0, 0,squareSize-0.5
        x, z = x - (squareSize/2), z - (squareSize/2)
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
        PdaPlugin_SoilCondition.buildFruitEffects(specs, self.pdaFontSize)
        PdaPlugin_SoilCondition.fruitEffects, PdaPlugin_SoilCondition.scrollLine = PdaPlugin_SoilCondition.makeScrollText(specs, self.pdaFontSize, self.pdaWidth, 3)
    end
    
    setTextAlignment(RenderText.ALIGN_LEFT);
    setTextColor(1,1,1,1);
    setTextBold(false);
    --
    if PdaPlugin_SoilCondition.fruitEffects ~= nil then
        local row = 0
        if PdaPlugin_SoilCondition.scrollLine ~= nil then
            row = (g_currentMission.time - PdaPlugin_SoilCondition.scrollLine)
        end
        local posY = self.pdaHeadRow - (0 * self.pdaFontSize) + ((row % 1000) / 1000 * self.pdaFontSize)
        
        row = math.floor(row / 1000)
        local maxRows = table.getn(PdaPlugin_SoilCondition.fruitEffects)
        
        row = (row % maxRows) + 1
        while posY > self.pdaMapPosY do
            PdaPlugin_SoilCondition.fruitEffects[row](self.pdaX, posY) -- draws the texts
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
    table.insert(specs, Utils.splitString("|", g_i18n:getText("FruitEffectsHeader")))
    table.insert(specs, ""); -- Blank line
    
    for i = 1, FruitUtil.NUM_FRUITTYPES do
        local fruitDesc = FruitUtil.fruitIndexToDesc[i]
        local fruitLayer = g_currentMission.fruits[fruitDesc.index];
        if fruitLayer ~= nil and fruitLayer.id ~= 0 then
            
            local fertilizerBoost = nil
            if fruitDesc.fmcBoostFertilizer ~= nil then
                local fillTypeDesc = Fillable.fillTypeIndexToDesc[fruitDesc.fmcBoostFertilizer]
                if fillTypeDesc ~= nil and fillTypeDesc.nameI18N ~= nil then
                    fertilizerBoost = fillTypeDesc.nameI18N
                elseif fillTypeDesc ~= nil and g_i18n:hasText(fillTypeDesc.name) then
                    fertilizerBoost = g_i18n:getText(fillTypeDesc.name)
                else
                    fertilizerBoost = "("..tostring(fruitDesc.fmcBoostFertilizer)..")?"
                end
            end
            
            local herbicideAffected = nil
            if fruitDesc.fmcHerbicideAffected ~= nil then
                local fillTypeDesc = Fillable.fillTypeIndexToDesc[fruitDesc.fmcHerbicideAffected]
                if fillTypeDesc ~= nil and fillTypeDesc.nameI18N ~= nil then
                    herbicideAffected = fillTypeDesc.nameI18N
                elseif fillTypeDesc ~= nil and g_i18n:hasText(fillTypeDesc.name) then
                    herbicideAffected = g_i18n:getText(fillTypeDesc.name)
                else
                    herbicideAffected = "("..tostring(fruitDesc.fmcHerbicideAffected)..")?"
                end
            end
            
            if fertilizerBoost ~= nil or herbicideAffected ~= nil then
                local fillTypeDesc = Fillable.fillTypeIndexToDesc[FruitUtil.fruitTypeToFillType[fruitDesc.index]]
                local fillTypeName = fillTypeDesc.nameI18N ~= nil and fillTypeDesc.nameI18N or (g_i18n:hasText(fillTypeDesc.name) and g_i18n:getText(fillTypeDesc.name) or fillTypeDesc.name);
                fertilizerBoost   = (fertilizerBoost   == nil and "-" or fertilizerBoost)
                herbicideAffected = (herbicideAffected == nil and "-" or herbicideAffected)

                table.insert(specs, {fillTypeName, fertilizerBoost, herbicideAffected});
            end
        end
    end
end    


--
function PdaPlugin_SoilCondition.makeScrollText(specs, fontSize, maxTextWidth, numCols)
    local scrollTxts = {}
    local colMaxWidth = {}
    
    -- Is text going into columns?
    if numCols ~= nil then
        -- Find max column widths
        local colPadding = getTextWidth(fontSize, "  ")
        local col1MaxChar = 0 
        local col1MaxTxt = ""
        for _,spec in pairs(specs) do
            if type(spec) == type({}) then
                local specCount = table.getn(spec)
                for idx,colTxt in ipairs(spec) do
                    local txtWidth = getTextWidth(fontSize, colTxt) + (idx<specCount and colPadding or 0)
                    colMaxWidth[idx] = (colMaxWidth[idx]~=nil and math.max(txtWidth, colMaxWidth[idx]) or txtWidth)
                end
                if spec[1]:len() > col1MaxChar then
                    col1MaxChar = spec[1]:len()
                    col1MaxTxt = spec[1]
                end
            end
        end
        -- Determine if first column should be truncated
        local totalWidth = 0
        for _,txtWidth in pairs(colMaxWidth) do
            totalWidth = totalWidth + txtWidth;
        end
        if totalWidth > maxTextWidth and col1MaxChar > 10 then
            -- Find best width of first column
            for maxChars = col1MaxChar,10,-1 do
                local newTxtWidth = getTextWidth(fontSize, col1MaxTxt:sub(1,maxChars) .. "…") + colPadding
                if maxChars == 10 or totalWidth - colMaxWidth[1] + newTxtWidth <= maxTextWidth then
                    col1MaxChar = maxChars
                    colMaxWidth[1] = newTxtWidth
                    break
                end
            end
            -- Truncate column-1 texts longer than the found max-chars.
            for _,spec in pairs(specs) do
                if type(spec) == type({}) then
                    if spec[1]:len() > col1MaxChar then
                        spec[1] = spec[1]:sub(1,col1MaxChar) .. "…"; -- 0x2026  -- "…"
                    end
                end
            end
        end
        
        -- Build the scrollable array, where functions are then used to render text later.
        for _,spec in pairs(specs) do
            if type(spec) == type({}) then
                table.insert(scrollTxts, function(x,y)
                        local offset = 0
                        for idx,txt in ipairs(spec) do
                            renderText(x+offset, y, fontSize, txt);
                            offset = offset + colMaxWidth[idx]
                        end
                    end
                )
            elseif type(spec) == type("") and spec ~= "" then
                table.insert(scrollTxts, function(x,y)
                        renderText(x, y, fontSize, spec);
                    end
                )
            else
                table.insert(scrollTxts, function(x,y) end) -- blank line
            end
        end
        table.insert(scrollTxts, function(x,y) end) -- blank line
        table.insert(scrollTxts, function(x,y) renderText(x,y,fontSize, g_i18n:getText("ScrollDivider")) end)
        table.insert(scrollTxts, function(x,y) end) -- blank line
    else
        -- Convert to scrollable text-area
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
        while table.getn(scrollTxts) < 12 do
            table.insert(scrollTxts, "")
        end
        --table.insert(scrollTxts, "")
        --table.insert(scrollTxts, g_i18n:getText("ScrollDivider"))
        --table.insert(scrollTxts, "")
    end
    
    return scrollTxts, g_currentMission.time
end

print(string.format("Script loaded: PdaPlugin_SoilCondition.LUA (v%s)", PdaPlugin_SoilCondition.version));
