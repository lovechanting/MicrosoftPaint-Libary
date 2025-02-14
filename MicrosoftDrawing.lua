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
        local props, obj, outline = self._props, self._object, self._outlineObject
        
        if key == "color" then
            props[key] = type(value) == "string" and {hexToRGB(value)} or {value.R * 255, value.G * 255, value.B * 255}
            obj.Color = Color3.fromRGB(unpack(props[key]))
        elseif key == "outlinecolor" then
            props[key] = type(value) == "string" and {hexToRGB(value)} or {value.R * 255, value.G * 255, value.B * 255}
            outline.Color = Color3.fromRGB(unpack(props[key]))
        elseif key == "thickness" then
            props[key] = math.clamp(value, 1, 10)
            obj.Thickness = props[key]
            outline.Thickness = props[key] + props.outlinethickness
        elseif key == "outlinethickness" then
            props[key] = math.clamp(value, 1, 10)
            outline.Thickness = props.thickness + props[key]
        elseif key == "outline" then
            props[key] = value
            outline.Visible = value
        elseif key == "visible" then
            props[key] = value
            obj.Visible, outline.Visible = value, value and props.outline
        elseif key == "position" then
            props[key] = value
            obj.Position, outline.Position = value, value
        elseif key == "size" then
            if not props.scalelock then
                props[key] = value
                obj.Size = value
                outline.Size = value + Vector2.new(props.outlinethickness, props.outlinethickness)
            end
        elseif key == "zindex" then
            props[key] = value
            obj.ZIndex, outline.ZIndex = value, value - 1
        elseif key == "transparency" then
            props[key] = value
            obj.Transparency, outline.Transparency = value, value
        elseif key == "borderradius" then
            props[key] = math.clamp(value, 0, 50)
            obj.Radius = props[key]
        elseif key == "animation" then
            props[key] = value
            if value then
                task.spawn(function()
                    while props.animation do
                        obj.Transparency = math.abs(math.sin(os.clock() * 2))
                        task.wait(0.05)
                    end
                end)
            end
        elseif key == "scalelock" then
            props[key] = value
            if value then
                props.originalSize = props.size
            end
        elseif key == "filltransparency" then
            props[key] = value
            obj.Filled = value < 1
            obj.Transparency = value
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
            filltransparency = 0
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
