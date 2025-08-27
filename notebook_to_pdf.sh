#!/bin/bash

## Util to convert .ipynb to .pdf on Rivanna. Invoke as:
## ./notebook_to_pdf.sh <mynotebook>.ipynb

module load jupyterlab/4.4.6-py3.12 texlive/2025

CMD="jupyter nbconvert --to pdf $1"
echo $CMD
$CMD
