all: la.pdf stocha.pdf dsal.pdf fosap.pdf bus.pdf mechanik_i.pdf maschinengestaltung_i.pdf numrech.pdf buk.pdf swt.pdf

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

mechanik_i.pdf: mechanik_i.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make mechanik_i.tex
	
maschinengestaltung_i.pdf: maschinengestaltung_i.tex
	latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make maschinengestaltung_i.tex

numrech.pdf: numrech.tex
	latexmk -pdflatex="xelatex -interaction=nonstopmode" -pdf numrech.tex

buk.pdf: buk.tex
	latexmk -pdflatex="lualatex -interaction=nonstopmode" -pdf buk.tex

swt.pdf: swt.tex
	latexmk -pdflatex="lualatex -interaction=nonstopmode" -pdf swt.tex

clean:
	latexmk -CA
