Instance.properties = properties({
    {name="Name", type="PropertyGroup", items={
        {name="Events", type="ObjectSet"},
    }}
})

function Instance:addEvent(eventName)
    local eventSetting = getEditor():createUIX(self.properties.Name:find("Events"), "Event Setting")
    eventSetting.properties:find("Replay"):setName(eventName)
end

function Instance:findEvent(eventName)
    local kit = self.properties.Name:find("Events")

    for i = 1, kit:getObjectCount() do
        local eventSetting = kit:getObjectByIndex(i)

        if eventSetting:getName() == eventName then
            return eventSetting
        end
    end
end
