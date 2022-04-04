function datadiscard_multi,indata,sigma=sigma,bounds=bounds

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
;040408 GL - added multi keyword, bounds keyword

;error check sizes
sz_data=size(indata,/dim)
if n_elements(sz_data) ne 2 then message,'ERROR: INDATA must be 2-dimensional'

;error check bounds keyword 
if keyword_set(bounds) then begin
	sz_bounds=size(bounds,/dim)
	if n_elements(sz_bounds) ne 2 then message,'ERROR: BOUNDS keyword must have 2-dimensions'
	if (sz_bounds[1] ne 2 or sz_bounds[0] ne sz_data[0]) then message,'ERROR: BOUNDS keyword must have n_params x 2 elements'
endif		

n_params=n_elements(indata[*,0])
goodflag_multi=replicate(1,n_elements(indata[0,*]))

nbadpoints=1
while(nbadpoints eq 1) do begin
	nbadpoints=0
	for i_param=0L,n_params-1L do begin
		good_index=where(goodflag_multi)
		dummy=datadiscard(indata[i_param,good_index],goodflag=goodflag_temp,sigma=sigma,bounds=reform(bounds[i_param,*]))
		badpoints=where(goodflag_temp eq 0,nbadpoints_temp)
		if nbadpoints_temp gt 0 then begin
			goodflag_multi[good_index[badpoints]]=0		
			nbadpoints=1
		endif
	endfor
endwhile

return,goodflag_multi
end
