#!/bin/bash

petcat -w2 -o input.prg blitz_bas.txt
./cranktheprint
perl -i -pe 's/<body>/<body><a href="https:\/\/github.com\/c1570\/Reblitz64">Back to Reblitz64<\/a><br\/><small>Using font by <a href="https:\/\/style64.org\/c64-truetype">Style<\/a><\/small><br\/>/gm' output.html
mv output.html blitz_bas.html
