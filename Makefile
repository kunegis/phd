#
# The Makefile used when only the phd/ directory is available. 
#
# PARAMETERS
#	$NOPDF	Don't include the rule for building thesis.pdf; used
# 		when including this Makefile and overriding this rule;
# 		however, include dependencies of it 
#

BIBFILES := $(foreach I, kunegis ref web unpublished tub, $(I).bib)

thesis.pdf:  \
  thesis.tex $(BIBFILES) \
  Number.tex number.tex datasets.tex \
  network-categories.tex category-descriptions.tex property-legend.tex \
  img-pdf/network-properties.b.crop.pdf \
  img-pdf/network-properties.d.crop.pdf \
  img-pdf/network-properties.m.crop.pdf \
  img-pdf/network-properties.r.crop.pdf \
  img-pdf/network-properties.si.crop.pdf \
  img-pdf/network-properties.time.crop.pdf \
  img-pdf/network-properties.t.crop.pdf \
  img-pdf/network-properties.us.crop.pdf \

ifneq (1,$(NOPDF))
thesis.pdf:   
	rm -f *.aux *.log *.out *.bbl *.blg
	pdflatex -file-line-error -halt-on-error thesis.tex
	bibtex thesis
	makeindex thesis
	pdflatex -file-line-error -halt-on-error thesis.tex
	pdflatex -file-line-error -halt-on-error thesis.tex
	pdflatex -file-line-error -halt-on-error thesis.tex
endif

img-pdf/%.crop.pdf:  img-pdf/%.pdf
	pdfcrop img-pdf/$*.pdf img-pdf/$*.crop.pdf

# Printed version
thesis-print.pdf:  thesis.pdf 
	cp thesis.tex thesis-print.tex
	pdflatex -file-line-error -halt-on-error "\def\printversion{}\input{thesis-print}"
	bibtex thesis-print
	makeindex thesis-print
	pdflatex -file-line-error -halt-on-error "\def\printversion{}\input{thesis-print}"
	pdflatex -file-line-error -halt-on-error "\def\printversion{}\input{thesis-print}"
	pdflatex -file-line-error -halt-on-error "\def\printversion{}\input{thesis-print}"

