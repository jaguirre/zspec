pro view_corr,file

; MB 25 July 2011: a script to view the correlation, one channel at a
; time.   Argument is the directory (usually the source) and filename 
; of the sav file with the data.

restore,!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+file
avespec_corr=calculate_corr(uber_spectra)
print,'computing correlation for nod error'
psderror_corr=calculate_corr(uber_psderror)
print,'computing correlation for psderror'
freqs=freqid2freq()
for i=0,159 do begin
    temp2=avespec_corr.in1.corr[i,*]
    temp1=psderror_corr.in1.corr[i,*]
    plot,freqs,temp1,title='Channel '+string(i)+', '+string(freqid2freq(i),format='(F6.2)')+ ' GHz: Correlation',psym=10
    oplot,freqs,temp2,psym=10,color=2
    xyouts,  200,0.9,'PSD Error'
    xyouts,  200,0.8,'Nod Error',color=2
    shit=''
    read,shit

end

end
