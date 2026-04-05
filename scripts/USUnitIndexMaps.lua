USUnitIndexMaps = {}
USUnitIndexMaps.modName = g_currentModName
USUnitIndexMaps.modDirectory = g_currentModDirectory
USUnitIndexMaps.didLogUpdate = false
USUnitIndexMaps.didPatchHUD = false
USUnitIndexMaps.didPatchGlobal = false
USUnitIndexMaps.lastVehicleRootNode = nil
USUnitIndexMaps.lastPatchedPlaceableCount = 0
USUnitIndexMaps.lastPatchedObjectCount = 0
USUnitIndexMaps.scanTimerMs = 0
USUnitIndexMaps.scanIntervalMs = 1000
USUnitIndexMaps.titleToFillType = {}
USUnitIndexMaps.fillTypeIndexToMode = {}
USUnitIndexMaps.fillTypeIndexToTitle = {}
USUnitIndexMaps.fillTypeIndexToNameUpper = {}
USUnitIndexMaps.fillTypeIndexToMassPerLiter = {}

local LITERS_PER_GALLON = 3.785411784
local KG_PER_SHORT_TON = 907.185

local BUSHEL_KG = {
    WHEAT = 27.22, WHEAT_CUT = 27.22,
    CORN = 25.4012, CORN_CUT = 25.4012,
    MAIZE = 25.4012, MAIZE_CUT = 25.4012,
    SOYBEAN = 27.22, SOYBEAN_CUT = 27.22,
    BARLEY = 21.7724, BARLEY_CUT = 21.7724,
    OAT = 14.5150, OAT_CUT = 14.5150,
    CANOLA = 22.6796, CANOLA_CUT = 22.6796,
    RAPESEED = 22.6796, RAPESEED_CUT = 22.6796,
    SUNFLOWER = 11.3398, SUNFLOWER_CUT = 11.3398,
    SORGHUM = 25.4012, SORGHUM_CUT = 25.4012,
    RYE = 25.4012, RYE_CUT = 25.4012,
    TRITICALE = 25.4012, TRITICALE_CUT = 25.4012,
    SPELT = 18.1437, SPELT_CUT = 18.1437,
    MILLET = 22.6796, MILLET_CUT = 22.6796,
    POPPY = 13.6078, POPPY_CUT = 13.6078,
    CORN_DRY = 25.4012, SOYBEAN_DRY = 27.22, SUNFLOWER_DRY = 11.3398,
    SORGHUM_DRY = 25.4012, CANOLA_DRY = 22.6796, OAT_DRY = 14.5150,
    BARLEY_DRY = 21.7724, WHEAT_DRY = 27.22
}

