;ZSPEC_FIT_LINES_CONT
;
;PURPOSE:
;  To fit a z-spec spectrum to a continuum + lines model.
;
;CALLING SEQUENCE:
;  fit = zspec_fit_lines_cont(flags, spec, err, redshift, species,
;                             transition, [cont_type=cont_type,
;                             lw_value=lw_value, lw_tied=lw_tied,
;                             lw_fixed=lw_fixed,
;                             z_tied=z_tied, z_fixed=z_fixed,
;                             frequency=frequency,
;                             profile_type=profile_type])
;
;REQUIRED INPUTS:
;  flags - [boolean] An array of flags, to decide which lines
;          to include in the fit (1 = yes, 0 = no).
;  spec - [float] The z-spec spectrum.
;  err - [float] The 1sigma rms error on spec.
;  redshift - [float] The start value for the source redshift to use
;             in the fit. This can be a scalar, or can be set to an
;             array specifying starting redshifts for each species
;             (i.e for fitting multiple sources).
;  species - [string] An array of strings specifying which species to
;            fit to (see zspec_line_table.txt for available species).
;  transition - [string] An array of strings specifying which
;               transitions for each species to fit to (see
;               zspec_line_table.txt for available transitions).
;
;OPTIONAL INPUTS:
;  cont_type - [string] Model for continuum fit. Options are:
;              1. 'NONE' - No continuum (default).
;              2. 'PWRLAW' - Power law, S(nu) =
;       d                     S(240GHz)*(nu/240GHz)^alpha
;              3. 'M82FFT' - Some model for M82 based on ?
;              4. '1068BBP' - See ngc1068_fitfun.pro
;  lw_value - [float] Starting value for the line width (km/s). Default is
;             200 km/s.
;  lw_tied - [boolean] Set this to 1 if you want to tie all linewidths
;            for all species together in the fit (i.e. fit a single
;            linewidth to all). Default is to fit each individually.
;  lw_fixed - [boolean] Set this to fix the linewidth to lw_value, and
;             don't fit it. Default is to let it be a free parameter.
;  z_tied - [integer] Either a scalar or an array indicating which
;           redshifts to tie together in the fit. If a scalar, z_tied
;           = 1 will tie all redshifts together (default), and z_tied
;           = 0 will not tie any together. If an array, must have the
;           same number of elements as SPECIES, and you set a single
;           integer for each line to tie together. For example, if you
;           want to simultaneously fit to two sources, one at z =
;           2.956 and the other at z = 2.532, and fit the 12CO
;           transitions, here's how you define redshift, species,
;           transitions, and z_tied:
;           REDSHIFT   = [ 2.956, 2.956, 2.956, 2.956, 2.532, 2.532,
;                          2.532, 2.532]
;           SPECIES    = ['12CO','12CO','12CO','12CO','12CO','12CO',
;                         '12CO','12CO']
;           TRANSITION = [ '7-6', '8-7', '9-8','10-9', '6-5', '7-6',
;                          '8-7', '9-8']
;           Z_TIED     = [     1,     1,     1,     1,     2,     2,
;                              2,     2]
;  z_fixed - [boolean] Set this if you want to fix the redshift in the
;            fix. Default is to let it be a free parameter.
;  frequency - ?
;  profile_type - ?
;
;OUTPUTS:
;  fit - a structure containings lots of information about the fit:
;
;MODIFICATION HISTORY
;  ??/??/?? - ?? - Created.
;  05/28/10 - KS - Added header.
;                - Added option to fit multiple sources at once.
;  06/07/10 - JRK - Added 1068 continuum option
;  08/06/10 - KS - Now doesn't tie redshifts together by default
;-------------------------------------------------------------------

; I may want to do the indication of flags or whfit differently, but
; this is consistent with the way zilf works ...

function zspec_fit_lines_cont, flags, spec, err, $
                               redshift, species, transition, $
                               cont_type = cont_type, $
                               LW_VALUE = LW_VALUE, $
                               LW_TIED = LW_TIED, $
                               LW_FIXED = LW_FIXED,$
                               z_tied = z_tied,$
                               z_fixed = z_fixed,$
                               frequency = frequency, $
                               profile_type = profile_type, stopit=stopit,$
                               fixed=fixed, limits=limits, $
                               startvals=startvals, base=base, covar=covar, $
                               freqs=freqs

