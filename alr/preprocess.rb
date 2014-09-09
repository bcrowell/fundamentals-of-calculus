#!/usr/bin/ruby

Dir.glob('ch*') do |dir|
  if File.directory?(dir) then
    if dir =~ /\Ach(\d+)\Z/ then
      n = $1
        Dir.glob("ch#{n}/*.rbtex").sort.each do |file|
          print "#{file}\n"
          file =~ /ch\d+\/(.*)\.rbtex/
          f = $1
          c = "cd #{dir} && cat ../m4_preamble #{f}.rbtex | m4 -P >#{f}.postm4 && ../../fruby #{f}.postm4 >#{f}.tex && cd -"
          print c+"\n"
          system(c) or exit(-1)
        end
    end
  end
end