-- Real-world density reference for tons conversion (kg/L)
-- Used to override game massPerLiter values for accuracy
-- Sources: USDA, FAO, industry standards
local TONS_KG_PER_LITER = {
    -- Forages (fresh) - actual bulk densities
    GRASS = 0.30,           -- fresh cut grass ~300 kg/m3
    GRASS_WINDROW = 0.30,
    MEADOW = 0.30,
    MEADOWWEED = 0.30,
    CHAFF = 0.30,
    FORAGE = 0.30,
    FORAGE_MIXING = 0.30,
    SILAGE = 0.45,          -- corn silage ~450 kg/m3
    -- Dry forages / hay
    DRYGRASS = 0.07,        -- dry hay bale density
    DRYGRASS_WINDROW = 0.07,
    HAY = 0.07,
    STRAW = 0.06,           -- straw ~60 kg/m3
    WOODCHIPS = 0.25,       -- wood chips ~250 kg/m3
    -- Montana 4X forages
    ALFALFA = 0.30,
    ALFALFA_WINDROW = 0.30,
    DRYALFALFA = 0.07,
    DRYALFALFA_WINDROW = 0.07,
    CLOVER = 0.30,
    CLOVER_WINDROW = 0.30,
    DRYCLOVER = 0.07,
    DRYCLOVER_WINDROW = 0.07,
    SOYBEANSTRAW = 0.06,
    CORN_STALKS = 0.06,
    -- Root vegetables (bulk densities, USDA/FAO)
    POTATO = 0.75,          -- 750 kg/m3
    SUGARBEET = 0.70,
    SUGARBEET_CUT = 0.70,
    BEETROOT = 0.52,
    CARROT = 0.64,
    PARSNIP = 0.58,
    ONION = 0.64,           -- similar to carrot
    SPRING_ONION = 0.64,
    GARLIC = 0.60,
    -- Fresh vegetables & fruit
    TOMATO = 0.70,
    LETTUCE = 0.20,         -- very light, leafy
    STRAWBERRY = 0.55,
    GREENBEAN = 0.42,
    PEA = 0.72,
    SPINACH = 0.13,         -- very light leafy
    NAPACABBAGE = 0.40,
    CHILLI = 0.50,
    -- Fruits used in tons
    GRAPE = 0.60,           -- ~600 kg/m3 in bins
    OLIVE = 0.60,
    SUGARCANE = 0.18,       -- loose in field
    -- Bulk ag materials
    MANURE = 0.70,
    STONE = 1.60,           -- mixed stone
    SEEDS = 0.35,
    COTTON = 0.23,          -- seed cotton in module
    FERTILIZER = 0.95,
    LIME = 0.85,
    -- AdditionalFilltypes minerals
    IRONORE = 2.20,         -- iron ore bulk ~2200 kg/m3
    SOIL = 1.20,
    ORGANICWASTE = 0.60,
    TOPSOIL = 1.10,
    POTSOIL = 0.60,
    COMPOST = 0.55,
    GRAVEL_FINE = 1.60,
    GRAVEL_COARSE = 1.55,
    GRAVEL_MIXED = 1.58,
    GRAVEL_TUMBLED = 1.55,
    CHARCOAL = 0.35,
    BEETPULP = 0.56,
    QUICKLIME = 0.85,
    SLAKEDLIME = 0.70,
    -- FilltypesTP / RGC minerals
    CLAY = 1.60,
    COAL = 0.85,
    COALPOWDER = 0.75,
    COKINGCOAL = 0.85,
    CONCRETE = 2.00,
    CRUSHEDCOAL = 0.80,
    CRUSHEDSTONE = 1.55,
    DIRT = 1.20,
    GRAVEL = 1.55,
    IRON = 2.20,
    LIMESTONE = 1.55,
    LITHIUMORE = 2.00,
    RIVERSAND = 1.65,
    RIVERSANDP = 1.65,
    RUBBLE = 1.40,
    SAND = 1.60,
    STONECHIPS = 1.50,
    STONEPOWDER = 1.40,
    TAILINGS = 1.40,
    FINETAILINGS = 1.30,
    COARSETAILINGS = 1.45,
    PAYDIRT = 1.50,
    CONCENTRATE = 2.00,
    STEEL = 7.85,           -- steel ~7850 kg/m3 (likely pellets/chunks in game)
    ASPHALT = 1.30,
    TOUTVENANT = 1.55,
}


local HIDE_FILLTYPES = {
    -- Operational fluids (never displayed as cargo)
    DIESEL=true, DEF=true, ADBLUE=true, METHANE=true,
    ELECTRICCHARGE=true, ELECTRICITY=true, AIR=true,
    OIL=true, GASOLINE=true, PETROL=true, BATTERYCHARGE=true,
    -- Animals (displayed as count, not volume)
    HORSE_PALOMINO=true, HORSE_BLACK=true, HORSE_BAY=true, HORSE_PINTO=true,
    HORSE_SEAL_BROWN=true, HORSE_GRAY=true, HORSE_DUN=true, HORSE_CHESTNUT=true,
    COW_SWISS_BROWN=true, COW_HOLSTEIN=true, COW_LIMOUSIN=true, COW_ANGUS=true,
    COW_WATERBUFFALO=true, COW_HIGHLAND_CATTLE=true,
    SHEEP_LANDRACE=true, SHEEP_SWISS_MOUNTAIN=true, SHEEP_STEINSCHAF=true, SHEEP_BLACK_WELSH=true,
    PIG_LANDRACE=true, PIG_BLACK_PIED=true, PIG_BERKSHIRE=true,
    CHICKEN=true, CHICKEN_ROOSTER=true, GOAT=true,
    -- Non-cargo items
    TARP=true, BALE_WRAP=true, BALE_NET=true, BALE_TWINE=true,
    SNOW=true, WEED=true, ROADSALT=true, OILSEEDRADISH=true,
    TREESAPLINGS=true, RICESAPLINGS=true, TREE=true, POPLAR=true,
    PIGFOOD=true, MINERAL_FEED=true, SILAGE_ADDITIVE=true,
    FERTILIZER=true, LIME=true, HERBICIDE=true, PESTICIDE=true,
    LIQUIDFERTILIZER=true, LIQUIDMANURE=true,
}

