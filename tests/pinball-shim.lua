-- Only platform primitives are mocked; tests execute the actual Lua simulation.
abs=math.abs min=math.min max=math.max sqrt=math.sqrt flr=math.floor ceil=math.ceil
function mid(a,b,c) return math.max(a,math.min(b,c)) end
function cos(a) return math.cos(a*math.pi*2) end
function sin(a) return -math.sin(a*math.pi*2) end
function rnd(n) return math.random()*(n or 1) end
function tostr(n) return tostring(n) end
function add(t,v) table.insert(t,v) return v end
function deli(t,i) return table.remove(t,i) end
function del(t,v) for i,x in ipairs(t) do if x==v then return table.remove(t,i) end end end
function all(t)
 local i=0 local last=nil
 return function()
  if last==nil or t[i]==last then i=i+1 end
  last=t[i] return last
 end
end
function dset() end
function sound() end
math.randomseed(42)
dofile('src/simulation.lua')
muted=true
dofile('src/main.lua')
dofile('tests/pinball-fixtures.lua')
print('PINBALL CHECKS '..pinball_checks())
