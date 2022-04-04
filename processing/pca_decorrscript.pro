;Removes the correlation from the data
function doRemove, nodspec, mask, avespec

s=size(nodspec)
curspec=nodspec - avespec#replicate(1.,s[2]) ;Remove the mean; we don't want 
                                             ;to change the continuum

n_good=total(mask,2)
averages=total(curspec*mask,2)/n_good

n=curspec*mask-averages#replicate(1.,s[2])
cov=n # transpose(n) ;Compute the covariance matrix
w=where(~finite(cov))
if w[0] ne -1 then cov[w]=0

eigenvals=eigenql(cov,eigenvectors=evects) ;Get its eigenvalues/vectors
proj=diag(replicate(1, n_e(eigenvals)))

i=indgen(3)
proj[i,i]=0 ;Zero out the first three eigenvectors 

;Rebuild curspec from the remaining eigenvectors
curspec=(evects#proj#transpose(evects))#(curspec)

return, curspec+avespec#replicate(1.,s[2]) ;Re-add the mean

end

function remove_corr_zapex, vopt, period, fits=fits

n_bolo=n_e(vopt)
n_nod=n_e(vopt[0].nod)
n_pos=n_e(vopt[0].nod[0].pos)
n_time=n_e(vopt[0].nod[0].pos[0].time)

fits=dblarr(n_bolo, n_nod, n_pos, n_time)
f=findgen(n_time)
weights=replicate(1, n_time)

for bolo=0, n_bolo-1 do $
  for nod=0, n_nod-1 do $
  for pos=0, n_pos-1 do begin
    wave=vopt[bolo].nod[nod].pos[pos].time
    fits[bolo, nod, pos, *]=mpcurvefit(f, wave,weights, $
                                       [(max(wave)-min(wave))/2, 2*!PI/period, 0, mean(wave)],$
                                       function_name='sine', /noderivative)

    vopt[bolo].nod[nod].pos[pos].time-=fits[bolo,nod, pos,*]    
endfor

spec=vopt.nod.pos.time
mask=vopt.nod.pos.flag
n_stream=n_e(spec)/n_bolo

spec=transpose(reform(spec, n_stream, n_bolo))
mask=transpose(reform(mask, n_stream, n_bolo))

avespec=total(spec, 2)/n_stream
spec=doRemove(spec, mask, avespec)

spec=reform(transpose(spec), n_time, n_pos, n_nod, n_bolo)
for i=0, n_bolo-1 do $
  for j=0, n_nod-1 do $
  for k=0, n_pos-1 do vopt[i].nod[j].pos[k].time=$
  spec[*,k,j,i]

for bolo=0, n_bolo-1 do $
  for nod=0, n_nod-1 do $
  for pos=0, n_pos-1 do $
  vopt[bolo].nod[nod].pos[pos].time+=fits[bolo,nod, pos,*]  

return, vopt

end

function PCA_decorrscript, struct, period=period, fits=fits

N=N_TAGS(struct)
names=TAG_NAMES(struct)

if N eq 1 then return, remove_corr_zapex(struct, period, fits=fits)

for alpha=0, N-1 do begin ;Extract the substructures

curStruct=struct.(alpha)
nodspec=curStruct.nodspec
mask=curStruct.mask
avespec=curStruct.avespec
corr=curStruct.corr

curStruct.nodspec=doRemove(nodspec, mask, avespec) ;Update nodspec

if alpha eq 0 then finalStruct=create_struct(names[alpha],curStruct) $
else finalStruct=create_struct(finalStruct,names[alpha],curStruct)

endfor

;Recalculate correlation
return, calculate_corr(finalStruct)

end
