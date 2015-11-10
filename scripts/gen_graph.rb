#!/usr/bin/ruby -w

# usage:
#    gen_graph.rb ch02/ch02.tex
# or
#    gen_graph.rb ch*/ch*.tex

# This requires gnuplot, pdftoppm, and imagemagick.
# It's invoked by doing a "make figures".

# There is something called ruby-gnuplot, but its Debian package is currently broken.

# See notes in unix.html about why gnuplot usually needs to be used with eps output
# rather than svg (e.g., smooth curves don't work with svg). However, eps output
# results in pdf files that use fonts (rather than outlines) for text. Therefore,
# when we generate eps output, we then use epstopdf | pdftoppm | ImageMagick
# to produce a png file.
# For figures that are output as svg, this script does not actually produce
# a pdf. IIRC, the ones that are output as svg are ones that need hand-editing,
# so there's a version with -raw in the name, which I then edit using Inkscape.

# For svg output, dots come out in the wrong style. See, for example,
# slope-interpretation in ch 1. See https://groups.google.com/forum/#!topic/comp.graphics.apps.gnuplot/Le8nqOJ3FGQ

# see my notes, apps:...:latex graphics:producing xy graphs

# Gnuplot sucks. Should probably switch to matplotlib.
# See sample code in sample_matplotlib.py

$asswipe = true # change this to false in order to leave behind gnuplot code so I can look at it

EPSTOPDF = "/usr/bin/epstopdf"

def main()
n=0
chapter = -1
# If wildcards are used, the shell expands ARGV before it comes to us.
ARGV.each { |file_name|
print "file #{file_name}\n"
IO.foreach(file_name) {
  |line|
  if line =~ /^%%chapter%%\s*([^\s]+)/
    chapter = $1
  end
  if line =~ /^%%graph%%\s*([^\s]+)\s((([^\s]+)\s+)*)/
    if chapter == -1 then print "error, no %%chapter%% in this file\n" end
    fig = $1;
    option_string = $2;
    print "  #{line}"
    options = {}
    sets = []
    option_string.split(/\s+/).each { |option|
      if option =~ /(.*)\=(.*)/
        options[$1] = $2
      end
      if option==';'
        sets.push(options.clone)
      end
    }
    sets.push(options.clone)
    n = n+1
    cmd_file = "#{fig}.gnuplot"
    cmd = File.new(cmd_file,'w')
    graph = Graph.new(sets[0])
    i=0
    sets.each { |onatop|
      if i>0
        graph = graph+Graph.new(onatop)
      end
      i=i+1
    }
    cmd.print graph
    cmd.close
    print "  created #{cmd_file}\n"
    if (graph.format=='eps')
      shell = "cd ch#{chapter}/figs && mv ../../#{cmd_file} . && gnuplot #{cmd_file} >#{fig}.eps"
    end
    if (graph.format=='svg')
      shell = "cd ch#{chapter}/figs && mv ../../#{cmd_file} . && gnuplot #{cmd_file} >#{fig}.svg"
    end
    print '  '+shell+"\n"
    unless system(shell) then
      $stderr.print "gen_graph.rb failed on file #{fig}\n"
      exit(-1)
    end
    if (graph.format=='eps')
      temp_filename = 'temp_file_for_graph'
      temp = File.new(temp_filename,'w')
      # mucking around with the bounding box, yech; offsets to each coord:
      a = 23 # x of left
      b = 8-graph.more_space_below # y of bottom
      c = -15 # x of right
      d = 13+graph.more_space_above # y of top
      IO.foreach("ch#{chapter}/figs/#{fig}.eps") { |l|
        if l=~ /(\%\%BoundingBox: )(\d+) (\d+)( \d+ )(\d+)/
          l = $1+(($2.to_i)+a).to_s+" "+(($3.to_i)+b).to_s+" "+(($4.to_i)+c).to_s+" "+(($5.to_i)+d).to_s+"\n"
        end
        temp.print l
      }
      temp.close
      #system("diff ch#{chapter}/figs/#{fig}.eps temp")
      shell = "cd ch#{chapter}/figs && mv ../../#{temp_filename} #{fig}.eps && #{EPSTOPDF} #{fig}.eps && pdftoppm -r 300 #{fig}.pdf temp && mv -f temp-1.ppm temp-000001.ppm && convert temp-000001.ppm #{fig}.png"
                     # ... older versions of pdftoppm make temp-000001.ppm, newer ones temp-1.ppm
      print '  '+shell+"\n"
      unless system(shell) then $stderr.print "error, #{$?}"; exit(-1) end
      if $asswipe then
        shell = "cd ch#{chapter}/figs && rm temp-000001.ppm #{fig}.pdf #{fig}.eps #{cmd_file}"
        print '  '+shell+"\n"
        unless system(shell) then $stderr.print "error, #{$?}"; exit(-1) end
      end
    end
  end
}
#print "#{n}\n"
}
end

