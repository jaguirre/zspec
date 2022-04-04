FUNCTION freqid2squarebw,freqid

; the below used to generate the lookup table which is now  used as
; the function

;freq=freqid2freq()
;squarebw=fltarr(160)
;for i=1,n_elements(squarebw)-2 do begin
;    squarebw[i]=0.5*(freq(i+1)-freq(i-1))
;end
;squarebw[0]=squarebw[1]+(freq(0)-freq(1))*$
;  (squarebw[2]-squarebw[1])/(freq(2)-freq(1))
;squarebw[159]=squarebw[158]+(freq(159)-freq(158))*$
;  (squarebw[157]-squarebw[158])/(freq(157)-freq(158))
;set_plot,'ps'
;device,/color,filename='squarebw.eps',/encapsulated
;plot,freq,squarebw,/yno,psym=6,xtitle='Frequency',ytitle='Square BW',/ylog,/xst,/yst,symsize=0.5
;for j=0,7 do begin
;oplot,freq[j*20]*[1,1],[1e-1,10],color=3,thick=3
;oplot,freq[(j+1)*20-1]*[1,1],[1e-1,10],color=2,thick=3
;end

;device,/close & set_plot,'x'

;stop


squarebw=[$
  0.414078,    0.444504,     0.474998,     0.483498,     0.473503,     0.457497,     0.423500,     0.436005,$
     0.473999,     0.468002,     0.460999,     0.484993,     0.471504,     0.489006,     0.485497,     0.440498,$
     0.441498,     0.498001,     0.565506,     0.587997,     0.547997,     0.489502,     0.512505,     0.513000,$
     0.519997,     0.531998,     0.513496,     0.503502,     0.561005,     0.556999,     0.486000,     0.524498,$
     0.539497,     0.546501,     0.549004,     0.537003,     0.553497,     0.549995,     0.587502,     0.686005,$
     0.647499,     0.575500,     0.555000,     0.564499,     0.575500,     0.572502,     0.577499,     0.595497,$
     0.639999,     0.584496,     0.582504,     0.618500,     0.610992,     0.616005,     0.606003,     0.617500,$
     0.630501,    0.628998,     0.661499,     0.720497,     0.718498,    0.670502,     0.632500,     0.625999,$
     0.646004,    0.634003,     0.674500,     0.680496,     0.639999,     0.652000,     0.660004,     0.670502,$
     0.690498,    0.700500,     0.692497,     0.678497,     0.691498,     0.703506,     0.727501,     0.854500,$
     0.827003,    0.736000,     0.729996,     0.723495,     0.737007,     0.748505,     0.746498,     0.752998,$
     0.750496,    0.750000,     0.783005,     0.797997,     0.800499,     0.775002,     0.774002,     0.803001,$
     0.811493,    0.807999,     0.833504,     0.946503,     0.948997,     0.829994,     0.799004,     0.814507,$
     0.822502,    0.836494,     0.838997,     0.828506,     0.850998,     0.867493,     0.877998,     0.872009,$
     0.850998,   0.862488,     0.870499,     0.916000,     0.959000,    0.900009,     0.933014,     1.09900,$
      1.07700,   0.959991,     0.961990,     0.951004,     0.947006,     0.972504,     0.954498,     0.9734954,$
      1.00751,    1.01450,      1.03999,      1.01901,      1.00850,      1.03650,      1.04401,      1.05449,$
      1.04500,    1.07350,     1.16150,      1.27051,      1.21950,      1.11450,     1.07350,      1.01900,$
      1.12000,      1.10449,      1.02951,      1.13850,      1.11299,      1.07500,      1.11900,      1.10851,$
      1.19299,      1.17000,      1.18600,      1.17351,      1.11000,      1.19749,      1.26900,     1.34673 $
]

case n_params() of 
    0: return,squarebw
    1: return,squarebw[freqid]
    ELSE: MESSAGE, 'What Bandwidths ?'
endcase
;stop
end