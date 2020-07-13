all: la.pdf stocha.pdf dsal.pdf fosap.pdf bus.pdf maschinengestaltung_i.pdf numrech.pdf buk.pdf swt.pdf datkom.pdf malo.pdf dbis.pdf effi.pdf afi.pdf ai.pdf cg.pdf bpi.pdf aat.pdf spa.pdf pp.pdf elehre.pdf algds.pdf meta.pdf sn.pdf

la.pdf: la.tex panikzettel.cls la.last-change
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make la.tex

stocha.pdf: stocha.tex
	latexmk -xelatex stocha.tex

dsal.pdf: dsal.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make dsal.tex

fosap.pdf: fosap.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make fosap.tex

bus.pdf: bus.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make bus.tex

maschinengestaltung_i.pdf: maschinengestaltung_i.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make maschinengestaltung_i.tex

numrech.pdf: numrech.tex panikzettel.cls numrech.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -use-make -pdf numrech.tex

buk.pdf: buk.tex
	latexmk -pdflatex="lualatex -interaction=nonstopmode" -pdf buk.tex

swt.pdf: swt.tex panikzettel.cls swt.last-change
	cp deps/tikz-uml.sty tikz-uml.sty
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf swt.tex

datkom.pdf: datkom.tex
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf datkom.tex

malo.pdf: malo.tex panikzettel.cls malo.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf malo.tex

dbis.pdf: dbis.tex
	cp deps/tikz-er2.sty tikz-er2.sty
	cp deps/BTrees.sty BTrees.sty
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf dbis.tex

effi.pdf: effi.tex panikzettel.cls effi.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf effi.tex

afi.pdf: afi.tex panikzettel.cls afi.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf afi.tex

ai.pdf: ai.tex panikzettel.cls ai.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf ai.tex

cg.pdf: cg.tex panikzettel.cls cg.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf cg.tex

bpi.pdf: bpi.tex panikzettel.cls bpi.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf bpi.tex

aat.pdf: aat.tex panikzettel.cls aat.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf aat.tex

spa.pdf: spa.tex panikzettel.cls spa.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf spa.tex

pp.pdf: pp.tex panikzettel.cls pp.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf pp.tex

elehre.pdf: elehre.tex panikzettel.cls elehre.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf elehre.tex

algds.pdf: algds.tex panikzettel.cls algds.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf algds.tex

meta.pdf: meta.tex panikzettel.cls meta.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode -shell-escape" -pdf meta.tex
	
sn.pdf: sn.tex panikzettel.cls meta.last-change
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf sn.tex

%.last-change: %.tex
	echo -n "Version " > $@
	git log --format=oneline -- $< | wc -l >> $@
	echo "---" >> $@
	git log --pretty=format:%ad --date=format:'%d.%m.%Y' -n 1 -- $< >> $@

clean:
	rm -f *.last-change
	latexmk -CA