local GALLON_FILLTYPES = {
    -- Water / base liquids
    WATER=true,
    -- Dairy liquids
    MILK=true, GOATMILK=true, BUFFALOMILK=true,
    MILK_BOTTLED=true, GOATMILK_BOTTLED=true, BUFFALOMILK_BOTTLED=true,
    -- Beverages
    BEER=true, WINE=true, WHISKEY=true, GRAPEJUICE=true,
    SOYMILK=true, NOODLESOUP=true,
    -- Agricultural liquids
    DIGESTATE=true, PROPANE=true, LPG=true,
    LIQUIDSEEDTREATMENT=true, ANHYDROUS=true,
    -- Industrial/processed oils & fuels
    ETHANOL=true, CORN_OIL=true, OLIVE_OIL=true,
    SUNFLOWER_OIL=true, RICE_OIL=true, CANOLA_OIL=true,
    HYDRAULICOIL=true,
    -- FilltypesTP industrial liquids
    CRUDEOIL=true, TAR=true,
    -- RGC Productions liquids
    KEROSENE=true,
}

local BUSHEL_FILLTYPES = {
    -- Wheat family
    WHEAT=true, WHEAT_CUT=true,
    -- Corn / Maize
    CORN=true, CORN_CUT=true, MAIZE=true, MAIZE_CUT=true, MAIZE2=true,
    -- Oilseeds
    SOYBEAN=true, SOYBEAN_CUT=true,
    CANOLA=true, CANOLA_CUT=true,
    RAPESEED=true, RAPESEED_CUT=true,
    SUNFLOWER=true, SUNFLOWER_CUT=true,
    -- Coarse grains
    BARLEY=true, BARLEY_CUT=true,
    OAT=true, OAT_CUT=true,
    SORGHUM=true, SORGHUM_CUT=true,
    RYE=true, RYE_CUT=true,
    TRITICALE=true, TRITICALE_CUT=true,
    SPELT=true, SPELT_CUT=true,
    MILLET=true, MILLET_CUT=true,
    POPPY=true, POPPY_CUT=true,
    -- Rice
    RICE=true, RICELONGGRAIN=true,
    -- Owendale Michigan dry crop variants
    CORN_DRY=true, SOYBEAN_DRY=true, SUNFLOWER_DRY=true,
    SORGHUM_DRY=true, CANOLA_DRY=true, OAT_DRY=true,
    BARLEY_DRY=true, WHEAT_DRY=true,
}

local TONS_FILLTYPES = {
    -- Fresh grasses and forages
    GRASS=true, GRASS_WINDROW=true,
    MEADOW=true, MEADOWWEED=true,
    -- Dry hay / forage
    DRYGRASS=true, DRYGRASS_WINDROW=true,
    HAY=true,
    -- Silage & fermented
    SILAGE=true, CHAFF=true, FORAGE=true, FORAGE_MIXING=true,
    -- Straw and crop residues
    STRAW=true, SOYBEANSTRAW=true, CORN_STALKS=true, WOODCHIPS=true,
    -- Montana 4X forages
    ALFALFA=true, ALFALFA_WINDROW=true,
    DRYALFALFA=true, DRYALFALFA_WINDROW=true,
    CLOVER=true, CLOVER_WINDROW=true,
    DRYCLOVER=true, DRYCLOVER_WINDROW=true,
    -- Root vegetables & tubers
    POTATO=true, SUGARBEET=true, SUGARBEET_CUT=true,
    BEETROOT=true, CARROT=true, PARSNIP=true,
    -- Fresh vegetables & fruit
    TOMATO=true, LETTUCE=true, STRAWBERRY=true,
    GREENBEAN=true, PEA=true, SPINACH=true,
    NAPACABBAGE=true, SPRING_ONION=true,
    GARLIC=true, CHILLI=true,
    GRAPE=true, OLIVE=true,
    SUGARCANE=true,
    -- Other bulk solids
    MANURE=true, STONE=true, SEEDS=true,
    COTTON=true,
    -- FilltypesTP mining/industrial bulk solids
    CLAY=true, COAL=true, COALPOWDER=true, CONCRETE=true,
    CRUSHEDCOAL=true, CRUSHEDSTONE=true, DIRT=true, GRAVEL=true,
    IRON=true, LIMESTONE=true, LITHIUMORE=true,
    RIVERSAND=true, RIVERSANDP=true, RUBBLE=true, SAND=true,
    STONECHIPS=true, STONEPOWDER=true, TAILINGS=true,
    ASPHALT=true, TOUTVENANT=true,
    -- AdditionalFilltypes bulk solids
    IRONORE=true, SOIL=true, ORGANICWASTE=true, TOPSOIL=true,
    POTSOIL=true, COMPOST=true, BEETPULP=true,
    GRAVEL_FINE=true, GRAVEL_COARSE=true, GRAVEL_MIXED=true, GRAVEL_TUMBLED=true,
    CHARCOAL=true, QUICKLIME=true, SLAKEDLIME=true,
    -- Owendale Michigan dry crop variants (bushels handled separately)
    -- RGC Productions mining/industrial
    PAYDIRT=true, FINETAILINGS=true, COARSETAILINGS=true,
    COKINGCOAL=true, CONCENTRATE=true, STEEL=true, PIPE=true,
    -- Vegetables
    ONION=true,
}





