;Function to avoid repeat code
;Gets the state value from the top level uvalue pointer
function get_state, top
widget_control, top, get_uvalue=state
return, *state
end

;---------------------------------------------------------------------------------------

;Function to avoid repeat code
;Sets the top level uvalue state pointer to the new state variable
pro set_state, top, state
widget_control, top, get_uvalue=oldState
ptr_free, oldState
widget_control, top, set_uvalue=ptr_new(state)
end

;--------------------------------------------------------------------------------------
;Calculates correlations
function calculate_corr, psderror, mask
nodspec=psderror.in1.nodspec

s=size(nodspec)
n_good=total(mask,2)
averages=total(nodspec*mask,2)/n_good
n=nodspec*mask-averages#replicate(1.,s[2])
sigmas=sqrt(total(n^2,2)/n_good)
denom=sqrt(n_good#transpose(n_good))*(sigmas#transpose(sigmas))

corr=(n # transpose(n))/denom

return, corr
end

;--------------------------------------------------------------------------------------

;Called automatically on exit. Deallocates all pointers
pro cleanup, top
ptr_free, ptr_valid()
end

;--------------------------------------------------------------------------------------

;Tests if a string is a double
function isDouble, str
match=stregex(str, '-?[0123456789]*\.?[0123456789]*', /extract) ;Match it to a digit regex
if match ne str then return, 0 ;Only a number of regex match IS the string
return, 1
end

;--------------------------------------------------------------------------------------

;Tests if a string is an integer
function isInt, str
match=stregex(str, '-?[0123456789]+', /extract) ;Match it to a digit regex
if match ne str then return, 0 ;Only a number of regex match IS the string
return, 1
end

;-------------------------------------------------------------------------------------

;Function to avoid repeat code
;Checks if numeric text input is nonempty an actually represents an integer
;at the time of input
;NAN means input is invalid
function verify_numeric_text_input, text, message, base, double=double

text=strcompress(text, /remove_all)
if text eq '' then begin ;Check for nonempty
    a=DIALOG_MESSAGE('ERROR: Must supply '+message, /error, dialog_parent=base)
    return, !values.F_NAN
endif

if keyword_set(double) then begin
;Check that it's a double
    if not isDouble(text) then begin
        a=DIALOG_MESSAGE('ERROR: '+message+' must be a real number!', /error, dialog_parent=base)
        return, !values.F_NAN
    endif 
endif else begin
    if not isInt(text) then begin
        a=DIALOG_MESSAGE('ERROR: '+message+' must be an integer!', /error, dialog_parent=base)
        return, !values.F_NAN
    endif 
endelse

if keyword_set(double) then convertedNum=double(text) $;Convert and return
else convertedNum=long(text)
return,convertedNum
end
;---------------------------------------------------------------------------------------
;Scales an image to the provided set of dimensions
function scaleImage, origImage, newDims

s=size(origImage)

xFac=newDims[0]/s[1]
yFac=newDims[1]/s[2]

scaledImage=congrid(origImage, s[1]*xFac, s[2]*yFac, /center)

return, scaledImage
end
;---------------------------------------------------------------------------------------
;Tests a data set for gaussianity
function gaussTest, psderror, rangeMask
nodspec=psderror.in1.nodspec
mask=psderror.in1.mask*rangeMask

s=size(nodspec)
n_good=total(mask,2)
averages=total(nodspec/mask,2, /nan)/n_good
n=nodspec/mask-averages#replicate(1.,s[2])
sigmas=sqrt(total(n^2,2, /nan)/n_good)

d=n/(sigmas#replicate(1,s[2]))

probs=dblarr(s[1])
for i=0, s[1]-1 do begin
 
    ksone, d[i,*], 'gauss_pdf', t, prob
    
    probs[i]=prob

endfor
return, probs
end
;---------------------------------------------------------------------------------------

;Displays the current nodspec array
pro display, base
state=get_state(base)

drawFrame=WIDGET_INFO(base, find_by_uname='Draw Frame')
nodspecButton=WIDGET_INFO(base, find_by_uname='Nodspec Button')
scaleOnButton=WIDGET_INFO(base, find_by_uname='Scale On Button')
scaleMinText=WIDGET_INFO(base, find_by_uname='Scale Min Text')
scaleMaxText=WIDGET_INFO(base, find_by_uname='Scale Max Text')
corrFrame=WIDGET_INFO(base, find_by_uname='Corr Frame')
gaussPanel=WIDGET_INFO(base, find_by_uname='Gauss Panel')
gaussReadout=WIDGET_INFO(base, find_by_uname='Gauss Readout')
minLabel=WIDGET_INFO(base, find_by_uname='Min Label')
maxLabel=WIDGET_INFO(base, find_by_uname='Max Label')
meanLabel=WIDGET_INFO(base, find_by_uname='Mean Label')
stdevLabel=WIDGET_INFO(base, find_by_uname='Stdev Label')

psderror=*state.psderror        ;Get current image + mask

if state.useAutoMask then $
  mask=transpose(psderror.in1.mask*(*state.rangeMask)*(*state.currMask)) $
else mask=transpose(*state.rangeMask*(*state.currMask))

if state.imageChanged then begin
    geometry=widget_info(drawFrame, /geometry) ;Drawing area geometry in pixels
    
    if widget_info(nodspecButton, /button_set) then spec=transpose(psderror.in1.nodspec) $
    else spec=transpose(psderror.in1.noderr)

    s=size(spec)
    
    xFac=geometry.draw_xsize/s[1] ;Scale up image to fit the drawing area
    yfac=geometry.draw_ysize/s[2]
  
    spec2=scaleImage(spec, [geometry.draw_xsize, geometry.draw_ysize])
    mask2=scaleImage(double(mask), [geometry.draw_xsize, geometry.draw_ysize])

    w=where(mask2 eq 0, c)
    if c ne 0 then mask2[w]=!values.F_NAN
    image=spec2*mask2           ;Mask out disabled channels

    ;Rescale image if requested
    if WIDGET_INFO(scaleOnButton, /button_set) then begin
        WIDGET_CONTROL, scaleMinText, get_value=minText ;Get and verify the new scales
        WIDGET_CONTROL, scaleMaxText, get_value=maxText
        minValue=verify_numeric_text_input(minText, 'Scale minimum', base,/double)
        maxValue=verify_numeric_text_input(maxText, 'Scale maximum', base,/double)
        minValue=minValue[0] ;Not sure why these become arrays, but this is a simple fix
        maxValue=maxValue[0]

        if ~finite(minValue) or ~finite(maxValue) then return

        if maxValue lt minValue then begin
            a=dialog_message('ERROR: Scale maximum must exceed scale minimum', /error, $
                             dialog_parent=base)
            return
        endif
        
                                ;Set everything < minValue to minValue
                                ;and everything > maxValue to maxValue
        w=where(image lt minValue, c) 
        if c ne 0 then image[w]=minValue 
        w=where(image gt maxValue, c)
        if c ne 0 then image[w]=maxValue 

    endif

    ptr_free, state.corr
    ptr_free, state.corrImage

    if widget_info(widget_info(base, find_by_uname='Save Mask'), /button_set) then $
      corrMask=*state.rangeMask*(*state.currMask)*psderror.in1.mask $
    else corrMask=*state.rangeMask*(*state.currMask)
    
    state.corr=ptr_new(calculate_corr(psderror, corrMask)) ;Compute correlation
    
    geometry2=widget_info(corrFrame, /geometry)
    state.corrImage=ptr_new(scaleImage(*state.corr, [geometry2.draw_xsize, geometry2.draw_ysize]))
        
    probs=gaussTest(psderror, *state.rangeMask) ;Test for gaussianity
    w=where(*state.bolo_flags eq 0, c)
    if c ne 0 then probs[w]=0
    ptr_free, state.gaussProbs
    state.gaussProbs=ptr_new(probs)
    
    WIDGET_CONTROL, gaussPanel, get_value=gaussID
    wset, gaussID
    erase
    plot, indgen(s[2]), probs, psym=10, xrange=[0,s[2]-1], yrange=[0,1.1], /xst

    str='Bolo: '+strcompress(string(reverse(indgen(s[2]))), /remove_all)+$
      ' Gauss Prob: '+strcompress(reverse(string(probs)), /remove_all)
    str=strjoin(str, string(10b))

    str='Channel Gaussian Probs: '+string(10b)+str
    WIDGET_CONTROL, gaussReadout, set_value=str
    state.imageChanged=0
endif else begin
    image=*state.scaledImage
    imageMask=*state.imageMask
    maxValue=max(image,/nan) ;If not scaling, get max/min from image
    minValue=min(image, /nan)
endelse

ptr_free, state.scaledImage
state.scaledImage=ptr_new(image)
ptr_free, state.imageMask
state.imageMask=ptr_new(mask2)
set_state, base, state

;Draw it
WIDGET_CONTROL, drawFrame, get_value=drawID
wset, drawID

m=max(image, /nan) ;Make masked out channels red instead of black (so they don't look simply off-scale)
;;; HERE! ;;;
im2=bytscl(image, max=maxValue, min=minValue,/nan,top=254)
whnotfin = where(~finite(image))
if whnotfin[0] ne -1 then begin
    im2[where(~finite(image))]=255
endif
m=max(im2)
tvlct, 255, 0, 0, m

tv, im2,/nan
loadct, 0

WIDGET_CONTROL, corrFrame, get_value=corrID
wset, corrID
tv, bytscl(*state.corrImage, min=min(*state.corr, /nan), max=max(*state.corr, /nan),/nan)

if widget_info(nodspecButton, /button_set) then begin
    d=psderror.in1.nodspec/(psderror.in1.mask*(*state.rangeMask))
    w=where(finite(d), count)

    if count gt 1 then begin
        
        WIDGET_CONTROL, minLabel, set_value='Min: '+$
          strcompress(string(min(psderror.in1.nodspec/(psderror.in1.mask*(*state.rangeMask)),/nan)),/remove_all) 
        WIDGET_CONTROL, maxLabel, set_value='Max: '+$
          strcompress(string(max(psderror.in1.nodspec/(psderror.in1.mask*(*state.rangeMask)),/nan)),/remove_all)
        WIDGET_CONTROL, meanLabel, set_value='Mean: '+$
          strcompress(string(mean(psderror.in1.nodspec/(psderror.in1.mask*(*state.rangeMask)),/nan)),/remove_all)
        WIDGET_CONTROL, stdevLabel, set_value='STDEV: '+$
          strcompress(string(stdev(d[w])),/remove_all)
    endif else begin
        WIDGET_CONTROL, minLabel, set_value='Min: NAN'
        WIDGET_CONTROL, maxLabel, set_value='Max: NAN'
        WIDGET_CONTROL, meanLabel, set_value='Mean: NAN'
        WIDGET_CONTROL, stdevLabel, set_value='STDEV: NAN'
    endelse
endif else begin
     d=psderror.in1.noderr/(psderror.in1.mask*(*state.rangeMask))
     w=where(finite(d), count)

     if count gt 1 then begin

         WIDGET_CONTROL, minLabel, set_value='Min: '+$
           strcompress(string(min(psderror.in1.noderr/(psderror.in1.mask*(*state.rangeMask)),/nan)) ,/remove_all)
         WIDGET_CONTROL, maxLabel, set_value='Max: '+$
           strcompress(string(max(psderror.in1.noderr/(psderror.in1.mask*(*state.rangeMask)),/nan)) ,/remove_all)
         WIDGET_CONTROL, meanLabel, set_value='Mean: '+$
           strcompress(string(mean(psderror.in1.noderr/(psderror.in1.mask*(*state.rangeMask)),/nan)) ,/remove_all)
     endif else begin
         WIDGET_CONTROL, minLabel, set_value='Min: NAN'
         WIDGET_CONTROL, maxLabel, set_value='Max: NAN'
         WIDGET_CONTROL, meanLabel, set_value='Mean: NAN'
         WIDGET_CONTROL, stdevLabel, set_value='STDEV: NAN'
     endelse
   
     WIDGET_CONTROL, stdevLabel, set_value='STDEV: '+$
       strcompress(string(stdev(d[w])) ,/remove_all)
endelse

end

;---------------------------------------------------------------------------------------

;Switches a range of nods on or off
pro toggleNods, base, button
state=get_state(base)

lowBoloText=widget_info(base, find_by_uname='Low Bolo Text')
highBoloText=widget_info(base, find_by_uname='High Bolo Text')
lowNodText=widget_info(base, find_by_uname='Low Nod Text')
highNodText=widget_info(base, find_by_uname='High Nod Text')

;Get the desired nod range extrema, and verify they're valid
WIDGET_CONTROL, lowBoloText, get_value=curText
lowBolo=verify_numeric_text_input(curText, 'starting bolometer',base)
WIDGET_CONTROL, highBoloText, get_value=curText
highBolo=verify_numeric_text_input(curText, 'ending bolometer',base)
WIDGET_CONTROL, lowNodText, get_value=curText
lowNod=verify_numeric_text_input(curText, 'starting nod',base)
WIDGET_CONTROL, highNodText, get_value=curText
highNod=verify_numeric_text_input(curText, 'ending nod',base)

if ~finite(lowBolo) or ~finite(highBolo) or ~finite(lowNod) or ~finite(highNod)$
  then return

;Verify that the ranges make sense
if lowNod gt highNod then begin
    a=DIALOG_MESSAGE('ERROR: Starting nod must be <= ending nod!', /error, dialog_parent=base)
    return
endif

if lowBolo gt highBolo then begin
    a=DIALOG_MESSAGE('ERROR: Starting bolo must be <= ending bolo!', /error, dialog_parent=base)
    return
endif

psderror=*state.psderror
s=size(psderror.in1.nodspec)
if lowBolo lt 0 or highBolo lt 0 or lowBolo ge s[1] or highBolo ge s[1] $
  or lowNod lt 0 or highNod lt 0 or lowNod ge s[2] or highNod ge s[2] then begin
    a=DIALOG_MESSAGE('ERROR: Invalid/out of range dimensions', /error, dialog_parent=base)
    return
endif

;Set or clear the mask flags in this range
mask=*state.currMask
if button eq widget_info(base, find_by_uname='On Button') then mask[lowBolo:highBolo, lowNod:highNod]=1 $
else mask[lowBolo:highBolo, lowNod:highNod]=0

s=size(mask)  ;Get rid of any channels we know are always bad
maskMult=*state.bolo_flags#replicate(1, s[2])
mask*=maskMult

ptr_free, state.lastMask
state.lastMask=ptr_new(*state.currMask)
ptr_free, state.currMask
state.currMask=ptr_new(mask)

state.changed=1
state.imageChanged=1

WIDGET_CONTROL, widget_info(base, find_by_uname='Undo Button'), /sensitive

set_state, base, state
display, base ;Display result

end

;---------------------------------------------------------------------------------------

;Load in an IDL .sav file
pro loadfile, base
state=get_state(base)

;Undo everything in case of error
catch, error_status
if error_status ne 0 then begin
    a=dialog_message('Recieved the following error: '+!error_state.msg, /error, dialog_parent=base)
    WIDGET_CONTROL, widget_info(base, find_by_uname='Dims Label'), set_value='Bolos: NaN  Nods: NaN'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Source Name Label'), set_value='Source: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='File Label'), set_value='File: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mouse X Text'), set_value='Bolo: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mouse Y Text'), set_value='Nod: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mouse Val Text'), set_value='Value: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Reset Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Plot Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Undo Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Save Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Save Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Bolo Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Bolo Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Bolo Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Bolo Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Nod Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Nod Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Nod Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Nod Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='On Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Off Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Min Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Min Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Max Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Max Label'),sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale On Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Range Button'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Range Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Range Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Low Range Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='High Range Text'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Min Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Max Label'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Min Label'), set_value='Min: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Max Label'), set_value='Max: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Label'), set_value='Mean: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='Stdev Label'), set_value='Stdev: NA'
    WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Subtraction'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='PCA'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Both Decorr'), sensitive=0
    WIDGET_CONTROL, widget_info(base, find_by_uname='Save Mask'), sensitive=0
    return
