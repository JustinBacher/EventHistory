Instance.properties = properties({
    {name="Name", type="PropertyGroup", onUpdate={
        {name="Replay", type="Action"},
    }, ui={expand=true}},
})

local buildAlertName = function(alert, isForSettings)
    local name, parent
    local parentName = parent:getName()

    if isForSettings then
        name = ""
        parent = alert:getParent()
    else
        name = alert.alert:getName()
        parent = alert.alert:getParent()
    end

    while parentName ~= "Global" do
        name = parentName .. " > " .. name
        parent = parent:getParent()
        parentName = parent:getName()
    end

    if isForSettings then
        return name
    else
        return os.date("%H:%M", alert.time) .. " | " .. name
    end
end

function Instance:setup(alert, args)
    self.alert = alert
end

