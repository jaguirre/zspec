;12/19/2012 - KSS - committed latest revision to svn

;Calculates the two-point correlation between the frequencies in nodspec
function corrscript2, nodspec, mask

;Mean adn STDEV of each frequency
s=size(nodspec)
n_good=total(mask,2)
averages=total(nodspec*mask,2)/n_good
n=nodspec*mask-averages#replicate(1.,s[2])
sigmas=sqrt(total(n^2,2)/n_good)

;Vectorized for performance
;2 point correlation
denom=sqrt(n_good#transpose(n_good))*(sigmas#transpose(sigmas))

cov=(n # transpose(n))
corr=cov/denom

return, {corr:corr, cov:cov}

end

function zapex_corr, vopt

spec=vopt.nod.pos.time
mask=vopt.nod.pos.flag

n_bolo=n_e(vopt)
n_nod=n_e(spec)/n_bolo

spec=transpose(reform(spec, n_nod, n_bolo))
mask=transpose(reform(mask, n_nod, n_bolo))

return, corrscript2(spec, mask)

end

function calculate_corr, struct

N=N_TAGS(struct)
names=TAG_NAMES(struct)

if N eq 1 then return, zapex_corr(struct)

for alpha=0, N-1 do begin ;Extract each substructure

    curStruct=struct.(alpha)
    nodspec=curStruct.nodspec
    mask=curStruct.mask
    
    result=corrscript2(nodspec, mask) ;Find its correlation
    
;Add it to the structure if it isn't already there, or replace it if
;it is
    subNames=TAG_NAMES(curStruct)
    w=where(subNames eq 'CORR')
    if w[0] eq -1 then begin
        curStruct=create_struct(curStruct,'corr',result.corr)
    endif else begin
        curStruct.corr=result.corr
    endelse
    
    w=where(subNames eq 'COV')
    if w[0] eq -1 then begin
        curStruct=create_struct(curStruct,'COV',result.cov)
    endif else begin
        curStruct.cov=result.cov
    endelse
    
    ;Rebuild the input structure
if alpha eq 0 then finalStruct=create_struct(names[alpha],curStruct) $
else finalStruct=create_struct(finalStruct,names[alpha],curStruct)

endfor

return, finalStruct

end
