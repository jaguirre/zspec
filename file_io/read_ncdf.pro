function read_ncdf, filename, varname, count=count, offset=offset,$
	no_nod_flag_fix=no_nod_flag_fix

;*************************************************************
;MODIFIED BY LE 20090226
;
;When reading in the 'nodding' flags, it will automatically 
;check the initial and final nod flags to see if nodding begins 
;low and then resets to low (as it 
;should.)  If not, it will correct the problem using the 
;function 'REPAIR_NOD_FLAG.PRO,' which currently lives in the 
;development directory.
;
;Using the keyword NO_NOD_FLAG_FIX will override this default
;and return the 'nodding' vector exactly as it is recorded 
;in the netCDF file
;
;************************************************************
;
; An attempt to make some reasonable netcdf file reader, instead of
; the god-forsaken mess that Bolocam has.

; Should make varname and filename able to be vectors ...

; Do some error checking
; Make sure the file exists
if (file_test(filename)) then begin
    
; This can crash if it's not a valid ncdf file - how to test for that?
    cdfid = ncdf_open(filename)
    varid = ncdf_varid(cdfid,varname)
    if (varid ne -1) then begin
; See if it's a valid variable name, and if there's anything in it
        varinq = ncdf_varinq(cdfid,varid)
        dimid = ncdf_dimid(cdfid,'time')
        ncdf_diminq,cdfid,dimid,name,size

        if (size gt 0) then begin
            ncdf_varget, cdfid, count=count, offset=offset, varname, value
        endif else begin
            message,/info,'Time variable is zero in ncdf file.'
            value = -1
        endelse

        ncdf_close,cdfid

;**************************************************************
;MODIFIED BY LE 20090226
;
;Lieko's kluge to correct 'unequal number of nod starts 
;and ends' problem 

        if ~keyword_set(no_nod_flag_fix) then begin
            
            if varname eq 'nodding' then begin
                
                if value[n_e(value)-1] eq 1 then begin
                    print,$
                      'using REPAIR_NOD_FLAG because final flag is high' 
                    value=repair_nod_flag(value)
                endif 
                
                if value[0] eq 1 then begin
                    print,$
                      'using REPAIR_NOD_FLAG because initial flag is high'
                    value=repair_nod_flag(value)
                endif
                
            endif
            
        endif
;*************************************************************
    endif else begin

        message,/info,'Variable does not exist.'
        value = -1 

    endelse

endif else begin
    
    message,/info,'File does not exist.'
    value = -1
    
endelse

return, value

end