local function log(msg)
    Logging.info('[USUnitIndexMaps] ' .. tostring(msg))
end

local function roundInt(v) return math.floor(v + 0.5) end
local function unpackArgs(t) return table.unpack(t) end

local function normalizeKey(s)
    if s == nil then return nil end
    s = tostring(s):lower()
    s = s:gsub('%s+', '')
    return s
end

function USUnitIndexMaps:classify(fillTypeIndex)
    return self.fillTypeIndexToMode[fillTypeIndex] or 'vanilla'
end

local function formatGallonsAmount(liters)
    return string.format('%d gal', roundInt((liters or 0) / LITERS_PER_GALLON))
end

function USUnitIndexMaps:formatBushelsAmount(liters, fillTypeIndex)
    local nameU = self.fillTypeIndexToNameUpper[fillTypeIndex]
    local massPerLiter = self.fillTypeIndexToMassPerLiter[fillTypeIndex]
    if nameU == nil or massPerLiter == nil then return nil end
    local kgPerBushel = BUSHEL_KG[nameU]
    if kgPerBushel == nil then return nil end
    local kgPerLiter = massPerLiter * 1000
    if kgPerLiter <= 0 then return nil end
    return string.format('%d bu', roundInt(((liters or 0) * kgPerLiter) / kgPerBushel))
end

function USUnitIndexMaps:formatTonsAmount(liters, fillTypeIndex)
    local nameU = self.fillTypeIndexToNameUpper[fillTypeIndex]
    -- Use our real-world reference density if available, fall back to game value
    local kgPerLiter = (nameU ~= nil and TONS_KG_PER_LITER[nameU]) or nil
    if kgPerLiter == nil then
        local massPerLiter = self.fillTypeIndexToMassPerLiter[fillTypeIndex]
        if massPerLiter == nil then return nil end
        kgPerLiter = massPerLiter * 1000
    end
    if kgPerLiter <= 0 then return nil end
    local shortTons = ((liters or 0) * kgPerLiter) / KG_PER_SHORT_TON
    return string.format('%.2f ton', shortTons)
end

local function getFillDisplay()
    if g_currentMission == nil or g_currentMission.hud == nil then return nil end
    return rawget(g_currentMission.hud, 'fillLevelsDisplay')
end

local function getVehicleName(vehicle)
    if type(vehicle) == 'table' and type(vehicle.getName) == 'function' then
        local ok, result = pcall(function() return vehicle:getName() end)
        if ok then return result end
    end
    return nil
end

local function maybeParseVolumeText(text)
    if type(text) ~= 'string' then return nil end
    local lower = text:lower()
    if lower:find(' gal', 1, true) or lower:find(' bu', 1, true) or lower:find(' ton', 1, true) then return nil end
    local s = text:gsub('[^0-9,%.%-]', '')
    if s == '' then return nil end
    if s:find(',', 1, true) and s:find('%.', 1, true) then
        s = s:gsub(',', '')
    elseif s:find(',', 1, true) and not s:find('%.', 1, true) then
        s = s:gsub(',', '')
    end
    return tonumber(s)
end