endif

;Get the file
file=dialog_pickfile(/must_exist, dialog_parent=base,$
                     path=state.base_dir, $
                     filter=['*.sav'], /fix_filter)

if strcompress(file, /remove_all) eq '' then return

restore, file 
ptr_free, state.psderror
ptr_free, state.spectra
ptr_free, state.jackknife
ptr_free, state.bolo_flags
ptr_free, state.uber_excl_flags
ptr_free, state.obs_labels
ptr_free, state.rangeMask
ptr_free, state.lastMask
ptr_free, state.uber_psderror
ptr_free, state.uber_spectra
ptr_free, state.uber_jackknife
ptr_free, state.ms_decorr_psderror
ptr_free, state.ms_decorr_spectra
ptr_free, state.ms_decorr_jackknife
ptr_free, state.pca_decorr_psderror
ptr_free, state.pca_decorr_spectra
ptr_free, state.pca_decorr_jackknife
ptr_free, state.both_decorr_psderror
ptr_free, state.both_decorr_spectra
ptr_free, state.both_decorr_jackknife


s=size(uber_psderror.in1.mask) ;Get rid of any channels we know are always bad
maskMult=uber_bolo_flags#replicate(1, s[2])
uber_spectra.in1.mask*=maskMult
uber_psderror.in1.mask*=maskMult

;Store everything in the state variable 
state.spectra=ptr_new(uber_spectra)
state.psderror=ptr_new(uber_psderror)
state.bolo_flags=ptr_new(uber_bolo_flags)
state.uber_excl_flags=ptr_new(uber_excl_flags)
state.obs_labels=ptr_new(obs_labels)
state.curFile=file
state.changed=0
state.imageChanged=1
state.rangeMask=ptr_new(replicate(1, s[1],s[2]))
state.lastMask=ptr_new(uber_psderror.in1.mask*maskMult)
state.z=z
state.ubername=ubername
state.uber_spectra=ptr_new(uber_spectra)
state.uber_psderror=ptr_new(uber_psderror)
s=size(uber_psderror.in1.mask)
state.currMask=ptr_new(replicate(1, s[1],s[2]))

