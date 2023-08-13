Instance.properties = properties({
    {name="Alert", type="Reference", ui={visible=false}},
    {name="Enabled", type="Bool", value=true, onUpdate="onEnabledUpdate"},
})

function Instance:onPostInit(constructor_type)
    if constructor_type == "File" then
        self.name = self:getAlert():getName()
        self:listen()
    end

    getUI():setUIProperty({{obj=self, expand=true}})
    self:onEnabledUpdate()
end

function Instance:initAlert(alert)
    self.properties.Alert:setObject(alert)
    self.name = alert:getName()
    self.properties:getPropertyByIndex(2):setName(self.name)
    self:listen()
end

function Instance:getAlert()
    return self.properties.Alert:getObject()
end

function Instance:ensureUtility()
    if not self.utility then
        self.utility = self:getParent():getParent().utility
    end
    return self.utility
end

function Instance:onAlert(alertOrArgs, alert)
    if self.enabled then
        if not self:ensureUtility() then
            return
        end
        self.utility:onAlert(
            alert or alertOrArgs,
            alert and alertOrArgs
        )
    end
end

function Instance:listen()
    self:getAlert():addEventListener(
        "onAlert",
        self,
        self.onAlert
    )
end

function Instance:onEnabledUpdate()
    self.enabled = self.properties:getPropertyByIndex(2):getValue()

    if self:ensureUtility() and not self.enabled then
        self.utility:removeEventsForAlert(self:getAlert())
    end
end