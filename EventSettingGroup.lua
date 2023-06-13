Instance.properties = properties({
    {name="Name", type="PropertyGroup", items={
        {name="Events", type="ObjectSet"},
    }}
})

function Instance:addAlert(alert)
    local eventSetting = getEditor():createUIX(self.properties.Name:find("Events"), "Event Setting")
    eventSetting:initAlert(alert)
end

function Instance:removeAlert(alert)
    local kit = self.properties.Name:find("Events")

    for i = 1, kit:getObjectCount() do
        local eventSetting = kit:getObjectByIndex(i)

        if eventSetting.alert == alert then
            getEditor():removeFromLibrary(eventSetting)
        end
    end
end

funciton Instance:groupName()
    return self.properties:getPropertyByIndex(1):getName()
end

function Instance:hasAlert(alertName)
    local kit = self.properties:find("Events")

    for i = 1, kit:getObjectCount() do
        if kit:getObjectByIndex(i):alertName() == alertName
            return true
    end

    return false
end
