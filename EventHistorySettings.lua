Instance.properties = properties({
    {name="Limit", type="Int", value=50, range={min=10, max=100}, ui={stride=5, easing=50}, onUpdate="onLimitUpdate"},
    {name="Events", type="ObjectSet", ui={readonly=true}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
    end
end

function Instance:onPostInit()
    local utils = {}
    getEditor():getUtilities(utils)
    for _, util in ipairs(utils) do
        if util:getUIXName() == "EventHistory:Event History Events" then
            util.settings = self
            util:setup(self)
            break
        end
    end
end

function Instance:onLimitUpdate(limit)
    local utils = {}
    getEditor():getUtilities(utils)
    for _, util in ipairs(utils) do
        if util:getUIXName() == "EventHistory:Event History Events" then
        util:setEventLimit(limit:getValue())
            break
        end
    end
end
