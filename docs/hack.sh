#!/bin/bash

petcat -w2 -o input.prg 5_blitz_fewer_gotos.bas.txt
./basictransplr
node_modules/.bin/js-beautify output.txt > output.js
cat helpers.js >> output.js
perl -i -pe 's/  user_prompt_mode\(\)/var_Tint=1; var_Ystr=""; var_Tstr="(prog. mode : 1)"/gm' output.js
perl -i -pe 's/  GOTO/\/\/GOTO/gm' output.js
perl -i -pe 's/  ON/\/\/ON/gm' output.js
perl -i -pe 's/console.log(.*)\;$/console.log\1/gm' output.js
perl -i -pe 's/\/\/console.log(.*)/console.log(\1)/gm' output.js
perl -i -pe 's/LEFT\$ \(/LEFT\$(/gm' output.js
perl -i -pe 's/LEFT\$\((.*?),(.*?)\)/\1.substr(0, \2)/gm' output.js
perl -i -pe 's/PEEK\((.*?)\)/0 \/* PEEK \1 *\//gm' output.js
perl -i -pe 's/STR\$//gm' output.js
perl -i -pe 's/LEN\((.*?)\)/\1.length/gm' output.js
perl -i -pe 's/SPC\((.*?)\)/\"   \"/gm' output.js
perl -i -pe 's/\/\/SYS  var_Mint \+86/sys_read_line()/gm' output.js
perl -i -pe 's/\/\/SYS  var_Mint/sys_chrget()/gm' output.js
perl -i -pe 's/\/\/SYS  var_Mint \+3/sys_chrget3()/gm' output.js
perl -i -pe 's/\/\/SYS  var_Nint/sys_find_in_array()/gm' output.js
perl -i -pe 's/var_B1 \= ASC.*$/\/\/ var_B1 is taken care of in sys_read_line/gm' output.js
perl -i -pe 's/var_L2int = ASC\(MID\$\(var_I1strarr\[var_I4\], 2\)\)/var_L2int = var_I1strarr\[var_I4\].charCodeAt(2-1)/gm' output.js
perl -i -pe 's/var_F = ASC\(var_Fstr\) \* 256 \+ ASC\(MID\$\(var_Fstr, 2\)\)/var_F = var_Fstr.charCodeAt(0) * 256 + var_Fstr.charCodeAt(2-1)/gm' output.js
perl -i -pe 's/MID\$\((.*?),(.*?)\)/\1.substr(\2-1)/gm' output.js
perl -i -pe 's/ASC\((.*?)\)/\1.charCodeAt(0)/gm' output.js
perl -i -pe 's/  pass2\(\)/console.log("skip pass2")/gm' output.js
node output.js
