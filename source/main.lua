import "CoreLibs/graphics"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry
local charge
local debug_rect
local crank_rect

local body_pos_x = 100
local body_pos_y = 100
local scared_pos_x = 100
local scared_pos_y = 100
local chill_pos_x <const> = 100
local chill_pos_y <const> = 100
local lose_x_1 <const> = 50
local lose_y_1 <const> = 400
local lose_y_2 <const> = 200
local target_pos_x = 100
local target_pos_y = 100
local body_offset_x <const> = -28
local body_offset_y <const> = -100
local l_shoulder_offset_x <const> = 2
local l_shoulder_offset_y <const> = 5
local r_shoulder_offset_x <const> = 80
local r_shoulder_offset_y <const> = 0
local r_hand_offset_x <const> = 43
local r_hand_offset_y <const> = 28
local l_hand_x <const> = 30
local l_hand_y <const> = 165
local r_hand_x
local r_hand_y
local l_hand_offset_x <const> = 13
local l_hand_offset_y <const> = 10
local crank_center_x <const> = 270
local crank_center_y <const> = 140
local box_offset_x <const> = -122
local box_offset_y <const> = -45
local jim_target_x <const> = 210
local jim_target_y <const> = 70

local r_hand_img = nil
local char_img = nil
local table_img = nil
local l_hand_img = nil
local box_img = nil
local jim_img = nil

local r_hand_spr
local l_hand_spr
local char_spr
local box_spr
local table_spr
local jim_spr

local crank_radius = 25
local arm_seg_length = 90

local gameover = false

function startup()
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineCapStyle(gfx.kLineCapStyleRound)

    math.randomseed(playdate.getSecondsSinceEpoch())
    charge = 0 
    r_hand_img = gfx.image.new("images/arm")
    l_hand_img = gfx.image.new("images/l_hand")
    char_img = gfx.image.new("images/char")
    box_img = gfx.image.new("images/box")
    table_img = gfx.image.new("images/table")
    jim_img = gfx.image.new("images/jim")

    r_hand_spr = gfx.sprite.new(r_hand_img)
    l_hand_spr = gfx.sprite.new(l_hand_img)
    char_spr = gfx.sprite.new(char_img)
    box_spr = gfx.sprite.new(box_img)
    table_spr = gfx.sprite.new(table_img)
    jim_spr = gfx.sprite.new(jim_img)

    r_hand_spr:setCenter(0, 0)
    l_hand_spr:setCenter(0, 0)
    char_spr:setCenter(0, 0)
    box_spr:setCenter(0, 0)
    table_spr:setCenter(0, 0)

    table_spr:moveTo(0, 0)
    box_spr:moveTo(crank_center_x + box_offset_x, crank_center_y + box_offset_y)
    

    -- hands in the front
    r_hand_spr:setZIndex(10)
    l_hand_spr:setZIndex(10)

    -- table in the middle
    table_spr:setZIndex(5)

    -- box in the middle
    box_spr:setZIndex(0)

    -- body in the back
    char_spr:setZIndex(-10)

    r_hand_spr:add()
    l_hand_spr:add()
    char_spr:add()
    box_spr:add()
    table_spr:add()
    jim_spr:add()

    jim_spr:setVisible(false)
end

startup()

function get_circle_intersect(x1, y1, r1, x2, y2, r2)
    local d = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local a = (r1^2 - r2^2 + d^2)/(2*d)
    local h = math.sqrt(r1^2-a^2)
    local x3 = x1 + a*(x2-x1) / d
    local y3 = y1 + a*(y2-y1) / d
    local x4 = x3 - h * (y2 - y1) / d
    local y4 = y3 + h * (x2 - x1) / d
    local x5 = x3 + h * (y2 - y1) / d
    local y5 = y3 - h * (x2 - x1) / d

    return x4, y4, x5, y5
end

function update_charge()
    if(not gameover) then
        local crank_change = playdate.getCrankChange()
        if (crank_change > 0) then
            crank_change /= math.random(5)
            charge += crank_change
            return crank_change
        end
    end
    return 0
end

function update_body(crank_change)
    local target_x
    local target_y
    if(not gameover) then
        if (crank_change > 0) then
            scared_pos_y += crank_change / 60
            scared_pos_x -= crank_change / 180
           
            target_x = scared_pos_x
            target_y = scared_pos_y
        else
            target_x = chill_pos_x
            target_y = chill_pos_y
        end
    else 
        target_x = lose_x_1
        target_y = lose_y_1
    end

    local x_diff = target_x - body_pos_x
    if(math.abs(x_diff) > 1) then
        body_pos_x += x_diff / 10
    else
        body_pos_x = target_x
    end
    local y_diff = target_y - body_pos_y
    if(math.abs(y_diff) > 1) then
        body_pos_y += y_diff / 10
    else
        body_pos_y = target_y
    end
