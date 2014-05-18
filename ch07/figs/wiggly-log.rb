#!/usr/bin/ruby

def find_solution_near_point_brute_force(x,y,deriv,n,radius,tol)
  best_err = 1e30
  best_x = x
  best_j = n+10 # impossible value
  1.upto(n) { |j|
    f = (j.to_f-n.to_f/2.0)/(n.to_f/2.0) # runs from -1 to 1
    xx = x+f*radius
    err = (xx+Math::cos(xx)-(y+Math::exp(y))).abs
    if err<best_err then
      best_x = xx
      best_err = err
      best_j = j
    end
  }
  if best_err>tol and (best_j==1 or best_j==n) then
    $stderr.print "error, best_j=#{best_j} at x=#{x}, y=#{y}, err=#{best_err}\n"
    exit(-1)
  end
  return best_x
end

s = -1 # run with 1, then change to -1 and run again
x = 0
y = 0
dx = s*0.001 # is only approximately the size of the step
err = 0
max_abs_x = 20
i = 0
while x.abs<max_abs_x do
  i = i+1
  print "#{x},#{y},#{err}\n" if i%100==0
  x = x+dx
  deriv = (1.0-Math::sin(x))/(1+Math::exp(y))
  y = y+deriv*dx
  n = 10 # controls numerical precision of brute-force search
  #safe = 100
  #if 2.0*Math::exp(y)>safe then safe=2.0*Math::exp(y) end
  radius = dx
  tol = 1.0e-6
  1.upto(8) { |k|
    x = find_solution_near_point_brute_force(x,y,deriv,n,radius,tol)
    radius = radius * (2.0/n.to_f)
  }
  err = (x+Math::cos(x)-(y+Math::exp(y))).abs
end
