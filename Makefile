all: la.pdf stocha.pdf dsal.pdf fosap.pdf bus.pdf maschinengestaltung_i.pdf numrech.pdf buk.pdf swt.pdf datkom.pdf malo.pdf dbis.pdf

la.pdf: la.tex
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

numrech.pdf: numrech.tex
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -use-make -pdf numrech.tex

buk.pdf: buk.tex
	latexmk -pdflatex="lualatex -interaction=nonstopmode" -pdf buk.tex

swt.pdf: swt.tex
	cp deps/tikz-uml.sty tikz-uml.sty
	latexmk -pdflatex="lualatex -interaction=nonstopmode" -pdf swt.tex

datkom.pdf: datkom.tex
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf datkom.tex

malo.pdf: malo.tex
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf malo.tex

dbis.pdf: dbis.tex
	cp deps/tikz-er2.sty tikz-er2.sty
	cp deps/BTrees.sty BTrees.sty
	latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf dbis.tex

clean:
	latexmk -CA
