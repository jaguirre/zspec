pro hist_nods,save_file,plot_file,info=info,all=all

;+
; NAME:
;  HIST_NODS
;
; MODIFICATION HISTORY:
;  JRK 4/23/10: No more outliercut keyword, because same keyword name
;        saved in uber_spectrum .sav file.  Instead, use keyword
;        /all to plot ALL nods, or do not use the keyword
;        to plot only those nods which were not cut in uber_spectrum.
;  JRK 4/20/09: Changed default directories for new convention.
;  JRK 3/20/09: Scratch last update.  Now there's a case for
;        outliercut ala uber_spectrum (default is no cuts).
;        Use keyword /info to print removal info.
;  JRK 3/10/09: Use keyword /noinfo to not plot the
;        sigma lines or # of nods proposed to be removed.
;        (Useful to compare histograms resulting from
;        different removal procedures.)
;  JRK 2/10/09: Added number of nods removed to
;        plot titles and final histogram of nod index
;        vs. number of times removed
;  JRK 2/9/09
;
; PURPOSE:
;  Reads in a saved coadded spectrum and produces
;  histograms of nods for each channel.
;
; CALLING SEQUENCE:
;  hist_nods,save_file,plot_file
;
; INPUTS:
;  save_file: the filename of the coadded spectrum.
;  plot_file: the filename for the PostScript output.
;
;  NEED SOURCE DIRECTORY.  Both will
;  use the /zspec_svn/processing/spectra/coadded_spectra/
;  folder automatically.
;
; OPTIONAL KEYWORDS:
;  /INFO: print lines or removal info for how many would
;      be removed.  Really only applies to outliercut = 0.  
; /ALL: plots all nods.  Otherwise, plots only nods not
;      cut in uber_spectrum.
; NO LONGER USED:
; OUTLIERCUT is set as an integer.  The default is 0.
;    0 = Do not cut any outlying nods.
;    1 = Cut out 3 sigma outliers with one pass.
;    2 = Recursively cut out 3 sigma outliers until none are left to be cut.
;
; EXAMPLE:
;  hist_nods,'Arp220_20090129_1806.sav','Arp220_hist.ps'
;
; OUTPUTS:
;  The output is a PostScript file containing the histograms.
;  Each page contains 12 histograms; each one contains all nods 
;  for one channel.  The 2, 3, and 4 sigma lines are overplotted
;  in blue.  Additionally, each plot title contains the number
;  and percent of nods that would be removed by 2, 3, and 4
;  sigma, respectively.
;  
;  The last histogram is of nod numbers verses number of times
;  removed.  
;
;-

;--------- CUT BY JRK 4/2/310
;outliercut=0
;
;if ~keyword_set(OUTLIERCUT) then begin
;   OUTLIERCUT=0
;endif
;if ((outliercut NE 0) and (outliercut NE 1) and (outliercut NE 2)) then begin
;   print,'Outlier cut must be 0, 1, or 2!  Will not continue.'
;   stop
;endif
;---------

sigma_cut=3

;______________________________________________________________
;RESTORE THE COADDED SPECTRUM

save_file=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+save_file
restore,save_file

;______________________________________________________________
;SET UP DEVICE FOR PLOTTING HISTOGRAMS

cleanplot

    psfile=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+plot_file

    set_plot,'ps'
    device,/portrait,filename=psfile,/inches,/color,$
      xsize=7.5, ysize=10, xoffset=0.5, yoffset=0.5

    !p.multi=[0,3,4]

    nu=freqid2freq()

;______________________________________________________________
;PLOT THE HISTOGRAMS

   ;Should be 160 channels, but just in case
   channels=n_e(uber_psderror.in1.nodspec[*,0])
   nnods=n_e(uber_psderror.in1.nodspec[0,*])
   
   bad_nods=[0]
   
   ;Loop over all channels
   for i=0, channels-1 do begin
     chan=strtrim(i+1,2)
     freq=strtrim(freqid2freq(i),2)
     nods=REFORM(uber_psderror.in1.nodspec[i,*])

;--------- CUT BY JRK 4/2/310
;     case outliercut of
;        0: begin ;No cuts
;           currmask = REPLICATE(1.0,n_e(nods))
;        end
;        1: begin ;One cut
;           currmask = mask_onecut(nods,sigma_cut)
;        end
;        2: begin ;Recursively cut
;           currmask = mask_recursive(nods,sigma_cut)
;        end
;     endcase
     
;     good=WHERE(currmask EQ 1,ngood)
;     goodnods=nods[good]
;---------

      ; Added by JRK 4/23/10
     currmask=uber_psderror.in1.mask[i,*]
     if keyword_set(all) then begin
        ngood=n_e(nods)
        goodnods=nods 
     endif else begin
        good=WHERE(currmask EQ 1,ngood)
        goodnods=nods[good]
     endelse
             
   
     ;Only do this next part if info is set
     if keyword_set(info) then begin
         ;Calculate mean and standard deviation
         mean_plot=MEAN(nods)
         sig_plot=STDDEV(nods)
         
         ;Assign the 2,3,4 sigma values 
         sigs=dblarr(6)
         sig_nums=[2,3,4,-2,-3,-4]
         for j = 0,n_e(sigs)-1 do sigs[j]=mean_plot+sig_plot*sig_nums[j]
         
         ;Figure how many would be removed in each scenario
         gone=intarr(3)
         for y = 0, 2 do begin
             dummy=WHERE(ABS(nods-mean_plot) GT sigs[y],count)
             if y EQ 1 then bad_nods=[bad_nods,dummy]
             if count EQ -1 then count=0
             gone[y]=count
         endfor
        
         ;Annotate this
         percent2=STRTRIM(ROUND(DOUBLE(gone[0])/nnods*100),2)+'%, '
         percent3=STRTRIM(ROUND(DOUBLE(gone[1])/nnods*100),2)+'%, '
         percent4=STRTRIM(ROUND(DOUBLE(gone[2])/nnods*100),2)+'%'
         note=STRTRIM(gone[0],2)+', '+STRTRIM(gone[1],2)+', '+STRTRIM(gone[2],2)+$
            ' nods of '+STRTRIM(nnods,2)+' ('+percent2+percent3+percent4+')'
      endif else begin
         note='Total nods: '+STRTRIM(ngood,2)
      endelse
     
     ;Plot!
     !Y.MARGIN=[2,4]
     plottitle='Channel '+chan+': '+freq+' Ghz!C'+note
     hist_plot,goodnods,title=plottitle
     
  
     ;Only do this next part if info is set
     if keyword_set(info) then begin
         ; Overplot the 2,3,4 sigma lines   
         sig_min=!y.crange[0]
         sig_max=!y.crange[1]
         for k = 0,n_e(sigs)-1 do oplot,fltarr(2)+sigs[k],[sig_min,sig_max],col=4
     endif
   endfor ;Looped over all channels
   
   ;Only do this next part if info is set
   if keyword_set(info) then begin
   ;A check to see if it's the same nod being removed in every channel
     real=WHERE(bad_nods NE 0 and bad_nods NE -1)
     bad_nods=bad_nods[real]
     hist_plot,bad_nods,title='Bad nod indices removed at 3 sigma',$
        xtitle='Nod Number',ytitle='# of Channels where Nod is Removed',$
        binsize=1
    endif
      
;______________________________________________________________
;CLOSE OUT THE PLOTTING DEVICE

    !p.multi=0
    device,/close
    set_plot,'x'

cleanplot

print,'Histograms are plotted at:'
print,psfile

END
