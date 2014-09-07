#!/usr/bin/ruby

Dir.glob('ch*') do |dir|
  if File.directory?(dir) then
    if dir =~ /\Ach(\d+)\Z/ then
      n = $1
        Dir.glob("ch#{n}/*.rbtex").sort.each do |file|
          print "#{file}\n"
          file =~ /ch\d+\/(.*)\.rbtex/
          f = $1
          c = "cd #{dir} && m4 -P #{f}.rbtex >#{f}.postm4 && ../../fruby #{f}.postm4 >#{f}.tex && cd -"
          print c+"\n"
          system(c)
        end
    end
  end
end

#	perl -e 'foreach $$f(<ch*>) {if (-d $$f) {$$f=~/ch(\d\d)/; $$n=$$1; $$c = "cd ch$$n && m4 -P ch$$n.rbtex >ch$${n}.postm4 && cd -"; print "$$c\n"; system $$c}}'
#	perl -e 'foreach $$f(<ch*>) {if (-d $$f) {$$f=~/ch(\d\d)/; $$n=$$1; $$c = "cd ch$$n && ../../fruby ch$$n.postm4 >ch$${n}temp.tex && cd -"; print "$$c\n"; system $$c}}'
#	pdflatex alr_fund
