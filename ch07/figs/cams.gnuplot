unset key
set terminal svg
set polar
set size square 
set output "cam1.svg"
plot [-pi:pi] [-2:2] [-2:2] 1+abs(t)/pi
set output "cam2.svg"
plot [-pi:pi] [-2:2] [-2:2] 1+(1/pi)*(abs(t)-0.5*sin(2*abs(t)))
unset polar

set output "a0.svg"
set yrange [1:2]
set size ratio 0.5
plot [t=-pi:pi] 1+abs(t)/pi

set output "a1.svg"
set yrange [-0.7:0.7]
set size ratio 0.5
plot [t=-pi:pi] (1/pi)*sgn(t)

set output "b0.svg"
set yrange [1:2]
set size ratio 0.5
plot [t=-pi:pi] 1+(1/pi)*(abs(t)-0.5*sin(2*abs(t)))

set output "b1.svg"
set yrange [-0.7:0.7]
set size ratio 0.5
plot [t=-pi:pi] (1/pi)*sgn(t)-(1/pi)*(cos(2*abs(t)))*sgn(t)

set output "b2.svg"
set yrange [-0.7:0.7]
set size ratio 0.5
plot [t=-pi:pi] (2/pi)*(sin(2*abs(t)))
