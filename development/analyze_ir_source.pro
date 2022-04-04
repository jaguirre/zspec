pro analyze_ir_source, ncdf_file, modfreq, labels

load_plot_colors

; Starting from a ncdf_file, analyze

; This bit is a module that should be pulled out, since it's common to
; all our dealings with test data

goodbolos = intarr(160)+1
goodbolos[81] = 0.

flag = read_ncdf(ncdf_file,'nodding')
bolos = read_ncdf(ncdf_file,'ac_bolos')
ntod = n_e(bolos[0,*])
; Unbelievable
t = read_ncdf(ncdf_file,'ticks')
si = find_sample_interval(t)

; Slice out the useful data
trans = find_transitions(flag)

npos = n_e(trans.rise)
;if npos ne 4 then message,'Seriously?  What are you doing?'

;stop

sig = dblarr(160,npos)

for i=0,npos-1 do begin

   for j=0,160-1 do begin
      
      p = psd(deglitch(bolos[j, trans.rise[i] : trans.fall[i]],/QUIET), $
              samp = si)

      sig[j,i] = max(p.psd[where(p.freq ge modfreq - 0.1 and $
                                 p.freq le modfreq + 0.1)])
      

      if (j eq 100) then begin
         plot_oo,p.freq[1:*],p.psd[1:*],/xst,/yst,yr=[1.d-7,1.d-1]
         plots,modfreq,sig[j,i],psy=1,col=2
         blah = ''
         read,blah
      endif

 
   endfor

endfor

nu = freqid2freq()

detmax = sig * (goodbolos#replicate(1.,npos))

cols = lonarr(npos)
for i=0,npos-1 do cols[i] = !cols.(i)

plot,nu,sig[*,0]/goodbolos,/xst,psy=10,col=cols[0],$
     xtit='Frequency (GHz)',ytit='V RMS',/yst,$
  yr=[0,max(detmax)*1.5],tit=ncdf_file

for i=1,npos-1 do begin

   oplot,nu,sig[*,i]/goodbolos,psy=10,col=cols[i]

endfor

;stop

legend,labels,textcol=cols,charsize=3

print,'DC Levels'
for i=0,npos-1 do print,mean(bolos[100,trans.rise[i]:trans.fall[i]])

;stop

end
