all: la.pdf stocha.pdf dsal.pdf fosap.pdf bus.pdf maschinengestaltung_i.pdf numrech.pdf buk.pdf swt.pdf datkom.pdf malo.pdf dbis.pdf effi.pdf afi.pdf ai.pdf cg.pdf bpi.pdf aat.pdf spa.pdf pp.pdf elehre.pdf algds.pdf meta.pdf sn19.pdf sn20.pdf lsp1.pdf or1.pdf

typst:
	find . -type f -iname "*.typ" -not -name "conf.typ" -not -iname "_*.typ" -exec ./scripts/compile-typst {} \;

la.pdf: la.tex panikzettel.cls la.last-change
	latexmk -output-directory=./build -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make la.tex

stocha.pdf: stocha.tex
	latexmk -output-directory=./build -xelatex stocha.tex

dsal.pdf: dsal.tex dsal.last-change
	latexmk -output-directory=./build -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make dsal.tex

fosap.pdf: fosap.tex
	latexmk -output-directory=./build -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make fosap.tex

bus.pdf: bus.tex
	latexmk -output-directory=./build -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make bus.tex

maschinengestaltung_i.pdf: maschinengestaltung_i.tex
	latexmk -output-directory=./build -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make maschinengestaltung_i.tex

numrech.pdf: numrech.tex panikzettel.cls numrech.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -use-make -pdf numrech.tex

buk.pdf: buk.tex
	latexmk -output-directory=./build -pdflatex="lualatex -interaction=nonstopmode" -pdf buk.tex

swt.pdf: swt.tex panikzettel.cls swt.last-change
	cp deps/tikz-uml.sty tikz-uml.sty
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf swt.tex

datkom.pdf: datkom.tex
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf datkom.tex

malo.pdf: malo.tex panikzettel.cls malo.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf malo.tex

dbis.pdf: dbis.tex
	cp deps/tikz-er2.sty tikz-er2.sty
	cp deps/BTrees.sty BTrees.sty
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf dbis.tex

effi.pdf: effi.tex panikzettel.cls effi.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf effi.tex

afi.pdf: afi.tex panikzettel.cls afi.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf afi.tex

ai.pdf: ai.tex panikzettel.cls ai.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf ai.tex

cg.pdf: cg.tex panikzettel.cls cg.last-changeting to /full/path/build/out.aux
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf bpi.tex

aat.pdf: aat.tex panikzettel.cls aat.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf aat.tex

spa.pdf: spa.tex panikzettel.cls spa.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf spa.tex

pp.pdf: pp.tex panikzettel.cls pp.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf pp.tex

elehre.pdf: elehre.tex panikzettel.cls elehre.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf elehre.tex

algds.pdf: algds.tex panikzettel.cls algds.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf algds.tex

#meta.pdf: meta.tex panikzettel.cls meta.last-change
#	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode -shell-escape" -pdf meta.tex

sn19.pdf: sn19.tex panikzettel.cls sn19.last-change $(wildcard sn19/*.tex)
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf sn19.tex

sn20.pdf: sn20.tex panikzettel.cls sn20.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf sn20.tex

lsp1.pdf: lsp1.tex panikzettel.cls lsp1.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf lsp1.tex

or1.pdf: or1.tex panikzettel.cls or1.last-change
	latexmk -output-directory=./build -pdflatex="pdflatex -interaction=nonstopmode" -pdf or1.tex

%.last-change: %.tex
	echo -n "Version " > $@
	git log --format=oneline -- $< | wc -l >> $@
	echo "---" >> $@
	git log --pretty=format:%ad --date=format:'%d.%m.%Y' -n 1 -- $< >> $@

clean:
	rm -f *.last-change
	latexmk -CA
	rm -rf ./buildnames