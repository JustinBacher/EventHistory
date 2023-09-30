Instance.properties = properties({
    {name="Event", type="Reference", ui={readonly=true}},
    {name="Replay", type="Action"},
})

function Instance:setup(data)
    local alert = data.alert
    self.properties.Event:setObject(alert)
    self.name = string.format("%s | %s", os.date("%c ", data.time), alert:getName())
    self.action = data.action
    self.args = data.args
end

function Instance:Replay()
    if self.action then
        self.action:run(self.args)
    end
end
