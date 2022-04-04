; HISTORY: 05 SEP 06 BN - simplified based on structures -> arrays
;                         changed so that input nod_struct isn't changed

function trim_nods, nod_struct_in, chop_period, length = new_length

; Trim the length of nods in a observation to a uniform length which is an
; integer multiple of the chop period.

  nod_struct = nod_struct_in

  lengths = nod_struct.pos.f - nod_struct.pos.i + 1

  median_length = median(lengths)
  min_length = min(lengths)
  
  new_length = round(FLOOR(min_length / chop_period) * chop_period)

  if (new_length lt 0.5 * median_length) then $
     message,'New nod position length is shorter than half the median.'

  nod_struct.pos.f = nod_struct.pos.i + new_length - 1
  
  return, nod_struct

end
