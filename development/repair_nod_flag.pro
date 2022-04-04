;Feb 2009, LE

;Sometimes a malinged observation is unable to get 
;demodulated because of an 'Unequal number of nod 
;starts and ends' error during find_nods.  
;
;It appears that this 
;problem is most often caused by the nod flag 
;failing to go low at the end of the final nod,
;or a nod flag starting high at the beginning of 
;an observation. 
;
;This is my kluge attempt at manually correcting 
;the nodding variable that is read from the 
;netCDF file so that find_nods can do its thing.
;
;This function is used by read_ncdf so that when
;read_ncdf is used to read in the 'nodding' value,
;it automatically looks for and corrects this 
;problem.

function repair_nod_flag, nodflags

;_____________________________________________________________________
;find out where nods are 

len=n_e(nodflags)

initial_flag=nodflags[0]
final_flag=nodflags[len-1]

low_ind=where(nodflags eq 0)
high_ind=where(nodflags eq 1)

;how long is each nod?
result=find_contiguous(high_ind)
nodlen=result.f-result.i+1

;how many nods are there?
nnods=n_e(nodlen)

;what is the shortest nod?
shortnodlen=min(nodlen)

;what is the length of the first nod?
firstnodlen=nodlen[0]

;what is the length of the final nod?
lastnodlen=nodlen[nnods-1]

if initial_flag eq 1 then begin

;    case 1 of 
;        firstnodlen gt shortnodlen: begin
            nodflags[0:4]=0
;        end
;        firstnodlen le shortnodlen: begin
;            ;what is the shortest complete nod?
;            shortcompletelen=min(nodlen[1:nnods-1])
;            ;is the first nod shorter by more than 50 samples?
;            if firstnodlen+50 lt shortcompletelen then begin
;                ;in that case throw out the whole nod
;                tempind=result.f
;                nodflags[0:tempind[0]]=0
;            endif else begin
;                ;otherwise just set the first 5 flags to 0
;                nodflags[0:4]=0
;            endelse
;        end
;    endcase

endif

if final_flag eq 1 then begin
    
;    case 1 of
;        lastnodlen gt shortnodlen: begin
            nodflags[len-5:len-1]=0
;        end
;        lastnodlen le shortnodlen: begin
;            ;what is the shortest complete nod?
;            shortcompletelen=min(nodlen[0:nnods-2])
;            ;is the last nod shorter by more than 50 samples?
;            if lastnodlen+50 lt shortcompletelen then begin
;                ;in that case throw out the whole nod
;                tempind=result.i
;                nodflags[tempind[n_e(tempind)-1]:len-1]=0
;            endif else begin
;                ;otherwise just set the last flag to 0
;                nodflags[len-5:len-1]=0
;            endelse
;       end
;    endcase

endif

return, nodflags

end
