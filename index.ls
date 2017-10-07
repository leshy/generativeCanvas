require! {
  util,
  leshdash: { map, flatten, filter, identity, assignInWith, times, clone, random, keys, omit, mapValues, union, reduce, sample }
}

rule = (f) ->
  (modifier) ->
    (ctx) ->
      elements = f()
      
defaultContext = ->
  (if window? then { x: Math.round(c.canvas.width / 2), y: Math.round(c.canvas.height - 50) } else { x: 500, y: 500 }) <<< { s: 5, r: 0 }

radianConstant = Math.PI / 180
radians = (d) -> d * radianConstant
  
  
applyVector = (v1, v2, angle) ->
  x = v2.x or 0
  y = v2.y or 0
  r = radians angle
  x2 = (Math.cos(r) * x) - (Math.sin(r) * y)
  y2 = (Math.sin(r) * x) + (Math.cos(r) * y)
  
  console.log angle, v2, { x: x2, y: y2 }
  
  { x: v1.x + x2, y: v1.y + y2 }

normalizeRotation = (angle) -> r: angle % 360

modifyContext = (ctx, mod) ->

  cvector = ctx{x, y}
  mvector = mod{x, y}
  assignInWith(ctx, mod, (+))
    <<< applyVector(cvector, mvector, ctx.r)
    <<< normalizeRotation(ctx.r)
    
  ctx

transform = (modification, rule) -> (ctx) ->
  rule modifyContext(ctx, modification)

next = (ctx) -> (...elements) -> map elements, (element) -> -> element(ctx)

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
  sample elements

arm = (ctx) ->
  next(ctx) do
    circle,
    transform( x: 10, y: 0, s: 0, r: random(-10,10),  arm)


start = (ctx) ->
  next(ctx) do
    arm

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

test = (n=10) ->
  execLoop n, start defaultContext! <<< { s: 10, r: -90 }

global.draw = ->
  global.c = c = document.getElementById('canvas').getContext('2d')
  c.strokeStyle = 'black';
  c.canvas.width  = window.innerWidth;
  c.canvas.height = window.innerHeight;
  test()


if not window? then test()

    

