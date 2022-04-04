function linefit_func,P

common commonb, plotmars,ploturanus,plotnep,fitpars,$
  cal_total_sky,cal_total,vbolo_quad_total,bolo

goodmars=plotmars(where(cal_total_sky[bolo,plotmars] gt 0))
gooduranus=ploturanus(where(cal_total_sky[bolo,ploturanus] gt 0))
goodnep=plotnep(where(cal_total_sky[bolo,plotnep] gt 0))

summars=(cal_total_sky[bolo,goodmars[0]]-$
  (P[0]+P[1]*vbolo_quad_total[goodmars[0],bolo]))^2.

sumuranus=(cal_total_sky[bolo,gooduranus[0]]-$
  (P[2]*(P[0]+P[1]*vbolo_quad_total[gooduranus[0],bolo])))^2.

sumneptune=(cal_total_sky[bolo,goodnep[0]]-$
  (P[3]*(P[0]+P[1]*vbolo_quad_total[goodnep[0],bolo])))^2.

for i=1,n_e(goodmars)-1 do begin
    summars+=(cal_total_sky[bolo,goodmars[i]]-$
    (P[0]+P[1]*vbolo_quad_total[goodmars[i],bolo]))^2.
endfor

for i=1,n_e(gooduranus)-1 do begin
    sumuranus+=(cal_total_sky[bolo,gooduranus[i]]-$
    (P[2]*(P[0]+P[1]*vbolo_quad_total[gooduranus[i],bolo])))^2.
endfor

for i=1,n_e(goodnep)-1 do begin
    sumneptune+=(cal_total_sky[bolo,goodnep[i]]-$
    (P[3]*(P[0]+P[1]*vbolo_quad_total[goodnep[i],bolo])))^2.
endfor

return,summars+sumuranus+sumneptune

end
