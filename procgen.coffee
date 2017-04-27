console.log "boom shakalaka"

# fix array, because it sux
Array.prototype.remove = (element) ->

    index = @indexOf(element)
    if index != -1
        @splice index, 1


# ======================================================

points = []
tracepoint = undefined
generating = false
now = undefined
tracedPoints = 0

maxTracedPoints = 500000
tracedPointsPerFrame = 10000

pointsSize = 5
tracedPointsSize = 0.1


# init shizzle

width = () -> return window.innerWidth
height = () -> return window.innerHeight

time = () -> return (new Date()).getTime()

# static generated layer
canvasImage = document.createElement 'canvas'
contextImage = canvasImage.getContext '2d'

canvasImage.width = width()
canvasImage.height = height()
document.body.appendChild canvasImage

# dynamic UI layer
canvasUI = document.createElement 'canvas'
contextUI = canvasUI.getContext '2d'

canvasUI.width = width()
canvasUI.height = height()
document.body.appendChild canvasUI

# text

contextImage.fillStyle = "hsla(0, 100%, 0%, 0.2)"
contextImage.fillRect 0, 0 , width(), 100
contextImage.fillStyle = "hsl(0, 100%, 00%)"
contextImage.font="24px Arial";
contextImage.fillText("Place at least 3 points with by left clicking anywhere", 10, 50);
contextImage.fillText("Then right click to place the starting point to start a generation", 10, 80);

# resize on window resize
#resize = () ->
#    canvasImage.width = width()
#    canvasImage.height = height()
#window.addEventListener('resize', resize, false);

# ======================================================


canvasUI.onclick = (event) ->

    if generating
        return

    contextImage.fillStyle = "hsl(100, 100%, 50%)"
    drawCircle contextImage, event.offsetX, event.offsetY, pointsSize

    points.push
        x: event.offsetX
        y: event.offsetY


canvasUI.oncontextmenu = (event) ->
    if generating
        return false

    if points.length <= 2
        return false

    contextImage.fillStyle = "hsl(200, 100%, 30%)"
    drawCircle contextImage, event.offsetX, event.offsetY, pointsSize

    tracepoint =
        x: event.offsetX
        y: event.offsetY

    startGenerating()

    return false


# ======================================================


drawCircle = (context, x, y, r) ->
    context.beginPath();
    context.arc(x, y, r, 0, 2*Math.PI, true);
    context.fill();

drawLine = (context, p1, p2) ->
    context.beginPath();
    context.moveTo(p1.x, p1.y);
    context.lineTo(p2.x, p2.y);
    context.stroke();

clear = (context) ->
    context.clearRect 0, 0, width(), height()


# ======================================================


pointOnLine = (p1, p2, t) ->
    return {
        x: p1.x + ( p2.x - p1.x ) * t
        y: p1.y + ( p2.y - p1.y ) * t
    }

# ======================================================

startGenerating = () ->
    contextUI.fillStyle = "hsl(0, 100%, 90%)"
    contextUI.fillRect 0, 0 , width(), 100
    contextUI.fillStyle = "hsl(0, 100%, 50%)"
    contextUI.fillText("Generating", width()/2, 50);

    now = time()
    generating = true
    generate()

stopGenerating = () ->
    clear contextUI

    points = []
    tracepoint = undefined
    generating = false
    now = undefined
    tracedPoints = 0

    console.log "done"


generate = () ->

    _now = time()
    difference = _now - now

    if tracedPoints == 0 || difference >= 0 || true
        now = _now

        for i in [0...tracedPointsPerFrame]

            tracedPoints++

            tracepoint = pointOnLine pick(points), tracepoint, 0.5

            contextImage.fillStyle = "hsl(200, 100%, 50%)"
            drawCircle contextImage, tracepoint.x, tracepoint.y, tracedPointsSize

#            contextUI.fillStyle = "hsla(0, 100%, 50%, 0.5)"
#            drawCircle contextUI, tracepoint.x, tracepoint.y, 10

        console.log "generating", (100 * tracedPoints / maxTracedPoints), "%"

        if tracedPoints >= maxTracedPoints
            stopGenerating()
            return

    if generating
        window.requestAnimationFrame generate


# ======================================================


# random functions

int = (max=1, min=0) ->
    return Math.floor(min + Math.random()*(max+1 - min))

chance = (percentage) ->
    return Math.random()*100 < percentage

pick = (list) ->
    return list[ int list.length-1 ]

inCircle = (radius) ->

    a = Math.random()
    b = Math.random()

    if b < a
        swap = b
        b = a
        a = swap

    ratio = if a == 0 then 0 else 2*Math.PI*a/b

    return {
        x: b * radius * Math.cos(ratio)
        y: b * radius * Math.sin(ratio)
    }