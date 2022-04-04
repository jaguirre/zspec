; To correctly read a sav file as an appropriate file for zilf, it
; must have:
; uber_spectra OR uber_psderror structures
; ubername
; source_name
; z

; Things to add:
; 
; Allow the fitter tolerance to be entered
;
; Allow mystery lines to be entered directly, rather than from the
; file.  Will have to set some upper limit.
;
; Each line should have the ability to 
; - tie the linewidth to the group value, or fit independently
;   if fitting independently, should be able to set the initial guess

pro set_chosen_weighting

; It's kind of a silly thing, but I have to do it in a couple of
; places, so make it a function.

common state,state

if (state.use_bin eq 1) then begin
    state.spec = state.spec_binw
    state.err = state.err_binw
    state.covar=state.covar_binw
endif else if state.use_bin eq 2 then begin
    state.spec = state.spec_jackknife
    state.err = state.err_jackknife
    state.covar=state.covar_jackknife
endif else begin
    state.spec = state.spec_psdw
    state.err = state.err_psdw
    state.covar=state.covar_psdw
endelse

end


;----------------------------------------------------------------------------
;Generates report file
pro doReport

common state, state

;Only do this if the fit is current
if ~state.fit_is_current or ~state.fit_is_defined or ~state.spectrum_is_defined then begin
    a=dialog_message('Fit is not up to date. Plase run the fit first', /error, $
                     dialog_parent=state.master_widget_base)
    return
endif

;Name the output file
if ~state.customName then file='zilf_fit_report.eps' $
else if state.out_file_name ne '' then file=state.out_file_name+'_fit_report.eps' $
else begin
    a=dialog_message('Custon name requested but not entered; using "zilf_fit_report"', $
                     dialog_parent=event.top)
    file='zilf_fit_report.eps'
endelse

set_plot, 'ps'
device, encap=0, /color, file=file

multiplot, [1,3]

if (state.xunits eq 0) then begin
    x = state.nu 
    xlabel = 'Frequency (GHz)'
endif else begin
    x = state.chan
    xlabel = 'Channel Number'
endelse

whlines = where(state.lines_to_fit eq 1,linecount)

;Plot the spectrum with fit overplotted
ploterror,x,state.spec/state.flags,state.err/state.flags,$
  /xst,/yst,$
  xrange=state.xrange_current,yrange=state.yrange_current,$
  psy=10, ytit='Spectrum and Fit [Jy]'

oplot,x,state.lcspec,psy=10,col=2

;Mark the lines we fit to
vline, state.frequency[whlines]/(1+state.z), col=4
xyouts, state.frequency[whlines]/(1+state.z), $
  .3*total(state.yrange_current), $
  state.species[whlines]+' ' +state.transition[whlines], orientation=90, col=4

multiplot

;Plot the fit residuals
ploterror,x,(state.spec-state.lcspec)/state.flags,state.err/state.flags,$
  /xst,/yst,$
  xrange=state.xrange_current,$
  psy=10, ytit='Fit Residuals'

;Mark the lines we fit to
vline, state.frequency[whlines]/(1+state.z), col=4

multiplot

;Plot the S/N 
plot, x, (state.spec-state.lcspec)/(state.flags*state.err), $
  /xst,/yst,$
  xrange=state.xrange_current,$
  psy=10, ytit='S/N', xtit=xlabel

;Mark the lines we fit to
vline, state.frequency[whlines]/(1+state.z), col=4
      
multiplot, /reset

erase ;Next Page

widget_control, state.report_wid, get_value=report

;Display the 'report' data from zilf
case 1 of 
    (WIDGET_INFO(widget_info(state.master_widget_base,find_by_uname='Corr Base'), /button_set) eq 1): decorr_state='None'
    (WIDGET_INFO(widget_info(state.master_widget_base,find_by_uname='Corr MS'), /button_set) eq 1): decorr_state='Mean Subtraction'
    (WIDGET_INFO(widget_info(state.master_widget_base,find_by_uname='Corr PCA'), /button_set) eq 1): decorr_state='PCA'
    (WIDGET_INFO(widget_info(state.master_widget_base,find_by_uname='Corr Both'), /button_set) eq 1): decorr_state='Both'
endcase

report=['                   Global', '','Source: '+state.source_name+' File: '+state.short_filename, $
        'Decorrelation Method: '+decorr_state,report]
newline='!C'
report=strjoin(report+newline)
xyouts, 0, .96, report, /normal

fit=*state.fit 
fixed=state.fixed
fixed2=replicate('No', n_e(fixed))
w=where(fixed, c)
if c gt 0 then fixed2[w]='Yes'
limits=state.limits
startvals=state.startvals
N=n_e(fixed2)

erase

;Continuum data
format='(A-21,G-12.4,G-12.4,A-8,G-12.4,G-12.4,G-12.4)'
continuumData='                   Continuum Results'
continuumData=[continuumData, string('Property', 'Value', 'Error','Fixed?', 'Lower Limit', 'Upper Limit', 'Starting Value', $
                                format='(A-21,A-14,A-14,A-8,A-12,A-12,A-12)')]
continuumData=[continuumData, string('Continuum Amplitude:',fit.camp, fit.caerr, fixed2[N-2], $
                               limits[N-2,0], limits[N-2,1],startvals[N-2],$
                               format=format)]
continuumData=[continuumData, string('Continuum Exponent:',fit.cexp, fit.ceerr, fixed2[N-1], $
                               limits[N-1,0], limits[N-1,1],startvals[N-1],$
                               format=format)]
xyouts, 0, .96, strjoin(continuumData+newline), charsize=.9,/normal

;Plot fit data for each source
;Includes limits/whether or not it was fixed
format='(A-18,A-10,G-12.4,G-12.4,A-8,G-12.4,G-12.4,G-12.4)'
for i=0, linecount-1 do begin
    erase

    ;Name
    linedata='                   '+state.species[whlines[i]]+' ' +state.transition[whlines[i]]

                                ;Frequency (rest and shifted)
    lineData=[lineData, strcompress(string(fit.centers[i], fit.xall.line_freqs[i],fit.scales[i],$
                                    format='("Rest Freq: ",G20.5, " GHz  Center   Freq: ",G20.5, '+$
                                           '" GHz    Scale Factor: ", G20.5)'))]

    lineData=[lineData, '']

    lineData=[lineData, string('Property', 'Units', 'Value', 'Error','Fixed?', 'Lower Limit', 'Upper Limit', 'Starting Value', $
                                format='(A-18,A-10,A-14,A-14,A-8,A-12,A-12,A-12)')]

    
    ;Amplitude in Jy km/s
    lineData=[lineData, string('Flux Amplitude:', 'Jy km/s',fit.amplitude[i], fit.amperr[i], fixed2[whlines[i]*3], $
                               limits[whlines[i]*3,0], limits[whlines[i]*3,1],startvals[whlines[i]*3],$
                               format=format)]
  
    ;Convert amplitude to K km/s
    fit.amplitude[i]=zspec_jytok(fit.amplitude[i], fit.centers[i])
    fit.amperr[i]=zspec_jytok(fit.amperr[i], fit.centers[i])
    limits[whlines[i]*3, *]=zspec_jytok(limits[whlines[i]*3,*], fit.centers[i])
    lineData=[lineData, string('Flux Amplitude:', 'K km/s',fit.amplitude[i], fit.amperr[i], fixed2[whlines[i]*3], $
                               limits[whlines[i]*3,0], limits[whlines[i]*3,1],startvals[whlines[i]*3],$
                               format=format)]

   ;Line Width
    lineData=[lineData, string('Line Width', 'km/s',fit.width[i], fit.widtherr[i], fixed2[whlines[i]*3+1], $
                               limits[whlines[i]*3+1,0], limits[whlines[i]*3+1,1], startvals[whlines[i]*3+1], $
                               format=format)]
  
    ;Unitless redshift
    c=2.99792458e5
    if state.zunits eq 0 then begin
        fit.redshift[i]*=c
        fit.zerr[i]*=c
        limits[whlines[i]*3+2, *]*=c
        startvals[whlines[i]*3+2]*=c
    endif
    lineData=[lineData, string('Redshift', 'NA',fit.redshift[i], fit.zerr[i], fixed2[whlines[i]*3+2], $
                               limits[whlines[i]*3+2,0], limits[whlines[i]*3+2,1], startvals[whlines[i]*3+2],$
                               format=format)]

    ;Redshift in km/s
    fit.redshift[i]/=c
    fit.zerr[i]/=c
    limits[whlines[i]*3+2, *]/=c
    startvals[whlines[i]*3+2]/=c
    lineData=[lineData, string('Redshift', 'km/s',fit.redshift[i], fit.zerr[i], fixed2[whlines[i]*3+2], $
                               limits[whlines[i]*3+2,0], limits[whlines[i]*3+2,1], startvals[whlines[i]*3+2],$
                               format=format)]

    xyouts, 0, .96, strjoin(lineData+newline), charsize=.9,/normal
       
endfor

device,/close
set_plot,'x'
!p.color = 0
!p.background = 1

