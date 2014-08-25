--
--  The Soil Management and Growth Control Project
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2014-08-xx
--

fmcSettings = {}
fmcSettings.keyValueDesc = {}

local function extractKeyAndValueName(keyValueName)
    local key, valueName = unpack(Utils.splitString("#", keyValueName))
    if valueName == nil then
        valueName = "value"
    end
    return key, valueName
end

--
function fmcSettings.setKeyValueDesc(keyValueName, value, description)
    local key, valueName = extractKeyAndValueName(keyValueName)
    if fmcSettings.keyValueDesc[key] == nil then
        fmcSettings.keyValueDesc[key] = {
            valueNameValues={}
        }
    end
    fmcSettings.keyValueDesc[key].valueNameValues[valueName] = value;
    if description ~= nil then
        fmcSettings.keyValueDesc[key].desc = tostring(description)
    end
end

--
function fmcSettings.updateKeyValueDesc(keyValueName, value)
    local key, valueName = extractKeyAndValueName(keyValueName)
    if fmcSettings.keyValueDesc[key] ~= nil then
        if fmcSettings.keyValueDesc[key].valueNameValues[valueName] ~= nil then
            fmcSettings.keyValueDesc[key].valueNameValues[valueName] = value
            return true
        end
    end
    return false
end

--
function fmcSettings.getKeyValue(keyValueName, defaultValue)
    local key, valueName = extractKeyAndValueName(keyValueName)
    if fmcSettings.keyValueDesc[key] ~= nil and fmcSettings.keyValueDesc[key].valueNameValues[valueName] ~= nil then
        return fmcSettings.keyValueDesc[key].valueNameValues[valueName];
    end
    return defaultValue
end

--
function fmcSettings.onLoadCareerSavegame(xmlFile, rootXmlKey)
    --
    for key,valueDesc in pairs(fmcSettings.keyValueDesc) do
        local xmlKey = rootXmlKey.."."..key

        for valueName,value in pairs(valueDesc.valueNameValues) do
            local xmlKeyName = xmlKey.."#"..valueName
        
            if type(value)=="boolean" then
                value = Utils.getNoNil(getXMLBool(xmlFile, xmlKeyName), value)
            elseif type(value)=="number" then
                value = Utils.getNoNil(getXMLFloat(xmlFile, xmlKeyName), value)
            else
                value = Utils.getNoNil(getXMLString(xmlFile, xmlKeyName), value)
            end

            --log(xmlKeyName,"=",value)
            if valueDesc.valueNameValues[valueName] ~= value then
                local shortKeyName = key .. (valueName~="value" and "#"..valueName or "")
                logInfo("Map-property '", shortKeyName, "' changed value from '", valueDesc.valueNameValues[valueName], "' to '", value, "'")
                valueDesc.valueNameValues[valueName] = value
            end
        end
    end
end

--
function fmcSettings.onSaveCareerSavegame(xmlFile, rootXmlKey)
    --
    for key,valueDesc in pairs(fmcSettings.keyValueDesc) do
        local xmlKey = rootXmlKey.."."..key

        for valueName,value in pairs(valueDesc.valueNameValues) do
            if value ~= nil then
                local xmlKeyName = xmlKey.."#"..valueName
            
                if type(value)=="boolean" then
                    setXMLBool(xmlFile, xmlKeyName, value)
                elseif type(value)=="number" then
                    if math.floor(value) == value then
                        setXMLInt(xmlFile, xmlKeyName, value)
                    else
                        setXMLFloat(xmlFile, xmlKeyName, value)
                    end
                else
                    setXMLString(xmlFile, xmlKeyName, tostring(value))
                end
            end
        end
        
        if valueDesc.desc ~= nil then
            setXMLString(xmlFile, xmlKey.."#description" ,valueDesc.desc)
        end
    end
end