if keyword_set(freqs) then nu=freqs else nu = freqid2freq()
nlines = n_e(species)

; The location in the svn of the line catalog
;line_catalog = !zspec_pipeline_root+'/line_cont_fitting/zilf/line_table.txt'

;input checking
;--------------
;redshift must be either a scalar or an nlines array
if (n_e(redshift) ne 1) and (n_e(redshift) ne nlines) then begin
    a=dialog_message('ERROR: REDSHIFT must be either a scalar or have the same number of elements as SPECIES.',$
      dialog_parent=base, /error)
    return, {valid:0}
endif
;if z_tied is set, must be either a scalar or an nlines array
if keyword_set(z_tied) then begin
    if (n_e(z_tied) ne 1) and (n_e(z_tied) ne nlines) then begin
        a=dialog_message('ERROR: Z_TIED must be either a scalar or have the same number of elements as SPECIES.',$
                         dialog_parent=base, /error)
        return, {valid:0}
    endif
endif

; Load in FTS data.  Be good to have a way to pass this in as well, I
; suppose ...
RESTORE, !ZSPEC_PIPELINE_ROOT + $
  '/line_cont_fitting/ftsdata/normspec_nov.sav'

; Indices for the parameters
paramsperline = 3
ampind = paramsperline*INDGEN(nlines)
widthind = paramsperline*INDGEN(nlines)+1
redind = paramsperline*INDGEN(nlines)+2
if (n_e(redshift) eq 1) then z_start = replicate(double(redshift), nlines) $
  else z_start = double(redshift)

; If the list of frequencies for the lines in question is already
; supplied (via the frequency keyword, a la zilf) then don't bother
; reading them in ... otherwise do so
if (~(keyword_set(frequency))) then begin
    frequency = dblarr(nlines)
; Read list of known lines and rest frequencies
;    print,'Reading catalog from'
;    print,line_catalog
;    readcol,line_catalog,$
;      comment=';',format='(A,A,D)',$
;      species_cat,transition_cat,frequency_cat,/silent
    read_line_catalog,species_cat,transition_cat,frequency_cat,profile_type_cat

; Make these all upper case for comparison
    species_cat = strupcase(species_cat)
    transition_cat = strupcase(transition_cat)

; Given the requested input species and transition, find the
; frequencies
    profile_type = strarr(nlines)
    for line=0,nlines-1 do begin

        wh = where(species_cat eq strupcase(species[line]) and $
                   transition_cat eq strupcase(transition[line]))
        if (wh[0] eq -1) then begin
            a=dialog_message('Line not recognized',dialog_parent=base, /error)
             return, {valid:0}
         endif
        frequency[line] = frequency_cat[wh]
        profile_type[line] = strupcase(profile_type_cat[wh])

    endfor

endif else begin

; For Zilf's benefit ... UGH.
    if (~keyword_set(profile_type)) then begin
        a=dialog_message('Must set both frequency and profile type', dialog_parent=base, /error)
        return, {valid:0}
    endif
    profile_type = strupcase(profile_type)

    if n_e(frequency) ne n_e(species) then begin
        a=dialog_message('Requested species and frequencies are incompatible.', dialog_parent=base, /error)
        return, {valid:0}
  endif

endelse


; Set the linewidth
if ~(lw_value) then linewidth = 200. $ ; km / s
  else linewidth = lw_value

; Set up the initial guess
p0 = dblarr(3*nlines)

p0[widthind] = linewidth
p0[redind] = redshift

; Deal with continuum choices ... we do this here so that the line
; amplitudes are referred to the continuum guess
cont_guess = dblarr(160)

if (~keyword_set(cont_type)) then begin
    cont_type = 'NONE'
endif else begin
    cont_type = strupcase(cont_type)
    case cont_type of
        'PWRLAW' : begin
; Add the necessary parameters to p0
            p0 = [p0,0.,0.]