s=size(uber_jackknife)
if s[n_e(s)-1] ne 0 then begin
    uber_jackknife.in1.mask*=maskMult
    state.jackknife=ptr_new(uber_jackknife) 
    state.uber_jackknife=ptr_new(uber_jackknife)
    state.has_jackknife=1
endif else begin
    state.jackknife=ptr_new()
    state.uber_jackknife=ptr_new()
    state.has_jackknife=0
endelse

s=size(ms_decorr_psderror)
if s[n_e(s)-1] ne 0 then begin
    ms_decorr_spectra.in1.mask*=maskMult
    ms_decorr_psderror.in1.mask*=maskMult
    state.ms_decorr_psderror=ptr_new(ms_decorr_psderror)
    state.ms_decorr_spectra=ptr_new(ms_decorr_spectra)

    if state.has_jackknife then begin
        ms_decorr_jackknife.in1.mask*=maskMult
        state.ms_decorr_jackknife=ptr_new(ms_decorr_jackknife) 
    endif else state.ms_decorr_jackknife=ptr_new()
    
    state.has_ms=1
endif else begin
    state.ms_decorr_psderror=ptr_new()
    state.ms_decorr_spectra=ptr_new()
    state.ms_decorr_jackknife=ptr_new()
    state.has_ms=0
endelse

s=size(pca_decorr_psderror)
if s[n_e(s)-1] ne 0 then begin
    pca_decorr_spectra.in1.mask*=maskMult
    pca_decorr_psderror.in1.mask*=maskMult

    state.pca_decorr_psderror=ptr_new(pca_decorr_psderror)
    state.pca_decorr_spectra=ptr_new(pca_decorr_spectra)

    if state.has_jackknife then begin
        pca_decorr_jackknife.in1.mask*=maskMult
        state.pca_decorr_jackknife=ptr_new(pca_decorr_jackknife) 
    endif else state.pca_decorr_jackknife=ptr_new()
    
    state.has_pca=1
endif else begin
    state.pca_decorr_psderror=ptr_new()
    state.pca_decorr_spectra=ptr_new()
    state.pca_decorr_jackknife=ptr_new()
    state.has_pca=0
endelse

if state.has_ms and state.has_pca then begin
    both_decorr_spectra.in1.mask*=maskMult
    both_decorr_psderror.in1.mask*=maskMult

    state.both_decorr_psderror=ptr_new(both_decorr_psderror)
    state.both_decorr_spectra=ptr_new(both_decorr_spectra)

    if state.has_jackknife then begin
        state.both_decorr_jackknife=ptr_new(both_decorr_jackknife) 
        both_decorr_jackknife.in1.mask*=maskMult
    endif else state.both_decorr_jackknife=ptr_new()
endif else begin
    state.both_decorr_psderror=ptr_new()
    state.both_decorr_spectra=ptr_new()
    state.both_decorr_jackknife=ptr_new()
endelse

;Display source info
dimsLabel=WIDGET_INFO(base,find_by_uname='Dims Label')
s=size(uber_psderror.in1.nodspec)
widget_control, dimsLabel, set_value='Bolos: '+$
  strcompress(string(s[1]), /remove_all)+' Nods: '+$
  strcompress(string(s[2]),/remove_all)

s=size(sourceName)
w=where(s ne 0, count)
sourceNameLabel=WIDGET_INFO(base, find_by_uname='Source Name Label')
if count eq 0 then begin
    source=strsplit(file, '/', /extract)
    WIDGET_CONTROL, sourceNameLabel, set_value='Source: '+source[n_e(source)-2]
    state.sourceName=source[n_e(source)-2]
endif else begin
    WIDGET_CONTROL, sourceNameLabel, set_value='Source: '+sourceName
    state.sourceName=sourceName
endelse

fileLabel=WIDGET_INFO(base, find_by_uname='File Label')
WIDGET_CONTROL, fileLabel, set_value='File: '+file

set_state, base, state
display, base ;Display nodspec

;Activate controls
WIDGET_CONTROL, widget_info(base, find_by_uname='Reset Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Plot Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Save Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Save Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Bolo Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Bolo Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Bolo Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Bolo Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Nod Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Nod Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Nod Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Nod Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='On Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Off Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Scale On Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Range Button'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Range Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Range Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Low Range Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='High Range Text'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Min Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Max Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Stdev Label'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), /sensitive
WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Subtraction'), sensitive=state.has_ms
WIDGET_CONTROL, widget_info(base, find_by_uname='PCA'), sensitive=state.has_pca
WIDGET_CONTROL, widget_info(base, find_by_uname='Both Decorr'), sensitive=(state.has_ms and state.has_pca)
WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), /set_button
WIDGET_CONTROL, widget_info(base, find_by_uname='Save Mask'), /sensitive

if WIDGET_INFO(WIDGET_INFO(base, find_by_uname='Scale On Button'), /button_set) then begin
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Min Label'), /sensitive
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Min Text'), /sensitive
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Max Text'), /sensitive
    WIDGET_CONTROL, widget_info(base, find_by_uname='Scale Max Label'),/sensitive
endif

;Show the max/min values of the current array as the current scale
nodspecButton=widget_info(base, find_by_uname='Nodspec Button')
scaleMinText=widget_info(base, find_by_uname='Scale Min Text')
scaleMaxText=widget_info(base, find_by_uname='Scale Max Text')

if widget_info(nodspecButton, /button_set) then begin
  WIDGET_CONTROL, scaleMinText, set_value=$
  strcompress(string(min(uber_psderror.in1.nodspec/uber_psderror.in1.mask,/nan)),/remove_all)
  WIDGET_CONTROL, scaleMaxText, set_value=$
    strcompress(string(max(uber_psderror.in1.nodspec/uber_psderror.in1.mask,/nan)),/remove_all)
endif else begin
    WIDGET_CONTROL, scaleMinText, set_value=$
      strcompress(string(min(uber_psderror.in1.noderr/uber_psderror.in1.mask,/nan)) ,/remove_all)
    WIDGET_CONTROL, scaleMaxText, set_value=$
      strcompress(string(max(uber_psderror.in1.noderr/uber_psderror.in1.mask,/nan)) ,/remove_all)
endelse

end

;--------------------------------------------------------------------------------------

;Respond to user mouse commands in the display window
pro handle_mouse_event, ev

state=get_state(ev.top)

;Cancel the change if mouse wheel clicked
if ev.press eq 2 then begin
    state.cancelled=1
    set_state, ev.top, state
    return
endif

drawFrame=WIDGET_INFO(ev.top, find_by_uname='Draw Frame')
mouseXText=WIDGET_INFO(ev.top, find_by_uname='Mouse X Text')
mouseYText=WIDGET_INFO(ev.top, find_by_uname='Mouse Y Text')
mouseValText=WIDGET_INFO(ev.top, find_by_uname='Mouse Val Text')
undoButton=WIDGET_INFO(ev.top, find_by_uname='Undo Button')
nodspecButton=WIDGET_INFO(ev.top, find_by_uname='Nodspec Button')

geometry=WIDGET_INFO(drawFrame, /geometry)

;If we're just moving inside the box...
if ~ev.press and ~ev.release then begin
    
                                ;Do nothing if no file is opened
    if ~ptr_valid(state.psderror) then return
    
    psderror=*state.psderror ;Display which nod/bolo we're pointing at
    s=size(psderror.in1.nodspec)
    xFac=geometry.draw_xsize/s[2]
    yFac=geometry.draw_ysize/s[1]
    
    WIDGET_CONTROL, mouseXText, set_value='Bolo: '+$
      strcompress(string(long(ev.y/yFac)), /remove_all)
    WIDGET_CONTROL, mouseYText, set_value='Nod: '+$
      strcompress(string(long(ev.x/xFac)), /remove_all)

    coords=[ev.y/yFac,ev.x/xFac]
    if coords[0] lt 0 then coords[0]=0
    if coords[0] ge s[1] then coords[0]=s[1]-1
    if coords[1] lt 0 then coords[1]=0
    if coords[1] ge s[2] then coords[1]=s[2]-1
    
    mask=psderror.in1.mask*(*state.rangeMask)
    if mask[coords[0], coords[1]] eq 0 then $
      WIDGET_CONTROL, mouseValText, set_value='Value: NAN' $
    else if widget_info(nodspecButton, /button_set) then $
      WIDGET_CONTROL, mouseValText, set_value='Value: '+$
      strcompress(string(psderror.in1.nodspec[coords[0], coords[1]]), /remove_all) $
    else  WIDGET_CONTROL, mouseValText, set_value='Value: '+$
      strcompress(string(psderror.in1.noderr[coords[0], coords[1]]), /remove_all)
    
     ;Do nothing else if we're not dragging/haven't clicked anything
    w=where(~finite(state.mouseStart), count)
    if count ne 0 then return
    
    ;Otherwise, find the start/stop drag positions to draw a box
    xStart=min([state.mouseStart[0], ev.x])
    xStop=max([state.mouseStart[0], ev.x])
    yStart=min([state.mouseStart[1], ev.y])
    yStop=max([state.mouseStart[1], ev.y])
 
    if xStart lt 0 then xStart=0
    if yStart lt 0 then yStart=0
    if xStop ge geometry.draw_xsize then xStop=geometry.draw_xsize-1
    if yStop ge geometry.draw_ysize then yStop=geometry.draw_ysize-1

    wset, state.wid
    device, copy=[0,0, state.xsize, state.ysize, 0,0, state.pixID]
    plots, [xStart, xStart, xStop, xStop, xStart], [yStart, yStop, yStop, yStart, yStart], /device, $
      Color=!values.F_NAN
   
    return
