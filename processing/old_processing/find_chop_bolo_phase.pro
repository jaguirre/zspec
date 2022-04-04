; Find the relative phase of the chopper and bolometers, assuming either
; 1) there is a large signal (i.e., Mars) or 
; 2) only use the chopper offset

function find_chop_bolo_phase, nod_struct, data_struct, chopper, chop_period

message,/info,'Assuming there is signal in timestream with which to phase up.'

nbolos = n_e(data_struct)
nnods = n_e(data_struct[0].nod)
npos = n_e(data_struct[0].nod[0].pos)
nodlen = nod_struct[0].pos[0].f - nod_struct[0].pos[0].i + 1

rel_phase = dblarr(nbolos)
t = dindgen(nodlen)

demod_cos = dblarr(nbolos,nnods,npos)
demod_sin = dblarr(nbolos,nnods,npos)

for i = 0,nnods-1 do begin
    for j=0,npos-1 do begin
; For this nod and position, determine the phase of the chopper relative to
; the start of the nod position
        indx = lindgen(nodlen) + nod_struct[i].pos[j].i
        chop_phase = find_chop_phase(chopper[indx],chop_period) 
; Make up the synthetic chop
        chop_cos = cos(2.*!dpi/chop_period * t - chop_phase)
        chop_cos = chop_cos - mean(chop_cos)
        chop_sin = sin(2.*!dpi/chop_period * t - chop_phase)
        chop_sin = chop_sin - mean(chop_sin)
; Extract the data
        temp = data_struct[*].nod[i].pos[j].time
; Mean subtract
;        temp = temp - replicate(1.d,nodlen)#(total(temp,1)/double(nodlen))
; Do the demodulation
        demod_cos[*,i,j] = $
          total((chop_cos#replicate(1.,nbolos))*temp,1)/total(chop_cos^2)
        demod_sin[*,i,j] = $
          total((chop_sin#replicate(1.,nbolos))*temp,1)/total(chop_sin^2)
    endfor
endfor

in_amp = (+ demod_cos[*,*,0] $
          - demod_cos[*,*,1] $
          - demod_cos[*,*,2] $
          + demod_cos[*,*,3])/4.

out_amp = (+ demod_sin[*,*,0] $
           - demod_sin[*,*,1] $
           - demod_sin[*,*,2] $
           + demod_sin[*,*,3])/4.

in_amp = total(in_amp,2)/nnods
out_amp = total(out_amp,2)/nnods

rel_phase = atan(out_amp, in_amp)

return,rel_phase

end