function USUnitIndexMaps:rebuildFillTypeMaps()
    self.titleToFillType = {}
    self.fillTypeIndexToMode = {}
    self.fillTypeIndexToTitle = {}
    self.fillTypeIndexToNameUpper = {}
    self.fillTypeIndexToMassPerLiter = {}

    if g_fillTypeManager == nil or type(g_fillTypeManager.getFillTypes) ~= 'function' then
        log('getFillTypes() unavailable while rebuilding fill type maps')
        return
    end

    local fillTypes = g_fillTypeManager:getFillTypes()
    local added = 0
    if type(fillTypes) == 'table' then
        for _, ft in pairs(fillTypes) do
            if type(ft) == 'table' and ft.index ~= nil then
                local idx = ft.index
                local title = ft.title
                local nameU = ft.name ~= nil and tostring(ft.name):upper() or nil
                local mode = 'vanilla'
                -- Skip animal/livestock types
                local isAnimal = nameU ~= nil and (
                    nameU:sub(1,6)=='HORSE_' or nameU:sub(1,4)=='COW_' or
                    nameU:sub(1,4)=='PIG_' or nameU:sub(1,5)=='SHEEP' or
                    nameU:sub(1,7)=='CHICKEN' or nameU=='GOAT'
                )
                if isAnimal then
                    mode = 'hidden'
                elseif nameU ~= nil then
                    if HIDE_FILLTYPES[nameU] then mode = 'hidden'
                    elseif GALLON_FILLTYPES[nameU] then mode = 'gallons'
                    elseif BUSHEL_FILLTYPES[nameU] then mode = 'bushels'
                    elseif TONS_FILLTYPES[nameU] then mode = 'tons'
                    else
                        -- Smart fallback for unknown/modded fill types
                        local mpl = ft.massPerLiter or 0
                        local kgL = mpl * 1000
                        if kgL == 0 then mode = 'hidden'          -- no mass = skip
                        elseif kgL >= 0.85 then mode = 'gallons'  -- dense = liquid
                        elseif kgL <= 0.15 then mode = 'tons'     -- very light = forage
                        -- mid-range (0.15-0.85): could be grain OR root veg, leave vanilla
                        end
                    end
                end
                self.fillTypeIndexToMode[idx] = mode
                self.fillTypeIndexToTitle[idx] = title
                self.fillTypeIndexToNameUpper[idx] = nameU
                self.fillTypeIndexToMassPerLiter[idx] = ft.massPerLiter
                if title ~= nil then
                    self.titleToFillType[normalizeKey(title)] = idx
                end
                added = added + 1
            end
        end
    end
    log(string.format('rebuilt fill type maps with %s entries', tostring(added)))
end

function USUnitIndexMaps:convertAmountByFillType(fillTypeIndex, liters)
    local mode = self:classify(fillTypeIndex)
    if mode == 'gallons' then return formatGallonsAmount(liters)
    elseif mode == 'bushels' then return self:formatBushelsAmount(liters, fillTypeIndex)
    elseif mode == 'tons' then return self:formatTonsAmount(liters, fillTypeIndex) end
    return nil
end

function USUnitIndexMaps:processEntry(entry)
    if type(entry) ~= 'table' then return 0 end
    local changed = 0
    local title = rawget(entry, 'title')
    local text = rawget(entry, 'text')
    if type(title) == 'string' and type(text) == 'string' then
        local fillTypeIndex = self.titleToFillType[normalizeKey(title)]
        if fillTypeIndex ~= nil then
            local liters = maybeParseVolumeText(text)
            if liters ~= nil then
                local newText = self:convertAmountByFillType(fillTypeIndex, liters)
                if newText ~= nil and newText ~= text then
                    rawset(entry, 'text', newText)
                    changed = changed + 1
                end
            end
        end
    end
    for _, v in pairs(entry) do
        if type(v) == 'table' then changed = changed + self:processEntry(v) end
    end
    return changed
end

function USUnitIndexMaps:postProcessInfoTable(infoTable)
    if type(infoTable) ~= 'table' then return 0 end
    local changed = 0
    for _, entry in pairs(infoTable) do
        if type(entry) == 'table' then changed = changed + self:processEntry(entry) end
    end
    return changed
end

