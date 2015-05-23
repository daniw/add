.PHONY: all full light clean

all: full light clean

full:
	pdflatex datasheet.tex
	pdflatex datasheet.tex
	pdflatex datasheet.tex

light:
	pdflatex datasheet_light.tex
	pdflatex datasheet_light.tex
	pdflatex datasheet_light.tex

clean:
	rm -f *.aux
	rm -f *.lof
	rm -f *.log
	rm -f *.lol
	rm -f *.lot
	rm -f *.out
	rm -f *.toc
