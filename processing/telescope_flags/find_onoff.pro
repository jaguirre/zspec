; HISTORY: 2006_08_25 BN Added in flagging
;          2006_11_01 BN Handling of flickering within on/off beam

function find_onoff, nod_struct_in, on_beam, off_beam, acquired, $
                     dataflags, diagnostic = diagnostic,vr,vi

nod_struct = nod_struct_in
nnods = n_e(nod_struct)
npos = n_e(nod_struct[0].pos)

goodmask = INTARR(N_E(on_beam))

; This is specific to LRRL nodding ...
for i = 0,nnods-1 do begin

    on = $
      digital_deglitch((on_beam*acquired)[nod_struct[i].i : nod_struct[i].f])
    off = $
      digital_deglitch((off_beam*acquired)[nod_struct[i].i : nod_struct[i].f])

    on_secs = find_contiguous(where(on eq 1))
    off_secs = find_contiguous(where(off eq 1))
    
    goodmask[nod_struct[i].i+WHERE(on EQ 1)] = 1
    goodmask[nod_struct[i].i+WHERE(off EQ 1)] = 1

    ;; Check "ON" positions
    if (n_e(on_secs) ne 2) then begin
       message,/info,'Nod '+strcompress(i,/rem)+$
               ', "ON" positions are anomalous'

       ;; Split on in half to see where the problem lies
       non = N_ELEMENTS(on)
       firston = on[0:non/2L]
       firston_secs = find_contiguous(WHERE(firston EQ 1))
       nf_secs = N_E(firston_secs)
       laston = on[non/2L + 1:*]
       laston_secs = find_contiguous(WHERE(laston EQ 1))
       laston_secs.i += N_E(firston)
       laston_secs.f += N_E(firston)
       nl_secs = N_E(laston_secs)

       ;; Check that all of the sections have been recovered
       IF ((nf_secs + nl_secs) NE N_E(on_secs)) THEN $
          MESSAGE,'I cannot solve this problem - Help me.'

       ;; Fix gaps in first "ON" position
       MESSAGE, /INFO, 'Checking first on beam'
       fixed_section = fix_sections(firston_secs)
       IF fixed_section.i EQ -1 THEN $
          MESSAGE,'Unable to fix first "ON" position - check flags' $
       ELSE on_secs[0] = fixed_section
       
       ;; Fix gaps in second "ON" position
       MESSAGE, /INFO, 'Checking second on beam'
       fixed_section = fix_sections(laston_secs)
       IF fixed_section.i EQ -1 THEN $
          MESSAGE,'Unable to fix second "ON" position - check flags' $
       ELSE on_secs[1] = fixed_section
    ENDIF

    ; Check "OFF" position
    if (n_e(off_secs) ne 1) then begin
       message,/info,'Nod '+strcompress(i,/rem)+$
               ', "OFF" position is anomalous'
       fixed_section = fix_sections(off_secs)
       IF fixed_section.i EQ -1 THEN $
          MESSAGE,'Unable to fix "OFF" position - check flags' $
       ELSE off_secs = fixed_section
    ENDIF

; The number of data points in the off beam
    noff = off_secs[0].f - off_secs[0].i + 1

; Feels like there should be a more general way of doing this ...
    nod_struct[i].pos[0].i = nod_struct[i].i + on_secs[0].i
    nod_struct[i].pos[0].f = nod_struct[i].i + on_secs[0].f
    nod_struct[i].pos[0].sgn = 1

    nod_struct[i].pos[1].i = nod_struct[i].i + off_secs[0].i
    nod_struct[i].pos[1].f = nod_struct[i].i + off_secs[0].i + noff/2L
    nod_struct[i].pos[1].sgn = -1

    nod_struct[i].pos[2].i = nod_struct[i].i + off_secs[0].i + noff/2L + 1
    nod_struct[i].pos[2].f = nod_struct[i].i + off_secs[0].f
    nod_struct[i].pos[2].sgn = -1

    nod_struct[i].pos[3].i = nod_struct[i].i + on_secs[1].i
    nod_struct[i].pos[3].f = nod_struct[i].i + on_secs[1].f
    nod_struct[i].pos[3].sgn = 1

 ENDFOR

; Make dataflags an optional argument.  If not present, print message.
IF N_PARAMS() EQ 5 THEN BEGIN
   dataflags = apply1dmask(goodmask, dataflags)