endif

;At this point, we must have clicked a button

if state.curFile eq '' then return ;Do nothing if we clicked without opening a file

;If we cancelled earlier by clicking the wheel, just reset all trackers
if state.cancelled then begin
    state.cancelled=0
    state.mouseStart=[!values.F_NAN, !values.F_NAN]
    set_state, ev.top, state
    
    return
endif

;If we PRESSED a button
if ev.press ne 0 then begin
    state.mouseStart=[ev.x, ev.y] ;Store the location
    
    window, /Free, /Pixmap, xsize=state.xsize, ysize=state.ysize
    state.pixID=!D.Window
    Device, Copy=[0,0, state.xsize, state.ysize, 0,0, state.wid]
    set_state, ev.top, state
    
endif else begin ;If we RELEASED
    w=where(~finite(state.mouseStart))
    if w[0] ne -1 then return

    mask=transpose(*state.currMask) ;psderror.in1.mask)
    
    s=size(mask)
    xFac=geometry.draw_xsize/s[1] ;We need to downsize since we blew up the image
    yfac=geometry.draw_ysize/s[2]

    xStart=min([state.mouseStart[0], ev.x])
    xStop=max([state.mouseStart[0], ev.x])
    yStart=min([state.mouseStart[1], ev.y])
    yStop=max([state.mouseStart[1], ev.y])

    if xStart lt 0 then xStart=0
    if yStart lt 0 then yStart=0
    if xStop gt geometry.draw_xsize then xStop=geometry.draw_xsize-1
    if yStop gt geometry.draw_ysize then yStop=geometry.draw_ysize-1
   
    coords=[xStart/xFac, xStop/xFac, yStart/yFac, yStop/yFac]
    if coords[0] lt 0 then coords[0]=0
    if coords[0] ge s[1] then coords[0]=s[1]-1
    if coords[1] lt 0 then coords[0]=0
    if coords[1] ge s[1] then coords[0]=s[1]-1
    if coords[2] lt 0 then coords[1]=0
    if coords[2] ge s[2] then coords[1]=s[2]-1
    if coords[3] lt 0 then coords[1]=0
    if coords[3] ge s[2] then coords[1]=s[2]-1
    if ev.release eq 1 then mask[coords[0]:coords[1], coords[2]:coords[3]]=1 $ ;Enable if left button
    else if ev.release eq 4 then mask[coords[0]:coords[1], coords[2]:coords[3]]=0 ;Disable if right button
    
    maskMult=*state.bolo_flags#replicate(1, s[1]) ;Get rid of the known bad channels

    ptr_free,state.lastMask
    state.lastMask=ptr_new(*state.currMask)
    ptr_free,state.currMask
    state.currMask=ptr_new(transpose(mask)*maskMult)
    ;Reset trackers
    state.changed=1 ;We changed the mask
    state.imageChanged=1
    state.mouseStart=[!values.F_NAN, !values.F_NAN]

    WIDGET_CONTROL, undoButton, /sensitive

    Device, copy=[0,0, state.xsize, state.ysize, 0, 0, state.pixID]
    wdelete, state.pixID

    set_state, ev.top, state
    display, ev.top ;Display image
endelse

end

;---------------------------------------------------------------------------------------
;Updates spectra to account for changed nodspec
function update_spectra, base, all=all, uber_psderror=uber_psderror, uber_spectra=uber_spectra,$
                         uber_jackknife=uber_jackknife, ms_decorr_psderror=ms_decorr_psderror,$
                         ms_decorr_spectra=ms_decorr_spectra, ms_decorr_jackknife=ms_decorr_jackknife,$
                         pca_decorr_psderror=pca_decorr_psderror, pca_decorr_spectra=pca_decorr_spectra,$
                         pca_decorr_jackknife=pca_decorr_jackknife, $
                         both_decorr_psderror=both_decorr_psderror,both_decorr_spectra=both_decorr_spectra,$
                         both_decorr_jackknife=both_decorr_jackknife

state=get_state(base)
plotButton=widget_info(base, find_by_uname='Plot Button')
undoButton=widget_info(base, find_by_uname='Undo Button')
saveButton=widget_info(base, find_by_uname='Save Button')
loadButton=widget_info(base, find_by_uname='Load Button')
resetButton=widget_info(base, find_by_uname='Reset Button')
offButton=widget_info(base, find_by_uname='Off Button')
onButton=widget_info(base, find_by_uname='On Button')
scaleOnButton=widget_info(base, find_by_uname='Scale On Button')
scaleButton=widget_info(base, find_by_uname='Scale Button')
rangeButton=widget_info(base, find_by_uname='Range Button')

WIDGET_CONTROL, plotButton, sensitive=0 ;Disable controls to prevent interference
WIDGET_CONTROL, undoButton, sensitive=0
WIDGET_CONTROL, saveButton, sensitive=0 
WIDGET_CONTROL, loadButton, sensitive=0
WIDGET_CONTROL, resetButton, sensitive=0
WIDGET_CONTROL, offButton, sensitive=0
WIDGET_CONTROL, onButton, sensitive=0
WIDGET_CONTROL, scaleOnButton, sensitive=0
WIDGET_CONTROL, scaleButton, sensitive=0
WIDGET_CONTROL, rangeButton, sensitive=0
WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), sensitive=0
WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Subtraction'), sensitive=0
WIDGET_CONTROL, widget_info(base, find_by_uname='PCA'), sensitive=0
WIDGET_CONTROL, widget_info(base, find_by_uname='Both Decorr'), sensitive=0
WIDGET_CONTROL, widget_info(base, find_by_uname='Save Mask'), sensitive=0

catch, error_status ;Just stop and reactivate if there's an error
if error_status ne 0 then begin
    a=dialog_message('Recieved the following error: '+!error_state.msg, /error, dialog_parent=base)
    WIDGET_CONTROL, plotButton, sensitive=1
    WIDGET_CONTROL, undoButton, sensitive=1
    WIDGET_CONTROL, saveButton, sensitive=1
    WIDGET_CONTROL, loadButton, sensitive=1
    WIDGET_CONTROL, resetButton, sensitive=1
    WIDGET_CONTROL, offButton, sensitive=1
    WIDGET_CONTROL, onButton, sensitive=1
    WIDGET_CONTROL, scaleOnButton, sensitive=1
    WIDGET_CONTROL, scaleButton, sensitive=1
    WIDGET_CONTROL, rangeButton, sensitive=1
    WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), sensitive=1
    WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Subtraction'), sensitive=state.has_ms
    WIDGET_CONTROL, widget_info(base, find_by_uname='PCA'), sensitive=state.has_pca
    WIDGET_CONTROL, widget_info(base, find_by_uname='Both Decorr'), $
      sensitive=(state.has_ms and state.has_pca)
    WIDGET_CONTROL, widget_info(base, find_by_uname='Save Mask'), sensitive=0
    return, 0
endif

if ~keyword_set(all) then begin

    psderror=*state.psderror
    spectra=*state.spectra
    uber_excl_flags=*state.uber_excl_flags
    obs_labels=*state.obs_labels

    oldPsderrorMask=psderror.in1.mask
    oldSpectraMask=spectra.in1.mask
    
    if state.useAutoMask then begin
        psderror.in1.mask*=(*state.rangeMask)*(*state.currMask)
        spectra.in1.mask*=(*state.rangeMask)*(*state.currMask)
    endif else begin
        psderror.in1.mask=(*state.rangeMask)*(*state.currMask)
        spectra.in1.mask=(*state.rangeMask)*(*state.currMask)
    endelse

;Re-average the spectra
    WIDGET_CONTROL, /hourglass
    spectra_ave,spectra,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
      EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
      oneTag='in1'
    spectra_ave,psderror,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
      EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
      oneTag='in1'
    
    if state.has_jackknife then begin
        jackknife=*state.jackknife

        oldJackknifeMask=jackknife.in1.mask

        jackknife.in1.mask*=(*state.rangeMask)*(*state.currMask)
        spectra_ave,jackknife,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        ptr_free, state.jackknife

        jackknife.in1.mask=oldJackknifeMask
        state.jackknife=ptr_new(jackknife)
    endif
    state.changed=0
    
;Store the new averages
    psderror.in1.Mask=oldPsderrorMask
    spectra.in1.Mask=oldSpectraMask

    ptr_free, state.psderror
    ptr_free, state.spectra
    state.psderror=ptr_new(psderror)
    state.spectra=ptr_new(spectra)
    set_state, base,state
