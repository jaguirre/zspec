function datadiscard_arr,indata,goodflag=goodflag,negative=negative

;NOTE: this function is only for use with JAN03 data

;this program statistically examines an array of data at tosses out data that has a 
;probability of less than half an even occuring.  Note: This assumes a gaussian 
;distribution and should be used with caution.

;this function assumes a 2D array as input (n,m) with n variables and m observations
;cut will be made on m

if keyword_set(negative) then neg_use=-1.0 else neg_use=1.0

;error check
sz=size(indata,/dim)
if n_elements(sz) ne 2 then message,'ERROR: indata must have two dimensions.'

newdata=double(indata)
goodflag=replicate(1,sz(1))
nbadpoints=1
nbadpoints2=1

while nbadpoints2 ge 1 do begin
   while(nbadpoints ge 1) do begin
	valid=where(goodflag,nvalid)
        if nvalid eq 1 then return,newdata(*,valid)

	goodflag_tot=0
	for i_var=0,sz(0)-1L do begin
		data=datadiscard(reform(newdata(i_var,valid)),goodflag=goodflag_temp)
		goodflag_tot=goodflag_tot+goodflag_temp
	endfor

;	badpoints=where(goodflag_tot lt sz(0),nbadpoints)
	badpoints=where(goodflag_tot lt sz(0) or neg_use*reform(newdata(0,valid)) le 0 or reform(newdata(1,valid))*2.354 le 20 or $
		reform(newdata(2,valid))*2.354 le 20,nbadpoints)

	;the problem we have is that a bimodal result with a large rms
	if nbadpoints eq nvalid then badpoints=where(goodflag_tot lt sz(0),nbadpoints)	;less restrictive
	if nbadpoints ge 1 then goodflag(valid(badpoints))=0
   endwhile

   valid2=where(goodflag,nvalid2)
   badpoints2=where(neg_use*newdata(0,valid2) lt 0.5*max(neg_use*newdata(0,valid2)),nbadpoints2)	
   if nbadpoints2 ge 1 then goodflag(valid2(badpoints2))=0

endwhile

return, indata(*,valid)
end	