; This is my way of dealing with nan's in the spectrum ...
            amp_guess = !values.d_nan
            offset = 0
            wh = find_nearest(nu,240.)
            while (finite(amp_guess) eq 0) do begin
                amp_guess = spec[wh+offset]
                ++offset
            endwhile
; Now that we have some reasonable guess at the continuum level, let's
; actually do a "pre-fit" for the continuum.
; This method might go bad if there are lots of flagged channels
            dspec = fin_diff(spec)
            whcont = where(abs(fin_diff(spec))/err lt 5)
            if (whcont[0] ne -1) then begin
                cont = $
                  mpfitfun_mr('pwrlaw_mpfit_func',$
                           nu[whcont]/240.,spec[whcont],err[whcont],$
                           [amp_guess,2.0],/quiet)
                p0[3*nlines] = cont[0]
                p0[3*nlines+1] = cont[1]
                cont_guess = pwrlaw_mpfit_func(nu/240.,cont)
             endif else begin
                p0[3*nlines] = amp_guess  
                p0[3*nlines+1] = 2.
                cont_guess = p0[3*nlines]*(nu/240.)^p0[3*nlines+1]
            endelse
        end
        'M82FFT' : begin
; Add the necessary parameters to p0
            p0 = [p0,0.,0.]
; This is my way of dealing with nan's in the spectrum ...
            amp_guess = !values.d_nan
            offset = 0
            wh = find_nearest(nu,240.)
            while (finite(amp_guess) eq 0) do begin
               amp_guess = spec[wh+offset]
               ++offset
            endwhile
            full_gal = hughes94_fitfun(nu[offset-1],[1.0,1.0])
            frac_guess = amp_guess/full_gal
; Now that we have some reasonable guess at the continuum level, let's
; actually do a "pre-fit" for the continuum.
; This method might go bad if there are lots of flagged channels
            dspec = fin_diff(spec)
            whcont = where(abs(fin_diff(spec))/err lt 5)
            if (whcont[0] ne -1) then begin
               cont = $
                  mpfitfun_mr('hughes94_fitfun',$
                           nu[whcont],spec[whcont],err[whcont],$
                           [frac_guess,1.0],/QUIET)
               p0[3*nlines] = cont[0]
               p0[3*nlines+1] = cont[1]
            endif else begin
               p0[3*nlines] = frac_guess  
               p0[3*nlines+1] = 1.
            endelse
            cont_guess = hughes94_fitfun(nu,p0[(3*nlines):(3*nlines+1)])
         end
        '1068BBP' : begin
; This section is really just copied from the M82 one, but changing the 
; name of the routine from hughes94_fitfun to ngc1068_fitfun.
; Add the necessary parameters to p0
            p0 = [p0,0.,0.]
; This is my way of dealing with nan's in the spectrum ...
            amp_guess = !values.d_nan
            offset = 0
            wh = find_nearest(nu,240.)
            while (finite(amp_guess) eq 0) do begin
               amp_guess = spec[wh+offset]
               ++offset
            endwhile
            full_gal = ngc1068_fitfun(nu[offset-1],[1.0,1.0])
            frac_guess = amp_guess/full_gal
; Now that we have some reasonable guess at the continuum level, let's
; actually do a "pre-fit" for the continuum.
; This method might go bad if there are lots of flagged channels
            dspec = fin_diff(spec)
            whcont = where(abs(fin_diff(spec))/err lt 5)
            if (whcont[0] ne -1) then begin
               cont = $
                  mpfitfun_mr('ngc1068_fitfun',$
                           nu[whcont],spec[whcont],err[whcont],$
                           [frac_guess,1.0],/QUIET)
               p0[3*nlines] = cont[0]
               p0[3*nlines+1] = cont[1]
            endif else begin
               p0[3*nlines] = frac_guess  
               p0[3*nlines+1] = 1.
            endelse
            cont_guess = ngc1068_fitfun(nu,p0[(3*nlines):(3*nlines+1)])
        end
        'NONE' : cont_guess=dblarr(160) ;Continuum of zeroes
        else: begin
            a=dialog_message('Continuum type not recognized', dialog_parent=base, /error)
            return, {valid:0}
        end

    endcase