class Graph
  attr_reader :preamble, :body, :postamble, :format, :more_space_below, :more_space_above
  attr_writer :preamble, :body, :postamble, :format, :more_space_below, :more_space_above
  def initialize(options)
    @options = options # a hash
         # x = string to label the x variable with
         # y = string to label the y variable with
    @func = @options['func']
    @xlo = @options['xlo'].to_f
    @xhi = @options['xhi'].to_f
    @ylo = @options['ylo'].to_f
    @yhi = @options['yhi'].to_f
    if (@options.has_key?('border'))
      @options['border']=(@options['border'].to_i==1)
    else
      @options['border']=false
    end
    @options['x']='x' unless @options.has_key?('x')
    @options['y']='y' unless @options.has_key?('y')
    @options['with']='lines' unless @options.has_key?('with')
                    # with lines, with points
    @options['samples']=300 unless @options.has_key?('samples')
    @options['xtic_spacing']=1 unless @options.has_key?('xtic_spacing')
    @options['ytic_spacing']=1 unless @options.has_key?('ytic_spacing')
    if @options.has_key?('xtic_lo') then @options['xtic_lo']=@options['xtic_lo'].to_f else @options['xtic_lo']=@xlo end
    if @options.has_key?('ytic_lo') then @options['ytic_lo']=@options['ytic_lo'].to_f else @options['ytic_lo']=@ylo end
    @options['format']='svg' unless @options.has_key?('format')
    @format = @options['format']
    if (@options.has_key?('more_space_below'))
      @more_space_below = @options['more_space_below'].to_i
    else
      @more_space_below = 0
    end
    if (@options.has_key?('more_space_above'))
      @more_space_above = @options['more_space_above'].to_i
    else
      @more_space_above = 0
    end
    #@terminal = 'postscript eps portrait' if @format=='eps'
    @terminal = 'postscript eps' if @format=='eps'
    @terminal = 'svg' if @format=='svg'
    if @options['with']=='lines'
      @style = 'linestyle 1'
    else
      @style = 'pointtype 31' if @format=='eps'
      @style = 'pointtype 7' if @format=='svg'
    end
    @xtic_list = tic_list(@options['xtic_lo'],@xhi,@options['xtic_spacing'].to_f)
    @ytic_list = tic_list(@options['ytic_lo'],@yhi,@options['ytic_spacing'].to_f)
    xrange = @xhi-@xlo
    @preamble = <<-END
      set terminal #{@terminal}
      set tmargin 0
      set bmargin 3
      set border -1 lw 0.5
      #{@options['border'] ? '' : 'unset border'}
      set style line 1 linetype -1 linewidth 1.5
          # ...   style for the curve itself
      set style arrow 1 size screen .017,20 filled linetype -1 linewidth .5
      set xtics axis (#{@xtic_list})
      set ytics axis (#{@ytic_list})
      set xzeroaxis linetype -1 linewidth 0.5
      set yzeroaxis linetype -1 linewidth 0.5
      set label "#{@options['x']}" at #{1.05*(@xhi-@xlo)+@xlo},0
      set label "#{@options['y']}" at 0,#{1.15*(@yhi-@ylo)+@ylo}
      set samples #{@options['samples']}
      unset key
      set size square 0.35,0.35
      set arrow from #{@xlo},0 to #{1.03*@xhi},0 arrowstyle 1
      set arrow from 0,#{@ylo} to 0,#{1.1*@yhi} arrowstyle 1
      set xrange [#{@xlo}:#{@xhi}]
      set yrange [#{@ylo}:#{@yhi}]
    END
    @preamble += 'plot '
    @body = "#{@func} with #{@options['with']} #{@style} "
    @postamble = ''
  end
  def +(other)
    result = self
    result.body += ','+other.body
    result
  end
  def tic_list(lo,hi,spacing)
    tic_list = ''
    x = lo
    (((hi-lo)/spacing).to_i+1).times do
      if (x!=0)
          # ... avoid labeling 0 at origin
        tic_list = tic_list+',' unless tic_list==''
        tic_list = tic_list+(x.to_s)
      end
      x = x+spacing
    end
    tic_list
  end
  def to_s
    @preamble+@body+"\n"+@postamble
  end
end

main()
