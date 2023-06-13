Instance.properties = properties({
    {name="Name", type="Bool", value=true, onUpdate="onSettingUpdate"},
})

function Instance:initAlert(alert)
    self.properties.Name:setName(alert:getName())
end

function Instance:onSettingUpdate()
    self:getParent():getParent()
end

function Instance:alertName()
    return self.properties:find("Name")
end
