Instance.properties = properties({
    {name="Source", type="Reference", ui={visible=false}},
    {name="Events", type="ObjectSet", ui={expand=true, readonly=true}},
})

function Instance:onPostInit(constructor_type)
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAlerts)
end

function Instance:initSource(source)
    self.properties.Source:setObject(source)
    self.name = source:getName()
    self:gatherAlerts()
end

function Instance:getSource()
    return self.properties.Source:getObject()
end

function Instance:searchForAlerts(currentAlerts, prop)
    local propType = type(prop)

    if propType == "Alert" then
        local alert = currentAlerts[prop]

        if alert == nil then
            alert = getEditor():createUIX(self.Events:getKit(), "EventSetting")
            alert:initAlert(prop)
        end

        currentAlerts[prop] = nil

    elseif propType == "PolyPopObject" then
        for i = 1, prop.properties:getPropertyCount() do
            self:searchForAlerts(currentAlerts, prop.properties:getPropertyByIndex(i))
        end

    elseif propType == "PropertyGroup" then
        for i = 1, prop:getPropertyCount() do
            self:searchForAlerts(currentAlerts, prop:getPropertyByIndex(i))
        end

    elseif propType == "ObjectSet" then
        prop = prop:getKit()
        for i = 1, prop:getObjectCount() do
            self:searchForAlerts(currentAlerts, prop:getObjectByIndex(i))
        end
    end
end

function Instance:gatherAlerts()
    local source = self.properties.Source:getObject()
    local eventsKit = self.properties.Events:getKit()
    local allEventAlerts = {}

    for i = 1, eventsKit:getObjectCount() do
        local eventKit = eventsKit:getObjectByIndex(i)
        allEventAlerts[eventKit:getAlert()] = eventKit
    end

    for i = 1, source.properties:getPropertyCount() do
        self:searchForAlerts(allEventAlerts, source.properties:getPropertyByIndex(i))
    end

    for _, eventKit in pairs(allEventAlerts) do
        getEditor():removeFromLibrary(eventKit)
    end

    getUI():setUIProperty({{obj=self, visible=self.properties.Events:getKit():getObjectCount() > 0}})
end