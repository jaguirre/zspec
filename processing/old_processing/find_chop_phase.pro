function find_chop_phase, chopper, chop_period, ampl = ampl

n = n_e(chopper)
t = dindgen(n)

; Make up artifical waveforms
c1 = cos(2.*!dpi/chop_period * t)
s1 = sin(2.*!dpi/chop_period * t)

c3 = cos(3.*2.*!dpi/chop_period * t)
s3 = sin(3.*2.*!dpi/chop_period * t)

c5 = cos(5.*2.*!dpi/chop_period * t)
s5 = sin(5.*2.*!dpi/chop_period * t)

c1fit = total(c1 * chopper)/total(c1 * c1)
s1fit = total(s1 * chopper)/total(s1 * s1)

c3fit = total(c3 * chopper)/total(c3 * c3)
s3fit = total(s3 * chopper)/total(s3 * s3)

c5fit = total(c5 * chopper)/total(c5 * c5)
s5fit = total(s5 * chopper)/total(s5 * s5)

a1 = sqrt(c1fit^2 + s1fit^2)
p1 = atan(s1fit , c1fit)

a3 = sqrt(c3fit^2 + s3fit^2)
p3 = atan(s3fit , c3fit)

a5 = sqrt(c5fit^2 + s5fit^2)
p5 = atan(s5fit , c5fit)

;plot,chopper
;
;composite = a1*cos(2.*!dpi/chop_period * t - p1) + $
;  a3*cos(3.*2.*!dpi/chop_period * t - p3) + $
;  a5*cos(5.*2.*!dpi/chop_period * t - p5)
;
;
return,p1

end
