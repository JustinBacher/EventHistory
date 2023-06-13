local push = function(self, x)
    assert(x ~= nil)
    if #self == self.maxSize then
        self[self.tail] = nil
    else
        self.tail = self.tail + 1
    end
    self[self.tail] = x
end

local pushLeft = function(self, x)
    assert(x ~= nil)
    self[self.head] = x
    self.head = self.head - 1
  end

local peekLeft = function(self)
    return self[self.tail]
end

local peek = function(self)
    return self[self.head+1]
end

local popLeft = function(self)
    if self:empty() then return nil end
    local r = self[self.tail]
    self[self.tail] = nil
    self.tail = self.tail - 1
    return r
end

local pop = function(self)
    if self:empty() then return nil end
    local r = self[self.head+1]
    self.head = self.head + 1
    local r = self[self.head]
    self[self.head] = nil
    return r
end

local _removeAtInternal = function(self, idx)
    for i=idx, self.tail do self[i] = self[i+1] end
    self.tail = self.tail - 1
end

local removeLeft = function(self, x)
    for i=self.tail,self.head+1,-1 do
        if self[i] == x then
            _removeAtInternal(self, i)
            return true
        end
    end
    return false
end

local remove = function(self, x)
    for i=self.head+1,self.tail do
        if self[i] == x then
            _removeAtInternal(self, i)
            return true
        end
    end
    return false
end

local length = function(self)
    return self.tail - self.head
end

local empty = function(self)
    return self:length() == 0
end

local contents = function(self)
    local r = {}
    for i=self.head+1,self.tail do
        r[i-self.head] = self[i]
    end
    return r
end

local iterRight = function(self)
    local i = self.tail+1
    return function()
        if i > self.head+1 then
            i = i-1
            return self[i]
        end
    end
end

local iterLeft = function(self)
    local i = self.head
    return function()
        if i < self.tail then
            i = i+1
            return self[i]
        end
    end
end

local methods = {
    push = push,
    pushLeft = pushLeft,
    peekLeft = peekLeft,
    peek = peek,
    popLeft = popLeft,
    pop = pop,
    removeLeft = removeLeft,
    remove = remove,
    iterRight = iterRight,
    iterLeft = iterLeft,
    length = length,
    empty = empty,
    contents = contents,
}

local new = function()
    local r = {head = 0, tail = 0, maxSize = 100}
    return setmetatable(r, {__index = methods})
end

return {
    new = new,
}