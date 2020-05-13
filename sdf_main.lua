local function load_shader(path)
    local str = love.filesystem.read(path)
    return gfx.newShader(str)
end

local sdf_shaders = {
    ellipse = load_shader("shaders/sdf/ellipse.glsl"),
    circle = load_shader("shaders/sdf/circle.glsl"),
    circle_trace = load_shader("shaders/sdf/raytracing.glsl"),
    render = load_shader("shaders/sdf/render.glsl")
}

local canvas = {
    sdf_buffer = love.graphics.newCanvas(
        gfx.getWidth(), gfx.getHeight(), {format='rgba32f'}
    )
}

local truncation = 100.0

local light_pos = {0, 0}
locked = false

function love.mousepressed(x, y, button, isTouch)
    if button == 2 then
        locked = not locked
    end
end

function love.mousemoved(x, y, dx, dy)
    if not locked then
        light_pos = {x, y}
    end
end

function love.load()
    circles = {}

    rng = love.math.random

    for i = 1, 10 do
        circles[i] = {
            radius = rng() * 100 + 10,
            center = {rng() * gfx.getWidth(), rng() * gfx.getHeight()}
        }
    end
end

function love.draw()
    local radius = 100
    local center = {200, 200}

    gfx.clear(0, 0, 0, 0)
    gfx.setShader(sdf_shaders.circle)
    gfx.setCanvas(canvas.sdf_buffer)
    gfx.clear(1000, 1000, 1000, 1000)

    gfx.setBlendMode("darken", "premultiplied")
    for _, circle in pairs(circles) do
        sdf_shaders.circle:send("radius", circle.radius)
        sdf_shaders.circle:send("center", circle.center)
        gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
    end

    gfx.setBlendMode("alpha")

    gfx.setCanvas()
    gfx.setShader(sdf_shaders.circle_trace)
    sdf_shaders.circle_trace:send("screen_size", {gfx.getWidth(), gfx.getHeight()})
    sdf_shaders.circle_trace:send("light_pos", light_pos)
    gfx.setColor(1, 1, 1)
    for i = 1, 300 do
        gfx.draw(canvas.sdf_buffer, 0, 0)
    end
    gfx.setShader()

    for _, circle in pairs(circles) do
        gfx.setColor(0, 0, 1, 1)
        gfx.circle("line", circle.center[1], circle.center[2], circle.radius)
    end

    gfx.circle("fill", light_pos[1], light_pos[2], 2)

    print(love.timer.getFPS())
end
