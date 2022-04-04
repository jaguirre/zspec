function decorrscript, vopt, coeffs=coeffs, timestreams=timestreams

n_bolos=n_e(vopt)
n_nods=n_e(vopt[0].nod)
n_pos=n_e(vopt[0].nod[0].pos)
n_time=n_e(vopt[0].nod[0].pos[0].time)

coeffs=dblarr(n_bolos,n_nods, n_pos)
timestreams=dblarr(2,n_nods, n_pos, n_time)

for nod=0, n_nods-1 do begin
    for pos=0, n_pos-1 do begin

        a1=dblarr(n_time)
        a2=dblarr(n_time)
        for time=0, n_time-1 do begin
           
            
            sum=0
            for bolo=0, n_bolos/2 do $
              sum+=(vopt[bolo].nod[nod].pos[pos].time[time]-$
                    mean(vopt[bolo].nod[nod].pos[pos].time))
            
            a1[time]=sum/(n_bolos/2)

            sum=0
            for bolo=n_bolos/2+1, n_bolos-1 do $
              sum+=(vopt[bolo].nod[nod].pos[pos].time[time]-$
                    mean(vopt[bolo].nod[nod].pos[pos].time)) 
            
            a2[time]=sum/(n_bolos/2)
        endfor
        
        a1-=mean(a1)
        a2-=mean(a2)

        for bolo=0, n_bolos/2 do begin
            m=mean(vopt[bolo].nod[nod].pos[pos].time)
            alpha=total(a1*(vopt[bolo].nod[nod].pos[pos].time-m))/total(a1^2)
            vopt[bolo].nod[nod].pos[pos].time-=(alpha*a1)

            coeffs[bolo, nod,pos]=alpha
            
      endfor
      
      for bolo=n_bolos/2+1, n_bolos-1 do begin
          m=mean(vopt[bolo].nod[nod].pos[pos].time)
          alpha=total(a2*(vopt[bolo].nod[nod].pos[pos].time-m))/total(a2^2)
          vopt[bolo].nod[nod].pos[pos].time-=(alpha*a2)
          
          coeffs[bolo, nod,pos]=alpha
            
      endfor
      
      timestreams[0,nod,pos,*]=a1
      timestreams[1,nod,pos,*]=a2
    endfor
endfor

return, vopt

end
