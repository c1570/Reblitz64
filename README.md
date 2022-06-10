# Reblitz64
https://github.com/c1570/Reblitz64

An effort to port the Blitz!/Austro-Speed compiler to JavaScript.

Simple live page (running in your browser): [docs/reblitz64.html](https://c1570.github.io/Reblitz64/reblitz64.html)

Porting using a 6502 emulator (see [blitz 0.1](https://csdb.dk/release/?id=173267)) or emulating the BASIC line structure using a `switch()` based finite state machine is relatively straightforward but does not result in maintainable/readable code.

Instead, this approach is about i) rewriting the original BASIC code to use structured GOTOs only (i.e., GOTOs that form proper IF/THEN/ELSE and loop block structures), ii) providing a transpiler that generates somewhat well-formed JavaScript code (without any GOTOs) from that input.

See [docs/blitz_bas.html](https://c1570.github.io/Reblitz64/blitz_bas.html) for annotated decompiled Blitz! sources.

[docs/hack.sh](docs/hack.sh) builds the JavaScript version of the compiler.
