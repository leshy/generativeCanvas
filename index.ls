require! {
  util,
  leshdash: { map, flatten, filter, identity, assignInWith, times, clone, random, keys, omit, mapValues, union, reduce, sample, head, find, last }
}

rule = (f) ->
  (modifier) ->
    (ctx) ->
      elements = f()
      
defaultContext = ->
  (if window? then { x: Math.round(c.canvas.width / 2), y: Math.round(c.canvas.height / 2) } else { x: 500, y: 500 }) <<< { s: 5, r: 0 }

radianConstant = Math.PI / 180
radians = (d) -> d * radianConstant
  
  
applyVector = (v1, v2, angle) ->
  x = v2.x or 0
  y = v2.y or 0
  r = radians angle
  x2 = Math.round(Math.cos(r) * x) - (Math.sin(r) * y)
  y2 = Math.round(Math.sin(r) * x) + (Math.cos(r) * y)
  
  { x: v1.x + x2, y: v1.y + y2 }

normalizeRotation = (angle) -> r: angle % 360

modifyContext = (ctx, mod) ->
  ctx = clone ctx
  cvector = ctx{x, y}
  mvector = mod{x, y}
  assignInWith(ctx, mod, (+))
    <<< applyVector(cvector, mvector, ctx.r)
    <<< normalizeRotation(ctx.r)

  if ctx.s > 0 then ctx else void

transform = (modification, rule) -> (ctx) ->
  if ctx = modifyContext(ctx, modification) then rule ctx

next = (ctx) -> (...elements) -> map elements, (element) -> -> element(ctx)

line = (ctx) ->
  if c = global.c
    c.beginPath();
    c.moveTo(ctx.x, ctx.y);
    { x, y } = applyVector({ x: 0, y: 0}, { x: ctx.s, y: 0 }, ctx.r)
    c.lineTo(ctx.x + x, ctx.y + y);
    c.stroke();

circle = (ctx) ->
  if c = global.c
    c.beginPath();
    c.arc(ctx.x,ctx.y,ctx.s,0,2*Math.PI);
    c.stroke();
  
square = (ctx) ->
  if c = global.c
    c.rect(ctx.x - ctx.s, ctx.y - ctx.s, ctx.s * 2, ctx.s * 2);
    c.stroke();

maybe = (...elements) ->
  sample elements

weighted = (...elements) ->
  target = Math.random() * reduce do
    elements
    (total, element) -> total + head element
    0

  last find elements, (element) ->
    0 > (target := target - head element)

size = -0.060

execute = (elements) ->
  map elements, (element) -> element()
  |> flatten
  |> filter _, identity

execLoop = (n, elements) ->

  render = (n) ->
    if not n then return
    elements := execute elements
    setTimeout -> render(n-1)

  render(n)


creep = (ctx) ->
  next(ctx) do
    circle,
    weighted do
      [ 25, transform( x: 3, y: 0, s: size, r: random(-30,30),  creep) ]
      [ 1, creepSplit ]

creepSplit = (ctx) -> next(ctx) creep, creep

test = (n=1000) ->
  execLoop n, creep defaultContext! <<< { s: 10, r: random(0,360) }
#  execLoop n, cai defaultContext! <<< { s: 50, r: 0 }

global.draw = ->
  global.c = c = document.getElementById('canvas').getContext('2d')
  c.strokeStyle = 'black';
  c.canvas.width  = window.innerWidth;
  c.canvas.height = window.innerHeight;
  test()


if not window? then test()
    
