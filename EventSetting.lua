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

function Instance:onAlert(alertOrArgs, alert)
    if _G.eventHistoryUtility == nil then
        local utils = {}
        getEditor():getUtilities(utils)
        for _, util in ipairs(utils) do
            if util:getUIXName() == "EventHistory:Event History Events" then
                if util.onAlert then
                    _G.eventHistoryUtility = util
                else
                    return
                end
                break
            end
        end
    end
    if self.enabled then
        _G.eventHistoryUtility:onAlert(
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
end