; NAME:                                                                                                                 
;    ZAPEX_CHECK_TIMESTAMPS
; PURPOSE:
;    Check either a backend netCDF file or a netCDF file that has
;    been converted from APEX/MBFITS for non-consecutive timestamps.
;    Return a boolean good/bad value as well as bad indices via keyword.
; INPUTS:
;    NCFILE = String of filename
; OPTIONAL OUTPUT KEYWORDS:
;      BAD_INDICES=indices where a timestamp has been missed
;      TIME=array of time samples
;      DT=derivative of TIME
; AUTHOR: Tom Downes (tpdownes@caltech.edu)
; DATE: December 2010

function zapex_check_timestamps, ncfile, bad_indices=bad_indices, $
                                 time=time, dt=dt

;; files converted from APECS MBFITS files have a variable named
;; 'telescope' set equal to 'APEX'. Files directly from ZSPECBE
;; do not have this variable. This is important because the IRIGB
;; timestamps are reduced in accuracy by the MBFITS writer, from
;; ~1E-6 seconds to ~1E-3 seconds.

ncid = ncdf_open(ncfile) 
tel_vid = ncdf_varid(ncid, 'telescope')
if tel_vid eq -1 then begin
    telescope = 'CSO'
endif else begin
    ncdf_varget, ncid, tel_vid, telescope
endelse 

if strcmp(telescope,'APEX') then begin
    vid = ncdf_varid(ncid, 'ticks')
    ncdf_varget, ncid, vid, time
    threshold = 2E-3
endif else if strcmp(telescope,'BEV1') then begin
    vid = ncdf_varid(ncid, 'timestampIRIGB')
    ncdf_varget, ncid, vid, iso_timestamps
        
    nsamples = n_elements(iso_timestamps[0,*])

    time = dblarr(nsamples)
    for j=0,nsamples-1 do begin
        tstampstr = string(iso_timestamps[*,j])
        tmp2 = strsplit(tstampstr, 'T', /extract)
        date = tmp2[0]
        tmp3 = strsplit(date,'-',/extract)
        year = long(tmp3[0])
        month = long(tmp3[1])
        day = long(tmp3[2])
        hms = tmp2[1]
        tmp4 = strsplit(hms,':',/extract)
        hour = tmp4[0]
        minute= tmp4[1]
        second = tmp4[2]
        time[j] = hour*3600d + minute*60. + second
    endfor
    threshold = 2E-6
end

ncdf_close, ncid

nsamples = n_elements(time)
dt = shift(time,-1) - time
dt = dt[0:nsamples-2]
mdndelta = median(dt)
diff = dt - mdndelta

good_indices = where(abs(diff) lt threshold, ngood, $
                     complement=bad_indices, ncomplement=nbad)
goodfile = nbad eq 0

if goodfile then begin
    message, ncfile + ' timestamps check out', $
      /continue
endif else begin
    message, ncfile + ' contains disparate timestamps', $
      /continue    
endelse

return, goodfile

END
