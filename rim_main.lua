
local function load_shader(path)
    local str = love.filesystem.read(path)
    return gfx.newShader(str)
end

canvas = {}
shader = {}

function love.load()
    local w, h = gfx.getWidth(), gfx.getHeight()
    canvas.occlusion = gfx.newCanvas(w, h)
    canvas.normal = gfx.newCanvas(w, h)
    canvas.rim = gfx.newCanvas(w, h, {format="rgba32f"})

    shader.rim = load_shader("shaders/rim.glsl")
    shader.rim:send("inv_size", {1.0 / w, 1.0 / h})
    shader.rim:send("light_pos", {0, 0})

    shader.normal = load_shader("shaders/compute_normal.glsl")
    shader.normal:send("inv_size", {1.0 / w, 1.0 / h})

    blur = moon(moon.effects.gaussianblur)
    blur.gaussianblur.sigma = 2.0

    im = gfx.newImage("anaak.png")
end

function love.mousemoved(x, y, dx, dy)
    shader.rim:send("light_pos", {x, y})
end

function love.draw()
    --gfx.clear(0, 0, 0, 0)
    gfx.setColor(1, 1, 1)
    --gfx.circle("fill", 200, 200, 100)
    gfx.setBlendMode("alpha")
    gfx.draw(im, 100, 0)

    gfx.setCanvas(canvas.occlusion)
    gfx.clear(0, 0, 0, 0)
    gfx.setColor(1, 1, 1)
    gfx.draw(im, 100, 0)
    --gfx.circle("fill", 200, 200, 100)

    gfx.setCanvas(canvas.normal)
    gfx.clear(0, 0, 0, 0)
    gfx.setShader(shader.normal)
    gfx.draw(canvas.occlusion)

    gfx.setColor(1, 0.8, 0.2)
    gfx.setCanvas(canvas.rim)
    gfx.clear(0, 0, 0, 1)
    gfx.setShader(shader.rim)
    gfx.setBlendMode("add")
    gfx.draw(canvas.normal)

    gfx.setBlendMode("add")
    gfx.setColor(1.0, 1.0, 1.0)
    gfx.setShader()
    gfx.setCanvas()
    blur(function()
        gfx.draw(canvas.rim)
    end)

end
