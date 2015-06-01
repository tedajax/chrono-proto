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

    handle_begin_contact(data1, b, coll)
    handle_begin_contact(data2, a, coll)
end

function handle_begin_contact(data, other, coll)
    if data.tag == ColliderTag.Bullet then
        Bullets:on_collision_begin(data.handle, other, coll)
    elseif data.tag == ColliderTag.Enemy then
        Enemies:on_collision_begin(data.handle, other, coll)
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