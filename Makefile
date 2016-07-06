all: panikzettel.pdf

panikzettel.pdf: panikzettel.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make panikzettel.tex

clean:
	latexmk -CA
