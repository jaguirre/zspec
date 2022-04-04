@run_zapex_one
@fivepoint_apex

;+
;NAME
; run_fivepoint_apex
;USAGE
; run_fivepoint_apex, scan, chop, [PROJ=proj, STEP=step]
;PURPOSE
; To reduce five-position Zspec pointing data at APEX
;INPUTS
; scan      The scan number of the pointing observation
; chop      The scan number of the obsrevation to get the
;            chopping information from.  For bright sources,
;            this can be one.
;OPTIONAL ARGUMENTS
; proj      The project this pointing is related to -- either
;            HERMES, ATLAS, or SPT
; step      Step size (def: 12)
;MODIFICATION HISTORY
; Author: Roxana Lupu, May 2011
; Dec 04 2012, Phil Korngut modified to bring out dx and dy
;

pro run_fivepoint_apex,scan,chop,proj=proj,step=step,dx=dx,dy=dy,bmx=bmx,bmy=bmy


obs=strtrim(string(scan),2)
chop_file=strtrim(string(chop),2)


if ~keyword_set(step) then step=12.
run_zapex_one,obs,chop_file,savfile=thisfile,proj=proj
fivepoint_apex,thisfile,step,dx=dx,dy=dy,bmx=bmx,bmy=bmy

end
