Instance.properties = properties({
    {name="Limit", type="Int", value=50, range={min=10, max=100}, ui={stride=5, easing=50}, onUpdate="onLimitUpdate"},
    {name="EnableAllEvents", type="Action"},
    {name="DisableAllEvents", type="Action"},
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
        self:toggleEnableDisable(false)
    end
end

function Instance:onPostInit()
    self.utility = self:getObjectKit():findObjectByName("Historical Events")
end

function Instance:onLimitUpdate()
    self.utility:setEventLimit()
end

function Instance:EnableAllEvents()
    self:toggleAllEvents(true)
end

function Instance:DisableAllEvents()
    self:toggleAllEvents(false)
end

function Instance:toggleEnableDisable(value)
    getUI():setUIProperty({
        {obj=self.properties:find("EnableAllEvents"), visible=value},
        {obj=self.properties:find("DisableAllEvents"), visible=not value},
    })
end

function Instance:toggleAllEvents(value)
    local groups = self.properties.Events:getKit()

    for i = 1, groups:getObjectCount() do
        local group = groups:getObjectByIndex(i).properties.Events:getKit()

        for j = 1, group:getObjectCount() do
            group:getObjectByIndex(j).properties:getPropertyByIndex(2):setValue(value)
        end
    end

    self:toggleEnableDisable(not value)
end
