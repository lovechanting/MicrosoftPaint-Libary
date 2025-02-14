local MicrosoftPaint = {}

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)) or 255,
           tonumber("0x" .. hex:sub(3, 4)) or 255,
           tonumber("0x" .. hex:sub(5, 6)) or 255
end

local ShapeMeta = {
    __index = function(self, key)
        return rawget(self, "_props")[key]
    end,
    __newindex = function(self, key, value)
        if key == "color" then
            if type(value) == "string" then
                self._props[key] = {hexToRGB(value)}
            elseif type(value) == "table" and #value == 3 then
                self._props[key] = value
            end
            self._object.Color = Color3.fromRGB(unpack(self._props[key]))
        elseif key == "outlinecolor" then
            if type(value) == "string" then
                self._props[key] = {hexToRGB(value)}
            elseif type(value) == "table" and #value == 3 then
                self._props[key] = value
            end
            self._object.OutlineColor = Color3.fromRGB(unpack(self._props[key]))
        elseif key == "thickness" then
            self._props[key] = math.clamp(value, 1, 10)
            self._object.Thickness = self._props[key]
        elseif key == "outlinethickness" then
            self._props[key] = math.clamp(value, 1, 10)
        elseif key == "outline" then
            self._props[key] = value
            self._object.Outline = value
        elseif key == "visible" then
            self._props[key] = value
            self._object.Visible = value
        elseif key == "position" then
            self._props[key] = value
            if self._object.Position then
                self._object.Position = value
            end
        elseif key == "size" then
            self._props[key] = value
            if self._object.Size then
                self._object.Size = value
            end
        else
            rawset(self._props, key, value)
        end
    end
}

local function createShape(shapeType)
    local obj = Drawing.new(shapeType)
    local shape = {
        _object = obj,
        _props = {
            visible = true,
            color = {255, 255, 255},
            thickness = 1,
            outline = false,
            outlinethickness = 1,
            outlinecolor = {0, 0, 0},
            position = Vector2.new(0, 0),
            size = Vector2.new(100, 100)
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

return MicrosoftPaint
