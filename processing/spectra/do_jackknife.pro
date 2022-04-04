function do_jackknife, struct

N=N_TAGS(struct)
total_iters=100

jackknives=dblarr(total_iters, N, 160)
for iter=0, total_iters-1 do begin
    curspec=spectra_jackknife(struct, 4)
    for tag=0, N-1 do begin
        jackknives[iter, tag, *]=curspec.(tag).avespec
    endfor
endfor

final_spectra=struct
for bolo=0, 159 do $
  for tag=0, N-1 do final_spectra.(tag).aveerr=$
  stddev(jackknives[*,tag, bolo], /nan)
  
return, final_spectra

end
