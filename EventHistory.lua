local Queue = require("historyqueue")

Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit()
    self:setName("Event History")
    self.queue = Queue:new()
end

function Instance:onRun()
    getUI():select(self:getProperties():getPropertyByIndex(1))
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