endelse

; Now deal with constraints on the parameters 
parinfo = replicate({value:0.D, $
                     fixed:0, $
                     limited:[0,0], $
                     limits:[0.D,0],$
                     tied:''}, $
                    n_e(p0))


; Now that we know the frequencies we're fitting, make educated
; guesses for the initial conditions.
for line = 0,nlines-1 do begin
    wh = find_nearest(nu,frequency[line]/(1.+z_start[line]))
; This is my way of dealing with nan's in the spectrum ...
    amp_guess = !values.d_nan
    offset = 0
    while (finite(amp_guess) eq 0) do begin
        amp_guess = spec[wh+offset]-cont_guess[wh+offset]
        ++offset
    endwhile
    p0[ampind[line]] = amp_guess
endfor

; Define where in the spectrum to fit
whfit = where(finite(spec) and flags)
if keyword_set(covar) then covar=(covar[whfit,*])[*,whfit]

parinfo(*).value = p0


; Line strengths are constrained away from 0.
for ls = 0,nlines-1 do begin
    case strupcase(profile_type[ls]) of
        'SINGLE_EMISSION' : begin       
            print,'Not limiting the amplitude'

            parinfo(ampind[ls]).limited=[0,0]
            parinfo(ampind[ls]).limits=[0.,0.]
            print,'emission'
            if parinfo(ampind[ls]).value lt 0. then $
              parinfo(ampind[ls]).value = 1.d-6
        end
        'SINGLE_ABSORPTION' : begin          
            parinfo(ampind[ls]).limited=[0,1]
            parinfo(ampind[ls]).limits=[0.,0.]
; This is going to cause a problem if the initial guess for the
; absorption line isn't negative.  Gotta put in some more error
; trapping ...
;           if p0[ampind[ls]] gt 0. then p0[ampind[ls]]*= -1.
            parinfo[ampind[ls]].value = -1.d-6
            print,'absorption'
        end
        else: begin
            a=dialog_message('Line profile type not recognized', dialog_parent=base, /error)
            return, {valid:0}
        end
    endcase
endfor

;stop

; You can quibble with the above, but line WIDTHS had always better be
; positive.  And reasonable for galaxies ... that you might quibble with.
parinfo(widthind).limited=[1,0]
parinfo(widthind).limits=[50.,0.]

; This will crash unless you're fitting at least one line.
if (keyword_set(z_tied)) then begin
; Tie all the line redshifts together?
    if (n_e(z_tied) eq 1) then begin
        parinfo(redind).tied='P(2)'
        parinfo(2).tied=''
    endif else begin
        ;identify number of uniq redshifts
        uniq_ind = uniq(z_tied)
        for kk = 0, n_e(uniq_ind)-1 do begin
            whm = where(z_tied eq z_tied[uniq_ind[kk]], nm)
            if (nm gt 1) then begin
                parinfo(redind[whm[1:*]]).tied = $
                  strcompress('P('+string(redind[whm[0]])+')',/remove)
            endif
        endfor
    endelse
endif


if (keyword_set(z_fixed)) then begin
    parinfo(redind).fixed=1
endif

if (keyword_set(lw_tied)) then begin
    parinfo(widthind).tied='P(1)'
    parinfo(1).tied = ''
endif

if (keyword_set(lw_fixed)) then begin
    parinfo(widthind).fixed=1
endif

; CLOVERLEAF SPECIFIC MODIFICATIONS
cloverleaf = 0
if (cloverleaf) then begin

whh2oabs = where(species eq 'H2O' and profile_type eq 'SINGLE_ABSORPTION')
if (whh2oabs[0] ne -1) then begin
; Don't tie the redshift to the others, but bound it very strongly
    parinfo(redind[whh2oabs]).tied=''
    parinfo(redind[whh2oabs]).fixed = 0
    parinfo(redind[whh2oabs]).limited=[1,1]
    parinfo(redind[whh2oabs]).limits=[2.54586,2.60807]
    parinfo(ampind[whh2oabs]).value = -0.006
end