function USUnitIndexMaps:patchPlaceableInstances()
    local placeableSystem = g_currentMission ~= nil and rawget(g_currentMission, 'placeableSystem') or nil
    if type(placeableSystem) ~= 'table' then return 0 end
    local placeables = rawget(placeableSystem, 'placeables')
    if type(placeables) ~= 'table' then return 0 end
    local patched = 0
    for _, placeable in pairs(placeables) do
        if type(placeable) == 'table' and not rawget(placeable, '_usUnitInfoPatched') then
            local originalUpdateInfo = rawget(placeable, 'updateInfo') or placeable.updateInfo
            if type(originalUpdateInfo) == 'function' then
                placeable.updateInfo = function(self, ...)
                    local args = {...}
                    local infoTable = nil
                    for _, arg in pairs(args) do
                        if type(arg) == 'table' then infoTable = arg; break end
                    end
                    local r1, r2, r3, r4, r5 = originalUpdateInfo(self, unpackArgs(args))
                    if infoTable ~= nil then USUnitIndexMaps:postProcessInfoTable(infoTable) end
                    return r1, r2, r3, r4, r5
                end
                rawset(placeable, '_usUnitInfoPatched', true)
                patched = patched + 1
            end
        end
    end
    return patched
end

function USUnitIndexMaps:patchObjectInstances()
    local nodeToObject = g_currentMission ~= nil and rawget(g_currentMission, 'nodeToObject') or nil
    if type(nodeToObject) ~= 'table' then return 0 end
    local patched = 0
    for _, obj in pairs(nodeToObject) do
        if type(obj) == 'table' and not rawget(obj, '_usUnitShowInfoPatched') then
            local showInfo = rawget(obj, 'showInfo') or obj.showInfo
            if type(showInfo) == 'function' and type(obj.getFillType) == 'function' and type(obj.getFillLevel) == 'function' then
                obj.showInfo = function(self, box, ...)
                    local fillType = nil
                    local fillLevel = nil
                    local ok1, v1 = pcall(function() return self:getFillType() end)
                    if ok1 then fillType = v1 end
                    local ok2, v2 = pcall(function() return self:getFillLevel() end)
                    if ok2 then fillLevel = v2 end
                    local title = USUnitIndexMaps.fillTypeIndexToTitle[fillType]
                    local converted = USUnitIndexMaps:convertAmountByFillType(fillType, fillLevel)
                    if box ~= nil and type(box.addLine) == 'function' and title ~= nil and converted ~= nil then
                        local originalAddLine = box.addLine
                        box.addLine = function(bx, lineTitle, lineText, ...)
                            if lineTitle == title or normalizeKey(lineTitle) == normalizeKey(title) then
                                return originalAddLine(bx, lineTitle, converted, ...)
                            end
                            return originalAddLine(bx, lineTitle, lineText, ...)
                        end
                        local results = {showInfo(self, box, ...)}
                        box.addLine = originalAddLine
                        return table.unpack(results)
                    end
                    return showInfo(self, box, ...)
                end
                rawset(obj, '_usUnitShowInfoPatched', true)
                patched = patched + 1
            end
        end
    end
    return patched
end

