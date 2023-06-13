Instance.properties = properties({
    {name="Name", type="Bool", onUpdate="updateState"},
})

function Instance:initName(name)
    self:setName(name)
end

function Instance:updateState(state)
    print("State: " .. state)
end