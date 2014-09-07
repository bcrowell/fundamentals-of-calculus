LATEX_OUTPUT_FILTER = /home/bcrowell/Documents/writing/books/physics/scripts/filter_latex_messages.rb

default:
	cp ../shaddap.sty .
	preprocess.rb
	pdflatex -interaction=nonstopmode alr_fund | $(LATEX_OUTPUT_FILTER)
	pdflatex -interaction=nonstopmode alr_fund | $(LATEX_OUTPUT_FILTER)
	rm -f shaddap.sty
	cp alr_fund.pdf ~/Lightandmatter/alr

clean:
	@rm -f *aux *idx *ilg *ind *log *toc *~
	@rm -f ch*/*aux ch*/*postm4 ch*/*~ ch*/*.tex
	
