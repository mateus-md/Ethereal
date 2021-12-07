-- Using leaf lib --
require 'leaf'
-- Init screen --
leaf.init({w = 640, h = 408, s = 3})

local data = {}

local slct, slot, dir, csl
local EMPTY = {}
for i = 1, 16 do

    EMPTY[i] = string.rep(string.char(255), 16)
end

function leaf.load()

    local file, info
    info = love.filesystem.getInfo('map.txt')

    if not info then
        -- create a new file --
        file = io.open('map.txt', 'w+')
        file:close()
    end

    if info then
        print('reading ' .. (info.size) .. ' bytes')
    end

    file = io.open('map.txt', 'rb')
    local cntt = file:read('*all')
    file:close()

    if not cntt:match('^\n?$') then

        local readl = info.size - info.size % 288
        for s = 0, readl, 288 do
            data[s / 288 + 1] = cntt:sub(s + 1, s + 288):split('ç')
        end

    else
        for i = 1, 10 do
            data[i] = leaf.table_copy(EMPTY)
        end
    end

    slct = leaf.vector(0, 0)
    slot = leaf.vector(0, 0)
    dir  = leaf.vector()

    csl = 1
    update_map(data[1])
end

function leaf.step()
    -- avoid moving when using commands --
    if not leaf.btn('lctrl') then
        -- move tilemap selection --
        if leaf.btnp('w') then slct = slct - dir.up    end
        if leaf.btnp('a') then slct = slct - dir.left  end
        if leaf.btnp('s') then slct = slct - dir.down  end
        if leaf.btnp('d') then slct = slct - dir.right end
    end

    slct.x = slct.x % 16; slct.y = slct.y % 16

    -- move tile selection --
    if leaf.btnp('up')    then slot = slot - dir.up    end
    if leaf.btnp('left')  then slot = slot - dir.left  end
    if leaf.btnp('down')  then slot = slot - dir.down  end
    if leaf.btnp('right') then slot = slot - dir.right end

    slot.x = slot.x % 16; slot.y = slot.y % 16

    if leaf.btnp('e') then
        -- if its editing the background --
        if csl ~= 0 then

            if not data[csl] then
                data[csl] = leaf.table_copy(EMPTY)
            end

            local line = data[csl][slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(slot.y * 16 + slot.x)
            data[csl][slct.y + 1] = pre .. tile .. pos

            update_map(data[csl])
        end
    end

    if not leaf.btn('lctrl') and leaf.btnp('q') then

        if not data[csl] then
            data[csl] = leaf.table_copy(EMPTY)
        end

        if csl ~= 0 then

            local line = data[csl][slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(255)

            data[csl][slct.y + 1] = pre .. tile .. pos
            update_map(data[csl])
        end

    elseif leaf.btnp('q') then

        if csl ~= 0 then

            data[csl] = leaf.table_copy(EMPTY)
            update_map(data[csl])
        end
    end

    for b = 1, 9 do
        if leaf.btnp(tostring(b)) then

            csl = b
            if not data[csl] then
                data[csl] = leaf.table_copy(EMPTY)
            end
            update_map(data[csl])
        end
    end
    if leaf.btnp('0') then

        csl = 0
        update_map()
    end

    if leaf.btn('lctrl') and leaf.btnp('s') then save_map() end
end

function leaf.draw()
    -- draw map --
    leaf.draw_tilemap()

    -- draw tilemap miniature --
    love.graphics.draw(leaf.tiled, 144, 4, 0, 0.51, 0.51)

    -- draw cursors --
    leaf.rect(slct.x * 8 + 4, slct.y * 8 + 4, 8)
    leaf.rect(slot.x * 4.08 + 144, slot.y * 4.08 + 4, 4.08)
end

function update_map(layer)

    local back = {}

    if layer then
        for y = 0, #layer - 1 do

            local line = layer[y + 1]
            for x = 0, #line - 1 do

                local tile = line:sub(x + 1, x + 1):byte()
                local sx   = tile % 16
                local sy   = (tile - sx) / 16

                table.insert(back, {
                    p = leaf.vector(x * 8 + 4, y * 8 + 4, 0.125),
                    s = leaf.vector(sx, sy, 8),
                    c = tile
                })
            end
        end
        leaf.tilemap({back})
    else
        for l = 1, 9 do
            back[l] = {}

            -- don't try to render empty layers --
            if not data[l] then goto continue end
            if leaf.table_eq(data[l], EMPTY) then goto continue end

            for y = 0, #data[l] - 1 do

                local line = data[l][y + 1]
                for x = 0, #line - 1 do

                    local tile = line:sub(x + 1, x + 1):byte()
                    local sx   = tile % 16
                    local sy   = (tile - sx) / 16

                    table.insert(back[l], {
                        p = leaf.vector(x * 8 + 4, y * 8 + 4, 0.125),
                        s = leaf.vector(sx, sy, 8),
                        c = tile
                    })
                end
            end
            ::continue::
        end
        local main
        if not data[10] or leaf.table_eq(data[10], EMPTY) then goto exit end

        main = {}
        for y = 0, #data[10] - 1 do

            local line = data[10][y] or EMPTY[1]
            for x = 0, #line - 1 do

                local tile = line:sub(x + 1, x + 1):byte()
                local sx   = tile % 16
                local sy   = (tile - sx) / 16

                table.insert(main, {
                    p = leaf.vector(x * 8 + 4, y * 8 + 4, 0.125),
                    s = leaf.vector(sx, sy, 8),
                    c = tile
                })
            end
        end
        ::exit::
        leaf.tilemap(back, main)
    end
end

function save_map()

    local file = io.open('map.txt', 'wb')
    local size = 0
    for _, layer in ipairs(data) do
        for l = 1, 16 do

            file:write((layer[l] or EMPTY[1]) .. 'ç')
            size = size + 16
        end
    end
    print('writing ' .. (size) .. ' bytes')
    file:close()
end
