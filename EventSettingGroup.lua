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
