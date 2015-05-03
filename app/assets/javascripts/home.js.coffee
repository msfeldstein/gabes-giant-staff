shader = null
# 107 px each strip
# 6 total strips (you can only see 3)
window.HEIGHT = LEDS_HIGH = 107;
window.WIDTH = LED_WIDTH = 3;

# Animation time that is passed into the shader
time = 0
# Current rotation of the staff
rotation = 0

broken = false

parameters = {
  run: true,
  speed: 0.01,
  feedbackAmount: 0.1,
  rotateSpeed: 0.01,
  translate: false,
  share: () ->
    prompt "Share this link (No promises, it can be flaky)", window.location + "/#" + encodeURIComponent(JSON.stringify(editor.value))
}

$ ->
  initGUI(parameters)

  canvas = document.getElementById("canvas")
  ctx = canvas.getContext("2d")
  editor = document.getElementById("editor")

  selector = $(".code-selector")
  for name, src of Codes
    selector.append($("<option></option>")
         .attr("value",src)
         .text(name));
  selector.on "change", () ->
    load(selector.val())

  compileShader = (src) ->
    str = """
    function __shader(x, y, WIDTH, HEIGHT, time) {
      #{src}
    }
    """
    eval str
    __shader

  drawArc = (x, y, c1, c2, rot1Deg, rot2Deg) ->
    ledSize = Math.floor(canvas.height / LEDS_HIGH - 1);
    xpos = (x - WIDTH / 2) * ledSize
    ypos =  (y - HEIGHT / 2) * ledSize
    r = Math.sqrt(xpos * xpos + ypos * ypos)
    theta = Math.atan2(ypos, xpos) + rot1Deg
    thetaDelta = rot2Deg - rot1Deg

    rot1 = rot1Deg / 360 * Math.PI * 2
    rot2 = rot2Deg / 360 * Math.PI * 2
    ctx.beginPath()

    color = "rgb(#{parseInt(c1[0] * 255)}, #{parseInt(c1[1] * 255)}, #{parseInt(c1[2] * 255)})"
    if parameters.rotateSpeed != 0

      ctx.strokeStyle = color
      ctx.lineWidth = ledSize / 2
      ctx.arc(0, 0, r, theta, theta + thetaDelta)
      ctx.stroke()
    else
      ctx.beginPath()
      ctx.fillStyle = color
      ctx.arc(r * Math.cos(theta), r * Math.sin(theta), ledSize * 0.25, 0, Math.PI * 2, false)
      ctx.fill()

  animate = () ->
    requestAnimationFrame(animate);
    if !parameters.run || broken then return
    ctx.save()
    time += parameters.speed;
    rotation += parameters.rotateSpeed * 0.5
    try
      ctx.globalCompositeOperation = "normal"
      ctx.fillStyle = "rgba(0,0,0,#{1.0 - Math.pow(parameters.feedbackAmount, .25)})"
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.translate(canvas.width / 2, canvas.height / 2)

      ctx.globalCompositeOperation = "lighter"

      for x in [0..LED_WIDTH-1]
        for y in [0..LEDS_HIGH]
          [r,g,b] = color1 = shader(x,y, LED_WIDTH, LEDS_HIGH, time)
          color2 = shader(x,y, LED_WIDTH, LEDS_HIGH, time + parameters.speed)
          rotation1 = rotation
          rotation2 = rotation + parameters.rotateSpeed * 0.5
          drawArc(x, y, color1, color2, rotation1, rotation2)
    catch e
      console.log "Problem running shader", e
      broken = true
    ctx.restore()

  requestAnimationFrame(animate);

  load = (code) ->
    editor.value = code
    update()

  update = () ->
    try
      broken = false
      shader = compileShader editor.value
      localStorage.setItem("lastSketch", editor.value)
    catch e
      broken = true
      console.log "Problem compiling shader", e

  debounceTimer = null
  $(editor).on "change keyup paste", () ->
    clearTimeout debounceTimer
    debounceTimer = setTimeout update, 500
  if window.location.hash
    lastSketch = JSON.parse(decodeURIComponent(window.location.hash.substring(1)))
  lastSketch ||= localStorage.getItem("lastSketch")
  load(lastSketch || Codes["2D noise"])