endif else begin
    WIDGET_CONTROL, /hourglass

    mask=(*state.rangeMask)*(*state.currMask)
    uber_excl_flags=*state.uber_excl_flags
    obs_labels=*state.obs_labels
    
    psderror=*state.uber_psderror
    spectra=*state.uber_spectra
    
    if state.useAutoMask then begin
        psderror.in1.mask*=mask
        spectra.in1.mask*=mask
    endif else begin
        psderror.in1.mask=mask
        spectra.in1.mask=mask
    endelse
    
     spectra_ave,spectra,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
      EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
      oneTag='in1'
    spectra_ave,psderror,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
      EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
      oneTag='in1'
    
    uber_psderror=psderror
    uber_spectra=spectra

    if state.has_jackknife then begin
        jackknife=*state.uber_jackknife
        jackknife.in1.mask=mask
        spectra_ave,jackknife,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        uber_jackknife=jackknife
    endif

    if state.has_ms then begin

        psderror=*state.ms_decorr_psderror
        spectra=*state.ms_decorr_spectra

        if state.useAutoMask then begin
            psderror.in1.mask*=mask
            spectra.in1.mask*=mask
        endif else begin
            psderror.in1.mask=mask
            spectra.in1.mask=mask
        endelse
        
        spectra_ave,spectra,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        spectra_ave,psderror,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        
        ms_decorr_psderror=psderror
        ms_decorr_spectra=spectra
        
        if state.has_jackknife then begin
            jackknife=*state.ms_decorr_jackknife
            jackknife.in1.mask=mask
            spectra_ave,jackknife,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
              EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
              oneTag='in1'
            ms_decorr_jackknife=jackknife
        endif
    endif
    if state.has_pca then begin
        psderror=*state.pca_decorr_psderror
        spectra=*state.pca_decorr_spectra
        
         if state.useAutoMask then begin
            psderror.in1.mask*=mask
            spectra.in1.mask*=mask
        endif else begin
            psderror.in1.mask=mask
            spectra.in1.mask=mask
        endelse
        
        spectra_ave,spectra,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        spectra_ave,psderror,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        
        pca_decorr_psderror=psderror
        pca_decorr_spectra=spectra
        
        if state.has_jackknife then begin
            jackknife=*state.pca_decorr_jackknife
            jackknife.in1.mask=mask
            spectra_ave,jackknife,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
              EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
              oneTag='in1'
            pca_decorr_jackknife=jackknife
        endif
    endif
    if state.has_pca and state.has_ms then begin
        psderror=*state.both_decorr_psderror
        spectra=*state.both_decorr_spectra

         if state.useAutoMask then begin
            psderror.in1.mask*=mask
            spectra.in1.mask*=mask
        endif else begin
            psderror.in1.mask=mask
            spectra.in1.mask=mask
        endelse
        
        spectra_ave,spectra,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        spectra_ave,psderror,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
          EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
          oneTag='in1'
        
        both_decorr_psderror=psderror
        both_decorr_spectra=spectra
        
        if state.has_jackknife then begin
            jackknife=*state.both_decorr_jackknife
            jackknife.in1.mask=mask
            spectra_ave,jackknife,ERRBIN=obs_labels.nnods,OUTLIERCUT=[2,2],$
              EXCLFLAGS=uber_excl_flags,OBS_LABELS=obs_labels,SIGMA_CUT=[10,3],$
              oneTag='in1'
            both_decorr_jackknife=jackknife
        endif
    endif
endelse 
   

;Reactivate
WIDGET_CONTROL, plotButton, sensitive=1
WIDGET_CONTROL, undoButton, sensitive=1
WIDGET_CONTROL, saveButton, sensitive=1
WIDGET_CONTROL, loadButton, sensitive=1
WIDGET_CONTROL, resetButton, sensitive=1
WIDGET_CONTROL, offButton, sensitive=1
WIDGET_CONTROL, onButton, sensitive=1
WIDGET_CONTROL, scaleOnButton, sensitive=1
WIDGET_CONTROL, scaleButton, sensitive=1
WIDGET_CONTROL, rangeButton, sensitive=1
WIDGET_CONTROL, scaleButton, sensitive=1
WIDGET_CONTROL, rangeButton, sensitive=1
WIDGET_CONTROL, widget_info(base, find_by_uname='No Decorr'), sensitive=1
WIDGET_CONTROL, widget_info(base, find_by_uname='Mean Subtraction'), sensitive=state.has_ms
WIDGET_CONTROL, widget_info(base, find_by_uname='PCA'), sensitive=state.has_pca
WIDGET_CONTROL, widget_info(base, find_by_uname='Both Decorr'), $
  sensitive=(state.has_ms and state.has_pca)
WIDGET_CONTROL, widget_info(base, find_by_uname='Save Mask'), sensitive=1
return,1
end

;---------------------------------------------------------------------------------------

;Create plots with the current mask
pro doPlots, base
state=get_state(base)

;If we changed the mask, re-average the spectra
;I'm using defaults from uber_spectrum
if state.changed then begin
   a=update_spectra(base)
   if a eq 0 then return
   state=get_state(base)
endif

psderror=*state.psderror
spectra=*state.spectra
uber_bolo_flags=*state.bolo_flags
uber_excl_flags=*state.uber_excl_flags
obs_labels=*state.obs_labels

m1=mean(spectra.in1.avespec/uber_bolo_flags, /nan)
m2=mean((spectra.in1.avespec/uber_bolo_flags)^2, /nan)
s=sqrt(m2-m1^2)


if ptr_valid(state.jackknife) then begin
    numPlots=3 
    jackknife=*state.jackknife
endif else numPlots=2

if widget_info(widget_info(base, find_by_uname='No Decorr'), /button_set) then prefix='uber' $
else if widget_info(widget_info(base, find_by_uname='Mean Subtraction'), /button_set) $
  then prefix='ms_decorr' $
else if widget_info(widget_info(base, find_by_uname='PCA'), /button_set) then prefix='pca_decorr' $
else prefix='both_decorr'

;Plot the results in new windows
;Commands taken from plot_uber_spectrum_jk
window, 1 
multiplot, [1,numPlots]
if numPlots eq 2 then xtit='Detector Channel, GHz' else xtit=''

plot, freqid2freq(), spectra.in1.avespec/(*state.bolo_flags), $
  psym=10,/ynoz, /yst, $
  ytit='Flux Density [Jy]',$
  xrange=xr,tit=prefix+'_spectra',/xst,/nodata,charsize=1.3,$
   _extra=ex, yr=[0,m1+2*s] 
oploterror, freqid2freq(), spectra.in1.avespec/(*state.bolo_flags), $
  spectra.in1.aveerr/(*state.bolo_flags), psym=10
multiplot
;window, 2
plot, freqid2freq(), psderror.in1.avespec/(*state.bolo_flags), $
  psym=10,/ynoz, /yst, $
  ytit='Flux Density [Jy]',$
  xrange=xr,tit=prefix+'_psderror',/xst,/nodata,charsize=1.3,$
  xtitle=xtit, _extra=ex, yr=[0,m1+2*s]
oploterror, freqid2freq(), psderror.in1.avespec/(*state.bolo_flags), $
  psderror.in1.aveerr/(*state.bolo_flags), psym=10

if numPlots eq 3 then begin
    multiplot
    plot, freqid2freq(), jackknife.in1.avespec/(*state.bolo_flags), $
      psym=10,/ynoz, /yst, $
      ytit='Flux Density [Jy]',$
      xrange=xr,tit=prefix+'_jackknife',/xst,/nodata,charsize=1.3,$
      xtitle='Detector Channel, GHz', _extra=ex, yr=[0,m1+2*s]
    oploterror, freqid2freq(), jackknife.in1.avespec/(*state.bolo_flags), $
      jackknife.in1.aveerr/(*state.bolo_flags), psym=10
endif
multiplot, [1,1]

r1=0.0 ;;initial guess for redshift
speci=['12CO']
transition=['2-1']
lfwhm=400. ;;km/s
fit=zspec_fit_lines_cont(*state.bolo_flags,spectra.in1.avespec,spectra.in1.aveerr,r1,speci,transition,$
                         lw_value=lfwhm,/z_fixed,/lw_fixed,/lw_tied,cont_type='PWRLAW')

window, 2 
multiplot, [1,numPlots]
plot, freqid2freq(), $
  (spectra.in1.avespec-fit.cspec)/spectra.in1.aveerr,ytit='S/N, contin. subtract.',psym=10,$
  xtit='',xrange=xr,/xsty, title=prefix+'_spectra significance'
hline,[-1,0,1],line=2

multiplot

fit=zspec_fit_lines_cont(*state.bolo_flags,psderror.in1.avespec,psderror.in1.aveerr,r1,speci,transition,$
                         lw_value=lfwhm,/z_fixed,/lw_fixed,/lw_tied,cont_type='PWRLAW')

plot, freqid2freq(), $
  (psderror.in1.avespec-fit.cspec)/psderror.in1.aveerr,ytit='S/N, contin. subtract.',psym=10,$
  xtit=xtit,xrange=xr,/xsty, title=prefix+'_psderror significance'
hline,[-1,0,1],line=2

