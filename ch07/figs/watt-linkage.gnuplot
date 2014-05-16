unset key
set terminal svg
set polar
set size square 
set output "lemniscate.svg"
set samples 300
plot [0:2*pi] [-2:2] [-2:2] sqrt(2*cos(2*t))
