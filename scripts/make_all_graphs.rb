#!/usr/bin/ruby

Dir["ch*/*tex"].sort.each { |f|
  print "Generating graphs for file #{f}\n"
  unless system("./scripts/gen_graph.rb #{f}") then
    $stderr.print "Error running gen_graph on #{f}\n"
    exit(-1)
  end
}
