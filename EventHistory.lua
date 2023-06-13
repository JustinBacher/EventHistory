local Queue = require("historyqueue")

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
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

function Instance:onInit()
    self:setName("Event History")
    self.queue = Queue:new()
    self:gatherAllAlerts()
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAllAlerts)
    self.settings = self:getParent()
end

function Instance:onRun()
    getUI():select(self:getProperties():getPropertyByIndex(1))
end

function Instance:listen(prop, group)
    if type(prop) == "Alert" then
        local name = buildAlertName(prop, true)
        if not self.settings:hasAlert(name, group) then
            prop:addEventListener("onAlert", self, self.onAlert)
            self.settings:addAlert(name, group)
        end
    elseif type(prop) == "PolyPopObject" then
        for i = 1, prop.properties:getPropertyCount() do
            self:listen(prop.properties:getPropertyByIndex(i), group)
        end
    elseif type(prop) == "PropertyGroup" then
        for i = 1, prop:getPropertyCount() do
            self:listen(prop:getPropertyByIndex(i), group)
        end
    elseif type(prop) == "ObjectSet" then
        for i = 1, prop:getKit():getObjectCount() do
            self:listen(prop:getKit():getObjectByIndex(i), group)
        end
    end
end

function Instance:gatherAllAlerts()
    local libraryKit = getEditor():getSourceLibrary()
    local groupKit = self.settings.properties:find("Events")
    local kitGroups = {}
    local libraryGroups = {}

    for i = 1, groupKit:getObjectCount() do
        local group = groupKit:getObjectByIndex(i)
        kitGroups[group:groupName()] = group
    end
    
    for i = 1, libraryKit:getObjectCount() do
        local prop = libraryKit:getObjectByIndex(i)
        local propName = prop:getName()
        local group = kitGroups[propName]
        
        if not group then
            group = getEditor:createUIX(groupKit, "EventSettingGroup")
            group:setName(propName)
        end
        
        libraryGroups[propName] = prop
        self:searchProperties(prop, group)
	end

    for name, group in pairs(kitGroups) do
        if not libraryGroups[name] then
            getUI():removeFromLibrary(group)
        end
    end
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