; Constrain the [CI] to near the Weiss value
whci = where(species eq '[CI]')
if (whci[0] ne -1) then begin
; Really need to fix it so that amplitude * width = Jy km/s, without
; this mucking about ...
    jeez = 5.2/500. * 5.2/16.28 * 5.2/7.52
    parinfo(ampind[whci]).value= jeez
;    parinfo(ampind[whci]).fixed=1
;    parinfo(ampind[whci]).limited = [1,1]
;    parinfo(ampind[whci]).limits = [jeez*0.5,jeez*1.5]
end

; Constrain the 7-6 to be near Barvainis value
wh76 = where(species eq '12CO' and frequency ge 806.6 and frequency le 806.7)

if (wh76[0] ne -1) then begin
; Really need to fix it so that amplitude * width = Jy km/s, without
; this mucking about ...
    jeez = 47.3/500. * 47.3/146.
    parinfo(ampind[wh76]).value= jeez
;    parinfo(ampind[wh76]).fixed=1
;    parinfo(ampind[wh76]).limited = [1,1]
;    parinfo(ampind[wh76]).limits = [jeez*0.5,jeez*1.5]
end

; Float the redshift of the water emission
whh2o = where(species eq 'H2O' and profile_type eq 'SINGLE_EMISSION')
if (whh2o[0] ne -1) then begin
; Don't tie the redshift to the others, but bound it very strongly
    parinfo(redind[whh2o]).tied=''
    parinfo(redind[whh2o]).fixed = 0
;    parinfo(redind[whh2o]).limited=[1,1]
;    parinfo(redind[whh2o]).limits=[2.54586,2.60807]
end

end

if keyword_set(fixed) then begin
;MJRR: Apply user limits
    for index=0, n_e(parinfo)-1 do begin
        if fixed[index] then parinfo[index].fixed=1
        if finite(limits[index, 0]) then begin
            parinfo[index].limited[0]=1
            parinfo[index].limits[0]=limits[index,0]
        endif
        if finite(limits[index, 1]) then begin
            parinfo[index].limited[1]=1
            parinfo[index].limits[1]=limits[index,1]
        endif
        if finite(startvals[index]) then parinfo[index].value=startvals[index]
    endfor
endif

; All right.  Let's just double check the goddamned parinfo variable
; for consistency.
for chk = 0,n_e(parinfo)-1 do begin

    if parinfo[chk].limited[0] eq 1 then begin
        if parinfo[chk].value lt parinfo[chk].limits[0] then begin
          a=dialog_message('Value less than negative limit', dialog_parent=base, /error)
          return, {valid:0}
      endif
    endif


    if parinfo[chk].limited[1] eq 1 then begin
        if parinfo[chk].value gt parinfo[chk].limits[1] then begin
          a=dialog_message('Value greater than positive limit', dialog_parent=base, /error)
          return, {valid:0}
      endif
    endif

    if parinfo[chk].limited[1] eq 1 and parinfo[chk].limited[0] eq 1 then begin
        if parinfo[chk].limits[0] ge parinfo[chk].limits[1] then begin
          a=dialog_message('Lower limit >= upper limit', dialog_parent=base, /error)
          return, {valid:0}
      endif
    endif
endfor

; -----------------------------------------------------------------------------
; Generate the independent variable for the fit
x = create_struct('species',species,$
                  'transition',transition,$
                  'line_freqs',frequency,$
                  'cont',cont_type,$
                  'nu_fts',nu_trim,$
                  'ftsspec',spec_coadd_norm[whfit,*])

; A structure that will generate the model for all frequencies, not
; just the ones that were fit.
xall = create_struct('species',species,$
                     'transition',transition,$
                     'line_freqs',frequency,$
                     'cont',cont_type,$
                     'nu_fts',nu_trim,$
                     'ftsspec',spec_coadd_norm[lindgen(160),*])

xall_lines = create_struct('species',species,$
                           'transition',transition,$
                           'line_freqs',frequency,$
                           'cont','none',$
                           'nu_fts',nu_trim,$
                           'ftsspec',spec_coadd_norm[lindgen(160),*])