if numPlots eq 3 then begin
    multiplot
    fit=zspec_fit_lines_cont(*state.bolo_flags,jackknife.in1.avespec,$
                             jackknife.in1.aveerr,r1,speci,transition,$
                             lw_value=lfwhm,/z_fixed,/lw_fixed,/lw_tied,cont_type='PWRLAW')
    
    plot, freqid2freq(), $
      (jackknife.in1.avespec-fit.cspec)/jackknife.in1.aveerr,ytit='S/N, contin. subtract.',psym=10,$
      xtit='Detector Channel [GHz]',xrange=xr,/xsty, title=prefix+'_jackknife significance'
    hline,[-1,0,1],line=2
endif

multiplot, /reset

end

;-----------------------------------------------------------------------------------------

;Reset the mask/averages to those in the original file
pro reset, base
state=get_state(base)

;restore, state.curFile ;Reopen the file

psderror=*state.psderror ;Clear out old results
spectra=*state.spectra
ptr_free, state.psderror
ptr_free, state.spectra


ptr_free, state.lastMask
s=size(psderror.in1.mask)
state.lastMask=ptr_new(*state.currMask)

uber_spectra=*state.uber_spectra
uber_bolo_flags=*state.bolo_flags
s=size(uber_spectra.in1.mask) ;Get rid of known bad channels
maskMult=uber_bolo_flags#replicate(1, s[2])

if widget_info(widget_info(base, find_by_uname='No Decorr'), /button_set) then begin
    spectra=*state.uber_spectra
    psderror=*state.uber_psderror
    if state.has_jackknife then jackknife=*state.uber_jackknife
endif else if widget_info(widget_info(base, find_by_uname='Mean Subtraction'), /button_set) then begin 
    spectra=*state.ms_decorr_spectra
    psderror=*state.ms_decorr_psderror
    if state.has_jackknife then jackknife=*state.ms_decorr_jackknife
endif else if widget_info(widget_info(base, find_by_uname='PCA'), /button_set) then begin
    spectra=*state.pca_decorr_spectra
    psderror=*state.pca_decorr_psderror
    if state.has_jackknife then jackknife=*state.pca_decorr_jackknife
endif else begin
    spectra=*state.both_decorr_spectra
    psderror=*state.both_decorr_psderror
    if state.has_jackknife then jackknife=*state.both_decorr_jackknife
endelse

;Store new data
spectra.in1.mask=spectra.in1.mask*maskMult
psderror.in1.mask=psderror.in1.mask*maskMult
state.spectra=ptr_new(spectra)
state.psderror=ptr_new(psderror)
state.changed=0
state.imageChanged=1
state.currMask=ptr_new(replicate(1,s[1],s[2]))

if state.has_jackknife then begin
    jackknife.in1.mask=jackknife.in1.mask*maskMult
    state.jackknife=ptr_new(jackknife)
endif else state.jackknife=ptr_new()

set_state, base, state

nodspecButton=widget_info(base, find_by_uname='Nodspec Button')
scaleMinText=widget_info(base, find_by_uname='Scale Min Text')
scaleMaxText=widget_info(base, find_by_uname='Scale Max Text')

if widget_info(nodspecButton, /button_set) then begin
    WIDGET_CONTROL, scaleMinText, set_value=$
      strcompress(string(min(psderror.in1.nodspec/psderror.in1.mask,/nan)),/remove_all) 

    WIDGET_CONTROL, scaleMaxText, set_value=$
      strcompress(string(max(psderror.in1.nodspec/psderror.in1.mask,/nan)),/remove_all)

endif else begin
    WIDGET_CONTROL, scaleMinText, set_value=$
      strcompress(string(min(psderror.in1.noderr/psderror.in1.mask,/nan)) ,/remove_all)
    WIDGET_CONTROL, scaleMaxText, set_value=$
      strcompress(string(max(psderror.in1.noderr/psderror.in1.mask,/nan)) ,/remove_all)
endelse

display, base                   ;Show them
end

;------------------------------------------------------------------------------------
;Save the current configuration
pro doSave, base

state=get_state(base)
saveText=widget_info(base, find_by_uname='Save Text')

if state.changed then begin
    a=update_spectra(base)
    if a eq 0 then return
    state=get_state(base)
endif

WIDGET_CONTROL, saveText, GET_VALUE=file
file=(strcompress(file, /remove_all))[0]

if file eq '' then begin
    time=repstr(repstr(systime(),' ','_'),':','.')
    source=strsplit(state.curFile, '/', /extract)
    file='nodspec_'+source[n_e(source)-2]+'_'+time+'.sav'
    a=dialog_message('No file name supplied; using '+file, dialog_parent=base)
endif

uber_bolo_flags=*state.bolo_flags
sourceFile=state.curFile
obs_labels=*state.obs_labels
uber_excl_flags=*state.uber_excl_flags
source_name=state.sourceName
z=state.z
ubername=state.ubername

a=update_spectra(base, all=1, uber_psderror=uber_psderror, uber_spectra=uber_spectra,$
         uber_jackknife=uber_jackknife, ms_decorr_psderror=ms_decorr_psderror,$
         ms_decorr_spectra=ms_decorr_spectra, ms_decorr_jackknife=ms_decorr_jackknife,$
         pca_decorr_psderror=pca_decorr_psderror, pca_decorr_spectra=pca_decorr_spectra,$
         pca_decorr_jackknife=pca_decorr_jackknife, $
         both_decorr_psderror=both_decorr_psderror,both_decorr_spectra=both_decorr_spectra,$
         both_decorr_jackknife=both_decorr_jackknife)

if a eq 0 then return

save, uber_psderror, uber_spectra, uber_bolo_flags, obs_labels, uber_excl_flags,$
  sourceFile,source_name, ubername, z, uber_jackknife, ms_decorr_psderror, ms_decorr_spectra, $
  ms_decorr_jackknife,pca_decorr_psderror,pca_decorr_spectra,pca_decorr_jackknife, $
  both_decorr_psderror,both_decorr_spectra, both_decorr_jackknife,filename=file

a=DIALOG_MESSAGE('Save Complete', /information, dialog_parent=base)

end

;------------------------------------------------------------------------------------
;Blanks out all nods beyond specified range
pro rangeCut, base
state=get_state(base)

lowRangeText=widget_info(base, find_by_uname='Low Range Text')
highRangeText=widget_info(base, find_by_uname='High Range Text')
nodspecButton=widget_info(base, find_by_uname='Nodspec Button')
undoButton=widget_info(base, find_by_uname='Undo Button')

WIDGET_CONTROL, lowRangeText, get_value=low
WIDGET_CONTROL, highRangeText, get_value=high

rangeMask=*state.rangeMask
s=size(rangeMask)
rangeMask=replicate(1, s[1],s[2])
psderror=*state.psderror

lowCut=0
highCut=0

;If a low range was provided...
if strcompress(low, /remove_all) ne '' then begin
    lowCut=1
    lowNum=verify_numeric_text_input(low, 'Lower range cutoff', base, /double) ;Verify
    if ~finite(lowNum) then return
    lowNum=lowNum[0] ;Cut out anything lower than it in the appropriate array
endif

;If a high range was provided
if strcompress(high, /remove_all) ne '' then begin
    highCut=1
    highNum=verify_numeric_text_input(high, 'Upper range cutoff', base, /double) ;Verify
    if ~finite(highNum) then return
    highNum=highNum[0] ;Cut out anything lower than it in the appropriate array
endif

if lowCut and highCut then begin
    if lowNum ge highNum then begin
        a=DIALOG_MESSAGE('Lower Range Cutoff must be <= Upper Range Cutoff', /error, dialog_parent=base)
        return
    endif
endif

if lowCut then begin

    if WIDGET_INFO(nodspecButton, /button_set) then begin
        w=where(psderror.in1.nodspec lt lowNum, c)
        if c ne 0 then rangeMask[w]=0
    endif else begin
        w=where(psderror.in1.noderr lt lowNum, c)
        if c ne 0 then rangeMask[w]=0
    endelse
endif

if highCut then begin
    if WIDGET_INFO(nodspecButton, /button_set) then begin
        w=where(psderror.in1.nodspec gt highNum, c)
        if c ne 0 then rangeMask[w]=0
    endif else begin
        w=where(psderror.in1.noderr gt highNum, c)
        if c ne 0 then rangeMask[w]=0
    endelse
endif 

s=size(rangeMask)
if ~lowCut and ~highCut then rangeMask=replicate(1, s[1],s[2])

ptr_free, state.rangeMask
state.rangeMask=ptr_new(rangeMask)
state.changed=1
state.imageChanged=1

WIDGET_CONTROL,undoButton, /sensitive

set_state, base, state ;Display
display, base
end

;------------------------------------------------------------------------------------
;Undoes the last change
pro undo, base
state=get_state(base)

currMask=*state.lastMask ;Restore the old Mask
ptr_free, state.currMask
state.currMask=ptr_new(currMask)

rangeMask=*state.lastMask
state.changed=1
state.imageChanged=1

undoButton=WIDGET_INFO(base, find_by_uname='Undo Button')
WIDGET_CONTROL, undoButton, sensitive=0 ;Can only undo most recent change

set_state, base, state
display, base

end

;-------------------------------------------------------------------------------------

