;Feb 2009, LE

;Sometimes a malinged observation is unable to get 
;demodulated because of an 'Unequal number of nod 
;starts and ends' error during find_nods.  
;
;It appears that this 
;problem is most often caused by the nod flag 
;failing to go low at the end of the final nod.  
;
;This is my kluge attempt at manually correcting 
;the nodding variable that is read from the 
;netCDF file so that find_nods can do its thing.
;
;This function is used by read_ncdf so that when
;read_ncdf is used to read in the 'chopper' value,
;it automatically looks for and corrects this 
;problem.

function repair_final_nod_flag, nodflags

;_____________________________________________________________________
;find out where nods are 

low_start=[0]
high_start=[0]

	i=0L
	keep_going=1
	
	while i lt n_e(nodflags) do begin   

		while nodflags[i] eq 0 do i+=1
		high_start=[high_start,i]

	        while  (nodflags[i] eq 1 and keep_going eq 1) do begin    

	           case 1 of 
	           	i lt n_e(nodflags)-1: i+=1
	           	i eq n_e(nodflags)-1: begin
		                keep_going=0
				;print,'keep_going is now 0'
				;print,i
				end
	           endcase

	        endwhile
	   
	        if keep_going eq 1 then low_start=[low_start,i] else $
	           i=n_e(nodflags)

	     ;print,low_start

	endwhile
	
	high_start=high_start[1:n_e(high_start)-1]

;______________________________________________________________________________
;find out how long the nods are

;the number of complete nods is one less than the number of high starts
;(this of course is the problem)

	n_complete_nods=n_e(high_start)-1

;count length of nods
	
	nodlen=intarr(n_complete_nods+1)
	for j=0,n_e(nodlen)-2 do begin
		nodlen[j]=low_start[j+1]-high_start[j]
	endfor

;_____________________________________________________________________________
;now decide where to set the flag back to low

;if the final string of high flags is longer than the shortest complete
;nod before it, then it will set the length of the final nod to be the
;same as the length of the shortest nod.

;if the final string of high flags is shorter than the shortest nod, then
;it will check to see if its still within a reasonable length for a complete 
;nod (i.e. is the number of high flags within 50 samples of the shortest nod
;length?)  If so, it will set the final flag to zero to end the nod. If not,
;it will scrap this nod completely.

minnod=min(nodlen[0:n_complete_nods-1])
final_string_len=n_e(nodflags)-high_start[n_e(high_start)-1]

if final_string_len gt minnod then begin

	nodlen[n_complete_nods]=minnod
	final_low_ind=$
		high_start[n_e(high_start)-1]+nodlen[n_complete_nods]
	low_start=[low_start,final_low_ind]
	nodflags[final_low_ind:n_e(nodflags)-1]=0

endif

if final_string_len le minnod then begin

	if minnod-final_string_len le 50 then begin
		nodlen[n_complete_nods]=final_string_len-1
		final_low_ind=n_e(nodflags)-1
		low_start=[low_start,final_low_ind]
		nodflags[final_low_ind]=0
	endif else begin
		nodflags[high_start[n_e(high_start)-1]:$
			n_e(nodflags)-1]=0
	endelse

endif

;print,'final_string_len is'
;print,final_string_len

return,nodflags


end