;Just in case this doesn't exist
fit=*state.fit
save, fit, file=repstr(file, '_report.eps', '.sav')

;Make output tex file
fittable_tex, state.source_name, repstr(file, '_report.eps', '.sav'),repstr(file, '.eps', '.tex'), $
  graphics=state.master_widget_base
   
 end

;-----------------------------------------------------------------------------
; Define parameter limits widget

;Tests if a string is a double
function isDouble, str
match=stregex(str, '-?[0123456789]*\.?[0123456789]*', /extract) ;Match it to a digit regex
if match ne str then return, 0 ;Only a number of regex match IS the string
return, 1 
end

;Toggle whether parameter is fixed in the fit
pro fixed_toggle, event, string, index
common state, state
fixed=state.fixed

;Disable limits if it's fixed and vice-versa
id=WIDGET_INFO(event.TOP,find_by_uname=string+'_low')
WIDGET_CONTROL, id, sensitive=~WIDGET_INFO(id, /sensitive)
id=WIDGET_INFO(event.TOP,find_by_uname=string+'_high')
WIDGET_CONTROL, id, sensitive=~WIDGET_INFO(id, /sensitive)

fixed[index]=~fixed[index] ;Toggle state
state.fixed=fixed

end

;Set the fit limits
pro set_limit, event, string, index, limit

common state, state
limits=state.limits

;Which limit to set
if limit eq '_low' then limIndex=0 else limIndex=1

id=WIDGET_INFO(event.TOP,find_by_uname=string+limit)
WIDGET_CONTROL, id, get_value=val

;Use NAN to signal no limit, otherwise se the limit
if strcompress(val, /remove_all) eq '' then limits[index, limIndex]=!values.D_NAN $ ;Blank means no limit
else if isDouble(val) then limits[index, limIndex]=double(val) $ ;Set the limit if it's a valid double
else begin
    widget_control, id, set_value='' ;Blank it if it's not a valid real number
    limits[index, limIndex]=!values.D_NAN
endelse

state.limits=limits
end

;Set the parameter start value
pro set_start, event, string, index

common state, state
startvals=state.startvals

id=WIDGET_INFO(event.TOP,find_by_uname=string+'_startval')
WIDGET_CONTROL, id, get_value=val

;Use NAN to signal no limit, otherwise se the limit
if strcompress(val, /remove_all) eq '' then startvals[index]=!values.D_NAN $;Blank means no limit
else if isDouble(val) then startvals[index]=double(val) $;Set the limit if it's a valid double
else begin
    widget_control, id, set_value='';Blank it if it's not a valid real number
    startvals[index]=!values.D_NAN
endelse

state.startvals=startvals
end

;Get the state structure parameter index and widget id of whatever generated the event
function find_id_and_index, eventval
common state, state

w=where(state.lines_to_fit, c) ;Currently selected lines
params=['Amplitude', 'Width', 'Z']

for i=0, c-1 do begin
    baseString=state.species[w[i]]+'_' +state.transition[w[i]] ;Which transition was set

    if strpos(eventval, baseString) ge 0 then begin
        for j=0, n_e(params)-1 do begin
            string=baseString+'_'+params[j] ;Which parameter for that transition
            if strpos(eventval, string) ge 0 then return, create_struct('string', string, 'index', 3*w[i]+j)
        endfor
    endif
endfor

return, -1 ;Didn't find anything. It should never get here. 

end

;Handle parameter limit events
pro zilf_param_limits_event, event

common state, state

N=n_e(state.fixed) ;Number of possible line parameters

WIDGET_CONTROL, event.id, GET_UVALUE = eventval	

if eventval eq 'Close' then begin ;Exit if close button was clicked
    widget_control, event.top, /destroy
    return
endif

;Get the id of the calling widget and index of the corresponding parameter
if strpos(eventval, 'camp') ge 0 then begin
    string='camp' & index=N-2
endif else if strpos(eventval, 'cexp') ge 0 then begin
    string='cexp' & index=N-1 
endif else begin
    a=find_id_and_index(eventval)
    s=size(a)
    if s[0] eq 0 then begin
        if a eq -1 then return
    endif
    string=a.string
    index=a.index
endelse

;Do what was asked
if strpos(eventval, 'fixed') ge 0 then fixed_toggle, event, string, index $
else if strpos(eventval, 'low') ge 0 then set_limit, event, string, index, '_low' $
else if strpos(eventval, 'high') ge 0 then set_limit, event, string, index, '_high' $
else set_start, event, string, index

state.fit_is_current = 0
widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event

end

;Creates the parameter limit GUI
;Dynamically generates fields for all selected lines
pro zilf_param_limits

common state, state

param_base=widget_base(group_leader=state.master_widget_base,/column, title='Parameter Limits')
w=where(state.lines_to_fit, c); Only use selected lines

fixed=state.fixed
limits=state.limits
startvals=state.startvals
N=n_e(fixed)

strings=['Amplitude', 'Width', 'Z']

