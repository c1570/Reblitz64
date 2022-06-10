#!/bin/bash

petcat -w2 -o input.prg 5_blitz_fewer_gotos.bas.txt
./basictransplr
echo "let pass1_result = ''" > output.js
echo "let data_values = ''" >> output.js
echo "let data_index = 0" >> output.js
echo "let pass2_result = ''" >> output.js
node_modules/.bin/js-beautify output.txt >> output.js



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
perl -i -pe 's/\/\/SYS  var_Mint \+3/sys_chrget3()/gm' output.js
perl -i -pe 's/\/\/SYS  var_Mint/sys_chrget()/gm' output.js
perl -i -pe 's/\/\/SYS  var_Nint/sys_find_in_array()/gm' output.js
perl -i -pe 's/var_B1 \= ASC.*$/\/\/ var_B1 is taken care of in sys_read_line/gm' output.js
perl -i -pe 's/var_L2int = Math.floor\(ASC\(MID\$\(var_I1strarr\[var_I4\], 2\)\)\)/var_L2int = var_I1strarr\[var_I4\].charCodeAt(2-1)/gm' output.js
perl -i -pe 's/var_F = ASC\(var_Fstr\) \* 256 \+ ASC\(MID\$\(var_Fstr, 2\)\)/var_F = var_Fstr.charCodeAt(0) * 256 + var_Fstr.charCodeAt(2-1)/gm' output.js
perl -i -pe 's/MID\$\((.*?),(.*?)\)/\1.substr(\2-1)/gm' output.js
perl -i -pe 's/ASC\((.*?)\)/\1.charCodeAt(0)/gm' output.js
perl -i -pe 's/if\ \(\!\(var_ST\)\)/if(false)/gm' output.js
perl -i -pe 's/var_Z \= var_F6/var_Jstr = String.fromCharCode(168) + float2string(var_F6); return/gm' output.js
perl -i -pe 's/for \(var_F = 2047\; var_F \<\= var_T1int\; var_F\+\+\) \{/var_F=var_T1int+1; if(false) \{/gm' output.js

# FIXME handle boolean AND/OR properly
perl -i -pe 's/&& ([0-9]+)/& \1/gm' output.js
perl -i -pe 's/if \(var_I1 \&\& var_I2\)/if (var_I1 & var_I2)/gm' output.js

# file handle 2 is basic input prg (in pass1) or pass1 result (in pass2)
# file handle 3 is result compiled prg (in pass2)
# file handle 4 is pass1 result (in pass1)
# file handle 5 is writing DATA values (in pass1)
# file handle 6 is offset-linenr helper file "z/..."
# file handle 7 is runtime
# file handle 8 is reading DATA values (in pass2)

perl -i -pe 's/\/\/PRINT\# 4, var_Istr ;/pass1_result = pass1_result + var_Istr/gm' output.js

perl -i -pe 's/\/\/PRINT\# 3, (.*)\;/pass2_result = pass2_result + \1/gm' output.js
perl -i -pe 's/\/\/PRINT\# 5, (.*)\;/data_values = data_values + \1/gm' output.js
perl -i -pe 's/\/\/GET \#8, (.*)/\1 = data_values.substr(data_index, 1); data_index++/gm' output.js
perl -i -pe 's/\/\/SYS  var_N1int/sys_p2_char_read()/gm' output.js
perl -i -pe 's/\/\/SYS  var_N2int/sys_p2_char_write()/gm' output.js


echo -e '\nlet input_prg = new Uint8Array([' >> output.js
cat test-input.prg | ./hex >> output.js
echo '])' >> output.js

echo 'let runtime = new Uint8Array([' >> output.js
dd if=0_blitz_orig.prg bs=1 count=6036 | ./hex >> output.js
echo '])' >> output.js
cat helpers.js >> output.js

node output.js
