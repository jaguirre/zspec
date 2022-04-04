pro compare_mars,filename,date

; Written by JRK March 2010, committed to SVN 4/19/10
;
; Use this routine while pointing/calibrating while observing to
; compare a Mars observation to the expected Mars flux.
;
; Before running this routine, do the following:
;  1) Make sure that mars_jy is updated with the dates that you need.
;  2) Run a single observation of Mars through uber_spectrum.
;     Keep track of the resulting filename.  It should be in
;     '~/zspec_svn/processing/spectra/coadded_spectra/Mars/'
;
; Run this routine as follows:
;    compare_mars,filename,date
; Example:
;    compare_mars,'Mars_20100322_0503.sav',20100322
;
; The results are:
;   1) A plot of the uber_spectrum and the expected spectrum.
;   2) A plot of the % difference between the two.  The mean
;      of the difference is printed on the plot.
;      Here, a negative percentage difference means Z-spec is lower
;      than the expected Jy for Mars.
;

restore,!zspec_pipeline_root+'/processing/spectra/coadded_spectra/Mars/'+filename

expect=mars_jy(date)

window,1
plot,freqid2freq(),uber_psderror.in1.avespec,yrange=[0,MAX(expect)],$
  title='Mars Uber_Spectrum vs. Expected',xtitle='Freq [GHz]',ytitle='Jy'
oploterror,freqid2freq(),uber_psderror.in1.avespec,uber_psderror.in1.aveerr,$
  col=4,errcol=4

oplot,freqid2freq(),expect,col=2

legend,['Expected','Z-spec'],linestyle=0,col=[2,4]

window,2
plot,freqid2freq(),(uber_psderror.in1.avespec-expect)/expect*100,psym=10,$
  title='Percent Difference',xtitle='Freq [GHz]',ytitle='Percent Difference (zspec-expect)/expect*100',$
  yrange=[-40,40],/nodata,$
  Yticklen=1.0,ygridstyle=1
  
oplot,freqid2freq(),(uber_psderror.in1.avespec-expect)/expect*100,psym=10,col=3

xyouts,210,30,'Mean: '+STRING(mean((uber_psderror.in1.avespec-expect)/expect)*100)+'%',charsize=1.5
xyouts,210,25,'Mean (excluding first 10 bolometers): '+$
   STRING(mean((uber_psderror.in1.avespec[10:159]-expect[10:159])/expect[10:159])*100)+'%',charsize=1.5


end
