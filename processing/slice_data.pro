; Take a 160 x ntod timestream data and slice it up
;
; HISTORY 01 SEP 06 BN Added flag slicing, 
;                      flag & coeff elements to base structure
;                      eliminated mean subtraction & psd creation
;         05 SEP 06 BN made flags optional & added JUST_DATA
;                      keyword to just slice data without other
;                      elements in structure.

function slice_data, nod_struct, timestream, flags, $
                     JUST_DATA = JUST_DATA
ntod = n_e(timestream[0,*])
nbolos = n_e(timestream[*,0])
nnods = n_e(nod_struct)
npos = n_e(nod_struct[0].pos)
nodlen = nod_struct[0].pos[0].f - nod_struct[0].pos[0].i + 1
nfreq = N_E((psd(FINDGEN(nodlen))).freq)
; This is the highest order polynomial we'll allow to be subtracted off
; This isn't very elegant, but I (BN) think it's the only sensible option.
max_poly_order = 10

IF KEYWORD_SET(JUST_DATA) THEN BEGIN
   pos = create_struct('time',DBLARR(nodlen))
ENDIF ELSE BEGIN
; This bit will need things added to it
   pos = create_struct('time',DBLARR(nodlen),$
                       'flag',INTARR(nodlen),$
                       'coeff',DBLARR(max_poly_order+1), $
                       'freq',DBLARR(nfreq), $ ; This is mondo redundant
                       'psd_raw',DBLARR(nfreq)) 
ENDELSE

temp = create_struct('pos',replicate(pos,npos))
nod = replicate(temp,nnods)
temp = create_struct('nod',nod)
chan = replicate(temp,nbolos)

t = dindgen(nodlen)

for i=0,nbolos-1 do begin
    for j = 0,nnods-1 do begin
        for k = 0,npos-1 do begin
            chan[i].nod[j].pos[k].time = $
               timestream[i,nod_struct[j].pos[k].i:nod_struct[j].pos[k].f]
            ; If flags parameter not present, then don't chop it up
            IF (N_PARAMS() EQ 3) AND ~(KEYWORD_SET(JUST_DATA)) THEN BEGIN
               chan[i].nod[j].pos[k].flag = $
                  flags[i,nod_struct[j].pos[k].i:nod_struct[j].pos[k].f]
            ENDIF
        endfor
    endfor
endfor

return, chan

end
