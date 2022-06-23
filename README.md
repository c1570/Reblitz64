# Reblitz64
https://github.com/c1570/Reblitz64

A port of the [Blitz!/Austro-Speed](https://csdb.dk/release/?id=72927) C64 BASIC V2 compiler to JavaScript.

Simple live page (running in your browser): [docs/reblitz64.html](https://c1570.github.io/Reblitz64/reblitz64.html)

You can run the compiler on command line using `node reblitz64.js source.prg target.prg`.

## Rationale
The original Blitz! compiler was written in BASIC (with a few assembler helpers for improved performance) and got compiled using itself.

Porting that compiler using a 6502 emulator (see [blitz 0.1](https://csdb.dk/release/?id=173267)) or emulating the BASIC line structure using a `switch()` based finite state machine is relatively straightforward but does not result in maintainable/readable code.

Instead, the approach taken here was i) rewriting the original BASIC code to use structured GOTOs only (i.e., GOTOs that form proper IF/THEN/ELSE and loop block structures), ii) creating a transpiler that generates somewhat well-formed JavaScript code (without any GOTOs) from that input.

This resulted in a somewhat readable and hackable result, and it's much faster than the emulation approach as well.

## basictransplr
A somewhat generic BASIC V2 transpiler can be found at [docs/basictransplr](docs/basictransplr).
This was used to do the major work of porting the Blitz! compiler to JavaScript.

Just as the name implies, basictransplr isn't actually a transpiler but more of a slightly extended BASIC detokenizer.
It interprets hints given in REMs and replaces GOTOs by the appropriate control structures and does some structure checks.

The annotations `BREAK`, `ELSE`, `WHILE(TRUE)` replace the last `GOTO` encountered in the line.
The annotation `DO` makes the line a loop start (including the statements of the line).
The annotation `IFBEGIN` marks the double GOTO pattern typically used in BASIC V2 to emulate multiline IF/THEN/ELSE.
The annotation `ELSEIF` is used for if/elseif/elseif/endif constructs.

Example:
```
10 I=I+1:REM"DO
20 IFI>10GOTO70:REM"BREAK
30 IFI>=3GOTO50:REM"IFBEGIN
40 PRINT"I IS LESS THAN 3":GOTO60:REM"ELSE
50 PRINT"I IS GREATER OR EQUAL TO 3"
60 GOTO10:REM"WHILE(TRUE)
70 IFI>10GOTO90:REM"ELSE
80 PRINT"THIS SHOULD NOT BE REACHED"
90 END
```

...gets transpiled to...
```
do {
  i=i+1
  if(i>10) break
  if(!(i>=3)) {
    console.log("i is less than 3")
  } else {
    console.log("i is greater or equal to 3")
  }
while(true)
if(!(i>10)) {
  console.log("this should not be reached")
}
// end
```

Make sure the annotations actually match GOTO semantics.

See [docs/blitz_bas.html](https://c1570.github.io/Reblitz64/blitz_bas.html) for more examples.

basictransplr is not complete and depends on quite a few nasty regex hacks in postprocessing to give anything resembling actual JavaScript as output.
Also, a lot of the semantics isn't quite right, e.g., BASIC `FOR` loops always run at least once, which the JS `for` loops in basictransplr's output don't do.

It's up to the user of basictransplr to adjust the input code accordingly.

## Getting rid of those GOTOs
In order to replace GOTOs used in the Blitz! compiler by structured control flow, its sources had to get modified quite extensively.

* GOTO into actual subroutines was replaced by `GOSUB...:RETURN`
* A lot of GOTOing around (i.e., from pass 1 to pass 2 code) got replaced by GOSUBs
* In pass 1, token handling code was jumped to via `ON...GOTO`. This got replaced by `IF...GOSUB`.
* Token handling code used GOTO to jump into error handling code. This got replaced by an error flag (`ER%=...:RETURN`).
* Many GOTO'd subroutines with optional inits were converted to nested subroutines (`100 I=0`, `110 I=I+1:GOTO(back)` => `100 I=0:GOSUB 110:RETURN`, `110 I=I+1:RETURN`)

## Putting it all together
See [docs/blitz_bas.html](https://c1570.github.io/Reblitz64/blitz_bas.html) for annotated decompiled and heavily rearranged Blitz! compiler sources (HTML output courtesy of [Crank the PRINT!](https://github.com/c1570/CrankThePRINT)).
Line numbers and variables have tooltips generated from [docs/labels.csv](docs/labels.csv).

Note that the rearranged code is longer than the original code and collides with the original ASM helpers as-is.
You can shorten the code (e.g., remove the chooser screen) or relocate ASM helpers to another position in memory if you want to run the rearranged Blitz! compiler in a C64 environment.

For the JavaScript output, the original ASM helpers get replaced by custom JavaScript helpers [docs/helpers.js](docs/helpers.js).

[docs/hack.sh](docs/hack.sh) builds the JavaScript version of the compiler and contains a lot of regex nastiness to make it all work.

## Fixes and changes in Reblitz64
* Pass 2 failed in case the generated P-code reached beyond $7FFF (overflow in `15139 l2%=c%(c5%)+c%:return`)
* (TODO typo in variable)
* (TODO broken comparison/variable count)
* The `::` mechanism to pass any code to the original BASIC interpreter got removed.

## Notes
* Want to force Blitz! to recognize one variable as integer (even though it isn't marked as such)?
  * 2680 iff1%=...andf2%=...thenl3%=128:f1%=f1%or128:f2%=f2%or128
  * 2681 f=f1%*256+f2%:...
