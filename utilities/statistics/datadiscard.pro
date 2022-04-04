function datadiscard,indata,goodflag=goodflag,sigma=sigma,bounds=bounds

;this program statistically examines an array of data at tosses out data that has a 
;probability of less than half an even occuring.  Note: This assumes a gaussian 
;distribution and should be used with caution.
;
;GOODFLAG returns an array of 1's and 0's with 0's indicating bad data
;SIGMA set this to do a n sigma cut on data
;MULTI set this to input a m x n_pts 2D array, function returns goodflag
;BOUNDS set to a 2 element array to set artificial boundaries to be cut
;
;031127 GL - added sigma keyword
;040114 GL - fixed bug with sigma keyword
;040408 GL - added bounds keyword

;error check bounds keyword 
if keyword_set(bounds) then if n_elements(bounds) ne 2 then message,'ERROR: BOUNDS keyword must have 2 elements'

newdata=double(indata)
goodflag=replicate(1,n_elements(indata))

if keyword_set(bounds) then begin
	badpoints=where(newdata lt bounds[0] or newdata gt bounds[1],nbadpoints)	
	if nbadpoints ge 1 then goodflag(badpoints)=0
	if nbadpoints eq n_elements(newdata) then message,'ERROR: No data falls within bounds'
endif

;iterate cut
nbadpoints=1
while(nbadpoints ge 1) do begin
	valid=where(goodflag,nvalid)
        if nvalid eq 1 then return,newdata(valid)

	mean=mean(newdata[valid],/double)

	stdev=double(stdev(newdata[valid]))
	if stdev eq 0.0 then return,newdata[valid]
	num_stdev=abs(newdata-mean)/stdev

	if keyword_set(sigma) then begin
		badpoints=where(num_stdev gt sigma and goodflag,nbadpoints)
	endif else begin
		numexp=double(nvalid)*(1.0D0-gauss_pdf(num_stdev)+gauss_pdf(-num_stdev))
		badpoints=where(numexp lt 0.5 and goodflag,nbadpoints)
	endelse
	if nbadpoints ge 1 then goodflag[badpoints]=0
endwhile

return, newdata[valid]
end	
