;+
;===========================================================================
;  NAME:
;                  BLO_REPLACE_BUFFER
;
;  DESCRIPTION:
;                  Replace blo_labtool data buffer by new set of data
;
;
;
;  USAGE:
;                  blo_replace_buffer, cm, dtim, data, run_info, $
;                  sample_info, paramline, colname1, colname2
;
;  INPUT:
;     cm           pointer array to data structures
;     dtim         (array double) new x axis of data array
;     data         (array double) 2 dim data array
;     run_info     (string) first file header line with filename added in first pos.
;     sample_info  (string array) new sample info
;     paramline    (string array)  new parameter line
;     colname1     (string array)  new channel names
;     colname2     (string array) new channel units
;
;  OUTPUT:
;     cm           updated and graph redraw
;
;  KEYWORDS:
;                  none
;
;  AUTHOR:
;                  Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  11/10/2002  B. Schulz  initial test version
;  11/11/2002  B. Schulz  time copied to data channel 0
;  27/01/2003  B. Schulz  xtitle handling removed
;  2003/01/29  B. Schulz  parameter passing via strarr only
;  2003/03/14  B. Schulz  fill in errors
;  2003/10/08  L. Zhang   add a filename desciption to the widget labl0
;  2004/07/19  B. Schulz  time offset support added
;
;
;===========================================================================
;-
pro blo_replace_buffer, cm, dtim, data, run_info, $
                        sample_info, paramline, colname1, colname2

flag = reform(byte(data) * 0)        ;create flag array
unct = reform(data * 0.)             ;create error array

filename=run_info[0]    ;remove filename in first position
run_info=run_info[1:n_elements(run_info)-1]

ix = where(strpos(colname1, 'ERR') EQ 0,cnt)

if cnt GT 0 then begin          ;find errors
  ix = where(strpos(colname1, 'ERR') EQ -1,cnt)
  for i=0, n_elements(ix)-1 do begin
    iy = where(strtrim(colname1,2) EQ 'ERR '+strtrim(colname1[i],2),cnt)
    if cnt GT 0 then unct[i,*] = data[iy[0],*]
  endfor
endif

data(0,*) = dtim                     ;update time in channel 0

PtsPerChan = n_elements(data(0,*))   ;final number of points per channel
paramline(0) = string(PtsPerChan)    ;update also header parameter line
ScanRateHz  = long(paramline[1])  ;scan rate in [Hz]
SampleTimeS = long(paramline[2])  ;Sample time in [s]

ptr_free, *(cm(1))
*(cm(1)) = ptr_new(temporary({run_info:run_info, sample_info:sample_info, $
  colname1:colname1, colname2:colname2, paramline:paramline, PtsPerChan:PtsPerChan, $
   ScanRateHz:ScanRateHz, SampleTimeS:SampleTimeS, $
   dtim:dtim, data:data, unct:unct, flag:flag}))

((*cm(0))).scale = 0                           ;reset scaling
((*cm(0))).disp  = 0                           ;reset display
((*cm(0))).cur_chan = 1                        ;set first default channel
cch = ((*cm(0))).cur_chan                      ;set copy just to be safe

if dtim[0] GT 1e9 then begin      ;define time offset for display
  (*cm[0]).xoffset = dtim[0]
  (*cm[0]).xoffstr = tai2utc(dtim[0],/ECS)
endif else begin
  (*cm(0)).xoffset=0                             ;reset time offset
  (*cm(0)).xoffstr=''                            ;reset time offset
endelse

widget_control, (*cm(2)).slid, $          ;set new slider range
    set_slider_max=n_elements(data(*,0))-1, set_value = 1


; LZ 10/8/03 Add a filename description

widget_control, (*cm(2)).labl0, $          ;change description
        set_value='File Name: ' + filename, /dynamic_resize

Txt=' '
for i=0, n_elements(run_info)-1 do begin
   txt=txt+ run_info[i]+ ' '
endfor
;widget_control, (*cm(2)).labl, $          ;change description
;        set_value=strmid(blo_tabstrcat(run_info),0,80), /dynamic_resize
widget_control, (*cm(2)).labl, $          ;change description
        set_value=txt, /dynamic_resize

widget_control, (*cm(2)).labl1, $         ;change description
    set_value= 'Channel: '+(**(cm(1))).colname1(cch) + $
   ' ' + (**(cm(1))).colname2(cch)  ,$
    /dynamic_resize

blo_redraw, cm(0), *(cm(1))

return
end
