let input_prg = []
let cur_input_idx = 2

function sys_read_line() {
  if(cur_input_idx >= input_prg.length || input_prg[cur_input_idx + 1] == 0) { var_C4int = 0; return }
  var_C4int = 1
  var_B1 = input_prg[cur_input_idx + 2] + input_prg[cur_input_idx + 3] * 256
}

function sys_chrget() {
  return int_sys_chrget(true)
}

function sys_chrget3() {
  return int_sys_chrget(false)
}

function int_sys_chrget(ignore_spaces) {
  var_C2int = 0
  var_C3int = 0
  let chr = 0
  do {
    var_C1int++
    chr = input_prg[cur_input_idx + var_C1int]
    if(chr == 0) { // end of line
      var_Cint = 0
      var_C2int = 1
      var_C3int = 0x1f
      cur_input_idx += var_C1int + 1
      return
    }
  } while(ignore_spaces && chr == 0x20)
  var_Cint = chr
  if(chr == 0x3a) { var_C3int = 0x1f }
  return
}

function copy_extra_data() {
  // called at beginning of pass2 to copy any trailing extra data to result file
  cur_input_idx+=2
  if(cur_input_idx < input_prg.length) {
    c64_print(`Copying ${input_prg.length - cur_input_idx} bytes trailing the BASIC part to output.`)
  }
  while(cur_input_idx < input_prg.length) {
    write_pcode()
    var_Istr = String.fromCharCode(input_prg[cur_input_idx])
    cur_input_idx++
  }
}

function sys_find_in_array() {
  let arr = 0
  if(var_C5int == 10427) {
    arr = var_Gintarr
  } else if(var_C5int == 12036) {
    arr = var_Hintarr
  } else if(var_C5int == 7218) {
    arr = var_Dintarr
  } else { console.log("ERROR in sys_findinarray") }
  let search_for = var_C6int
  let size = var_C7int
  var_C5int = -1
  let i = 0
  while(i < size) {
    if(arr[i] == search_for) {
      var_C5int = i
      return
    }
    i++
  }
}

function float2string(f) {
  let f_buf = new Float64Array([f])
  let b_buf = new Uint32Array(f_buf.buffer)
  let sign_1b = b_buf[1] >> 31
  let exponent_11b = ((b_buf[1] >> 20) & 0x7ff) - 1023
  let fraction_31b = ((b_buf[1] & 0xfffff) << 11) | (b_buf[0] >>> 21) // implicit leading 1
  if((b_buf[0] >>> 19 & 3) >= 1) fraction_31b++ // rounding
  let c64_b1 = exponent_11b + 129
  let c64_b2 = (sign_1b << 7) + (fraction_31b >> 24)
  let c64_b3 = (fraction_31b >> 16) & 0xff
  let c64_b4 = (fraction_31b >> 8) & 0xff
  let c64_b5 = fraction_31b & 0xff
  return String.fromCharCode(c64_b1) + String.fromCharCode(c64_b2) + String.fromCharCode(c64_b3) + String.fromCharCode(c64_b4) + String.fromCharCode(c64_b5)
}

// adjust var_T1int to change length of runtime/offset of P-code
// comment out the following line to exclude runtime from output
for(let ch of runtime) { pass2_result = pass2_result + String.fromCharCode(ch) }

let p2_cur_p1_result_idx = 0

function sys_p2_char_read() {
  var_C1int = pass1_result.charCodeAt(p2_cur_p1_result_idx)
  p2_cur_p1_result_idx++
}

function sys_p2_char_write() {
  pass2_result = pass2_result + String.fromCharCode(var_C1int)
}

function c64_parse_float(s) {
  if(s == ".") return 0
  return parseFloat(s)
}

let scr_output = ""

function c64_print(s) {
  scr_output = scr_output + s + "\n"
}

if(typeof document !== 'undefined') {
  document.run_it = main
  console.log("document.run_it() to start")
} else {
  const fs = require('fs')
  input_prg = fs.readFileSync(process.argv[2], null)
  console.log(`Reading file ${process.argv[2]}, length ${input_prg.length}`)
  c64_print = console.log
  let start = performance.now()
  main()
  console.log(`Running took ${(performance.now() - start)>>>0}ms`)
  console.log(`Result length is ${pass2_result.length} bytes`)
  // fs.writeFileSync('test_p1_result.bin', pass1_result, {encoding: "ascii"});
  fs.writeFileSync(process.argv[3], pass2_result, {encoding: "ascii"});
}
