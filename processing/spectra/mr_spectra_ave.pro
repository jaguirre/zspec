;Rewrite of spectra_ave to be less "spaghetti code" and separte
;flagging from averaging.

PRO mr_spectra_ave, spectra, transmission=transmission, SIGMA_CUT = SIGMA_CUT, $
                    FUNDAMENTAL = FUNDAMENTAL, $
                    ERRBIN = ERRBIN, QUIET = QUIET, OUTLIERCUT = OUTLIERCUT, $
                    EXCLFLAGS = EXCLFLAGS, OBS_LABELS = OBS_LABELS, $
                    NOD_CUT_THRESHOLD = NOD_CUT_THRESHOLD, oneTag=oneTag
                                ;, WEIGHTS_MATRIX=WEIGHTS_MATRIX

  IF ~KEYWORD_SET(SIGMA_CUT) THEN SIGMA_CUT = [10.0,3.0]
  IF ~KEYWORD_SET(OUTLIERCUT) THEN OUTLIERCUT = [2,2]

  IF ~KEYWORD_SET(ERRBIN) then BEGIN
     IF KEYWORD_SET(OBS_LABELS) THEN BEGIN
        ERRBIN = obs_labels.nnods
     ENDIF ELSE BEGIN
       ; UNWEIGHTED = 1
        ERRBIN = 0
     ENDELSE
  ENDIF 

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
         FOR bolo = 0, nbolos - 1 DO BEGIN
           currnods = REFORM(nodspec[bolo,*])
           currerrs = REFORM(noderr[bolo,*])
           currexcl = REFORM(exclflags[bolo,*]) ; Exclusion flags from 
                                                ; uber_spectrum
           IF pass EQ 1 THEN IF nbadnods GT 0 THEN currexcl[badnods] = 1
           exclude = WHERE(currexcl EQ 1,nExclude)
           
           ;Get rid of any known bad points to start
           currmask=reform(spectra.(currtag).mask[bolo,*])
           if nExclude GT 0 then currmask[exclude]=0

           ;Unweighted data flagging
           case outliercut[0] of
               0: nloops=0
               1: nloops=1
               2: nloops=50
           endcase

           for loop=0, nloops-1 do begin
               mean=compute_mean(currnods, currmask) ;Get mean and stdev
               sdom=compute_sdom(currnods, currmask)
               ;Flag out outliers
               currmask2=flag_data(currnods, mean, sdom, currmask, sigma_cut[0])
               w=where(currmask2 eq currmask,count)
               if count eq n_e(currmask) then break ;Stop if there weren't any
               currmask=currmask2
           endfor

                                ;Unweighted data flagging
           case outliercut[1] of
               0: nloops=0
               1: nloops=1
               2: nloops=50
           endcase

           for loop=0, nloops-1 do begin
                                ;Get weighted mean and stdev
               mean=compute_mean(currnods, currmask, currerrs, errbin=errbin, $
                                 /weighted )
               sdom=compute_sdom(currerrs, currmask, errbin=errbin, /weighted)
                                ;Flag out outliers
               currmask2=flag_data(currnods, mean, sdom, currmask, sigma_cut[1])
               w=where(currmask2 eq currmask,count)
               if count eq n_e(currmask) then break;Stop if there weren't any
               currmask=currmask2
           endfor
           
           ;Final mean and stdev
           currave=compute_mean(currnods,currmask, currerrs, errbin=errbin, $
                                weights_out=weights_out, /weighted)
           currsigma=compute_sdom(currerrs, currmask, errbin=errbin, /weighted)
           
           weights[bolo,*]=weights_out
           spectra.(currtag).avespec[bolo] = currave
           spectra.(currtag).aveerr[bolo] = currsigma
           spectra.(currtag).mask[bolo,*] = currmask
;        spectra.(currtag).weights[bolo,*] = currweights
           ngoodpts = TOTAL(currmask)
           IF ngoodpts NE nnods AND ~KEYWORD_SET(QUIET) THEN $
              MESSAGE, /INFO, STRING(nnods - ngoodpts, F='(I0)') + $ 
                       ' of ' +  STRING(nnods, F='(I0)') + $
                       ' points cut from freqID # ' + STRING(bolo,F='(I0)') + $
                       ' in tag ' + tag_names[tag]
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
