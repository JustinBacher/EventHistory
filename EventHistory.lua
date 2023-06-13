local Queue = require("historyqueue")

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

local buildAlertName = function(event, isForSettings)
    local name, parent
    local parentName = parent:getName()

    if isForSettings then
        name = ""
        parent = event:getParent()
    else
        name = event.alert:getName()
        parent = event.alert:getParent()
    end

    while parentName ~= "Global" do
        name = parentName .. " > " .. name
        parent = parent:getParent()
        parentName = parent:getName()
    end

    if isForSettings then
        return name
    else
        return os.date("%H:%M", event.time) .. " | " .. name
    end
end

function Instance:onInit()
    self:setName("Event History")
    self:gatherAllAlerts()
    self.queue = Queue:new()
    self.alerts = {}

    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.onSourceLibraryUpdate)
end

function Instance:onRun()
    getUI():select(self:getProperties():getPropertyByIndex(1))
end

function Instance:listen(prop)
    if type(prop) == "Alert" then
        -- If it's already in self.alerts then we can ignore it
        for _, alert in ipairs(self.alerts) do
            if alert == prop then
                return
            end
        end

        prop:addEventListener("onAlert", self, self.onAlert)
        self.alerts[
            getEditor():createUIX(self:getParent().properties:find("Events"), "")
        ] = prop
        self:getParent()
    elseif type(prop) == "PolyPopObject" then
        for i = 1, prop.properties:getPropertyCount() do
            self:listen(prop.properties:getPropertyByIndex(i))
        end
    elseif type(prop) == "PropertyGroup" then
        for i = 1, prop:getPropertyCount() do
            self:listen(prop:getPropertyByIndex(i))
        end
    elseif type(prop) == "ObjectSet" then
        for i = 1, prop:getKit():getObjectCount() do
            self:listen(prop:getKit():getObjectByIndex(i))
        end
    end
end

function Instance:searchProperties(source, group)
    if source.properties == nil then return end
    local allProps = {}
    local prop, propName

    for i = 1, source.properties:getPropertyCount() do
        prop = source.properties:getPropertyByIndex(i)
        propName = prop:getName()
        allProps[buildAlertName(prop, true)] = prop

        if group.properties:find(propName) then
            getEditor():createUIX(group, "EventGroupAlert")
        end
        self:listen(prop)
    end

    for j = 1, group:getObjectCount() do
        prop = group:getObjectByIndex(j)

        if allProps[prop:getName()] == nil then
            getEditor():removeFromLibrary(prop)
        end
    end
end

function Instance:gatherAllAlerts()
    local kit = getEditor():getSourceLibrary()
    local prop, propName, group

    for i = 1, kit:getObjectCount() do
        prop = kit:getObjectByIndex(i)
        propName = prop:getName()  
        group = self.parentSettings.Events:find(propName)

        if group then
            group = getEditor:createUIX(self.parentSettings.Events:getKit(), "EventGroup")
            group:setName(propName)
        end

        self:searchProperties(prop, group)
	end
end

function Instance:onSourceLibraryUpdate()
    self:gatherAllAlerts()
end

function Instance:onAlert(alertOrArgs, alert)
    print("Alerted")
    local args = alertOrArgs
    if alert == nil then
        alert = alertOrArgs
        args = nil
    end

    self.queue:push({alert=alert, args=args, time=os.time()})
    local props = self:getProperties()

    local i = 1
    for event in self.queue:iterRight() do
        local eventProp = props:getPropertyByIndex(i)
        eventProp:setName(buildAlertName(event))
        eventProp.event = event
        getUI():setUIProperty({{obj=eventProp, visible=true}})
        i = i + 1
    end
end

function Instance:replayEvent(alert)
    local props = self:getProperties()
    for i = 1, props:getPropertyCount() do
        if props:getPropertyByIndex(i) == alert then
            local event = self.queue:contents()
            return event.alert:raise(event.args)
        end
    end
    local i = 1
end

function Instance:ReplayUpdated()
    print("RU")
end

function Instance:Replay(btn)
    print("Replay pressed" .. " | " .. type(btn))
end