; -----------------------------------------------------------------------------
;stop
p = mpfitfun_mr('zspec_line_cont_fitfun', x, spec[whfit], err[whfit], $ 
             parinfo=parinfo,maxiter=2000,$
             DOF = dof, BESTNORM = sqresid,$
             PERROR = parerr, COVAR = covar,$
             ftol = 1.d-4, status=status, errmsg=errmsg, data_covar=covar)
;stop

if status le 0 then begin
    a=dialog_message('MPFITFUN_MR returned the followng error: '+errmsg, dialog_parent=base, /error)
    return, {valid:0}
endif


dof = double(dof)

fitspec = zspec_line_cont_fitfun(xall,p,scales,centers)
linespec = zspec_line_cont_fitfun(xall_lines,p,scales,centers)

resid = spec - fitspec

; Note that the original errors will be too large to properly
; normalize, because of the loss of degrees of freedom 
norm_resid = resid[whfit] / (err[whfit] * sqrt(dof/n_e(whfit)) )

hresid = hist_wrapper(norm_resid,.5,-5,5)

; And now, pretty print the lines ...

if total(parerr[widthind] eq 0) then widtherr = replicate(1.,nlines) $
  else widtherr = parerr[widthind]

int_line = p[ampind]*scales*p[widthind]
int_line_err = parerr[ampind]*scales*p[widthind]

summary = strarr(nlines+2)
summary[0] = string('Species','Transition',$
                    'Line Flux','Error','S/N',$
                    format='(A12,A12,A12,A12,A12)')

summary[1] = string(' ',' ',$
                    '(Jy km/s)','(Jy km/s)',' ',$
                    format='(A12,A12,A12,A12,A12)')

for lines=0,nlines-1 do begin

    summary[lines+2] = string(species[lines],transition[lines],$
                            int_line[lines],int_line_err[lines],$
                            int_line[lines]/int_line_err[lines],$
                            format='(A12,A12,G12.2,G12.2,G12.2)')
    
endfor

; Make up the return structure

CASE cont_type OF 
   'PWRLAW': BEGIN
      camp = p[3*nlines]
      caerr = parerr[3*nlines]
      cexp = p[3*nlines+1]
      ceerr = parerr[3*nlines+1]
   END
   'M82FFT': BEGIN
      camp = p[3*nlines]
      caerr = parerr[3*nlines]
      cexp = p[3*nlines+1]
      ceerr = parerr[3*nlines+1]
   END
   '1068BBP': BEGIN
      camp = p[3*nlines]
      caerr = parerr[3*nlines]
      cexp = p[3*nlines+1]
      ceerr = parerr[3*nlines+1]
   END
   ELSE: BEGIN
      camp = 0.d
      caerr = 0.d
      cexp = 0.d
      ceerr = 0.d
   END
ENDCASE


;; if (cont_type eq 'PWRLAW') then begin
;;     camp = p[3*nlines]
;;     caerr = parerr[3*nlines]
;;     cexp = p[3*nlines+1]
;;     ceerr = parerr[3*nlines+1]
;; endif else begin
;;     camp = 0.d
;;     caerr = 0.d
;;     cexp = 0.d
;;     ceerr = 0.d
;; endelse

fit = create_struct('lcspec',fitspec,$
                    'cspec',fitspec-linespec,$
                    'flags',flags,$
                    'redchi',sqresid/dof,$
                    'dof',dof,$
                    'camp',camp,$
                    'caerr',caerr,$
                    'cexp',cexp,$
                    'ceerr',ceerr,$
                    'amplitude',p[ampind],$
                    'amperr',parerr[ampind],$
                    'redshift',p[redind],$
                    'zerr',parerr[redind],$
                    'width',p[widthind],$
                    'widtherr',parerr[widthind],$
                    'covar',covar,$
                    'parinfo',parinfo,$
                    'summary',summary,$
                    'x',x,$
                    'xall',xall,$
                    'xall_lines',xall_lines,$
                    'p',p,$
                    'scales',scales,$
                    'centers',centers, $
                    'valid', 1)

if keyword_set(stopit) then stop                    

return,fit

end