function USUnitIndexMaps:rewriteFillData(display)
    if type(display) ~= 'table' then return 0,0,0 end
    local data = rawget(display, 'fillLevelData')
    if type(data) ~= 'table' then return 0,0,0 end
    local filtered, changed, hidden = {}, 0, 0
    for i = 1, #data do
        local row = rawget(data, i)
        if type(row) == 'table' then
            local fillTypeIndex = rawget(row, 'fillType') or rawget(row, 'fillTypeIndex')
            local fillLevel = rawget(row, 'fillLevel') or rawget(row, 'level') or 0
            local capacity = rawget(row, 'capacity') or rawget(row, 'maxCapacity') or 0
            local mode = self:classify(fillTypeIndex)
            if mode == 'hidden' then
                hidden = hidden + 1
            else
                if mode == 'gallons' then
                    rawset(row, 'fillLevelText', string.format('%d / %d gal', roundInt(fillLevel / LITERS_PER_GALLON), roundInt(capacity / LITERS_PER_GALLON)))
                    changed = changed + 1
                elseif mode == 'bushels' then
                    local newText = self:formatBushelsAmount(fillLevel, fillTypeIndex)
                    local newCap = self:formatBushelsAmount(capacity, fillTypeIndex)
                    if newText ~= nil and newCap ~= nil then
                        rawset(row, 'fillLevelText', string.format('%s / %s', newText:gsub(' bu$', ''), newCap))
                        changed = changed + 1
                    end
                elseif mode == 'tons' then
                    local massPerLiter = self.fillTypeIndexToMassPerLiter[fillTypeIndex]
                    if massPerLiter ~= nil and massPerLiter > 0 then
                        rawset(row, 'fillLevelText', string.format('%.1f / %.1f ton', (fillLevel * massPerLiter * 1000) / KG_PER_SHORT_TON, (capacity * massPerLiter * 1000) / KG_PER_SHORT_TON))
                        changed = changed + 1
                    end
                end
                filtered[#filtered + 1] = row
            end
        end
    end
    if hidden > 0 then
        for i = #data, 1, -1 do rawset(data, i, nil) end
        for i = 1, #filtered do rawset(data, i, filtered[i]) end
    end
    return changed, hidden, #filtered
end

function USUnitIndexMaps:patchHUD(display)
    if type(display) ~= 'table' or display._usUnitIndexMapsPatched then return false end
    local originalDraw = display.draw
    if type(originalDraw) ~= 'function' then
        log('fillLevelsDisplay.draw not found, HUD patch not applied')
        return false
    end
    display.draw = function(self, ...)
        USUnitIndexMaps:rewriteFillData(self)
        return originalDraw(self, ...)
    end
    local originalSetVehicle = display.setVehicle
    if type(originalSetVehicle) == 'function' then
        display.setVehicle = function(self, vehicle, ...)
            local result = originalSetVehicle(self, vehicle, ...)
            USUnitIndexMaps:rewriteFillData(self)
            return result
        end
    end
    display._usUnitIndexMapsPatched = true
    log('HUD patch success on g_currentMission.hud.fillLevelsDisplay')
    return true
end

function USUnitIndexMaps:patchGlobals()
    if self.didPatchGlobal then return true end
    self.didPatchGlobal = true
    log('index-map global patches applied')
    return true
end

function USUnitIndexMaps:loadMap(mapNode, mapFile)
    log(string.format('loadMap called for mod %s', tostring(self.modName)))
    self.didLogUpdate = false
    self.didPatchHUD = false
    self.lastVehicleRootNode = nil
    self.lastPatchedPlaceableCount = 0
    self.lastPatchedObjectCount = 0
    self.scanTimerMs = 0
    self:rebuildFillTypeMaps()
end

function USUnitIndexMaps:update(dt)
    if not self.didLogUpdate then
        log(string.format('first update() tick for mod %s', tostring(self.modName)))
        self.didLogUpdate = true
    end
    self:patchGlobals()
    local display = getFillDisplay()
    if not self.didPatchHUD and type(display) == 'table' then self.didPatchHUD = self:patchHUD(display) end
    self.scanTimerMs = self.scanTimerMs + (dt or 0)
    if self.scanTimerMs >= self.scanIntervalMs then
        self.scanTimerMs = 0
        local patchedPlaceables = self:patchPlaceableInstances()
        if patchedPlaceables > 0 then
            self.lastPatchedPlaceableCount = self.lastPatchedPlaceableCount + patchedPlaceables
            log(string.format('patched placeable instances this pass=%s total=%s', tostring(patchedPlaceables), tostring(self.lastPatchedPlaceableCount)))
        end
        local patchedObjects = self:patchObjectInstances()
        if patchedObjects > 0 then
            self.lastPatchedObjectCount = self.lastPatchedObjectCount + patchedObjects
            log(string.format('patched object instances this pass=%s total=%s', tostring(patchedObjects), tostring(self.lastPatchedObjectCount)))
        end
    end
    if type(display) == 'table' then
        local vehicle = rawget(display, 'vehicle')
        if type(vehicle) == 'table' then
            local rootNode = rawget(vehicle, 'rootNode')
            if rootNode ~= self.lastVehicleRootNode then
                self.lastVehicleRootNode = rootNode
                log(string.format('active vehicle changed: name=%s rootNode=%s typeName=%s', tostring(getVehicleName(vehicle)), tostring(rootNode), tostring(rawget(vehicle, 'typeName'))))
            end
        end
    end
end

function USUnitIndexMaps:deleteMap()
    log(string.format('deleteMap called for mod %s', tostring(self.modName)))
end

log(string.format('script file executed for mod %s', tostring(USUnitIndexMaps.modName)))
addModEventListener(USUnitIndexMaps)
log(string.format('addModEventListener complete for mod %s', tostring(USUnitIndexMaps.modName)))





