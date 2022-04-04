function decorr, vopt, coeffs=coeffs

n_bolos=n_e(vopt)
n_nods=n_e(vopt[0].nod)
n_pos=n_e(vopt[0].nod[0].pos)
n_time=n_e(vopt[0].nod[0].pos[0].time)

coeffs=dblarr(n_nods, n_pos, n_time)

for nod=0, n_nods-1 do begin
    for pos=0, n_pos-1 do begin

        a=dblarr(n_time)
        for time=0, n_time-1 do begin
            
            sum=0
            
            for bolo=0, n_bolos-1 do begin
                sum+=vopt[bolo].nod[nod].pos[pos].time[time]      
            endfor

            a[time]=sum/n_bolos
        endfor

        for bolo=0, n_bolos-1 do begin
            alpha=total(a*vopt[bolo].nod[nod].pos[pos].time)/total(a^2)
            vopt[bolo].nod[nod].pos[pos].time-=(alpha*a)
      endfor

      coeffs[nod,pos,*]=a
    endfor
endfor

return, vopt

end