;Top level event handler
;Determines what widget caused the event, and chooses the appropriate
;response function
PRO nodspecGUI_event, ev 

state=get_state(ev.top)

WIDGET_CONTROL, ev.id, GET_UVALUE = eventval
scaleOnButton=WIDGET_INFO(ev.top, find_by_uname='Scale On Button')
scaleMinText=WIDGET_INFO(ev.top, find_by_uname='Scale Min Text')
scaleMaxText=WIDGET_INFO(ev.top, find_by_uname='Scale Max Text')
scaleMinLabel=WIDGET_INFO(ev.top, find_by_uname='Scale Min Label')
scaleMaxLabel=WIDGET_INFO(ev.top, find_by_uname='Scale Max Label')

if eventval eq '' then return

case eventval of 

    'Load Button': loadFile, ev.top
    'Draw Frame': handle_mouse_event, ev
    'Reset Button': reset, ev.top
    'On Button': toggleNods, ev.top, widget_info(ev.top, find_by_uname='On Button')
    'Off Button': toggleNods, ev.top,widget_info(ev.top, find_by_uname='Off Button')
    'Plot Button': doPlots, ev.top
    'Save Button': doSave, ev.top
    'Nodspec Button': begin
        if state.curFile eq '' then return
        
                                ;Set scale info if autoscaling
        if ~widget_info(scaleOnButton, /button_set) then begin
            psderror=*state.psderror
            WIDGET_CONTROL, scaleMinText, set_value=$
              strcompress(string(min(psderror.in1.nodspec/psderror.in1.mask,/nan)) ,/remove_all)
            WIDGET_CONTROL, scaleMaxText, set_value=$
              strcompress(string(max(psderror.in1.nodspec/psderror.in1.mask,/nan)) ,/remove_all)
        endif

        imageChanged=1
        set_state, ev.top, state
        display, ev.top
    end
    'Noderr Button': begin
        if state.curFile eq '' then return
        
                                ;Set scale info if autoscaling
        if ~widget_info(scaleOnButton, /button_set) then begin
            psderror=*state.psderror
            WIDGET_CONTROL, scaleMinText, set_value=$
              strcompress(string(min(psderror.in1.noderr/psderror.in1.mask,/nan)) ,/remove_all)
            WIDGET_CONTROL, scaleMaxText, set_value=$
              strcompress(string(max(psderror.in1.noderr/psderror.in1.mask,/nan)) ,/remove_all)
        endif
        
        state.imageChanged=1
        set_state, ev.top, state
        display, ev.top
    end
    'Scale On Button': begin
        if WIDGET_INFO(scaleOnButton, /button_set) then begin
            WIDGET_CONTROL, scaleMinLabel, /sensitive
            WIDGET_CONTROL, scaleMaxLabel, /sensitive
            WIDGET_CONTROL, scaleMinText, /sensitive
            WIDGET_CONTROL, scaleMaxText, /sensitive
        endif else begin
            WIDGET_CONTROL, scaleMinLabel, sensitive=0
            WIDGET_CONTROL, scaleMaxLabel, sensitive=0
            WIDGET_CONTROL, scaleMinText, sensitive=0
            WIDGET_CONTROL, scaleMaxText, sensitive=0
        endelse
    end
    'Scale Button': begin
        state.imageChanged=1
        set_state, ev.top, state
        display, ev.top
    end
    'Range Button': rangeCut, ev.top
    'Undo Button': undo, ev.top

    'No Decorr': begin
        ptr_free, state.psderror
        ptr_free, state.spectra
        ptr_free, state.jackknife
        
        psderror=*state.uber_psderror
        spectra=*state.uber_spectra
        
        state.psderror=ptr_new(psderror)
        state.spectra=ptr_new(spectra)

        if state.has_jackknife then begin
            jackknife=*state.uber_jackknife
            jackknife.in1.mask=*state.currMask
            state.jackknife=ptr_new(jackknife)
        endif else state.jackknife=ptr_new()
        state.imageChanged=1
        state.changed=1
        set_state, ev.top, state
        display, ev.top
    end
    'Mean Subtraction': begin
        ptr_free, state.psderror
        ptr_free, state.spectra
        ptr_free, state.jackknife
        
        psderror=*state.ms_decorr_psderror
        spectra=*state.ms_decorr_spectra
        
        state.psderror=ptr_new(psderror)
        state.spectra=ptr_new(spectra)

        if state.has_jackknife then begin
            jackknife=*state.ms_decorr_jackknife
            jackknife.in1.mask=*state.currMask
            state.jackknife=ptr_new(jackknife)
        endif else state.jackknife=ptr_new()
        state.imageChanged=1
        state.changed=1
        set_state, ev.top, state
        display, ev.top
    end
    'PCA': begin
        ptr_free, state.psderror
        ptr_free, state.spectra
        ptr_free, state.jackknife
        
        psderror=*state.pca_decorr_psderror
        spectra=*state.pca_decorr_spectra
        
        state.psderror=ptr_new(psderror)
        state.spectra=ptr_new(spectra)

        if state.has_jackknife then begin
            jackknife=*state.pca_decorr_jackknife
            jackknife.in1.mask=*state.currMask
            state.jackknife=ptr_new(jackknife)
        endif else state.jackknife=ptr_new()
        state.imageChanged=1
        state.changed=1
        set_state, ev.top, state
        display, ev.top
    end
    'Both Decorr': begin
        ptr_free, state.psderror
        ptr_free, state.spectra
        ptr_free, state.jackknife
        
        psderror=*state.both_decorr_psderror
        spectra=*state.both_decorr_spectra
        
        state.psderror=ptr_new(psderror)
        state.spectra=ptr_new(spectra)

        if state.has_jackknife then begin
            jackknife=*state.both_decorr_jackknife
            jackknife.in1.mask=*state.currMask
            state.jackknife=ptr_new(jackknife)
        endif else state.jackknife=ptr_new()
        state.imageChanged=1
        state.changed=1
        set_state, ev.top, state
        display, ev.top
    end
    
    'Save Mask': begin
        state.imageChanged=1
        state.changed=1
        state.useAutoMask=WIDGET_INFO(WIDGET_INFO(ev.top, find_by_uname='Save Mask'), /button_set)
        set_state, ev.top, state
        display, ev.top
    end
    else: return
endcase

END 

;-------------------------------------------------------------------------------------

;Main initiator function
;Can optionally take size values for the window
PRO nodspec_gui, x, y, base_dir=base_dir
if ~keyword_set(x) then x=10 ;Default size in inches
if ~keyword_set(y) then y=4
if ~keyword_set(base_dir) then base_dir=!zspec_pipeline_root+$
  '/processing/spectra/coadded_spectra'

