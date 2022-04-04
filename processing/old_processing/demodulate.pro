function demodulate, nod_struct, data_struct, chopper, chop_period, $
                     rel_phase = rel_phase, diag = diag

nbolos = n_e(data_struct)
nnods = n_e(data_struct[0].nod)
npos = n_e(data_struct[0].nod[0].pos)
nodlen = nod_struct[0].pos[0].f - nod_struct[0].pos[0].i + 1

if not (keyword_set(rel_phase)) then $
  rel_phase = dblarr(nbolos)
t = dindgen(nodlen)

demod_cos = dblarr(nbolos,nnods,npos)
demod_sin = dblarr(nbolos,nnods,npos)

for i = 0,nnods-1 do begin
    for j=0,npos-1 do begin
        print,i,j
; For this nod and position, determine the phase of the chopper relative to
; the start of the nod position
        indx = lindgen(nodlen) + nod_struct[i].pos[j].i
        chop_phase = find_chop_phase(chopper[indx],chop_period) 
; Make up the synthetic chop
; Need to modify this to deal with different phases for each bolometer 
        synth_cos = cos(2.*!dpi/chop_period * t - chop_phase)
        synth_cos = synth_cos - mean(synth_cos)
        synth_sin = sin(2.*!dpi/chop_period * t - chop_phase)
        synth_sin = synth_sin - mean(synth_sin)
; Now rotate the phase appropriate for each bolometer ...
        chop_cos = (synth_cos#replicate(1.,nbolos)) * $
;          cos(tan(replicate(1.,nodlen)#(rel_phase))) + $
          cos(replicate(1.,nodlen)#(rel_phase)) + $
          (synth_sin#replicate(1.,nbolos)) * $
;          sin(tan(replicate(1.,nodlen)#(rel_phase)))
          sin(replicate(1.,nodlen)#(rel_phase))
        chop_sin = (-synth_cos#replicate(1.,nbolos)) * $
;          sin(tan(replicate(1.,nodlen)#(rel_phase))) + $
          sin(replicate(1.,nodlen)#(rel_phase)) + $
          (synth_sin#replicate(1.,nbolos)) * $
;          cos(tan(replicate(1.,nodlen)#(rel_phase)))
          cos(replicate(1.,nodlen)#(rel_phase))
; Extract the data
        temp = data_struct[*].nod[i].pos[j].time
; Mean subtract
;        temp = temp - replicate(1.d,nodlen)#(total(temp,1)/double(nodlen))
; Do the demodulation
        demod_cos[*,i,j] = $
          total(chop_cos*temp,1)/total(synth_cos^2)
        demod_sin[*,i,j] = $
          total(chop_sin*temp,1)/total(synth_cos^2)

; Now let's do some diagnosis
        if keyword_set(diag) then begin
            plot,temp[*,diag],/xst,title=$
              string('Nod',i,'Pos',j,'Chan',diag,format='(A4,I3,A4,I3,A5,I5)')
;            oplot,temp[*,diag+10],col=2
            oplot,demod_cos[diag,i,j]*chop_cos,col=2
;;        oplot,demod_cos[diag,i,j]*chop_cos,col=2
            oplot,temp[*,diag]-demod_cos[diag,i,j]*chop_cos,col=3
            blah = ''
            read,blah
        endif
    endfor
endfor

out = create_struct('demod_in',demod_cos,$
                    'demod_out',demod_sin)

return,out

end
