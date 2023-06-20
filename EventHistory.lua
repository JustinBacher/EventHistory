require "util"

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit()
    local button_img = getEditor():createNewFromFile(self:getObjectKit(), "Static2DTexture", getLocalFolder() .. "Event_History_Button.png")
	self:addCast(button_img)
    self.queue = {}
end

function Instance:setup(parent)
    self.settings = parent
    self:setEventLimit(parent.properties.Limit)
end

function Instance:onPostInit()
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAllAlerts)
    self:setName("Event History")
    getAnimator():createTimer(self, self.clearEvents, seconds(0.5))
    getAnimator():createTimer(self, self.gatherAllAlerts, seconds(0.5))
end

function Instance:clearEvents()
    self.properties = properties({
        {name="Events", type="ObjectSet", ui={readonly=true}},
    })
end

function Instance:setEventLimit(limit)
    self.limit = limit
    for i = limit, #self.queue do
        self.queue[i] = nil
    end
    self:clearEvents()
    self:refreshEvents()
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
    local props = self.properties.Events
    local firstFew = {}
    local prop

    if props == nil then
        self:clearEvents()
    end

    props = self.properties.Events:getKit()

    for i, data in  ipairs(self.queue) do
        prop = (
            props:getObjectByIndex(i)
            or
            getEditor():createUIX(props, "Event")
        )
        prop:setup(data)

        if i <= 10 then
            table.insert(firstFew, {obj=prop, expand=true})
        end
    end

    json.encode(firstFew)
    if #firstFew >= #self.queue then
        getUI():setUIProperty({table.unpack(firstFew)})
    end
end