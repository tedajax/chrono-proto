function create_object_pool(create_func, capacity)
    assert_object_poolable(create_func(0     ))

    local pool = {}

    pool.objects = {}
    pool.free_indices = {}
    pool.capacity = capacity
    pool.create_func = create_func

    for i = 1, capacity do
        pool.free_indices[i] = i
        pool.objects[i] = pool.create_func(i)
    end

    pool.free_head = capacity

    pool.pop_index = function(self)
        assert(self.free_head > 1, "No more free space in pool.  Increase capacity.")
        local result = self.free_indices[self.free_head]
        self.free_head = self.free_head - 1
        return result
    end

    pool.push_index = function(self, index)
        self.free_head = self.free_head + 1
        self.free_indices[self.free_head] = index
    end

    pool.add = function(self, ...)
        local index = self:pop_index()
        self.objects[index]:activate(...)
        return self.objects[index]
    end

    pool.remove = function(self, obj)
        self.objects[obj.handle]:reset()
        self:push_index(obj.handle)
    end

    pool.remove_flagged = function(self)
        for i = 1, self.capacity do
            if self.objects[i].active and self.objects[i].destroy_flag then
                self:remove(self.objects[i])
            end
        end
    end

    pool.execute = function(self, func)
        for i = 1, self.capacity do
            if self.objects[i].active then
                func(self.objects[i])
            end
        end
    end

    pool.execute_obj_func = function(self, func_name, ...)
        for i = 1, self.capacity do
            if self.objects[i].active then
                self.objects[i][func_name](self.objects[i], ...)
            end
        end
    end

    return pool
end

function assert_object_poolable(obj)
    assert(type(obj.handle) == "number")
    assert(type(obj.active) == "boolean")
    assert(type(obj.destroy_flag) == "boolean")
    assert(type(obj.activate) == "function")
    assert(type(obj.reset) == "function")
end