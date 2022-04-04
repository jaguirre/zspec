@focus_apex

;+
; NAME
;  run_focus_apex
; PURPOSE
;  To reduce a Zspec focus observation at APEX
; USAGE
;  run_focus_apex, scans, chop, [ /FX, /FY, /FZ, PROJ=proj,
;          SOURCE=source, DATE=date ]
; INPUTS
;  scans     The list of focus scans (array of 5 scan numbers)
;  chop      The scan number to take the chop values from
; REQUIRED KEYWORDS
;  /FX, /FY, /FZ One of these must be set, specifying which axis
;     to use and the focus offsets
; REQUIRED INPUTS
;  PROJ      The project in use (either 'ATLAS', 'SPT', or 'HERMES'
; OPTIONAL INPUTS
;  SOURCE    The name of the source
;  DATE      Which date the scan was on in ymd format (i.e., 20110411)
; NOTES
;  If you use non-standard focus offsets, you can't use this program.
;  The values are hardwired to [-2,-1,0,1,2] for /FX, /FY, and
;  [-1.2,-0.6,0,0.6,1.2] for /FZ    
;-

pro run_focus_apex,scans,chop,fx=fx,fy=fy,fz=fz,proj=proj,$
                   source=source,date=date

if keyword_set(fx) then begin 
    off=[-2.,-1.,0.,1.,2]
    dir='z'
endif else if keyword_set(fy) then begin
    off=[-2.,-1.,0.,1.,2]
    dir='y'
endif else if keyword_set(fz) then begin
    off=[-1.2,-0.6,0.,0.6,1.2]
    dir='z'
endif else begin
    MESSAGE,"You must set one of /fx, /fy, /fz"
endelse

nf=n_e(scans)
use=1

if ~keyword_set(date) then date=20110000
if ~keyword_set(source) then source='FOCUS'

filename='focus_'+strtrim(string(date),1)+dir+'.txt'
openw,1,'/home/zspec/zspec_svn/processing/spectra/coadd_lists/'+filename
printf,1,source
printf,1,''
printf,1,0.0
printf,1,''
for j=0,nf-1 do begin
printf,1,date,scans(j),use,chop
endfor
close,1




focus_apex,filename,off,proj=proj

end
