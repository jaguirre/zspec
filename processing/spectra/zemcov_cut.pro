;Uses Zemcov's algorithm to remove bad nods from the data
;Inputs: the original nodspec array, a set of "parallelArrays" to be
;trimmed according to the algorithm (e.g., the errors on each nodspec
;point), the nnods array from obs_labels
function zemcov_cut, structure

N=N_TAGS(structure)
names=TAG_NAMES(structure)

for alpha=0, n-1 do begin

    curStruct=structure.(alpha)
    nodspec=curStruct.nodspec
    s=size(nodspec)
    mask=curStruct.mask
    
    for j=0,2 do begin          ;Algorithm loops 3 times

        bad=0
                                ;Get the mean and standard deviation of each nod
        avg=dblarr(s[1]) 
        sigmas=dblarr(s[1])
        for i=0, s[1]-1 do begin
            z=where(mask[i,*] ne 0)
            if z[0] eq -1 then begin
                 bad=1
                 continue
            endif

            numGood=n_elements(where(mask[i,*] eq 1))
            avg[i]=total(nodspec[i,*]*mask[i,*])/numGood
            av2=total(nodspec[i,*]^2*mask[i,*])/numGood
            sigmas[i]=sqrt(av2-avg[i]^2)
        endfor

        if bad then begin
            ;mask[i,*]=0
            continue
        endif
        
                                ;Fit a line to the mean, using the stdev as the error
        freqs=freqid2freq(/no_shift)

        params=mpfitfun('line', freqs, avg, sigmas, [1,1])
        fit=line(freqs, params)
        
                                ;Compute the d array
                                ; d[i] is the total deviation of the
                                ; first five and last five frequencies
                                ; of each nod in units of the error
                                ; for each nod
        d=dblarr(s[2])
        for i=0, s[2]-1 do begin
            d[i]=total(abs(nodspec[0:4,i]-fit[0:4])/sigmas[0:4])+$
              total(abs(nodspec[s[1]-5:s[1]-1,i]-fit[s[1]-5:s[1]-1])/$
                    sigmas[s[1]-5:s[1]-1])
        endfor
        
        a=where(d gt 10)        ;Keep only the nods where d<10
        if a[0] ne -1 then for i=0, s[1]-1 do mask[i,a]=0
      
    endfor
    
    structure.(alpha).mask=mask
    
endfor

return, structure 

end
