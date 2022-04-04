; Modified by JRK 7/21/09: outlier_cut and sigma_cut are now 2 element vectors,
;    referring to a preliminary cut of huge outliers using mask_onecut or
;    mask_recursive and the final cuts in rm_outlier_binweighted.  Nods
;    are now also binned by observation.
;
; Modified by JRK 5/19/09: Added Exclflags to read in channel exclusion flags
;    from uber_spectrum.
;
; Modified by JRK 3/13/09: Now keyword outliercut will determine how to 
; deal with outliers.  The February 2009 edit no longer applies.
; OUTLIERCUT is set as an integer.  The default is 2.
;    0 = Do not cut any outlying nods.  Use all nods in weighted average.
;    1 = Cut out 3 sigma outliers with one pass.
;    2 = Recursively cut out 3 sigma outliers until none are left to be cut
;
; Modified by JRK February 2009: spectra_ave now removes 3 sigma outlying
; nods before binning and averaging when calculating the weighted mean.
; Override this with keyword /allnods. 
;
; Modified by MB Aug 2008 to include ERRBIN keyword.  ERRBIN
; determines the number of nods over which to average the noise in
; order to obtain a weight in the weighted mean.  Default is 10, per
; the original Naylor code.
; 
; JRK 12/7/12: pass keyword quiet to rm_outlier_binweighted and
; mask_recursive
; JRK 12/10/12: commented out the message stating how many points were
;  cut from each freqID#.
; KSS 12/19/12: Committed latest revision to svn.

PRO spectra_ave, spectra, transmission=transmission, SIGMA_CUT = SIGMA_CUT, $
                 FUNDAMENTAL = FUNDAMENTAL, UNWEIGHTED = UNWEIGHTED, $
                 ERRBIN = ERRBIN, QUIET = QUIET, OUTLIERCUT = OUTLIERCUT, $
                 EXCLFLAGS = EXCLFLAGS, OBS_LABELS = OBS_LABELS, $
                 NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD, oneTag=oneTag
                                ;, WEIGHTS_MATRIX=WEIGHTS_MATRIX

  IF ~KEYWORD_SET(SIGMA_CUT) THEN SIGMA_CUT = [10.0,3.0]
  IF ~KEYWORD_SET(OUTLIERCUT) THEN OUTLIERCUT = [2,2]

  IF ~KEYWORD_SET(ERRBIN) AND ~KEYWORD_SET(UNWEIGHTED) THEN BEGIN
     IF KEYWORD_SET(OBS_LABELS) THEN BEGIN
        ERRBIN = obs_labels.nnods
     ENDIF ELSE BEGIN
       ; UNWEIGHTED = 1
        ERRBIN = 0
     ENDELSE
  ENDIF

  IF ~KEYWORD_SET(ERRBIN) AND KEYWORD_SET(UNWEIGHTED) THEN ERRBIN = 0
  
  ntags = N_TAGS(spectra)
  tag_names = TAG_NAMES(spectra)
  nbolos = N_E(spectra.(0).(0)[*,0])
  nnods = N_E(spectra.(0).(0)[0,*])
  
  IF ~KEYWORD_SET(EXCLFLAGS) THEN EXCLFLAGS = FLTARR(nbolos,nnods)
  
;Array for number of bad nods in each channel.
  nbadarr = fltarr(ntags,nbolos)
  
; make a matrix of weights
  
  IF KEYWORD_SET(FUNDAMENTAL) THEN $
     usetags = [0,1,2,5] $
  ELSE usetags = INDGEN(ntags)
  
  if keyword_set(oneTag) then begin
      tags=tag_names(spectra)
      oneTag=strupcase(oneTag)
      w=where(tags eq oneTag, c)
      if c eq 0 then begin
          print, 'Error: Tag '+oneTag+' does not exist!'
          return
      endif
  endif

  FOR tag = 0, N_E(usetags) - 1 DO BEGIN
     
     currtag = usetags[tag]
     nodspec = spectra.(currtag).nodspec
     noderr = spectra.(currtag).noderr
     weights=fltarr(nbolos,nnods)
    
     IF KEYWORD_SET(NOD_CUT_THRESHOLD) THEN npass = 2 ELSE npass = 1
     if keyword_set(oneTag) then $
       if tag_names[tag] ne oneTag then npass=0
         
     FOR pass = 0, npass-1 DO BEGIN ; Do outlier removal twice 
                                    ; (if NOD_CUT_THRESHOLD is set)
         IF pass EQ 1 THEN BEGIN ; Extract nod flags based on threshold value
           nmasked = nbolos - TOTAL(spectra.(currtag).mask,1)
           badnods = WHERE(nmasked GT NOD_CUT_THRESHOLD*float(nbolos), nbadnods)
        ENDIF
        
        FOR bolo = 0, nbolos - 1 DO BEGIN
           currnods = REFORM(nodspec[bolo,*])
           currerrs = REFORM(noderr[bolo,*])
           currexcl = REFORM(exclflags[bolo,*]) ; Exclusion flags from 
                                                ; uber_spectrum
           IF pass EQ 1 THEN IF nbadnods GT 0 THEN currexcl[badnods] = 1
           exclude = WHERE(currexcl EQ 1,nExclude)

           IF ~KEYWORD_SET(UNWEIGHTED) THEN BEGIN
               case outliercut[0] of ; This is the first cut to 
                                    ;remove very high sigma outliers.
                 0: begin           ;No cuts
                    currmask = REPLICATE(1.0,nnods)
                                ;Unless any values were set to NaN before.
                    if nExclude GT 0 then currmask[exclude]=0
                 end
                 1: begin       ;One cut
                    if nExclude GT 0 then currnods[exclude]=!Values.D_NaN
                    currmask = mask_onecut(currnods,sigma_cut[0],/median)
                 end
                 2: begin       ;Recursively cut
                     if nExclude GT 0 then currnods[exclude]=!Values.D_NaN
                     currmask = mask_recursive(currnods,sigma_cut[0],/median,/quiet)
                 end
                 3: currmask=spectra.(currtag).mask[bolo,*]
            endcase
            
