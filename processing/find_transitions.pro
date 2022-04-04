function find_transitions,array, fin_diff = fin_diff, thresh = thresh

n = n_e(array)

fin_diff = array[1:*]-array[0:n-2]

if not(keyword_set(thresh)) then $
  thresh = .01

; Rising edges
wh_rise = where(fin_diff gt thresh)

; Falling edges
wh_fall = where(fin_diff lt -thresh)

trans = create_struct('rise',wh_rise+1,$
                      'fall',wh_fall+1)

return,trans

end
