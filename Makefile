all: la.pdf stocha.pdf

la.pdf: la.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make la.tex

stocha.pdf: Stocha.tex
	latexmk -xelatex Stocha.tex

clean:
	latexmk -CA
