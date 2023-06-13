Instance.properties = properties({
    {name="Name", type="PropertyGroup", onUpdate={
        {name="Replay", type="Action"},
    }, ui={expand=true}},
})

function Instance:initName(eventName)
    self.properties:find("Name"):setName(eventName)
end

