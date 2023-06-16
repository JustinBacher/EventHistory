local Queue = require("historyqueue")

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:setup(parent)
    self.settings = parent
    getEditor():getSourceLibrary():addEventListener("onUpdate", self, self.gatherAllAlerts)
    self:clearEvents()
    self.limit = self.settings.properties.Limit
    self:gatherAllAlerts()
end

function Instance:clearEvents()
    self.queue = {}
    local kit = self.properties.Events:getKit()
    for i = 1, kit:getObjectCount() do
        getEditor():removeFromLibrary(kit:getObjectByIndex(i))
    end
end

function Instance:setEventLimit(limit)
    local kit = self.properties.Events:getKit()
    self.limit = limit
    for i = limit, #self.queue do
        getEditor():removeFromLibrary(kit:getObjectByIndex(i))
        self.queue[i] = nil
    end
end

function Instance:onRun()
    getUI():select(self:getProperties():getPropertyByIndex(1))
end

function Instance:gatherAllAlerts()
    local groupKit = self.settings.properties.Events:getKit()
    local groupKits = {}

    print("Count: " .. groupKit:getObjectCount())
    for i = 1, groupKit:getObjectCount() do
        local group = groupKit:getObjectByIndex(i)
        groupKits[group:source()] = group
    end

    for _, source in kit(getEditor():getSourceLibrary()) do
        if source ~= self.settings then
            local group = groupKits[source] or getEditor():createUIX(groupKit, "EventSettingGroup")
            group:initSource(source)
            groupKits[source] = nil
        end
	end

    for _, group in pairs(groupKits) do
        getEditor():removeFromLibrary(group)
    end
end

function Instance:onAlert(...)
    local props = self.properties.Events:getKit()
    table.insert(self.queue, 1, {...})

    if #self.queue <= self.limit then
        table.remove(self.queue)
    end

    for i, eventData in ipairs(self.queue) do
        local prop = props:getObjectByIndex(i) or getEditor():createUIX(props, "Event")
        prop:setup(eventData)
    end
end