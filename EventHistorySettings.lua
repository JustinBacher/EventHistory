Instance.properties = properties({
    {name="Limit", type="Int", value=100, range={min=10, max=1000}, ui={easing=500}},
    {name="Events", type="ObjectSet", ui={readonly=true, visible=false}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
    end
    
    self.settings = {}
    self:gatherAllAlerts()
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.onSourceLibraryUpdate)
end

function Instance:removeAlert(alert)
    local kit = self.properties:find(Events)

    for i = 1, kit:getObjectCount() do
        local eventGroup = kit:getObjectByIndex(i)
        eventGroup:removeAlert(alert)
    end
end

function addAlert(alert)

end

function Instance:updateSetting(alert, value)
    self.settings[alert] = value
end

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

function Instance:listen(prop, group)
    if type(prop) == "Alert" then
        -- If it's already in self.alerts then we can ignore it
        for _, alert in ipairs(self.alerts) do
            if alert == prop then
                return
            end
        end

        prop:addEventListener("onAlert", self, self.onAlert)
        getEditor():createUIX(self:getParent().properties:find("Events"), "")
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
    local kit = getEditor():getSourceLibrary()
    local groupKit = self.properties:find("Events")
    local allGroups = {}
    local allKit = {}

    for i = 1, groupKit:getObjectCount() do
        local group = groupKit:getObjectByIndex(i)
        allGroups[group:groupName()] = group
    end
    
    for i = 1, kit:getObjectCount() do
        local prop = kit:getObjectByIndex(i)
        local propName = prop:getName()
        local group = allGroups[propName]
        
        if group == nil then
            group = getEditor:createUIX(self.parentSettings.Events:getKit(), "EventSettingGroup")
            group:setName(propName)
        end
        
        allKit[propName] = prop
        self:searchProperties(prop, group)
	end

    for name, group in pairs(allGroups) do
        if allKit[name] ~= nil then
            getUI():removeFromLibrary(group)
        end
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
