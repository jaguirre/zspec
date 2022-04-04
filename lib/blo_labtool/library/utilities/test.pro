
pro test
t1 = indgen(25)*0.2

t2 = indgen(10)*1.0+1.1

a2 = sin(t1*0.4*!PI)
;stop
bolo_time_expnd, t1, t2, ixout

a1 = a2[ixout]

plot, t2, a2, psym=5, symsize=0.5, yrange=[0,1.1], ystyle=3, xrange=[-5,9]
oplot, t1, a1, psym=4
end