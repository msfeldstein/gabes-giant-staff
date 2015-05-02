shader = null

$ ->

  parameters = {
    feedbackAmount: 0.1
    rotateSpeed: 0.01,
    translate: false
  }
  gui = new dat.GUI
  gui.add(parameters, "feedbackAmount", 0.0, 1.0)
  gui.add(parameters, "rotateSpeed", 0.0, 1.0).step(0.01).listen()
  parameters.rotateSpeed = 0
  gui.add(parameters, "translate")

  canvas = document.getElementById("canvas")
  editor = document.getElementById("editor")
  selector = $(".code-selector")
  for name, src of Codes
    selector.append($("<option></option>")
         .attr("value",src)
         .text(name));
  selector.on "change", () ->
    load(selector.val())

  resize = () ->
    $("#editor-column").css('width', 300)
    $("#canvas-column").css('width', window.innerWidth - 300)
    canvas.width = window.innerWidth - 300;
    canvas.height = window.innerHeight;
  $(window).on "resize", resize
  resize()


  # canvas.style.webkitFilter = "blur(1px)";
  # 107 px each strip
  # 6 total strips (you can only see 3)
  ctx = canvas.getContext("2d");

  LEDS_HIGH = 107;
  LED_SIZE = Math.floor(canvas.height / LEDS_HIGH - 1);
  LED_WIDTH = 3;

  noise.seed(Math.random());

  drawCircle = (x, y, r, g, b) ->
    ctx.beginPath()
    ctx.lineWidth = 2
    color = "rgb(#{parseInt(r)}, #{parseInt(g)}, #{parseInt(b)})"
    ctx.fillStyle = color;
    ctx.arc(x * LED_SIZE, y * LED_SIZE, LED_SIZE * 0.4, 0, Math.PI * 2, false);
    ctx.fill();

  time = 0
  rotation = 0

  createFunction = (src) ->
    str = """
    function __shader(x, y, WIDTH, HEIGHT) {
      #{src}
    }
    """
    console.log str
    eval str
    __shader

  animate = () ->
    ctx.save()
    time += 0.01;
    rotation += parameters.rotateSpeed
    try
      ctx.globalCompositeOperation = "normal"
      ctx.fillStyle = "rgba(0,0,0,#{1.0 - parameters.feedbackAmount})"
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.translate(canvas.width / 2 - LED_SIZE * LED_WIDTH / 2, 20)


      ctx.translate(LED_SIZE * LED_WIDTH / 2, LED_SIZE * LEDS_HIGH / 2)
      ctx.rotate(rotation)
      ctx.translate(-LED_SIZE * LED_WIDTH / 2, -LED_SIZE * LEDS_HIGH / 2)

      ctx.globalCompositeOperation = "lighter"

      for x in [0..LED_WIDTH]
        for y in [0..LEDS_HIGH]
          [r,g,b] = shader(x,y, LED_WIDTH, LEDS_HIGH)
          drawCircle(x, y, clamp(round(255 * r), 0, 255), clamp(round(255 * g), 0, 255), clamp(round(255 * b), 0, 255))
    catch e
      console.log e
      # nothin
    ctx.restore()
    requestAnimationFrame(animate);
  requestAnimationFrame(animate);

  load = (code) ->
    editor.value = code
    update()


  update = () ->
    try
      shader = createFunction editor.value
    catch e
      console.log e
  debounceTimer = null
  $(editor).on "change keyup paste", () ->
    console.log "change"
    clearTimeout debounceTimer
    debounceTimer = setTimeout update, 500
  load(Codes["2D noise"])
