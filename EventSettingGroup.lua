require "util"

Instance.properties = properties({
    {name="Source", type="Reference", cast_types={"Source"}},
    {name="Name", type="PropertyGroup", items={
        {name="Enabled", type="Bool", value=true, onUpdate="onEnabledUpdate"},
        {name="Events", type="ObjectSet"},
    }}
})

function Instance:onInit()

end

function Instance:onPostInit(constructor_type)
    if constructor_type == "File" then
        getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAlerts)
    end
    self.eventsUtility = self:getParent().eventsUtility
end

function Instance:initSource(source)
    self.properties.Source:setObject(source)
    self:gatherAlerts()
    self.properties.Name:setName(source:getName())
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAlerts)
end

function Instance:source()
    return self.properties.Source:getObject()
end

function Instance:searchForAlerts(currentAlerts, prop)
    local propType = type(prop)

    if propType == "Alert" then
        local alert = currentAlerts[prop]

        if alert == nil then
            alert = getEditor():createUIX(self.properties.Name.Events:getKit(), "EventSetting")
        end

        alert:initAlert(prop)
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

    if source == nil then
        getEditor():removeFromLibrary(self)
        return
    end

    local eventsKit = self.properties.Name.Events:getKit()
    local allEventAlerts = {}

    for i = 1, eventsKit:getObjectCount() do
        local eventKit = eventsKit:getObjectByIndex(i)
        allEventAlerts[eventKit:alert()] = eventKit
    end

    for i = 1, source.properties:getPropertyCount() do
        self:searchForAlerts(allEventAlerts, source.properties:getPropertyByIndex(i))
    end

    for _, eventKit in pairs(allEventAlerts) do
        getEditor():removeFromLibrary(eventKit)
    end
end