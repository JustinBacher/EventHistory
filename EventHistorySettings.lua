Instance.properties = properties({
    {name="Limit", type="Int", value=100, range={min=10, max=1000}, ui={easing=500}},
    {name="Events", type="ObjectSet", ui={readonly=true, visible=false}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
    end
end

function Instance:removeAlert(alertName, groupName)
    local kit = self.properties:find("Events")

    for i = 1, kit:getObjectCount() do
        local group = kit:getObjectByIndex(i)

        if group:groupName() == groupName then
            eventGroup:removeAlert(alertName)
        end
    end
end

function Instance:addAlert(alertName, groupName)
    local kit = self.properties:find("Events")
    local group

    for i = 1, kit:getObjectCount() do
        local obj = kit:getObjectByIndex(i)

        if obj:groupName() == groupName then
            group = obj
            break
        end
    end

    if not group then
        group = getEditor():createUIX(kit, "EventSettingGroup")
        group:initName()
    end
    
    group:addAlert(alertName)
end

function Instance:hasAlert(alertName, groupName)
    local kit = self.properties:find(Events)
    
    for i = 1, kit:getObjectCount() do
        local group = kit:getObjectByIndex(i)
        
        if group:groupName() == groupName then
            return group:hasAlert()
        end
    end

    return false
end

function Instance:updateSetting(alert, value)
    self.settings[alert] = value
end