;Limits for each species
if c ne 0 then for i=0, c-1 do begin
    label=widget_label(param_base, /align_center, $
                       value=state.species[w[i]]+' ' +state.transition[w[i]]) ;Species+transition name

    subbase=widget_base(param_base, /row, frame=2)
    for j=0, n_e(strings)-1 do begin
        
                                ;For each paramter listed in 'strings'
                                ;above, created a 'Fixed' button, and
                                ;input fields for lower limit, upper
                                ;limit, and starting value
        label=widget_label(subbase, /align_center, $
                           value=strings[j])
        fixedButton=cw_bgroup(subbase, 'Fixed', /nonexclusive, /row,$
                              uvalue=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_fixed',$
                              uname=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_fixed')
        startVal=cw_field(subbase, /all_events, title='Start value:', $
                          uvalue=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_startval',$
                          uname=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_startval', xsize=10)
        lowField=cw_field(subbase, /all_events, title='Low:', $
                          uvalue=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_low',$
                          uname=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_low', xsize=10)
        highField=cw_field(subbase, /all_events, title='High:', $
                       uvalue=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_high',$
                           uname=state.species[w[i]]+'_' +state.transition[w[i]]+'_'+strings[j]+'_high', xsize=10)
        
                                ;If z_fixed or lw_fixed were set by
                                ;other routines, disable their limits here
        if (j eq 2 and state.z_fixed) or (j eq 1 and state.lw_fixed) then begin 
            widget_control, fixedButton, sensitive=0
            widget_control, lowField, sensitive=0
            widget_control, highField, sensitive=0
        endif

                                ;Disable limits if we already said
                                ;this was fixed (as in, the last time
                                ;this window was open)
        if fixed[w[i]*3+j] then begin
            widget_control, fixedButton, set_value=[1]
            widget_control, lowField, sensitive=0
            widget_control, highField, sensitive=0
        endif

                                ;Set starting values based on prior
                                ;selections or other windows
        if finite(startvals[w[i]*3+j]) then widget_control, startVal, set_value=string(startvals[w[i]*3+j]) $
        else if j eq 2 then begin
            widget_control, startVal, set_value=string(state.redshift) 
            state.startvals[w[i]*3+j]=state.redshift
        endif else if j eq 1 then begin
            widget_control, startVal, set_value=string(state.lw_value)
            state.startvals[w[i]*3+j]=state.lw_value
        endif 
        
                                ;Set limits if they were preselected
        if finite(startvals[w[i]*3+j]) then widget_control, startVal, set_value=string(startvals[w[i]*3+j])
        if finite(limits[w[i]*3+j, 0]) then widget_control, lowField, set_value=string(limits[w[i]*3+j,0])
        if finite(limits[w[i]*3+j, 1]) then widget_control, highField, set_value=string(limits[w[i]*3+j,1])

    endfor
endfor

;Limits for continuum amplitude
subbase=widget_base(param_base, /row, frame=2)
label=widget_label(subbase, /align_center, $
                   value='Continuum Amplitude')
fixedButton=cw_bgroup(subbase, 'Fixed', /nonexclusive, /row,$
                      uvalue='camp_fixed',$
                      uname='camp_fixed')
startVal=cw_field(subbase, /all_events, title='Start value:', $
                          uvalue='camp_startval',$
                          uname='camp_startval', xsize=10)
lowField=cw_field(subbase, /all_events, title='Low:', $
                  uvalue='camp_low',$
                  uname='camp_low', xsize=10)
highField=cw_field(subbase, /all_events, title='High:', $
                   uvalue='camp_high',$
                   uname='camp_high', xsize=10)

if fixed[N-2] then begin
    widget_control, fixedButton, set_value=[1]
    widget_control, lowField, sensitive=0
    widget_control, highField, sensitive=0
endif

if finite(startvals[N-2]) then widget_control, startVal, set_value=string(startvals[N-2])
if finite(limits[N-2, 0]) then widget_control, lowField, set_value=string(limits[N-2,0])
if finite(limits[N-2, 1]) then widget_control, highField, set_value=string(limits[N-2,1])

;if finite(state.

;Limits for continuum exponent
subbase=widget_base(param_base, /row, frame=2)
label=widget_label(subbase, /align_center, $
                   value='Continuum Exponent')
fixedButton=cw_bgroup(subbase, 'Fixed', /nonexclusive, /row,$
                      uvalue='cexp_fixed',$
                      uname='cexp_fixed')
startVal=cw_field(subbase, /all_events, title='Start value:', $
                          uvalue='cexp_startval',$
                          uname='cexp_startval', xsize=10)
lowField=cw_field(subbase, /all_events, title='Low:', $
                  uvalue='cexp_low',$
                  uname='cexp_low', xsize=10)
highField=cw_field(subbase, /all_events, title='High:', $
                   uvalue='cexp_high',$
                   uname='cexp_high', xsize=10)

if fixed[N-1] then begin
    widget_control, fixedButton, set_value=[1]
    widget_control, lowField, sensitive=0
    widget_control, highField, sensitive=0
endif

if finite(startvals[N-1]) then widget_control, startVal, set_value=string(startvals[N-1])
if finite(limits[N-1, 0]) then widget_control, lowField, set_value=string(limits[N-1,0])
if finite(limits[N-1, 1]) then widget_control, highField, set_value=string(limits[N-1,1])

;Kill switch
close=widget_button(param_base, value='Close', uvalue='Close')

WIDGET_CONTROL, param_base, /realize
XMANAGER, 'zilf_param_limits', param_base, $
  EVENT_HANDLER = 'zilf_param_limits_event', no_block = 1

end

; -----------------------------------------------------------------------------
; Define the widget that allows file selection and its event handler

pro zilf_read_file_event, event

common state, state

WIDGET_CONTROL, event.id, GET_UVALUE = eventval	

widget_control,widget_info(event.top,find='Read File'),get_value=file

found_struct = 0

; Set up error handling in case the user decides to click on a non-sav file
is_savfile = 1
CATCH, Error_status
;This statement begins the error handler:
IF  Error_status NE 0 THEN BEGIN
    print, !error_state.msg
    msg =  'Error index: ' + string(Error_status)+'!C' + $
      'Error message: ' + !ERROR_STATE.MSG
    msg = 'Selected file is not an IDL sav file'
    ok = dialog_message(msg,/error,/center, dialog_parent=event.top)
; Handle the error
    is_savfile = 0
    CATCH, /CANCEL
ENDIF

case eventval of
    
    'Read File' : begin
        
; Check that the file exists
        if (file_search(file) eq '') then begin
            print,'File not found'
            state.draw_plot = 0
        endif else begin
            if (is_savfile) then begin
; Need to error check that the file is actually an uber_spectrum file
                found_struct = 0
                sobj = obj_new('IDL_Savefile',file)
                names = sobj->Names()
                has_jackknife=0
                for ncheck = 0,n_e(names)-1 do begin
                    if (names[ncheck] eq 'UBER_SPECTRA' or $
                        names[ncheck] eq 'UBER_PSDERROR') then found_struct = 1
                    if names[ncheck] eq 'UBER_JACKKNIFE' then has_jackknife=1
                endfor

                whlines=where(state.lines_to_fit, linecount)
                if (found_struct) then begin
                    sobj->Restore,names[*]
                    state.spectrum_is_defined=1
                    state.filename = ubername
                    temp = strsplit(ubername,'/',/extract)
                    state.short_filename = temp[n_e(temp)-1]
                    state.source_name = source_name

                    widget_control,state.source_name_wid,$
                      set_value=state.source_name
                    widget_control,state.filename_wid,   $
                      set_value=state.short_filename

                    state.redshift_from_file = double(z)
                    state.redshift = double(z)

                    if linecount gt 0 then state.startvals[3*whlines+2]=double(z)
                    
                    tags=tag_names(uber_psderror.in1)
                    w=where(tags eq 'CORR', count)
                    if count eq 0 then has_corr=0 else has_corr=1
                    
                    ID=widget_info(state.master_widget_base,find_by_uname='covar_fit')
                    WIDGET_CONTROL, id, sensitive=has_corr

                    state.spec_binw = uber_spectra.in1.avespec
                    state.err_binw = uber_spectra.in1.aveerr
                    if has_corr then state.covar_binw=uber_spectra.in1.corr*(state.err_binw#state.err_binw)

                    state.spec_psdw = uber_psderror.in1.avespec
                    state.err_psdw = uber_psderror.in1.aveerr
                    if has_corr then state.covar_psdw=uber_psderror.in1.corr*(state.err_psdw#state.err_psdw)

                    state.base_binw_spec=uber_spectra.in1.avespec
                    state.base_binw_err=uber_spectra.in1.aveerr
                    if has_corr then state.base_binw_covar=uber_spectra.in1.corr*(state.base_binw_err#state.base_binw_err)

                    state.base_psdw_spec=uber_psderror.in1.avespec
                    state.base_psdw_err=uber_psderror.in1.aveerr
                    if has_corr then state.base_psdw_covar=uber_psderror.in1.corr*(state.base_psdw_err#state.base_psdw_err)

                    if has_jackknife then begin
                        state.base_jackknife_spec=uber_jackknife.in1.avespec
                        state.base_jackknife_err=uber_jackknife.in1.aveerr
                        
                        state.spec_jackknife=uber_jackknife.in1.avespec
                        state.err_jackknife=uber_jackknife.in1.aveerr
                        if has_corr then state.base_jackknife_covar=uber_jackknife.in1.corr*$
                          (state.base_jackknife_err#state.base_jackknife_err)
                    
                        ID=widget_info(state.master_widget_base,find_by_uname='Jackknife')
                        WIDGET_CONTROL, id, /sensitive
                    endif else begin
                        ID=widget_info(state.master_widget_base,find_by_uname='Jackknife')
                        WIDGET_CONTROL, id, sensitive=0
                    endelse
            
                    ID=widget_info(state.master_widget_base,find_by_uname='Corr Base')
                    WIDGET_CONTROL, id, /sensitive
                    WIDGET_CONTROL, id, /set_button
                    s1=size(MS_decorr_psderror)
                    ID=widget_info(state.master_widget_base,find_by_uname='Corr MS')
                    if s1[n_e(s1)-1] ne 0 then begin
                        WIDGET_CONTROL, id, /sensitive 
                        state.MS_decorr_binw_spec=MS_decorr_spectra.in1.avespec
                        state.MS_decorr_binw_err=MS_decorr_spectra.in1.aveerr
                        if has_corr then state.MS_decorr_binw_covar=MS_decorr_spectra.in1.corr*$
                          (state.MS_decorr_binw_err#state.MS_decorr_binw_err)
                        state.MS_decorr_psdw_spec=MS_decorr_psderror.in1.avespec
                        state.MS_decorr_psdw_err=MS_decorr_psderror.in1.aveerr
                        if has_corr then state.MS_decorr_psdw_covar=MS_decorr_psderror.in1.corr*$
                          (state.MS_decorr_psdw_err#state.MS_decorr_psdw_err)
                        if has_jackknife then begin
                            state.MS_decorr_jackknife_spec=MS_decorr_jackknife.in1.avespec
                            state.MS_decorr_jackknife_err=MS_decorr_jackknife.in1.aveerr
                            if has_corr then state.MS_decorr_jackknife_covar=MS_decorr_jackknife.in1.corr*$
                              (state.MS_decorr_jackknife_err#state.MS_decorr_jackknife_err)
                        endif
                    endif else WIDGET_CONTROL, id, sensitive=0
                    s2=size(PCA_Decorr_psderror)
                    ID=widget_info(state.master_widget_base,find_by_uname='Corr PCA')
                    if s2[n_e(s2)-1] ne 0 then begin
                        WIDGET_CONTROL, id, /sensitive 
                        state.PCA_Decorr_binw_spec=PCA_Decorr_spectra.in1.avespec
                        state.PCA_Decorr_binw_err=PCA_Decorr_spectra.in1.aveerr
                        if has_corr then state.PCA_decorr_binw_covar=PCA_decorr_spectra.in1.corr*$
                          (state.PCA_decorr_binw_err#state.PCA_decorr_binw_err)
                        state.PCA_Decorr_psdw_spec=PCA_Decorr_psderror.in1.avespec
                        state.PCA_Decorr_psdw_err=PCA_Decorr_psderror.in1.aveerr
                        if has_corr then state.PCA_decorr_psdw_covar=PCA_decorr_psderror.in1.corr*$
                          (state.PCA_decorr_psdw_err#state.PCA_decorr_psdw_err)
                        if has_jackknife then begin
                            state.PCA_Decorr_jackknife_spec=PCA_Decorr_jackknife.in1.avespec
                            state.PCA_Decorr_jackknife_err=PCA_Decorr_jackknife.in1.aveerr
                            if has_corr then state.PCA_decorr_jackknife_covar=PCA_decorr_jackknife.in1.corr*$
                              (state.PCA_decorr_jackknife_err#state.PCA_decorr_jackknife_err)
                        endif
                    endif else WIDGET_CONTROL, id, sensitive=0
                    ID=widget_info(state.master_widget_base,find_by_uname='Corr Both')
                    if s1[n_e(s1)-1] ne 0 and s2[n_e(s2)-1] ne 0 then begin 
                        WIDGET_CONTROL, id, /sensitive 
                        state.both_decorr_binw_spec=both_decorr_spectra.in1.avespec
                        state.both_decorr_binw_err=both_decorr_spectra.in1.aveerr
                        if has_corr then state.both_decorr_binw_covar=both_decorr_spectra.in1.corr*$
                          (state.both_decorr_binw_err#state.both_decorr_binw_err)
                        state.both_decorr_psdw_spec=both_decorr_psderror.in1.avespec
                        state.both_decorr_psdw_err=both_decorr_psderror.in1.aveerr
                        if has_corr then  state.both_decorr_psdw_covar=both_decorr_psderror.in1.corr*$
                          (state.both_decorr_psdw_err#state.both_decorr_psdw_err)
                        if has_jackknife then begin
                            state.both_decorr_jackknife_spec=both_decorr_jackknife.in1.avespec
                            state.both_decorr_jackknife_err=both_decorr_jackknife.in1.aveerr
                            if has_corr then state.both_decorr_jackknife_covar=both_decorr_jackknife.in1.corr*$
                              (state.both_decorr_jackknife_err#state.both_decorr_jackknife_err)
                        endif 
                    endif  else WIDGET_CONTROL, id, sensitive=0
                    
                    set_chosen_weighting

;                    state.flags = uber_bolo_flags
; Whenever new data are read in, re-define the yrange
                    mn = min(state.spec-state.err,/nan)
                    mx = max(state.spec+state.err,/nan)
                    state.yrange_current=1.1*[mn,mx]
                    state.draw_plot = 1
                    state.fit_is_current=0
                endif else begin
                    msg = 'No recognized structure in sav file'
                    ok = dialog_message(msg,/error,/center, dialog_parent=event.top)
;                    message,/info,$
;                      'sav file does not contain a recognized structure'
                    state.draw_plot = 0
                endelse
; Once you've read in the structure, you need to destroy the object,
; or else IDL leaves the logical unit to the sav file allocated.  God
; bless IDL.
                obj_destroy,sobj
            endif
        endelse

    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY

endcase

help,state.yrange_current
print,state.yrange_current

; Trigger an event for the main event handler
;evnt = create_struct('id',0L,'top',0L,'handler',0L,'subwidget_trigger',1L)
if (found_struct) then $
  widget_control,state.master_widget_base,$
  send_event=state.subwidget_trigger_event

end

pro zilf_read_file 

; This is the most likely choice ...
data_path = '/home/local/zspec/zspec_data_svn/coadded_spectra/';!zspec_pipeline_root+'/processing/spectra/coadded_spectra'
;!zspec_data_root+'/ncdf/uber_spectra/'

common state, state

filesel_base = widget_base(group_leader=state.master_widget_base,$
                           tit='Read Uber Spectrum File',/column,$
                           uvalue='Read File Widget')

filesel = cw_filesel(filesel_base,$
                     filter=[".sav"],$
                     path = data_path,$
                     uname='Read File',uvalue='Read File')
;                     uname='Read File',uvalue='Read File')

select_lines_close = widget_button(filesel_base, $
                                   value='Close',uvalue='Close') 

widget_control,filesel_base,/realize
XMANAGER, 'zilf_read_file', filesel_base, $
  EVENT_HANDLER = 'zilf_read_file_event', no_block = 1

end

; -----------------------------------------------------------------------------

pro zilf_flag_channels_event, event

common state, state

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of 

    'Flags': begin

        widget_control,widget_info(event.top,find='Flags'),get_value=flags

        state.flags = flags
        print,total(flags)

; Whenever the user flags or unflags something, redraw the plot and
; indicate that the fit is no longer up-to-date
        state.fit_is_current = 0
        state.draw_plot = 1
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY
    
endcase

end

pro zilf_flag_channels

common state, state

label = string(state.chan,format='(I3)')+'  '+string(state.nu,format='(F5.1)')
;

base = widget_base(group_leader=state.master_widget_base,$
                   tit='Flag Channels',/column)

;lab = label[0]+'  '
;for i=1,159 do lab += label[i]+'  '

flag_base = cw_bgroup(base,label,column=160,$
                      /scroll,x_scroll=1000,$
                      uname='Flags',$
                      uvalue ='Flags',$ ;button_uvalue=[0,1],$
                      /nonexclusive,set_value=state.flags)

;label_base = widget_text(base,value=lab)

close = widget_button(base, $
                      value='Close',uvalue='Close') 

widget_control,base,/realize
XMANAGER, 'zilf_flag_channels',base, $
  EVENT_HANDLER = 'zilf_flag_channels_event', no_block = 1

end

; -----------------------------------------------------------------------------
; select_continuum

pro zilf_select_continuum_event, event

common state, state

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of 

    'Continuum': begin

        widget_control,widget_info(event.top,find='Continuum'),$
          get_value=cont_select
        state.cont_model = cont_select

; Update the main page to indicate the fit is not up-to-date with the
; current parameters
        state.fit_is_current = 0
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY
    
endcase

end

pro zilf_select_continuum

common state, state

base = widget_base(group_leader=state.master_widget_base,$
                   tit='Select Continuum',/column)

continuum_base = cw_bgroup(base,['Power Law','M82 Free-Free + Thermal','NGC1068 BB + Powerlaw','No Continuum'],$
                           column=1,$
                           button_uvalue = [0,1,2,3],$
                           uname='Continuum',$
                           uvalue ='Continuum',$ 
                           /exclusive,set_value=state.cont_model)

;label_base = widget_text(base,value=lab)

close = widget_button(base, $
                      value='Close',uvalue='Close') 

widget_control,base,/realize
XMANAGER, 'zilf_select_continuum',base, $
  EVENT_HANDLER = 'zilf_select_continuum_event', no_block = 1

end

; -----------------------------------------------------------------------------
; Define the widget that allows line selection and its event handler

pro zilf_select_lines_event, event

common state, state

WIDGET_CONTROL, event.id, GET_UVALUE = eventval	

case eventval of

    'SelectLine' : begin

        widget_control,widget_info(event.top,find='SelectLine'),$
          get_value=lines_to_fit

; This uses the button_value, which was set to be the index in the
; overall array of the requested line, to the select value, either 0
; or 1, depending on what the user did.  All line species clicks are
; handled the same way.
        wh_indx = event.value
        state.lines_to_fit[wh_indx] = event.select
        
        if ~event.select then begin
            for j=0, 2 do begin
                state.startvals[3*wh_indx+j]=!values.D_NAN
                state.limits[3*wh_indx+j, *]=!values.D_NAN
                state.fixed[3*wh_indx+j]=0
            endfor
        endif else begin
            state.startvals[3*wh_indx+2]=state.redshift
            state.startvals[3*wh_indx+1]=state.lw_value
        endelse
;;;
;;;        help,wh_indx
;;;        print,wh_indx
;;;        help,lines_to_fit
;;;        print,lines_to_fit
;;;        print,state.species[wh_indx]
;;;        print,state.transition[wh_indx]
;;;
;;;        help,event,/str
;;;
;        state.lines_to_fit = lines_to_fit
;        print,lines_to_fit

; If the lines selected have changed, then the fit is no longer current
        state.fit_is_current = 0
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY

endcase

end

pro zilf_select_lines

common state, state

nlinecat = n_e(state.species)

; It sure would be nice to parse these out by species ... but it's
; gonna be ugly ...
uniq_species = uniq(state.species)

nuniq = n_e(uniq_species)

base_select_lines = widget_base(group_leader=state.master_widget_base,$
                                /col,$
                                tit='Select Lines')


dummy = widget_base(base_select_lines,row=2,$
                    xsize=1300,ysize=1200,$
                   /scroll,x_scroll=1300,y_scroll=500)

for i = 0,n_e(uniq_species)-1 do begin

    wh = where(state.species eq state.species[uniq_species[i]])
    lab = state.transition[wh] + ' / ' + $
      string(state.frequency[wh],format='(F8.3)')+' GHz'
;    label = widget_label(dummy,value=state.species[wh[0]])
    speccol = cw_bgroup(dummy,lab,col=1,$
                        uname='SelectLine',$
                        uvalue ='SelectLine',$ 
                        label_top=state.species[wh[0]],$
                        frame=1,$
                        /nonexclusive,$
                        set_value=state.lines_to_fit[wh],$
                        button_uvalue = wh)

endfor


;; -----------------------------------------------------------------------------
;; This is the working code
;lab = strarr(nlinecat)
;for i=0,nlinecat-1 do begin
;    lab[i] = state.species[i]+'  '+state.transition[i]
;endfor
;
;select_line_wid = cw_bgroup(base_select_lines,lab,$
;                   column=1,$
;                   uname='SelectLine',$
;                   uvalue ='SelectLine',$ 
;                   /nonexclusive,set_value=state.lines_to_fit)
;; -----------------------------------------------------------------------------
;
;select_lines_label = widget_label(base_select_lines,value='Select Lines')
select_lines_close = widget_button(base_select_lines, $
                                   value='Close',uvalue='Close',xsize=20) 

widget_control,base_select_lines,/realize
XMANAGER, 'zilf_select_lines', base_select_lines, $
  EVENT_HANDLER = 'zilf_select_lines_event', no_block = 1

end

; -----------------------------------------------------------------------------
; define_linewidth

pro zilf_define_linewidth_event, event

common state, state

WIDGET_CONTROL, event.id, GET_UVALUE = eventval	

 w=where(state.lines_to_fit, linecount)
case eventval of

    'lw' : begin

        widget_control,widget_info(event.top,find='lw'),get_value=lw
        state.lw_value = lw
       
        if linecount gt 0 then state.startvals[3*w+1]=lw
        state.fit_is_current = 0
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
    end

    'TieFix' : begin

        widget_control,widget_info(event.top,find='TieFix'),$
          get_value=tiefix
       
        state.lw_tied = tiefix[0]
        state.lw_fixed = tiefix[1]

        state.fixed[3*w+1]=tiefix[1]
        
        state.fit_is_current = 0
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
        
    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY

endcase

end

pro zilf_define_linewidth

common state, state

base = widget_base(group_leader=state.master_widget_base,/column,$
                                tit='Define Linewidth')

opts = widget_base(base,/row)

lw_entry = widget_base(opts,/col)
;lab = widget_label(lw_entry,value='Linewidth (km/s)',/align_center)
lw = cw_field(lw_entry,/row,/float,/return_events,$
              title='Linewidth (km/s)',uname='lw',uvalue='lw',$
              value=state.lw_value,xsize=7)

tiefix = cw_bgroup(opts,['Tie Linewidths Together', 'Fix Linewidth in Fit'],$
                   column=2,$
                   uname='TieFix',$
                   uvalue ='TieFix',$ 
                   /nonexclusive,set_value=[state.lw_tied,state.lw_fixed])

close = widget_button(base, $
                      value='Close',uvalue='Close') 

widget_control,base,/realize
XMANAGER, 'zilf_define_linewidth', base, $
  EVENT_HANDLER = 'zilf_define_linewidth_event', no_block = 1

end

; -----------------------------------------------------------------------------
; redshift_options

pro zilf_redshift_options_event, event

common state, state

common z_entry, z_entry

WIDGET_CONTROL, event.id, GET_UVALUE = eventval	
w=where(state.lines_to_fit, linecount)

case eventval of

    'WhichRedshift' : begin

        widget_control,widget_info(event.top,find='WhichRedshift'),$
          get_value=whichz
        state.whichz = whichz
        widget_control,z_entry,sens=whichz        
        state.fit_is_current = 0        
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
    end

    'Redshift' : begin

        widget_control,widget_info(event.top,find='Redshift'),$
          get_value=z
        help,z
        state.redshift = z

        if linecount gt 0 then state.startvals[3*w+2]=z
        state.fit_is_current = 0        
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
        
    end

    'ZUnits' : begin

        widget_control,widget_info(event.top,find='ZUnits'),$
          get_value=zunits
        help,zunits
        state.zunits = zunits
        state.fit_is_current = 0        
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event

    end

    'TieFix' : begin

        widget_control,widget_info(event.top,find='TieFix'),$
          get_value=tiefix
       
;        state.lw_tied = tiefix[0]
        state.z_fixed = tiefix[0]
        
        if linecount gt 0 then  state.fixed[3*w+2]=tiefix[0]
        help,tiefix[0]
;        print,tiefix

        state.fit_is_current = 0
        widget_control,state.master_widget_base,$
          send_event=state.subwidget_trigger_event
        
    end

    'Close' : WIDGET_CONTROL, event.TOP, /DESTROY

endcase

end

pro zilf_redshift_options

common state, state

; Klugy ...
common z_entry, z_entry

base = widget_base(group_leader=state.master_widget_base,/column,$
                                tit='Redshift Options')

opts = widget_base(base,/row)

b = widget_base(opts,/col,frame=1)

zff = cw_bgroup(b,$
                ['Use redshift from file: '+$
                 string(state.redshift_from_file,format='(F6.4)'),$
                 'Enter redshift: '], $
                /exclusive,set_value=state.whichz,$
                uname='WhichRedshift',uvalue='WhichRedshift')

z_entry = widget_base(b,/col)

z = cw_field(z_entry,/row,/float,/return_events,$
             title='',uname='Redshift',uvalue='Redshift',$
             value=state.redshift,xsize=7)

lab = widget_label(z_entry,value='Redshift units are:',/align_left)

zunits = cw_bgroup(z_entry,['km/s','dimensionless'],column=1,$
                   uname='ZUnits',uvalue='ZUnits',$
                   /exclusive,set_value=state.zunits)

; I'm not sure if there's currently a way to float all the line
; redshifts, or whether they *have* to be tied together.
; You can see the syntax here leaves that possibility open.
tiefix = cw_bgroup(opts,'Fix Redshift in Fit',$
                   column=1,$
                   uname='TieFix',$
                   uvalue ='TieFix',$ 
                   /nonexclusive,set_value=state.z_fixed,$
                   yoffset=200)

close = widget_button(base, $
                      value='Close',uvalue='Close') 

; If the default is to use the redshift in the file, then don't allow
; entries. 
if (state.whichz eq 0) then widget_control,z_entry,sens=0

widget_control,base,/realize
XMANAGER, 'zilf_redshift_options', base, $
  EVENT_HANDLER = 'zilf_redshift_options_event', no_block = 1

end

; -----------------------------------------------------------------------------

PRO zilf_event, event

common state, state

tags = tag_names(event)

if (total(strcmp(tags,'SUBWIDGET_TRIGGER')) gt 0) then begin
    eventval = ''
endif else begin
; Find the user value of the widget where the event occured
    WIDGET_CONTROL, event.id, GET_UVALUE = eventval		
; But to what sub-widget does that widget belong?  Ah, that is the question.
; If a generic trigger event is sent from one of the sub-widgets (with
; a separate xmanager), then the above line won't parse it and
; eventval will be undefined.  So ...
endelse

x = state.nu
xlabel = 'Frequency (GHz)'

; Debug for every time an event is generated
;message,/info,'An event was generated'
;help,event,/str
;print,eventval
;blah = ''
;read,blah

; Begin the control loop for events generated from the main panel
if (eventval ne '') then begin

; Defaults
state.draw_plot = 0

case eventval of

    'Read File' : begin
; Make the base widget insensitive
;        widget_control,state.master_widget_base,sens=0
        zilf_read_file
;        widget_control,state.master_widget_base,sens=1
; Set the values in the Y Range box to their new values in case the
; above actions did anything
    end

    'Flag Channels' : begin
        zilf_flag_channels
    end  

    'Select Lines' : begin
        zilf_select_lines
    end

    'Select Continuum Model' : begin
        zilf_select_continuum
    end

    'Define Linewidth' : begin
        zilf_define_linewidth
    end

    'Redshift Options' : begin
        zilf_redshift_options
    end

    'Set Parameter Limits': zilf_param_limits

    'Generate Report': doReport
        

; Widgets only on the main panel

    ;'Weight' : begin
    ;    state.draw_plot = 1
    ;    state.fit_is_current = 0
    ;    widget_control,widget_info(event.top,find='Weight'),get_value=use_bin
    ;    state.use_bin = use_bin
    ;end
    'PSD': begin
        state.draw_plot = 1
        state.fit_is_current = 0
        state.use_bin = 0
    end

    'BINW': begin
        state.draw_plot = 1
        state.fit_is_current = 0
        state.use_bin = 1
    end

    'Jackknife': begin
        state.draw_plot = 1
        state.fit_is_current = 0
        state.use_bin = 2
    end

    'x1' : begin
        widget_control,widget_info(event.top,find='x1'),get_value=x1
        state.xrange_current[0] = x1
        state.draw_plot = 1
    end

    'x2' : begin
        widget_control,widget_info(event.top,find='x2'),get_value=x2
        state.xrange_current[1] = x2
        state.draw_plot = 1
    end

    'y1' : begin
        widget_control,widget_info(event.top,find='y1'),get_value=y1
        state.yrange_current[0] = y1
        state.draw_plot = 1
    end

    'y2' : begin
        widget_control,widget_info(event.top,find='y2'),get_value=y2
        state.yrange_current[1] = y2
        state.draw_plot = 1
    end

    'xunits' : begin
        state.draw_plot = 1
        widget_control,widget_info(event.top,find='xunits'),get_value=xunits
        state.xunits = xunits
; Since this is a change, also update the current xrange units
        if (state.xunits eq 0) then begin
            state.xrange_current = minmax(state.nu)
        endif else begin
            state.xrange_current = [0,159]
        endelse
    end

    'Do Fit': begin

        if (state.spectrum_is_defined) then begin

            whlines = where(state.lines_to_fit eq 1, linecount)
            if whlines[0] eq -1 then begin
                ok = dialog_message('No lines have been selected.',$
                                    /error,/center, dialog_parent=event.top)
            endif else begin
                c = 2.99792458d8

                case state.cont_model of 
                    0 : cont_type = 'PWRLAW' ; cont = [20.0,0.0,2.0,20.0]/1000.
                    1 : cont_type = 'M82FFT' ; cont = 0
                    2 : cont_type = '1068BBP'
                    3 : cont_type = 'NONE' ; cont = 0
                endcase
                
; Figure out whether we're using the redshift from the file or a
; user-entered value
                if (state.whichz eq 0) then $
                  redshift = state.redshift_from_file $
                else $
                  redshift = state.redshift

; If the units are dimensionless, convert to km/s, which is what the
; fitter wants to see
;            if (state.zunits eq 1) then redshift *= c/1.d3

; But my new fitter works w/ dimensionless redshift
               
                N=N_E(state.fixed)
                
                fixed=state.fixed[whlines[0]*3:whlines[0]*3+2]
                limits=state.limits[whlines[0]*3:whlines[0]*3+2,*]
                startvals=state.startvals[whlines[0]*3:whlines[0]*3+2]
                for i=1, linecount-1 do begin
                    fixed=[fixed,state.fixed[whlines[i]*3:whlines[i]*3+2]]
                    limits=[limits,state.limits[whlines[i]*3:whlines[i]*3+2,*]]
                    startvals=[startvals,state.startvals[whlines[i]*3:whlines[i]*3+2]]
                endfor

                fixed=[fixed, state.fixed[N-2:N-1]]
                limits=[limits, state.limits[N-2:N-1, *]]
                startvals=[startvals, state.startvals[N-2:N-1]]

                if (state.zunits eq 0) then begin
                    redshift *= 1.d3/c
                    
                    for i=0, linecount-1 do limits[3*i,*]*=1.d3/c
                endif

                widget_control,/hourglass

                if state.covar_fit then covar=state.covar

save,file='zilf_fit_params.sav',state,redshift,whlines,cont_type,fixed,limits,startvals,covar             
                fit = $
                  zspec_fit_lines_cont(state.flags,state.spec,state.err,$
                                       redshift,$
                                       state.species[whlines],$
                                       state.transition[whlines],$
                                       cont=cont_type,$
                                       frequency = state.frequency[whlines],$
                                       profile_type=state.profile_type[whlines],$
                                       z_fixed = state.z_fixed,$
                                       lw_value = state.lw_value,$
                                       lw_fixed = state.lw_fixed,$
                                       lw_tied = state.lw_tied,$
                                       z_tied=1, fixed=fixed, limits=limits, startvals=startvals,$
                                       base=state.master_widget_base, covar=covar)
                
;            fit = fit_lines_planck(whfit,state.spec,state.err,redshift,$
;                                   species,transitions,amps,$
;                                   cont = cont,$
;                                   z_fixed = state.z_fixed,$
;                                   lw_value = state.lw_value,$
;                                   lw_fixed = state.lw_fixed,$
;                                   lw_tied = state.lw_tied)
                
                if ~fit.valid then break
              
                if ~state.customName then file='zilf_fit.sav' $
                else if state.out_file_name ne '' then file=state.out_file_name+'_fit.sav' $
                else begin
                    a=dialog_message('Custon name requested but not entered; using "zilf_fit"', $
                         dialog_parent=event.top)
                    file='zilf_fit.sav'
                endelse

                save,fit,file=file

                ptr_free, state.fit
                state.fit=ptr_new(fit)
                state.lcspec = fit.lcspec
                state.cspec = fit.cspec
                state.lspec = fit.lcspec - fit.cspec
                state.redchi = fit.redchi
                state.dof = fit.dof
                
                state.camp = fit.camp
                state.caerr = fit.caerr
                state.cexp = fit.cexp
                state.ceerr =  fit.ceerr
                
                state.z = fit.redshift[0]
                state.zerr = fit.zerr[0]
                
                state.draw_plot = 1
                state.fit_is_defined = 1
                state.fit_is_current = 1

; Start building up the text output ... surely there's a better way ...
                report = string(state.redchi,$
                                format='("Reduced chi squared: ",F7.3)')
                report = [report, [string(state.dof,$
                                          format='("Degrees of freedom: ",I8)')]]

                w=where(~state.flags, badcount)
                report=[report, [string(badcount, format='("Excluded Channels: ", I3)')]]
            
                report = [report, [' ']]
                temp = 'Continuum model: '
                if (state.cont_model eq 0) then begin
                    report = [report, [temp + 'power law']]
                    report = [report, ['Continuum Amplitude: '+string(state.camp,fit.caerr,$
                                              format='(F7.4," +/- ",F7.4)')]]
                    report = [report, ['Continuum Exponent: '+string(state.cexp,fit.ceerr,$
                                              format='(F7.4," +/- ",F7.4)')]]      
                endif
                temp = 'Continuum model: '
                if (state.cont_model eq 1) then begin
                    report = [report, [temp + 'M82 Free Free + Thermal']]
                    report = [report, ['Continuum Amplitude: '+string(state.camp,fit.caerr,$
                                              format='(F7.4," +/- ",F7.4)')]]
                    report = [report, ['Continuum Exponent: '+string(state.cexp,fit.ceerr,$
                                              format='(F7.4," +/- ",F7.4)')]]      
                endif
                if (state.cont_model eq 2) then begin
                    report = [report, [temp + 'NGC1068 Blackbody + Powerlaw']]
                    report = [report, ['Continuum Amplitude: '+string(state.camp,fit.caerr,$
                                              format='(F7.4," +/- ",F7.4)')]]
                    report = [report, ['Continuum Exponent: '+string(state.cexp,fit.ceerr,$
                                              format='(F7.4," +/- ",F7.4)')]]      
                endif
                if (state.cont_model eq 3) then $
                  report = [report, [temp + 'none']]  
                
                report = [report, [' ']]
                report = [report, ['Redshift']]
; Default is that redshift is stored dimensionless ... double-check!!!
                report = $
                  [report, [string(state.z[0],fit.zerr[0],$
                                   format='(F10.4," +/- ",F10.4)')]]
                report = $
                  [report, [string(state.z[0]*c/1.d3,fit.zerr[0]*c/1.d3,$
                                   format='(F10.1," +/- ",F10.1," km/s")')]]
                

                report = [report, [' ']]
                report = [report, ['Line width']]
                report = $
                  [report, [string(fit.width[0],fit.widtherr[0],$
                                   format='(F10.1," +/- ",F10.1," km/s")')]]

                report = $
                  [report,'  ',fit.summary]

                widget_control,state.report_wid,$
                  set_value=report
            endelse
            
        endif else begin
                
            ok = dialog_message('No spectrum has been loaded.',$
                                /error,/center, dialog_parent=event.top)
                
        endelse
        
    end
        
    'Quit' : begin 
        WIDGET_CONTROL, event.TOP, /DESTROY
        return
    end

    'FileNameSwitch': begin
        id=WIDGET_INFO(event.TOP,find_by_uname='FileNameInput')
        WIDGET_CONTROL, id, sensitive=~WIDGET_INFO(id, /sensitive)
        state.customName=~state.customName        
    end

    'FileNameInput': begin
        WIDGET_CONTROL, event.id, get_value=str
        state.out_file_name=strcompress(str, /remove_all)
    end
        
    'Corr Base': begin
        state.spec_binw = state.base_binw_spec
        state.err_binw = state.base_binw_err
        state.covar_binw=state.base_binw_covar
        state.spec_psdw = state.base_psdw_spec
        state.err_psdw = state.base_psdw_err
        state.covar_psdw=state.base_psdw_covar
        state.spec_jackknife=state.base_jackknife_spec
        state.err_jackknife=state.base_jackknife_err
        state.covar_jackknife=state.base_jackknife_covar
        state.draw_plot=1
        state.fit_is_current=0
    end
    'Corr MS': begin
        state.spec_binw = state.MS_decorr_binw_spec
        state.err_binw = state.MS_decorr_binw_err
        state.covar_binw=state.MS_decorr_binw_covar
        state.spec_psdw =state.MS_decorr_psdw_spec
        state.err_psdw =state.MS_decorr_psdw_err
        state.covar_psdw=state.MS_decorr_psdw_covar
        state.spec_jackknife =state.MS_decorr_jackknife_spec
        state.err_jackknife =state.MS_decorr_jackknife_err
        state.covar_jackknife=state.MS_decorr_jackknife_covar
        state.draw_plot=1
        state.fit_is_current=0
    end
    'Corr PCA': begin      
        state.spec_binw =state.PCA_Decorr_binw_spec
        state.err_binw =state.PCA_Decorr_binw_err
        state.covar_binw=state.PCA_decorr_binw_covar
        state.spec_psdw = state.PCA_Decorr_psdw_spec
        state.err_psdw = state.PCA_Decorr_psdw_err
        state.covar_psdw=state.PCA_decorr_psdw_covar
        state.spec_jackknife = state.PCA_Decorr_jackknife_spec
        state.err_jackknife = state.PCA_Decorr_jackknife_err
        state.covar_jackknife=state.PCA_decorr_jackknife_covar
        state.draw_plot=1
        state.fit_is_current=0
    end
    'Corr Both': begin
        state.spec_binw = state.both_decorr_binw_spec
        state.err_binw =state.both_decorr_binw_err
        state.covar_binw=state.both_decorr_binw_covar
        state.spec_psdw = state.both_decorr_psdw_spec
        state.err_psdw = state.both_decorr_psdw_err
        state.covar_psdw=state.both_decorr_psdw_covar
        state.spec_jackknife = state.both_decorr_jackknife_spec
        state.err_jackknife = state.both_decorr_jackknife_err
        state.covar_jackknife=state.both_decorr_jackknife_covar
        state.draw_plot=1
        state.fit_is_current=0
    end
    'covar_fit': if widget_info(widget_info(event.top,find_by_uname='covar_fit'), /button_set) then $
      state.covar_fit=1 else state.covar_fit=0
    else : return
    
endcase

endif 

; Things that are done every time an event is generated, regardless of
; what it is ...

; Set the X, Y range fields to reflect the current state of affairs
widget_control,state.x1wid,$
  set_value=state.xrange_current[0]
widget_control,state.x2wid,$
  set_value=state.xrange_current[1]
widget_control,state.y1wid,$
  set_value=state.yrange_current[0]
widget_control,state.y2wid,$
  set_value=state.yrange_current[1]

if (state.fit_is_defined) then begin
    if (state.fit_is_current) then begin
        fit_status='Fit is up-to-date'
    endif else begin
        fit_status='Fit is NOT up-to-date'
    endelse
endif else begin
    fit_status = 'No current fit'
endelse
widget_control,state.fit_status_wid,set_value=fit_status

set_chosen_weighting

if (state.spectrum_is_defined and state.draw_plot) then begin
    
;    print,'Plotting'

;    help,src_flag
;    help,lgd_flag

; Set the x variable and label depending on the current value of the
; state.xunits variable.
    if (state.xunits eq 0) then begin
        x = state.nu 
        xlabel = 'Frequency (GHz)'
    endif else begin
        x = state.chan
        xlabel = 'Channel Number'
    endelse
    
    if ~state.customName then file='zilf_plot.eps' $
    else if state.out_file_name ne '' then file=state.out_file_name+'_plot.eps' $
    else file='zilf_plot.eps' 

    for i=0,1 do begin

        if (i eq 0) then begin
            wset,state.draw_window_index
        endif else begin
            set_plot,'ps'
            device,file=file,/encap,/color
        endelse

        whlines=where(state.lines_to_fit, linecount)
    ploterror,x,state.spec/state.flags,state.err/state.flags,$
      /xst,/yst,$
      xrange=state.xrange_current,yrange=state.yrange_current,$
      xtit=xlabel,psy=10

    if linecount gt 0 then begin 
        if state.xunits eq 0 then begin
            vline, state.frequency[whlines]/(1+state.z), col=4
            xyouts, state.frequency[whlines]/(1+state.z), $
              .5*total(state.yrange_current), $
              state.species[whlines]+' ' +state.transition[whlines], orientation=90, col=4
        endif else begin
            vline, freq2freqid(state.frequency[whlines]/(1+state.z)), col=4
            xyouts, freq2freqid(state.frequency[whlines]/(1+state.z)), $
              .5*total(state.yrange_current), $
              state.species[whlines]+' ' +state.transition[whlines], orientation=90, col=4
        endelse
    endif

    if (state.fit_is_defined and state.fit_is_current) then begin
        
        oplot,x,state.lcspec,psy=10,col=2
        
    endif

    if (i eq 1) then begin
        device,/close
        set_plot,'x'
        !p.color = 0
        !p.background = 1
    endif

endfor

endif

END  

; -----------------------------------------------------------------------------
; The main program
; -----------------------------------------------------------------------------

pro zilf, flags=flags

common state, state

; We're going to need a variable to hold the possible lines we know
; how to fit, and of course we won't know how big that variable is
; until we read it in.  So that'll have to come first.

; One downside of having this in a common block variable is that
; adding a line requires the user to quit and restart zilf.  Oh, well ...
;readcol,!zspec_pipeline_root+'/line_cont_fitting/zilf/line_table.txt',$
;  comment=';',format='(A,A,D)',$
;  species,transition,frequency,/silent
read_line_catalog,species,transition,frequency,profile_type


; This is ugly, but it makes displaying the options easier later on.
srt = sort(species)
species = species[srt]
transition = transition[srt]
frequency = frequency[srt]
profile_type = profile_type[srt]

n_lines_in_cat = n_e(species)

nu = freqid2freq()

if (keyword_set(flags)) then flags = flags else flags=dblarr(160)+1

; state contains all the global variables.  widgets that change these
; things modify the state variable in the common block.  This forms
; the basis for what is displayed and fit.
state = create_struct('master_widget_base',0L,$
                      'draw_window_index',0L,$
                      'subwidget_trigger_event',$
                      create_struct('id',0L,$
                                    'top',0L,$
                                    'handler',0L,$
                                    'subwidget_trigger',1L),$
                      'spectrum_is_defined',0L,$
                      'fit_is_defined',0L,$
                      'fit_is_current',0L,$
                      'draw_plot',0L,$
                      'filename','',$
                      'short_filename','',$
                      'filename_wid',0L,$
                      'source_name','',$
                      'source_name_wid',0L,$
                      'redshift_from_file',0.d,$
                      'redshift',0.d,$
                      'whichz',0L,$  ; Default is z from file
                      'zunits',1L,$  ; which is dimensionless
                      'nu',nu,$
                      'chan',dindgen(160),$
                      'xunits',0L,$
                      'x1wid',0L,$
                      'x2wid',0L,$
                      'y1wid',0L,$
                      'y2wid',0L,$
                      'spec',dblarr(160),$
                      'err',dblarr(160),$
                      'covar', dblarr(160,160),$
                      'spec_binw',dblarr(160),$
                      'err_binw',dblarr(160),$
                      'covar_binw', dblarr(160,160),$
                      'spec_psdw',dblarr(160),$
                      'err_psdw',dblarr(160),$
                      'covar_psdw', dblarr(160,160),$
                      'spec_jackknife',dblarr(160),$
                      'err_jackknife',dblarr(160),$
                      'covar_jackknife', dblarr(160,160),$
                      'base_binw_spec',dblarr(160),$
                      'base_binw_err',dblarr(160),$
                      'base_binw_covar', dblarr(160,160),$
                      'base_psdw_spec',dblarr(160),$
                      'base_psdw_err',dblarr(160),$
                      'base_psdw_covar', dblarr(160,160),$
                      'base_jackknife_spec',dblarr(160),$
                      'base_jackknife_err',dblarr(160),$
                      'base_jackknife_covar', dblarr(160,160),$
                      'MS_decorr_binw_spec',dblarr(160),$
                      'MS_decorr_binw_err',dblarr(160),$
                      'MS_decorr_binw_covar', dblarr(160,160),$
                      'MS_decorr_psdw_spec',dblarr(160),$
                      'MS_decorr_psdw_err',dblarr(160),$
                      'MS_decorr_psdw_covar', dblarr(160,160),$
                      'MS_decorr_jackknife_spec',dblarr(160),$
                      'MS_decorr_jackknife_err',dblarr(160),$
                      'MS_decorr_jackknife_covar', dblarr(160,160),$
                      'PCA_Decorr_binw_spec',dblarr(160),$
                      'PCA_Decorr_binw_err',dblarr(160),$
                      'PCA_Decorr_binw_covar', dblarr(160,160),$
                      'PCA_Decorr_psdw_spec',dblarr(160),$
                      'PCA_Decorr_psdw_err',dblarr(160),$
                      'PCA_Decorr_psdw_covar', dblarr(160,160),$
                      'PCA_Decorr_jackknife_spec',dblarr(160),$
                      'PCA_Decorr_jackknife_err',dblarr(160),$
                      'PCA_Decorr_jackknife_covar', dblarr(160,160),$
                      'both_decorr_binw_spec',dblarr(160),$
                      'both_decorr_binw_err',dblarr(160),$
                      'both_decorr_binw_covar', dblarr(160,160),$
                      'both_decorr_psdw_spec',dblarr(160),$
                      'both_decorr_psdw_err',dblarr(160),$
                      'both_decorr_psdw_covar', dblarr(160,160),$
                      'both_decorr_jackknife_spec',dblarr(160),$
                      'both_decorr_jackknife_err',dblarr(160),$
                      'both_decorr_jackknife_covar', dblarr(160,160),$
                      'use_bin',0L,$
                      'flags',flags,$
                      'xrange_default',minmax(nu),$
                      'yrange_default',[0.,0.], $
                      'xrange_current',minmax(nu),$
                      'yrange_current',[0.,0.],$
                      'lw_value',400.d,$
                      'lw_tied',1L,$
                      'lw_fixed',0L,$
                      'z_fixed',0L,$
                      'cont_model',0L,$
                      'species',species,$
                      'transition',transition,$
                      'frequency',frequency,$
                      'profile_type',profile_type,$
                      'lines_to_fit',intarr(n_lines_in_cat),$
                      'lcspec',dblarr(160),$
                      'cspec',dblarr(160),$
                      'lspec',dblarr(160),$
                      'redchi',0.d,$
                      'dof',0L,$
                      'camp', 0.d, $
                      'caerr', 0.d, $
                      'cexp', 0.d, $
                      'ceerr', 0.d, $
                      'z',0.d,$
                      'zerr',0.d,$
                      'fit_status_wid',0L,$
                      'report_wid',0L,$
                      'customName', 0,$
                      'out_file_name','',$
                      'fixed', replicate(0, n_lines_in_cat*3+2),$
                      'limits', replicate(!values.D_NAN, n_lines_in_cat*3+2, 2),$
                      'startvals',replicate(!values.D_NAN, n_lines_in_cat*3+2),$
                      'fit', ptr_new(),$
                      'covar_fit',0)

; The problem with globally storing the fit variables is that the
; number of them can change depending on the user's selections.  So
; you probably need to leave space for all possibilities ... that's
; the brute force method, anyway, and given IDL's crappy structure
; resizing capabilities, and the limitations of common blocks, it's
; probably the only way.

;
;  LCSPEC          DOUBLE    Array[160]
;   CSPEC           DOUBLE    Array[160]
;   CENTER          DOUBLE    Array[4]
;   SCALE           DOUBLE    Array[4]
;   AMP             DOUBLE    Array[4]
;   AERR            DOUBLE    Array[4]
;   WIDTH           DOUBLE    Array[4]
;   WERR            DOUBLE    Array[4]
;   REDCHI          DOUBLE           1.1337736
;   DOF             LONG               145
;   REDSHIFT        DOUBLE    Array[4]
;   ZERR            DOUBLE    Array[4]
;   CAMP            DOUBLE         0.021727917
;   CAERR           DOUBLE       0.00044860867
;   CTEMP           DOUBLE           0.0000000
;   CTERR           DOUBLE           0.0000000
;   CEXP            DOUBLE           3.0000000
;   CEERR           DOUBLE          -0.0000000
;   CFFAMP          DOUBLE         0.021727917
;   CFERR           DOUBLE           0.0000000
;   LINENAME        STRING    Array[4]
;   FREQSHIFT       FLOAT           0.00000
;   COVAR           DOUBLE    Array[16, 16]
;

; At a high level, we have to constantly keep track of the key
; parameters of the fitting:

;    fit = fit_lines_planck(whfit,spec,err,zeff*c/1.d3,$
;                           species,transitions,amps,$
;                           cont=[20.0,0.0,2.0,20.0],$
;                           lw_value=400.,/lw_fixed,/lw_tied)

!p.color = 0
!p.background = 1

; Define the top level widget
base = WIDGET_BASE(/row,tit='ZILF: the Z-spec Interactive Line Fitter')

state.master_widget_base = base

; User menu options
menu_base = widget_base(base,/column)

select_lines = $
  widget_button(menu_base, value='Read Uber Spectrum File',uvalue='Read File')

select_lines = $
  widget_button(menu_base, value='Flag Channels',uvalue='Flag Channels') 

select_lines = widget_button(menu_base, value='Select Lines',uvalue='Select Lines') 

select_continuum = widget_button(menu_base, $
                                 value = 'Select Continuum Model',$
                                 uvalue = 'Select Continuum Model')

define_linewidth = widget_button(menu_base, $
                                 value = 'Define Linewidth',$
                                 uvalue = 'Define Linewidth')

redshift = widget_button(menu_base, $
                         value = 'Redshift Options',$
                         uvalue = 'Redshift Options')

limits = widget_button(menu_base, $
                       value = 'Set Parameter Limits',$
                       uvalue = 'Set Parameter Limits')

do_fit = widget_button(menu_base, value='Do Fit',uvalue='Do Fit')
subbase=widget_base(menu_base, /nonexclusive)
covar_fit_button=widget_button(subbase, value='Covariance-based Fit?', uname='covar_fit',uvalue='covar_fit', sensitive=0)

report = widget_button(menu_base, $
                       value='Generate Report',uvalue='Generate Report')

quit = widget_button(menu_base, value='Quit',uvalue='Quit') 

;xunits = cw_bgroup(menu_base,['PSD by Nod','Binned Sample Variance','Error Jackknife'],column=1,$
;                   uname='Weight',$
;                   uvalue ='Weight',label_top='Weighting',$
;                   /exclusive,set_value=0)

err_choice=widget_base(menu_base, /exclusive, /column, uvalue='corr_choice', uname='corr_choice')
psd_button=widget_button(err_choice, value='PSD by Nod', uvalue='PSD', uname='PSD', sensitive=1)
binw_button=widget_button(err_choice, value='Binned Sample Variance', uvalue='BINW', uname='BINW', sensitive=1)
jackknife_button=widget_button(err_choice, value='Error Jackknife', uvalue='Jackknife', uname='Jackknife', sensitive=0)
WIDGET_CONTROL, psd_button, /set_button

customNameBase=widget_base(menu_base, /column, frame=5)
customNameSelect=cw_bgroup(customNameBase, ['Name Plot/Save File?'], column=1, $
                           /nonexclusive, uname='FileNameSwitch', uvalue='FileNameSwitch',$
                           set_value=[0])
customNameInput=cw_field(customNameBase, /column, /string,uname='FileNameInput', uvalue='FileNameInput', /all_events)
WIDGET_CONTROL, customNameInput, sensitive=0                         

; This sets up the plot window
draw_base = widget_base(base,/column)
draw = WIDGET_DRAW(draw_base, XSIZE = 700, YSIZE = 500)

;plotrange_label = widget_label(draw_base,/align_center,value='Plot Range')
plotrange_base = widget_base(draw_base,/row)

x_base = widget_base(plotrange_base,/column)
x_label = widget_label(x_base,/align_center,value='X Range')

x_entry = widget_base(x_base,/row,frame=1)

state.x1wid = cw_field(x_entry,/row,/float,/return_events,$
                       title='x1',uname='x1',uvalue='x1',$
                       value=state.xrange_current[0],xsize=7)

state.x2wid = cw_field(x_entry,/row,/float,/return_events,$
                       title='x2',uname='x2',uvalue='x2',$
                       value=state.xrange_current[1],xsize=7)

y_base = widget_base(plotrange_base,/column)
y_label = widget_label(y_base,/align_center,value='Y Range')

y_entry = widget_base(y_base,/row,frame=1)

state.y1wid = cw_field(y_entry,/row,/float,/return_events,$
                       title='y1',uname='y1',uvalue='y1',$
              value=state.yrange_current[0],xsize=7)

state.y2wid = cw_field(y_entry,/row,/float,/return_events,$
               title='y2',uname='y2',uvalue='y2',$
              value=state.yrange_current[1],xsize=7)

xunits = cw_bgroup(plotrange_base,['Frequency','Channel'],column=1,$
                   uname='xunits',$
                   uvalue ='xunits',button_uvalue=[0,1],label_top='X Units',$
                   /exclusive,set_value=0)
corr_choice=widget_base(plotrange_base, /exclusive, frame=5, /column, uvalue='corr_choice', uname='corr_choice')
base_button=widget_button(corr_choice, value='Base', uvalue='Corr Base', uname='Corr Base', sensitive=0)
MS_decorr_button=widget_button(corr_choice, value='Mean Subtraction', uvalue='Corr MS', uname='Corr MS', sensitive=0)
PCA_Decorr_button=widget_button(corr_choice, value='PCA', uvalue='Corr PCA', uname='Corr PCA', sensitive=0)
both_decorr_button=widget_button(corr_choice, value='Both', uvalue='Corr Both', uname='Corr Both', sensitive=0)


; Set up the output window
result_list = widget_base(base,/column,frame=1)

temp1 = widget_base(result_list,/column)
temp2 = widget_base(temp1,/row)

src = widget_label(temp2,/align_left,value='Source:')
state.source_name_wid = widget_label(temp2,value='',/dynamic_resize);,xsize=50)

temp3 = widget_base(temp1,/row)

fl = widget_label(temp3,/align_left,value='File:  ')
state.filename_wid = widget_label(temp3,value='',/dynamic_resize);xsize=50)

result_label = widget_label(result_list,/align_center,$
                            value='Fit Results')

state.fit_status_wid = $
  widget_label(result_list,/align_center,$
               value = 'No current fit',/dyn)

;state.redchi_wid = $
;  widget_label(result_list,/align_left,value='Shall I !C tempt fate?',/dyn)
;
;state.dof_wid = $
;  widget_label(result_list,/align_left,value='',/dyn)

state.report_wid = $
  widget_text(result_list,frame=1,xsize=60,ysize=20,/scroll,$
;              value = ['This is a test','of the emergency broadcast'],$
              uvalue='Fit Result',uname='Fit Result')


WIDGET_CONTROL, base, /REALIZE 
; Make sure we know the window ID of the plot window, and make sure
; the default plot window for the IDL session is different
WIDGET_CONTROL, draw, GET_VALUE = index
state.draw_window_index = index
;!d.window=index+1
;WSET, state.draw_window_index

XMANAGER, 'zilf', base, EVENT_HANDLER = 'zilf_event', no_block = 1

end
