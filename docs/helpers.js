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

let p2_cur_p1_result_idx = 0

function sys_p2_char_read() {
  var_C1int = pass1_result.charCodeAt(p2_cur_p1_result_idx)
  p2_cur_p1_result_idx++
}

function sys_p2_char_write() {
  pass2_result = pass2_result + String.fromCharCode(var_C1int)
}

function print_pass2_result() {
  let res = ''
  for(i=0; i<pass2_result.length; i++) {
    res = res + ("0" + pass2_result.charCodeAt(i).toString(16)).slice(-2) + " "
  }
  console.log(res)
  console.log(`P-code length is ${pass2_result.length} bytes`)
}

if(typeof document !== 'undefined') {
  document.runit = main
  console.log("document.runit() to start")
} else {
  main()
}
