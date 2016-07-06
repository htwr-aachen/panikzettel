all: la.pdf

la.pdf: la.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make la.tex

clean:
	latexmk -CA
