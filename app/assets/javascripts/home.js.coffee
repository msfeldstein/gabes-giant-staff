$ ->
  canvas = document.getElementById("canvas");
  editor = document.getElementById("editor");
  playbutton = document.getElementById("play-button")

  canvas.width = window.innerWidth / 2;
  canvas.height = window.innerHeight;
  window.addEventListener "resize", () ->
    canvas.width = window.innerWidth / 2;
    canvas.height = window.innerHeight;

  canvas.style.webkitFilter = "blur(1px)";
  # 107 px each strip
  # 6 total strips (you can only see 3)
  ctx = canvas.getContext("2d");

  LEDS_HIGH = 107;
  LED_SIZE = Math.floor(canvas.height / LEDS_HIGH - 1);
  LED_WIDTH = 3;
  ctx.translate(canvas.width / 2 - LED_SIZE * LED_WIDTH / 2, 20)
  noise.seed(Math.random());

  drawCircle = (x, y, r, g, b) ->
    ctx.beginPath()
    ctx.lineWidth = 2;
    color = "rgba(" + parseInt(r) + ", " + parseInt(g) + ", " + parseInt(b) + ",255);"
    ctx.fillStyle = color;
    ctx.arc(x * LED_SIZE, y * LED_SIZE, LED_SIZE * 0.4, 0, Math.PI * 2, false);
    ctx.fill();

  time = 0;

  code1 = """
    r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
    g = noise.simplex3(x / 10, y / 50 + .5 * time, time + 100);
    b = noise.simplex3(x / 100, y / 40, time / 10 + 300);
    return [r,g,b];
  """
  editor.value = code1
  createFunction = (src) ->
    str = """
    function __shader(x, y) {
      #{src}
    }
    """
    console.log str
    eval str
    __shader

  shader = createFunction code1
  animate = () ->
    time += 0.01;
    for x in [0..LED_WIDTH]
      for y in [0..LEDS_HIGH]
        [r,g,b] = shader(x,y)
        drawCircle(x, y, 255 * r, 255 * g, 255 * b)
    requestAnimationFrame(animate);

  animate();

  $("#play-button").on "click", () ->
    shader = createFunction editor.value
