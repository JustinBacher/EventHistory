Instance.properties = properties({
    {name="Events", type="ObjectSet", ui={readonly=true, visible=false}},
})

function Instance:onInit(constructor_type)
    if constructor_type == "Default" then
        getEditor():createUIX(self:getObjectKit(), "Event History Events")
    end
end

