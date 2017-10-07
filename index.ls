require! {
  util,
  leshdash: { map, flatten, filter, identity, assignInWith, times, clone, random }
}

rule = (f) ->
  (modifier) ->
    (ctx) ->
      elements = f()
      
defaultContext = -> { x: c.canvas.width / 2, y: c.canvas.height / 2, s: 10, a: 0 }

specialTransforms = do
  x: (ctx, mod) -> x: (ctx.x + mod.x)
  y: (ctx, mod) -> y: (ctx.y + mod.y)

modifyContext = (context, modification) ->
  context = clone context
  assignInWith context, modification, (+)


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

arm = (ctx) ->
  next(ctx) do
    transform( {s: random(30) }, circle)
    transform( y: 40, arm)
    transform( y: -40, arm)
    transform( x: 30, arm)
    transform( x: -30, arm)

start = (ctx) ->
  next(ctx) do
    square
    arm

execute = (elements) ->
  map elements, (element) -> element()
  |> flatten
  |> filter _, identity

execLoop = (n, elements) ->

  render = (n) ->
    if not n then return
    console.log elements.length
    elements := execute elements
    setTimeout -> render(n-1)

  render(n)

    
test = (n=7)-> 
  console.log execLoop n, start defaultContext!

global.draw = ->
  global.c = c = document.getElementById('canvas').getContext('2d')
  c.strokeStyle = 'black';
  c.canvas.width  = window.innerWidth;
  c.canvas.height = window.innerHeight;
  test()
  
if not window? then test()
  

