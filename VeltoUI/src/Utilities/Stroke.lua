local Theme = require(script.Parent.Parent.Themes.Default)

return function(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or Theme.Secondary
    stroke.Parent = parent
    return stroke
end