;Main frame and drawing area
  base = WIDGET_BASE(unit=1,/column, frame=5,/align_center,$
                    kill_notify='cleanup')
  drawBase=WIDGET_BASE(base, /row)
  drawFrame=WIDGET_DRAW(drawbase, /button_events, /motion_events, xsize=x, $
                        ysize=y, units=1, frame=2, uname='Draw Frame', uvalue='Draw Frame')
  gaussPanel=WIDGET_DRAW(drawBase, xsize=y, ysize=y, units=1, frame=2, uname='Gauss Panel', $
                         uvalue='Gauss Panel')
  gaussReadout=WIDGET_TEXT(drawBase, scr_xsize=y/2, ysize=y, units=1, /scroll, uname='Gauss Readout',$
                           uvalue='Gauss Readout')
  corrFrame=WIDGET_DRAW(drawbase, xsize=y,ysize=y, units=1, frame=2, uname='Corr Frame', uvalue='Corr Frame')
  topRow=WIDGET_BASE(base, /row, /align_center)
  
  ;Load and dimension controls
  loadFrame=WIDGET_BASE(topRow, /row, frame=10, /align_center)
  loadButton=WIDGET_BUTTON(loadFrame, value='Load File', uname='Load Button', uvalue='Load Button')
  dimsLabel=WIDGET_LABEL(loadFrame, value='Bolos: NaN  Nods: NaN', uname='Dims Label', uvalue='Dims Label')

  ;Decorr state controls
  decorrFrame=WIDGET_BASE(topRow, /column, frame=10, /align_center, /exclusive)
  no_decorr_button=WIDGET_BUTTON(decorrFrame, value='No Decorr', uname='No Decorr', uvalue='No Decorr')
  ms_decorr_button=WIDGET_BUTTON(decorrFrame, value='Mean Subtraction', uname='Mean Subtraction', $
                                 uvalue='Mean Subtraction', sensitive=0) 
  pca_decorr_button=WIDGET_BUTTON(decorrFrame, value='PCA',uname='PCA', uvalue='PCA', sensitive=0) 
  both_decorr_button=WIDGET_BUTTON(decorrFrame, value='Both',uname='Both Decorr', $
                                   uvalue='Both Decorr', sensitive=0) 
  WIDGET_CONTROL, no_decorr_button, /set_button
  
  ;Nodspec/noderr selection
  selectFrame=WIDGET_BASE(topRow, /column, frame=10, /exclusive, /align_center)
  nodspecButton=WIDGET_BUTTON(selectFrame, value='nodspec', uname='Nodspec Button', uvalue='Nodspec Button')
  noderrButton=WIDGET_BUTTON(selectFrame, value='noderr', uname='Noderr Button', uvalue='Noderr Button')
  WIDGET_CONTROL, nodspecButton, /set_button

  saveMaskFrame=WIDGET_BASE(topRow, /column, frame=10, /align_center, /nonexclusive)
  saveMaskButton=WIDGET_BUTTON(saveMaskFrame, value='Use Auto Flags?', uname='Save Mask', $
                               uvalue='Save Mask', sensitive=0)
  WIDGET_CONTROL, saveMaskButton, /set_button

  ;Controls to toggle ranges off and on
  toggleFrame=WIDGET_BASE(topRow, /row, frame=10, /align_center)
  lowBoloLabel=WIDGET_LABEL(toggleFrame, value='Bolo Start', sensitive=0, uname='Low Bolo Label')
  lowBoloText=WIDGET_TEXT(toggleFrame, xsize=5, sensitive=0, /editable, uname='Low Bolo Text', $
                          uvalue='Low Bolo Text')
  highBoloLabel=WIDGET_LABEL(toggleFrame, value='Bolo End', sensitive=0, uname='High Bolo Label')
  highBoloText=WIDGET_TEXT(toggleFrame, xsize=5, sensitive=0, /editable, uname='High Bolo Text', $
                           uvalue='High Bolo Text')
  lowNodLabel=WIDGET_LABEL(toggleFrame, value='Nod Start', sensitive=0, uname='Low Nod Label')
  lowNodText=WIDGET_TEXT(toggleFrame, xsize=5, sensitive=0, /editable,uname='Low Nod Text', $
                           uvalue='Low Nod Text')
  highNodLabel=WIDGET_LABEL(toggleFrame, value='Nod End', sensitive=0, uname='High Nod Label')
  highNodText=WIDGET_TEXT(toggleFrame, xsize=5, sensitive=0, /editable,uname='High Nod Text', $
                           uvalue='High Nod Text')
  offButton=WIDGET_BUTTON(toggleFrame, sensitive=0, value='OFF', uname='Off Button', uvalue='Off Button')
  onButton=WIDGET_BUTTON(toggleFrame, sensitive=0, value='ON', uname='On Button', uvalue='On Button')

  midrow=WIDGET_BASE(base, /row, /align_center)

  rangeFrame=WIDGET_BASE(midRow, /row, frame=10, /align_center)
  lowRangeLabel=WIDGET_LABEL(rangeFrame, value='Cut Minimum', sensitive=0, uname='Low Range Label')
  lowRangeText=WIDGET_TEXT(rangeFrame, xsize=10, sensitive=0, /editable, uname='Low Range Text', $
                           uvalue='Low Range Text')
  highRangeLabel=WIDGET_LABEL(rangeFrame, value='Cut Maximum', sensitive=0, uname='High Range Label')
  highRangeText=WIDGET_TEXT(rangeFrame, xsize=10, sensitive=0, /editable, uname='High Range Text', $
                            uvalu='High Range Text')
  rangeButton=WIDGET_BUTTON(rangeFrame, sensitive=0, value='Cut', uname='Range Button', $
                            uvalue='Range Button')
    
   ;Mouse pointer data
  mouseBox=WIDGET_BASE(midRow, /column, frame=10, /align_center)
  mouseXText=WIDGET_LABEL(mouseBox, value='Bolo: NA', xsize=100, uname='Mouse X Text')
  mouseYText=WIDGET_LABEL(mouseBox, value='Nod: NA', xsize=100, uname='Mouse Y Text')
  mouseValText=WIDGET_LABEL(mouseBox, value='Value: NA', xsize=100, uname='Mouse Val Text')

  ;Reset/plot button
  buttonBase=WIDGET_BASE(midRow, /align_center, /row, ysize=2, units=2)
  resetButton=WIDGET_BUTTON(buttonBase, sensitive=0, value='Reset', uname='Reset Button', $
                            uvalue='Reset Button')
  plotButton=WIDGET_BUTTON(buttonBase, sensitive=0, value='Plot', uname='Plot Button', uvalue='Plot Button')
  undoButton=WIDGET_BUTTON(buttonBase, sensitive=0, value='Undo', uname='Undo Button', uvalue='Undo Button')
  
  lastRow=WIDGET_BASE(base, /row,/align_center)

                                ;Intensity scaling controls
  scaleBase=WIDGET_BASE(lastRow, /row, frame=10, /align_center)
  scaleSubBase=WIDGET_BASE(scaleBase, /nonexclusive)
  scaleOnButton=WIDGET_BUTTON(scaleSubBase, value='Change Scale', sensitive=0, uname='Scale On Button',$
                              uvalue='Scale On Button')
  scaleMinLabel=WIDGET_LABEL(scaleBase, value='Scale Min', sensitive=0, uname='Scale Min Label', $
                             uvalue='Scale Min Label')
  scaleMinText=WIDGET_TEXT(scaleBase, xsize=10, /editable, sensitive=0, uname='Scale Min Text', $
                             uvalue='Scale Min Text')
  scaleMaxLabel=WIDGET_LABEL(scaleBase, value='Scale Max', sensitive=0, uname='Scale Max Label', $
                             uvalue='Scale Max Label')
  scaleMaxText=WIDGET_TEXT(scaleBase, xsize=10, /editable, sensitive=0, uname='Scale Max Text', $
                             uvalue='Scale Max Text')
  scaleButton=WIDGET_BUTTON(scaleBase, value='Rescale Image', sensitive=0, uname='Scale Button', $
                             uvalue='Scale Button')
  
  ;Save button/text field
  saveBase=WIDGET_BASE(lastRow, /column, frame=10)
  saveButton=WIDGET_BUTTON(saveBase, sensitive=0, value='Save Configuration', uname='Save Button', $
                           uvalue='Save Button')
  saveText=WIDGET_TEXT(saveBase, xsize=50, ysize=1,sensitive=0, /editable, uname='Save Text', $
                       uvalue='Save Text')
  
  extremesBase=WIDGET_BASE(lastRow, /column, /align_center, frame=10)
  maxLabel=WIDGET_LABEL(extremesBase, value='Max: NA', /dynamic_resize,sensitive=0, $
                        uname='Max Label', uvalue='Max Label')
  minLabel=WIDGET_LABEL(extremesBase, value='Min: NA', /dynamic_resize,sensitive=0,$
                        uname='Min Label', uvalue='Min Label')
  meanLabel=WIDGET_LABEL(extremesBase, value='Mean: NA', /dynamic_resize,sensitive=0, $
                         uname='Mean Label', uvalue='Mean Label')
  stdevLabel=WIDGET_LABEL(extremesBase, value='STDEV: NA', /dynamic_resize,sensitive=0,$
                          uname='Stdev Label', uvalue='Stdev Label')

    ;Source name and file info
  nameBase=WIDGET_BASE(base, /row, /align_center)
  sourceNameLabel=WIDGET_LABEL(nameBase, value='Source: NA', /dynamic_resize, $
                               uname='Source Name Label', uvalue='Source Name Label')
  fileLabel=WIDGET_LABEL(nameBase, value='File: NA', /dynamic_resize, uname='File Label', $
                         uvalue='File Label')

  WIDGET_CONTROL, base, /REALIZE ;Show GUI

  loadct, 0

  ;Store everything in a big state structure
  geometry=widget_info(drawFrame, /geometry) ;Drawing area geometry in pixels
  WIDGET_CONTROL, drawFrame, get_value=wid
  state={psderror:ptr_new(), spectra:ptr_new(),jackknife:ptr_new(),curFile:'',$
         bolo_flags:ptr_new(),mouseStart:[!values.f_nan, !values.f_nan], $
         obs_labels:ptr_new(),uber_excl_flags:ptr_new(),changed:0, cancelled:0,$
         scaledImage:PTR_NEW(), imageChanged:0, sourceName:'', rangeMask:ptr_new(), $
         lastMask:ptr_new(),currMask:ptr_new(),ubername:'', z:'',corr:ptr_new(), corrImage:ptr_new(),$
         gaussProbs:ptr_new(), decorr_state:'None', uber_psderror:ptr_new(), uber_spectra:ptr_new(),$
         uber_jackknife:ptr_new(), ms_decorr_psderror:ptr_new(), ms_decorr_spectra:ptr_new(),$
         ms_decorr_jackknife:ptr_new(), pca_decorr_psderror:ptr_new(), pca_decorr_spectra:ptr_new(), $
         pca_decorr_jackknife:ptr_new(),both_decorr_psderror:ptr_new(), both_decorr_spectra:ptr_new(),$
         both_decorr_jackknife:ptr_new(), has_jackknife:0, has_ms:0, has_pca:0, useAutoMask:1,$
         pixID:-1,xsize:geometry.draw_xsize, ysize:geometry.draw_ysize, wid:wid, base_dir:base_dir,$
         imageMask:ptr_new()}

   ;Store this structure in the base widget uvalue
  widget_control, base, set_uvalue=ptr_new(state)
  
  XMANAGER, 'nodspecGUI', base, /no_block  ;Register event handler
END
