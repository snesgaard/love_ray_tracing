lume = require "lume"
lurker = require "lurker"
suit = require "SUIT"

gfx = love.graphics

local function load_shadow_shader()
    local path = "shadow.glsl"
    local str = love.filesystem.read(path)
    return gfx.newShader(str)
end

local function load_tone_shader()
    local path = "tone.glsl"
    local str = love.filesystem.read(path)
    return gfx.newShader(str)
end

local function update_shadow_shader()
    print("Updating shadow shader")
    local status, shader = pcall(load_shadow_shader)
    if status then
        shadow_shader = shader
        shadow_shader:send("diffuse_tex", color_buffer)
    else
        print(shader)
    end
end

local function update_tone_shader()
    print("Updating tone shader")
    local status, shader = pcall(load_tone_shader)
    if status then
        tone_shader = shader
        tone_shader:send("exposure", 1.0)
        tone_shader:send("gamma", 2.2)
    else
        print(shader)
    end
end


function love.load(args)
    love.graphics.setBackgroundColor(0, 0, 0, 0)

    color_buffer = love.graphics.newCanvas(gfx.getWidth(), gfx.getHeight())
    ambient_buffer = love.graphics.newCanvas(gfx.getWidth(), gfx.getHeight())
    occlusion_buffer = love.graphics.newCanvas(gfx.getWidth(), gfx.getHeight())
    tone_buffer = love.graphics.newCanvas(
        gfx.getWidth(), gfx.getHeight(),
        {format='rgba32f'}
    )

    update_shadow_shader()
    update_tone_shader()
end

local render_modes = {"color", "occlusion", "full"}
local mode = "full"

local diffuse_slider = {value = 1.0, min = 0, max = 1}
local ambient_slider = {value = 0.1, min = 0, max = 1}
local occlusion_slider = {value = 0.5, min = 0, max = 1}
local exposure_slider = {value = 1.0, min = 0, max = 10}

function love.keypressed(key, scancode, isrepeat)
    if key == "tab" then
        update_shadow_shader()
        update_tone_shader()
    elseif key == "c" then
        mode = "color"
    elseif key == "o" then
        mode = "occlusion"
    elseif key =="f" then
        mode = "full"
    end
end

function love.update(dt)
    suit.layout:reset(20, 20, 20, 5)
    suit.layout:push(suit.layout:row(200, 20))
    suit.Slider(diffuse_slider, suit.layout:col(200, 20))
    suit.Label("Diffue alpha", suit.layout:col(100))
    suit.layout:pop()
    suit.layout:push(suit.layout:row(200, 20))
    suit.Slider(ambient_slider, suit.layout:col(200, 20))
    suit.Label("Ambient alpha", suit.layout:col(100))
    suit.layout:pop()
    suit.layout:push(suit.layout:row(200, 20))
    suit.Slider(occlusion_slider, suit.layout:col(200, 20))
    suit.Label("Occlusion alpha", suit.layout:col(100))
    suit.layout:pop()
    suit.layout:push(suit.layout:row(200, 20))
    suit.Slider(exposure_slider, suit.layout:col(200, 20))
    suit.Label("Exposure", suit.layout:col(100))

    angle = angle + 3.0 * dt
end

rng = love.math.random

rectangles = {
    {
        shape={400, 300, 100, 50},
        occlusion=0.5,
        color={rng(), rng(), rng()}
    }, {
        shape={400, 400, 100, 50},
        occlusion=0.1,
        color={rng(), rng(), rng()}
    }
}
rectangles = {}

for j = 1, 5 do
    for i = 1, 5 do
        color = {rng(), rng(), rng()}
        rectangles[#rectangles + 1] = {
            shape={0 + i * 120, 0 + j * 100, 100, 20},
            occlusion=0.1,
            occ_color = {1 - color[1], 1 - color[2], 1 - color[3]},
            color=color,
            phase = rng() * 3.14 * 2
        }
    end
end


background_color = {1.0, 1.0, 1.0}

angle = 1

local function draw_color()
    gfx.setColor(background_color)
    gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
    for _, r in ipairs(rectangles) do
        gfx.setColor(r.color)
        --gfx.rectangle("fill", unpack(r.shape))
        gfx.push()
        gfx.translate(r.shape[1], r.shape[2])
        gfx.rotate(angle + r.phase)
        gfx.ellipse("fill", 0, 0, r.shape[3] / 2, r.shape[4] / 2)
        gfx.pop()
    end
end

local function draw_ambient()
    gfx.setColor({1, 1, 1, 0.2})
    gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
    for _, r in ipairs(rectangles) do
        gfx.setColor(r.color)
        --gfx.rectangle("fill", unpack(r.shape))
        gfx.push()
        gfx.translate(r.shape[1], r.shape[2])
        gfx.rotate(angle + r.phase)
        gfx.ellipse("fill", 0, 0, r.shape[3] / 2, r.shape[4] / 2)
        gfx.pop()
    end
end

local function draw_occlusion()
    gfx.clear(0, 0, 0, 0)
    for _, r in ipairs(rectangles) do
        gfx.setColor(1.0 - r.color[1], 1.0 - r.color[2], 1.0 - r.color[3], occlusion_slider.value)
        --gfx.rectangle("fill", unpack(r.shape))
        gfx.push()
        gfx.translate(r.shape[1], r.shape[2])
        gfx.rotate(angle + r.phase)
        gfx.ellipse("fill", 0, 0, r.shape[3] / 2, r.shape[4] / 2)
        gfx.pop()
    end
end

function love.mousepressed(x, y, button, isTouch)
    if button == 2 then
        locked_light = not locked_light
    end
end

function love.mousemoved(x, y, dx, dy)
    if shadow_shader and not locked_light then
        shadow_shader:send("light", {x, y})
    end
end

local function draw_full()
    gfx.setBlendMode("alpha")

    gfx.setCanvas(ambient_buffer)
    gfx.clear()
    draw_ambient()

    gfx.setCanvas(color_buffer)
    gfx.clear()
    draw_color()
    gfx.setCanvas(occlusion_buffer)
    gfx.setBlendMode("alpha", "premultiplied")
    draw_occlusion()

    gfx.setCanvas()
    if not shadow_shader then return end

    gfx.setBlendMode("add")
    gfx.setCanvas(tone_buffer)
    gfx.clear(0, 0, 0, 0)


    gfx.setShader(shadow_shader)
    gfx.setColor(1, 1, 1, diffuse_slider.value)
    gfx.draw(occlusion_buffer, 0, 0)

    gfx.setShader()
    gfx.setColor(1, 1, 1, ambient_slider.value)
    gfx.draw(ambient_buffer, 0, 0)

    gfx.setCanvas()
    gfx.setColor(1, 1, 1)
    gfx.setShader(tone_shader)
    if tone_shader then
        tone_shader:send("exposure", exposure_slider.value)
    end
    gfx.draw(tone_buffer, 0, 0)
end

function love.draw()
    gfx.push("all")
    if mode == "occlusion" then
        draw_occlusion()
    elseif mode == "color" then
        draw_color()
    elseif mode == "full" then
        local start = love.timer.getTime()
        for i = 1, 1 do
            --gfx.setCanvas()
            --gfx.clear(0, 0, 0, 0)
            draw_full()
        end
        local stop = love.timer.getTime()
        print(stop - start, love.timer.getFPS())
    end

    gfx.pop()

    suit.draw()
end
