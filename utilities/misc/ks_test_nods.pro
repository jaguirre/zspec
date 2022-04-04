pro ks_test_nods,save_file,plot_file

;+
; NAME:
;  KS_TEST_NODS
;
; MODIFICATION HISTORY:
;  JRK 7/14/09
;
; PURPOSE:
;  Reads in a saved coadded spectrum does a KS test to 
;  check Gaussianity.
;
; CALLING SEQUENCE:
;  ks_test_nods,save_file,plot_file
;
; INPUTS:
;  save_file: the filename of the coadded spectrum.
;       NEED SOURCE DIRECTORY.  Will use 
;       /zspec_svn/processing/spectra/coadded_spectra/
;  plot_file: the filename for the PostScript output.
;
; EXAMPLE:
;  ks_test_nods,'Arp220/Arp220_20090129_1806.sav','~/Arp220_hist.ps'
;
; OUTPUTS:
;  The output is a PostScript file containing the plots
;  produced by ksone.pro, which are CDFs of the data (solid) and
;  of a normalized Gaussian (dashed).  The place of maximum difference
;  is marked with a vertical line.
;  The last page has 2 plots: probabilities vs. channel, and then
;  a histogram of the probabilities.
;-

;if ~keyword_set(save_file) then save_file='NGC1068/NGC1068_Uranus.sav'
;if ~keyword_set(plot_file) then plot_file='NGC1068/NGC1068_Uranus_NormHist.ps'

;______________________________________________________________
;RESTORE THE COADDED SPECTRUM

  save_file=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+save_file
  restore,save_file
    
;______________________________________________________________
;SET UP DEVICE FOR PLOTTING HISTOGRAMS

  cleanplot

  psfile=plot_file

  set_plot,'ps'
  device,/portrait,filename=psfile,/inches,/color,$
      xsize=7.5, ysize=10, xoffset=0.5, yoffset=0.5

  !p.multi=[0,3,4]

  nu=freqid2freq()

;______________________________________________________________
;PLOT THE HISTOGRAMS

   channels=n_e(uber_psderror.in1.nodspec[*,0])
   nnods=n_e(uber_psderror.in1.nodspec[0,*])  
  
   prob=DBLARR(channels)
   D=DBLARR(channels)

   
   ;Loop over all channels
   for i=0, channels-1 do begin
   
     ;Get the values for this loop
     values = REFORM(uber_psderror.in1.nodspec[i,*])
     sigmas = REFORM(uber_psderror.in1.noderr[i,*])
     mask   =  REFORM(uber_psderror.in1.mask[i,*])
     titlestring = 'Channel ID '+STRING(i)
     
     ;Also get the previously computed average and error for this channel
     ave = uber_psderror.in1.avespec[i]
     err = uber_psderror.in1.aveerr[i]
   
     ;Mask out bad nods
     keep=WHERE(uber_psderror.in1.mask[i,*] EQ 1, nkeep)
     values=values[keep]
     sigmas=sigmas[keep]
     
     ;Want to compare to a normalized Gaussian
     normalized = (values-ave)/sigmas
     
     ;KS test
     ksone, normalized, 'gaussint', thisD, thisprob, /PLOT, TITLE=titlestring
     
     ;Keep all Ds and probs
     D[i]=thisD
     prob[i]=thisprob
   
   endfor ;Looped over all channels
   
   
   ;Last page has 2 plots
   !p.multi=[0,1,2]
   plot,prob,psym=10,$
      xrange=[0,160],yrange=[0,1],xstyle=1,$
      title='Probabilities',xtitle='Channel ID'
      
   hist_plot,prob,binsize=0.05,$
      title='Distribution of Probabilities',$
      xtitle='Probability (binned to 0.05 increments)',$
      ytitle='Number of channels with this probability',$
      xrange=[0,1],/xst
  
;______________________________________________________________
;CLOSE OUT THE PLOTTING DEVICE

    !p.multi=0
    device,/close
    set_plot,'x'

cleanplot

print,'Plots are located here:'
print,psfile
  
end