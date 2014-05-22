#!/usr/bin/ruby

n=10
a=0.0
b=1.0
sample = 'm' # can be l for left, m for middle, r for right

def f(x)
 u = (x-0.3)*4.0
 return Math::exp(-u*u/2.0)+0.3
end

def svg(s)
return <<"SVG"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="744.09448819"
   height="1052.3622047"
   id="svg2"
   version="1.1"
   inkscape:version="0.48.4 r9939"
   sodipodi:docname="New document 1">
  <defs
     id="defs4" />
  <sodipodi:namedview
     id="base"
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0.0"
     inkscape:pageshadow="2"
     inkscape:zoom="0.71466463"
     inkscape:cx="160"
     inkscape:cy="847.14286"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     showgrid="false"
     inkscape:window-width="1280"
     inkscape:window-height="996"
     inkscape:window-x="0"
     inkscape:window-y="0"
     inkscape:window-maximized="1" />
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     id="layer1">
     #{s}
  </g>
</svg>
SVG
end

sum = 0.0
dx = (b-a)/n
rects = ''
0.upto(n-1) { |k|
  u = k.to_f+0.5
  if sample=='l' then u=u-0.5 end
  if sample=='r' then u=u+0.5 end
  x = a+u*dx
  y = f(x)
  sum = sum+y*dx
  dx_svg = 200.0/n.to_f
  width = dx_svg
  x_svg = k.to_f*dx_svg
  height = 100.0*y
  if y>=0 then
    y_svg = -height # top of rectangle
  else
    y_svg = 0
  end 
  rects = rects + <<"RECT"
    <rect
       style="fill:#5e5e5e;fill-opacity:1;stroke:#000000;stroke-width:0.875;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:none"
       id="rect#{k}"
       width="#{width}"
       height="#{height}"
       x="#{x_svg}"
       y="#{y_svg}" />
RECT
}

print svg(rects)

$stderr.print "sum=#{sum}\n"
