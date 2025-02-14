local MicrosoftPaint = {}

local colorPresets = {
    red = {255, 0, 0}, green = {0, 255, 0}, blue = {0, 0, 255},
    yellow = {255, 255, 0}, cyan = {0, 255, 255}, magenta = {255, 0, 255},
    black = {0, 0, 0}, white = {255, 255, 255}, gray = {128, 128, 128},
    pink = {255, 192, 203}, lightpink = {255, 182, 193},
    orange = {255, 165, 0}, purple = {128, 0, 128}
}

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)) or 255,
           tonumber("0x" .. hex:sub(3, 4)) or 255,
           tonumber("0x" .. hex:sub(5, 6)) or 255
end

local players = {}
local renderDistance = 200

local function createLocalPlayerEffect()
    local circle = MicrosoftPaint.Draw("Circle")
    circle.size = Vector2.new(50, 50)
    circle.position = Vector2.new(0, 0)
    circle.color = {255, 0, 0}
    circle.animation = true
    task.spawn(function()
        while true do
            local time = os.clock()
            local scale = math.sin(time * 2) * 10 + 50
            circle.size = Vector2.new(scale, scale)
            local r = math.abs(math.sin(time * 1)) * 255
            local g = math.abs(math.sin(time * 2)) * 255
            local b = math.abs(math.sin(time * 3)) * 255
            circle.color = {r, g, b}
            task.wait(0.05)
        end
    end)
    return circle
end

local localPlayerEffect = createLocalPlayerEffect()

local ShapeMeta = {
    __index = function(self, key)
        return rawget(self._props, key)
    end,
    __newindex = function(self, key, value)
        local props, obj, outline = self._props, self._object, self._outlineObject
        
        if key == "color" or key == "outlinecolor" then
            if type(value) == "string" then
                props[key] = colorPresets[value:lower()] or {hexToRGB(value)}
            elseif typeof(value) == "Color3" then
                props[key] = {value.R * 255, value.G * 255, value.B * 255}
            elseif type(value) == "table" and #value == 3 then
                props[key] = value
            end
            local colorObj = Color3.fromRGB(unpack(props[key]))
            if key == "color" then obj.Color = colorObj else outline.Color = colorObj end
        elseif key == "position" then
            if props.scalelock and props.player and players[props.player] then
                props[key] = players[props.player].Position
            else
                props[key] = value
            end
            obj.Position, outline.Position = props[key], props[key]
        elseif key == "size" then
            if props.scalelock and props.player and players[props.player] then
                props[key] = players[props.player].Size
            else
                props[key] = value
            end
            obj.Size = props[key]
            outline.Size = props[key] + Vector2.new(props.outlinethickness, props.outlinethickness)
        elseif key == "player" then
            props[key] = value
            if value and players[value] then
                props.scalelock = true
                props.size = players[value].Size
                obj.Size = props.size
                outline.Size = props.size + Vector2.new(props.outlinethickness, props.outlinethickness)
            end
        else
            rawset(props, key, value)
        end
    end
}

local function createShape(shapeType)
    local obj, outline = Drawing.new(shapeType), Drawing.new(shapeType)
    outline.ZIndex, outline.Color, outline.Thickness, outline.Visible = obj.ZIndex - 1, Color3.new(0, 0, 0), obj.Thickness + 1, false
    
    local shape = {
        _object = obj,
        _outlineObject = outline,
        _props = {
            visible = true,
            color = {255, 255, 255},
            thickness = 1,
            outline = false,
            outlinethickness = 1,
            outlinecolor = {0, 0, 0},
            position = Vector2.new(0, 0),
            size = Vector2.new(100, 100),
            zindex = 1,
            transparency = 1,
            borderradius = 0,
            animation = false,
            scalelock = false,
            filltransparency = 0,
            player = nil
        }
    }
    setmetatable(shape, ShapeMeta)
    return shape
end

function MicrosoftPaint.Draw(shapeType)
    local validShapes = {"Square", "Circle", "Triangle", "Line", "Quad", "Rectangle", "Text"}
    if table.find(validShapes, shapeType) then
        return createShape(shapeType)
    else
        error("Invalid shape type: " .. tostring(shapeType))
    end
end

function MicrosoftPaint.UpdatePlayers(newPlayers)
    players = newPlayers
end

return MicrosoftPaint
