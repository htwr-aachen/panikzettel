all: la.pdf stocha.pdf

la.pdf: la.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make la.tex

stocha.pdf: Stocha.tex
    xelatex Stocha.tex

clean:
    rm Stocha.aux
    rm Stocha.log
    rm Stocha.out
    rm Stocha.toc
    rm Stocha.pdf
	latexmk -CA
