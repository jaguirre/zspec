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
curspec=(evects#proj#transpose(evects))#(curspec*mask)

return, curspec+avespec#replicate(1.,s[2]) ;Readd the mean

end


function remove_corr, struct

struct=calculate_corr(struct)
N=N_TAGS(struct)
names=TAG_NAMES(struct)

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
