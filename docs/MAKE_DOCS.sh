# pandoc integrate_quick_guide.md -o INTEGRATE_Quick_Guide.pdf \
#   --pdf-engine=xelatex \
#   --variable geometry:margin=1in \
#   --variable fontsize=11pt \
#   --variable mainfont="Charter" \
#   --variable sansfont="Fira Code" \
#   --variable monofont="Fira Code" \
#   --variable colorlinks=true \
#   --variable linkcolor=darkblue \
#   --variable urlcolor=darkblue \
#   --variable header-includes='\usepackage{fancyhdr} \pagestyle{fancy} \fancyhead[L]{INTEGRATE} \fancyhead[R]{\today}' \
#   --number-sections \
#   --highlight-style=kate

pandoc integrate_quick_guide.md -o INTEGRATE_Quick_Guide.pdf \
  --pdf-engine=xelatex \
  --variable geometry:margin=1in \
  --variable fontsize=11pt \
  --variable mainfont="Charter" \
  --variable sansfont="Fira Code" \
  --variable monofont="Fira Code" \
  --variable colorlinks=true \
  --variable linkcolor=darkblue \
  --variable urlcolor=darkblue \
  --variable header-includes='\usepackage{fancyhdr,booktabs,xcolor,colortbl} \pagestyle{fancy} \fancyhead[L]{INTEGRATE Quick Reference} \fancyhead[R]{\today} \rowcolors{2}{lightgray}{white} \definecolor{lightgray}{RGB}{240,240,240} \renewcommand{\arraystretch}{1.2}' \
  --number-sections \
  --highlight-style=kate

pandoc integrate_documentation.md -o INTEGRATE.pdf \
  --pdf-engine=xelatex \
  --variable geometry:margin=1in \
  --variable fontsize=11pt \
  --variable mainfont="Charter" \
  --variable sansfont="Fira Code" \
  --variable monofont="Fira Code" \
  --variable colorlinks=true \
  --variable linkcolor=darkblue \
  --variable urlcolor=darkblue \
  --variable header-includes='\usepackage{fancyhdr} \pagestyle{fancy} \fancyhead[L]{INTEGRATE Quick Reference} \fancyhead[R]{\today}' \
  --number-sections \
  --toc \
  --toc-depth=3 \
  --highlight-style=kate