end

function draw_all()
    -- draw pos for right hand image
    r_hand_x = crank_center_x + math.sin(math.rad(playdate.getCrankPosition())) * 5
    r_hand_y = crank_center_y + math.cos(math.rad(playdate.getCrankPosition())) * -(crank_radius) - 32

    -- body draw pos
    local body_draw_x = body_pos_x + body_offset_x
    local body_draw_y = body_pos_y + body_offset_y

    -- draw body
    char_spr:moveTo(body_draw_x, body_draw_y)


    -- draw left hand
    l_hand_spr:moveTo(l_hand_x, l_hand_y)
    -- draw right hand
    r_hand_spr:moveTo(r_hand_x, r_hand_y)

    gfx.sprite.update()
end

gfx.sprite.setBackgroundDrawingCallback(
        function (x, y, width, height)
            gfx.setClipRect(x, y, width, height )
            -- end of right arm
            local r_joint_x = r_hand_x + r_hand_offset_x
            local r_joint_y = r_hand_y + r_hand_offset_y
            -- start of right arm
            local r_shoulder_x = body_pos_x + r_shoulder_offset_x
            local r_shoulder_y = body_pos_y + r_shoulder_offset_y
            -- right elbow
            -- local r_elbow_x, r_elbow_y = get_circle_intersect(r_shoulder_x, r_shoulder_y, arm_seg_length, r_joint_x, r_joint_y, arm_seg_length)
            local r_elbow_x = math.abs(r_joint_x - r_shoulder_x) / 3 + math.min(r_shoulder_x, r_joint_x)
            local r_elbow_y = math.abs(r_joint_y - r_shoulder_y) / 3 + math.max(r_shoulder_y, r_joint_y)
           
            -- end of left arm
            local l_joint_x = l_hand_x + l_hand_offset_x
            local l_joint_y = l_hand_y + l_hand_offset_y
            -- start of left arm
            local l_shoulder_x = body_pos_x + l_shoulder_offset_x
            local l_shoulder_y = body_pos_y + l_shoulder_offset_y
            -- left elbow
            -- local l_elbow_x, l_elbow_y = get_circle_intersect(l_shoulder_x, l_shoulder_y, 70, l_joint_x, l_joint_y, 40)
            local l_elbow_x = math.abs(l_joint_x - l_shoulder_x) / 3 + math.min(l_shoulder_x, l_joint_x)
            local l_elbow_y = math.abs(l_joint_y - l_shoulder_y) / 3 + math.min(l_shoulder_y, l_joint_y)

            -- draw left arm
            gfx.setLineWidth(20)
            gfx.drawLine(l_shoulder_x, l_shoulder_y, l_elbow_x, l_elbow_y)
            gfx.drawLine(l_elbow_x, l_elbow_y, l_joint_x, l_joint_y)
            -- draw right arm
            gfx.drawLine(r_shoulder_x, r_shoulder_y, r_elbow_x, r_elbow_y)
            gfx.drawLine(r_elbow_x, r_elbow_y, r_joint_x, r_joint_y)

            
            -- draw crank rod
            gfx.setLineWidth(8)
            gfx.drawLine(crank_center_x + 4, crank_center_y, r_hand_x + 4, r_hand_y + 32)

            if(jim_spr:isVisible()) then
                gfx.drawLine(jim_target_x, 400, jim_spr.x, jim_spr.y)
            end
            gfx.clearClipRect()
        end
    )

local jim_y_accel = 0
local jim_y_vel = 0

function update_jim()
    if(jim_spr:isVisible()) then
        jim_y_accel = (jim_target_y - jim_spr.y) / 30
        jim_y_vel += jim_y_accel
        local friction <const> = 0.4
        if (jim_y_vel < 0) then
            jim_y_vel += friction
        else
            jim_y_vel -= friction
        end

        jim_spr:moveBy(0, jim_y_vel)
        print(jim_y_vel..", "..jim_y_accel)
    end
end

local jim_spawned = false

function playdate.update()
    local crank_change = update_charge()
    if(charge > 4000 + math.random(3000)) then
        gameover = true
        if(not jim_spawned) then
            jim_spawned = true

            jim_spr:setVisible(true)
            jim_spr:moveTo(jim_target_x, 200)
        end
    end
    update_body(crank_change)
    update_jim()

    gfx.clear(gfx.kColorWhite)
    draw_all()
end
