function find_nods, nodding

; This may not be necessary
nod = digital_deglitch(nodding)

nod_trans=find_transitions(nod)
n_trans_start=n_elements(nod_trans.rise)
n_trans_end=n_elements(nod_trans.fall)
; these had better be the same!
if(n_trans_start eq n_trans_end) then begin
    n_nods=n_trans_start
endif else begin
    print, 'Unequal number of nod starts and ends!'
    stop
endelse

temp = create_struct('i',0L,$
                     'f',0L,$
                     'sgn',0L)

; We're sort of always assuming a LRRL nodding ... so far, that's all we do
nod_pos_struct = replicate(temp,4)

temp = create_struct('i',0L, $
                     'f',0L, $
                     'pos',nod_pos_struct)

nod_struct = replicate(temp,n_nods)

for i=0,n_nods-1 do begin
    nod_struct[i].i = nod_trans.rise[i]
    nod_struct[i].f = nod_trans.fall[i]
endfor

return,nod_struct

end
