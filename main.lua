-- Using leaf lib --
require 'leaf'
-- Init screen --
leaf.init(640, 408, 3, false, false)

local data = {}
local left

local slct, slot, dir, csl
local EMPTY = {}
for i = 1, 16 do

    EMPTY[i] = string.rep(string.char(255), 16)
end

function leaf.load()

    local file
    if not love.filesystem.getInfo('map.txt') then

        file = io.open('map.txt', 'w+')
        file:close()
    end

    file = io.open('map.txt', 'rb')
    assert(file, 'map.txt not found')

    local cntt = file:read('*all')
    file:close()

    if not cntt:match('^\n?$') then

        data.back = cntt:sub(001, 256 + 16):split('ç')
        data.main = cntt:sub(259 + 16, 515 + 16):split('ç')

        if #data.back == 0 then data.back = leaf.table_copy(EMPTY) end
        if #data.main == 0 then data.main = leaf.table_copy(EMPTY) end

        left = cntt:match('::ÊLASQUERA::(.*)') or ''
    else
        data.back = leaf.table_copy(EMPTY)
        data.main = leaf.table_copy(EMPTY)
        left = ""
    end

    slct = leaf.vector(0, 0)
    slot = leaf.vector(0, 0)
    dir  = leaf.vector()

    csl = 1
    update_map(data.back)
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

        if csl == 1 then

            local line = data.back[slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(slot.y * 16 + slot.x)
            data.back[slct.y + 1] = pre .. tile .. pos

            update_map(data.back)

        elseif csl == 2 then

            local line = data.main[slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(slot.y * 16 + slot.x)

            data.main[slct.y + 1] = pre .. tile .. pos
            update_map(data.main)
        end
    end

    if not leaf.btn('lctrl') and leaf.btnp('q') then

        if csl == 1 then

            local line = data.back[slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(255)

            data.back[slct.y + 1] = pre .. tile .. pos
            update_map(data.back)

        elseif csl == 2 then

            local line = data.main[slct.y + 1]
            local pre, pos = line:sub(1, slct.x), line:sub(slct.x + 2)

            local tile = string.char(255)

            data.main[slct.y + 1] = pre .. tile .. pos
            update_map(data.main)
        end
    elseif leaf.btnp('q') then

        if csl == 1 then

            data.back = leaf.table_copy(EMPTY)
            update_map(data.back)

        elseif csl == 2 then

            data.main = leaf.table_copy(EMPTY)
            update_map(data.main)
        end
    end

    if leaf.btnp('1') then

        csl = 1
        update_map(data.back)
    end
    if leaf.btnp('2') then

        csl = 2
        update_map(data.main)
    end
    if leaf.btnp('3') then

        csl = 3
        update_map(data.back, data.main)
    end

    if leaf.btn('lctrl') and leaf.btnp('s') then save_map() end
end

function leaf.draw()

    leaf.draw_tilemap()
    love.graphics.draw(leaf.tiled, 144, 4, 0, 0.51, 0.51)

    leaf.rect(slct.x * 8 + 4, slct.y * 8 + 4, 8)
    leaf.rect(slot.x * 4.08 + 144, slot.y * 4.08 + 4, 4.08)
end

function update_map(layer, other)

    local back = {}
    local main = {}

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

    if other then

        for y = 0, #other - 1 do

            local line = other[y + 1]
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
    end

    leaf.tilemap(back, other and main)
end

function save_map()

    local file = io.open('map.txt', 'w')
    local cntt = ""

    for _, line in ipairs(data.back) do

        file:write(line .. 'ç')
    end

    for _, line in ipairs(data.main) do

        file:write(line .. 'ç')
    end

    file:write('::ÊLASQUERA::', left)
    file:close()
end
