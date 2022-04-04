function flag_data, values, mean, sdom, mask, cut_range

N_values=n_e(values)

;Just stop if there's nothing left to flag
w=where(mask eq 0, count)
IF (count EQ N_values) THEN BEGIN
     message, /info, 'No good data points for flag_data'
     message, /info, 'Masking out everything'
     return, mask
 endif
 
;Search for outliers
 w=where(abs(values-mean) ge cut_range*sdom, bad_count)

 if bad_count eq N_values then begin
     message, /info, 'No good data points to flag, returning original mask'
     return, mask
 endif

                                ;flag them out
 if bad_count ne 0 then mask[bad_count]=0

return, mask

end