;MJRR addition

            currmask*=spectra.(currtag).mask[bolo,*]

             bad=WHERE(currmask EQ 0,nbad)
              nbadarr[tag,bolo]=nbad
              if nbad GT 0 then begin
                 currnods[bad]=!VALUES.D_NAN
                 currerrs[bad]=!VALUES.D_NAN
              endif           
              case outliercut[1] of
                 0: begin       ;No cuts
                    n_loops=1
                    MESSAGE,/INFO,'rm_outlier_binweighted must do at ' + $
                            'least 1 pass of outlier removal.'
                 end
                 1: n_loops=1   ; One cut
                 2: n_loops=50  ;Recursively cut
              endcase
              currave=rm_outlier_binweighted(currnods, currerrs, $
                                             currsigma, currmask,$
                                             WEIGHTS_OUT = WEIGHTS_OUT, $
                                             ERRBIN=ERRBIN, $
                                             CUT_LEVEL = sigma_cut[1],$
                                             n_loops=n_loops,/quiet)
              weights[bolo,*]=weights_out
          ENDIF ELSE BEGIN
              IF N_E(SIGMA_CUT) EQ 2 THEN $
                 currave = rm_outlier(currnods,SIGMA_CUT[1],$
                                      currmask,currsigma,/SDEV,QUIET = 1) $
              ELSE currave = rm_outlier(currnods,SIGMA_CUT,$
                                        currmask,currsigma,/SDEV,QUIET = 1)
           ENDELSE 
           spectra.(currtag).avespec[bolo] = currave
           spectra.(currtag).aveerr[bolo] = currsigma
           spectra.(currtag).mask[bolo,*] = currmask
;        spectra.(currtag).weights[bolo,*] = currweights
           ngoodpts = TOTAL(currmask)
          ; IF ngoodpts NE nnods AND ~KEYWORD_SET(QUIET) THEN $
          ;    MESSAGE, /INFO, STRING(nnods - ngoodpts, F='(I0)') + $ 
          ;             ' of ' +  STRING(nnods, F='(I0)') + $
          ;             ' points cut from freqID # ' + STRING(bolo,F='(I0)') + $
          ;             ' in tag ' + tag_names[tag]
        ENDFOR                  ; loop on bolos
    ENDFOR
    subtags=tag_names(spectra.(0)) & n_subtags=n_tags(spectra.(0))
     for subtag=0,n_subtags-1 do begin
        if subtag eq 0 then $
           temp=create_struct(subtags[subtag],spectra.(tag).(subtag))$
        else temp=create_struct(temp,subtags[subtag],spectra.(tag).(subtag))
    end
    w=where(subtags eq 'WEIGHTS')
     if w[0] eq -1  then temp=create_struct(temp,'weights',weights) $
     else temp.weights=weights
     if tag eq 0 then temp_str=create_struct(tag_names[tag],temp)$
     else temp_str=create_struct(temp_str,tag_names[tag],temp)
  ENDFOR                        ; loop on tags
  
;Report bad nod removal stats.
  maxbad=MAX(nbadarr)
  minbad=MIN(nbadarr)
  avgbad=MEAN(nbadarr)
  avgbadin1=MEAN(nbadarr[2,*])
  
  MESSAGE, /INFO, 'Maximum nods cut from a channel: '+STRING(maxbad, F='(I0)')
  MESSAGE, /INFO, 'Minimum nods cut from a channel: '+STRING(minbad, F='(I0)')
  MESSAGE, /INFO, 'Average nods cut from channels: '+STRING(avgbad, F='(I0)')
  MESSAGE, /INFO, 'Average nods cut from channels in tag IN1: '+$
           STRING(avgbadin1, F='(I0)')
  
  spectra=temp_str
  
END
