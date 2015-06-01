ColliderTag = {
    Player = 0,
    Bullet = 1,
    Enemy = 2,
    Environment = 3,
}

function create_collider_tag(tag, handle)
    return { tag = ColliderTag[tag], handle = handle }
end

function on_begin_contact(a, b, coll)
    local data1 = a:getUserData()
    local data2 = b:getUserData()

    print("Data 1: "..tostrnil(data1))
    print("Data 2: "..tostrnil(data2))

    if data1 ~= nil and data1.tag == ColliderTag.Bullet then
        Bullets:on_collision_begin(data1.handle, b, coll)
    elseif data2 ~= nil and data2.tag == ColliderTag.Bullet then
        Bullets:on_collision_begin(data2.handle, a, coll)
    end
end

function on_end_contact(a, b, coll)
end

function on_pre_solve(a, b, coll)
    -- print("pre solve")
end

function on_post_solve(a, b, coll, normal1, tangent1, normal2, tangent2)
    -- print("post solve")
end