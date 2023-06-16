Instance.properties = properties({
    {name="Limit", type="Int", value=100, range={min=10, max=1000}, ui={easing=500}},
    {name="Events", type="ObjectSet", ui={readonly=true, visible=false}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        self.eventsUtility = getEditor():createUIX(self:getObjectKit(), "Event History Events")
        self.eventsUtility:setName("Event History")
    end
end

function Instance:onPostInit()
    for _, obj in kit(self:getObjectKit()) do
        if type(obj) == "Utility" then
            self.eventsUtility = obj
            break
        end
    end
    self.eventsUtility:setup(self)

end