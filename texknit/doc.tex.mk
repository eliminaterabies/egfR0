texknit/doc.tex.deps texknit/doc.subdeps: ; touch $@

texknit/doc.tex.deps: | . 

texknit/doc.tex.deps: rplot_combo.Rout.pdf intervalPlots.Rout.pdf ./interval.png mexico.Rout.pdf R0combo.Rout.pdf 


