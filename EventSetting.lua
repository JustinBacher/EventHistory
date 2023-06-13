Instance.properties = properties({
    {name="Name", type="Bool"},
})

function Instance:onInit()
    
end

function Instance:initParams(alert)
    self.alert = alert
    self.properties.Name:setName(alert:getName())
end