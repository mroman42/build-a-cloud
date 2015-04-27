PDF=$(addsuffix .pdf, $(basename $(basename $(wildcard *.doc.md *.pres.md))))

default: $(PDF)

%.pdf: %.doc.md references.bib
	pandoc --to latex --latex-engine xelatex -N -o $@ $< --filter pandoc-citeproc

%.pdf: %.pres.md
	pandoc --to beamer --latex-engine xelatex -N -o $@ $<

clean:
	rm -f $(PDF)
