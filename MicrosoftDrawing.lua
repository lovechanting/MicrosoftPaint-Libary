local MicrosoftPaint = {}

local function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)) or 255,
           tonumber("0x" .. hex:sub(3, 4)) or 255,
           tonumber("0x" .. hex:sub(5, 6)) or 255
end

local ShapeMeta = {
    __index = function(self, key)
        return rawget(self._props, key)
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
            self._outlineObject.Color = Color3.fromRGB(unpack(self._props[key]))
        elseif key == "thickness" then
            self._props[key] = math.clamp(value, 1, 10)
            self._object.Thickness = self._props[key]
        elseif key == "outlinethickness" then
            self._props[key] = math.clamp(value, 1, 10)
            self._outlineObject.Thickness = self._props[key]
        elseif key == "outline" then
            self._props[key] = value
            self._outlineObject.Visible = value
        elseif key == "visible" then
            self._props[key] = value
            self._object.Visible = value
            self._outlineObject.Visible = value and self._props.outline
        elseif key == "position" then
            self._props[key] = value
            self._object.Position = value
            self._outlineObject.Position = value - Vector2.new(self._props.outlinethickness / 2, self._props.outlinethickness / 2)
        elseif key == "size" then
            self._props[key] = value
            self._object.Size = value
            self._outlineObject.Size = value + Vector2.new(self._props.outlinethickness, self._props.outlinethickness)
        elseif key == "zindex" then
            self._props[key] = value
            self._object.ZIndex = value
            self._outlineObject.ZIndex = value - 1
        elseif key == "transparency" then
            self._props[key] = value
            self._object.Transparency = value
        else
            rawset(self._props, key, value)
        end
    end
}

local function createShape(shapeType)
    local obj = Drawing.new(shapeType)
    local outlineObj = Drawing.new(shapeType)
    outlineObj.Transparency = 1
    outlineObj.ZIndex = obj.ZIndex - 1

    local shape = {
        _object = obj,
        _outlineObject = outlineObj,
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
            transparency = 1
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
