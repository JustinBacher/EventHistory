Instance.properties = properties({
    {name="ClearQueue", type="Action"},
    {name="Limit", type="Int", value=50, range={min=10, max=100}, ui={stride=5, easing=50}, onUpdate="onLimitUpdate"},
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
    end
end

function Instance:ClearQueue()
    self.utility.queue = {}
    self.utility:clearEvents()
end

function Instance:onPostInit(constructor_type)
    self.utility = self:getObjectKit():findObjectByName("Historical Events")
    print(tostring(self.utility))
end

function Instance:onLimitUpdate()
    self.utility:setEventLimit()
end