ENDIF ELSE BEGIN
   MESSAGE, /INFO, 'No dataflags argument given, ' + $
            'goodmask not applied or saved.'
ENDELSE
 
if (keyword_set(diagnostic)) then begin
    set_plot,'ps'
    device,file=diagnostic,/color
    DEVICE,/LANDSCAPE,/INCHES,$
           XOFFSET=0.5,XSIZE=10,$
           YOFFSET=10.5,YSIZE=7.5
    thck=!p.thick
    !p.thick=3
    chthck=!p.charthick
    !p.charthick=2
    
    
     x = lindgen(nod_struct[nnods-1].f - nod_struct[0].i + 1) + nod_struct[0].i
       plot,acquired+0.05,/yst,$
            yr=[-0.3,1.2],xs=1,$
            title='All Nods',$
         xthick=2,ythick=2
       oplot,on_beam+.15,col=2
       oplot,off_beam-.15,col=3
       oplot,goodmask-.05,col=5
       oplot,(vr(100,*)-mean(vr(100,*)))*20,line=1
       oplot,(vi(100,*)-mean(vi(100,*)))*20,line=1,col=2

       ;; Add labels
       labx = noff/20.
       XYOUTS, labx, 1.1, '"ON" position', COLOR = 2
       XYOUTS, labx, 1.0, 'Acquired'
       XYOUTS, labx, 0.9, 'Good Mask', COLOR = 5
       XYOUTS, nod_struct[0].pos[1].i + noff/20., 0.8, $
               '"OFF" position', COLOR = 3

;       labx -= noff/60.
;       OPLOT, [labx,labx], [0.68,0.75], COLOR = 4, LINE = 1
;       XYOUTS, labx+noff/80., 0.7, 'Nod Position Start', COLOR = 4
;       OPLOT, [labx,labx], [0.58,0.65], COLOR = 4, LINE = 5
;       XYOUTS, labx+noff/80., 0.6, 'Nod Position End', COLOR = 4;


   FOR i = 0,nnods-1 DO BEGIN

       x = lindgen(nod_struct[i].f - nod_struct[i].i + 1) + nod_struct[i].i
       plot,x,acquired[nod_struct[i].i : nod_struct[i].f]+0.05,xst=2,/yst,$
            xr=[min(x),max(x)],yr=[-0.3,1.2],$
            title='Nod # ' + STRING(i,F='(I0)'),$
         xthick=2,ythick=2
       oplot,x,on_beam[nod_struct[i].i : nod_struct[i].f]+.15,col=2
       oplot,x,off_beam[nod_struct[i].i : nod_struct[i].f]-.15,col=3
       oplot,x,goodmask[nod_struct[i].i : nod_struct[i].f]-.05,col=5
       oplot,x,(vr[100,nod_struct[i].i : nod_struct[i].f]-mean(vr(100,*)))*20,line=1
       oplot,x,(vi[100,nod_struct[i].i : nod_struct[i].f]-mean(vi(100,*)))*20,line=1,col=2
       for pl=0,3 do oplot,[1,1]*nod_struct[i].pos[pl].i,[-1,2],col=4,line=1
       for pl=0,3 do oplot,[1,1]*nod_struct[i].pos[pl].f,[-1,2],col=4,line=5

       ;; Add labels
       labx = nod_struct[i].pos[0].i + noff/20.
       XYOUTS, labx, 1.1, '"ON" position', COLOR = 2
       XYOUTS, labx, 1.0, 'Acquired'
       XYOUTS, labx, 0.9, 'Good Mask', COLOR = 5
       XYOUTS, nod_struct[i].pos[1].i + noff/20., 0.8, $
               '"OFF" position', COLOR = 3

       labx -= noff/60.
       OPLOT, [labx,labx], [0.68,0.75], COLOR = 4, LINE = 1
       XYOUTS, labx+noff/80., 0.7, 'Nod Position Start', COLOR = 4
       OPLOT, [labx,labx], [0.58,0.65], COLOR = 4, LINE = 5
       XYOUTS, labx+noff/80., 0.6, 'Nod Position End', COLOR = 4

       legend, /bottom, /left, [string(nod_struct[i].pos.i,format='(4I10)'),$
                                string(nod_struct[i].pos.f,format='(4I10)')]

       
   ENDFOR
   
   !p.thick=thck
   !p.charthick=chthck

   device,/close
   set_plot,'x'
endif

return,nod_struct

end
