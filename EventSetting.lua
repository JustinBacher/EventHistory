Instance.properties = properties({
    {name="Alert", type="Reference", cast_types={"Alert"}},
    {name="Enabled", type="Bool", value=true, onUpdate="onSettingUpdate"},
})

function Instance:onPostInit(constructor_type)
    if constructor_type == "File" then
        self:listenToAlert(self:alert())
    end
end

function Instance:initAlert(alert)
    self.properties.Alert:setObject(alert)
    self.properties:find("Enabled"):setName(alert:getName())
    self:listenToAlert(alert)
end

function Instance:alert()
    return self.properties.Alert:getObject()
end

function Instance:listenToAlert(alert)
    print(tostring(self:getKit():getParent().eventsUtility))
    alert:addEventListener(
        self:getParent().eventsUtility,
        function(eventsUtility, alertOrArgs, alert)
            if self.properties.Enabled then
                eventsUtility:onAlert(
                    alert and alertOrArgs,
                    alert or alertOrArgs
                )
            end
        end
    )
end