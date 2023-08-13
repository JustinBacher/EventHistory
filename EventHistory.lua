require "util"

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit(constructor_type)
    local button_img = getEditor():createNewFromFile(self:getObjectKit(), "Static2DTexture", getLocalFolder() .. "Event_History_Button.png")
	self:addCast(button_img)
    self.name = "Historical Events"
    self.queue = {}

    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAllAlerts)
end

function Instance:onPostInit(constructor_type)
    self.settings = self:getParent()
    self:setEventLimit()
    getAnimator():createTimer(self, self.clearEvents, seconds(1))
    getAnimator():createTimer(self, self.gatherAllAlerts, seconds(2))
end

function Instance:clearEvents()
    local events = self.properties.Events:getKit()

    while true do
        local event = events:getObjectByIndex(1)

        if not event then
            return
        end

        getEditor():removeFromLibrary(event)
    end
end

function Instance:setEventLimit()
    local props = self.properties:find("Events"):getKit()
    local prop

    self.limit = self.settings.properties.Limit

    if self.limit < #self.queue then
        return
    end

    for i = self.limit, #self.queue do
        prop = props:getObjectByIndex(i)
        if prop then
            getEditor():removeFromLibrary(props:getObjectByIndex(i))
        end
        self.queue[i] = nil
    end
end

function Instance:onRun()
    getUI():select(self:getProperties():getPropertyByIndex(1))
end

function Instance:gatherAllAlerts()
    local groupKit = self.settings.properties.Events:getKit()
    local groupKits = {}

    for i = 1, groupKit:getObjectCount() do
        local group = groupKit:getObjectByIndex(i)
        groupKits[group:getSource()] = group
    end

    for _, source in kit(getEditor():getSourceLibrary()) do
        if source ~= self.settings then
            local group = groupKits[source]

            if group == nil then
                group = getEditor():createUIX(groupKit, "EventSettingGroup")
                group:initSource(source)
            end

            groupKits[source] = nil
        end
	end

    for _, group in pairs(groupKits) do
        getEditor():removeFromLibrary(group)
    end
end

function Instance:addToQueue(alert, args)
    if not self.limit then
        self:setEventLimit()
    end

    local kit = getEditor():getWireLibrary()
    local eventData = {alert=alert, args=args, time=os.time()}
    local wire

    if #self.queue >= self.limit then
        table.remove(self.queue)
    end

    for i = 1, kit:getObjectCount() do
        wire = kit:getObjectByIndex(i)
        if wire:getSourceObject() == alert then
            eventData.action = wire:getTargetObject()
        end
    end
    table.insert(self.queue, 1, eventData)
end

function Instance:onAlert(...)
    self:addToQueue(...)
    self:refreshEvents()
end

function Instance:refreshEvents()
    if not self.properties.find then
        return
    end

    local firstFew = {}
    local prop
    local props = self.properties:find("Events"):getKit()

    for i, data in ipairs(self.queue) do
        prop = props:getObjectByIndex(i)

        if prop == nil then
            prop = getEditor():createUIX(props, "Event")
        end

        prop:setup(data)

        if i <= 10 then
            table.insert(firstFew, {obj=prop, expand=true})
        end
    end

    if #firstFew >= #self.queue then
        getUI():setUIProperty({table.unpack(firstFew)})
    end
end

function Instance:removeEventsForAlert(alert)
    local i = 1
    local data

    while true do
        data = self.queue[i]

        if not data then
            break
        end

        if alert == data.alert then
            table.remove(self.queue, i)
        else
            i = i + 1
        end

    end

    self:clearEvents()
    self:refreshEvents()
end