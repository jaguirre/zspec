function mpgaussian, x, p

  return, p[0]*exp(-(x-p[1])^2/2./p[2]^2)

end
;PRO ZEARCH_KS
;
;CALLING SEQUENCE:
;
;
;PURPOSE:
;  Takes in spectrum from z-spec and determines best redshift for the
;  source.
;
;INPUTS:
;  nu - [float] observed frequency [GHz].
;  spec_in - [float] observed spectrum [Jy].
;  spec_err - [float] error on spec_in [Jy].
;
;OPTIONAL INPUTS:
;  nocont - [boolean] If set, will not subtract the continuum before
;           identifying the redshift.
;  resolution - [integer] 1/2 the number of redshifts to
;               sample. Default is r = 2000.
;  name - [string] Prefix for output postscript file. Default is
;         "MySource", and the output name will be
;         "MySource_zearch.eps". Also prefix for output saveset.
;  noeps - [boolean] Set this to avoid outting a postscript file.
;  z_to_flag - [float] A scalar or vector array specifying which
;              redshifts to flag. The output arrays Z_FLAGS1,
;              Z_FLAGS2, and Z_FLAGS3 will be set to zero at these
;              redshifts and where secondary peaks occur in the En(z)
;              distribution. If not set, will determine this from the
;              maximum in the En(z) distributions. Alternatively, can
;              be set to -1, and no values will be flagged.
;  
;OUTPUTS:
;  z - [float] redshifts.
;  sn - [float] S/N estimate as a function of z. Calculated as the
;       summed S/N from all lines in the band.
;  snpair - [float] S/N estimate as a function of z. Calculated as the
;           median of the line-to-line average S/N.
;  snave - [float] S/N estimate as a function of z. Calculated as the
;          weighted average S/N for all lines in the band.
;  cont - [float] Continuum from fit [Jy].
;  z_flags1 - [integer] An array of flags corresponding to z. Is set
;             to 1 for values to use in determining the En(z)
;             distribution. Is set to 0 at the maximum En(z) and it's
;             secondary peaks. This corresponds to the E1(z)
;             estimator, or output variable SN.
;  z_flags2 - [integer] An array of flags corresponding to z. Is set
;             to 1 for values to use in determining the En(z)
;             distribution. Is set to 0 at the maximum En(z) and it's
;             secondary peaks. This corresponds to the E2(z)
;             estimator, or output variable SNPAIR.
;  z_flags3 - [integer] An array of flags corresponding to z. Is set
;             to 1 for values to use in determining the En(z)
;             distribution. Is set to 0 at the maximum En(z) and it's
;             secondary peaks. This corresponds to the E3(z)
;             estimator, or output variable SNAVE.
;
;MODIFICATION HISTORY:
;  05/24/10 - KS - Adapted from zsearch_rl.pro, adding notes and
;             comments. Changes:
;             1. fits power law to the continuum, instead of 4-deg polynomial
;             2. Added snave, the weighted average of the S/N
;             3. Added width as an optional keyword
;             4. Removed zmax and zerr outputs
;             5. Outputs saveset with results.
;  06/07/10 - KS - Added flagging for ringing about the maximum z.
;  06/09/10 - KS - Added keyword NOEPS.
;  06/16/10 - KS - Added keyword Z_TO_FLAG
;                - Changed to printing z at max En(z), rather than
;                  fit, to the eps file.
;                - Changed to fitting 4-deg polynomial, rather than 
;                  powerlaw.
;  06/25/10 - KS - Removed fitting of gaussian. Error estimates on z comes
;                  from width of bins now.
;                - Simplified code to flag secondary peaks.
;  07/15/10 - KS - Updated spectral frequencies.
;  08/03/10 - KS - Added option to not flag any redshifts
;  01/26/11 - KS - Changed E3(z) estimator to that
;                  suggested by JZ for testing
;                - Replaced error estimate with gaussian fits
;==================================================================

pro zearch, nu, spec_in, specerr, z, sn, snpair, cont, $
            resolution=resolution, nocont=nocont, name=name, $
            snave=snave, z_flags1=z_flags1, z_flags2=z_flags2, $
            z_flags3=z_flags3, noeps=noeps, z_to_flag=z_to_flag, $
            fp1=fp1, fp2=fp2, fp3=fp3, png=png, zrange=zrange, suffix=suffix, $
            mol=mol

if ~keyword_Set(suffix) then suffix=''
;constants    
c=2.99792458e5 ;km/s

;defaults
if not keyword_set(z_to_flag) then z_to_flag = 0

;Subtract the continuum from the spectrum, fitting a power-law
if not keyword_set(nocont) then begin 
    a = poly_fit(nu, spec_in, 4, measure_errors=specerr)
    cont = poly(nu, a)
    spec = spec_in - cont
endif else begin
    spec = spec_in ;Jy
    cont = nu*0.
endelse
nnu = n_e(nu)

;compute width (i.e. error) of frequency bins
dnuu = fltarr(nnu)
dnul = fltarr(nnu)
for i = 0, nnu-1 do begin
    if (i eq 0) then dnul[i] = (nu[i+1] - nu[i])/2. $
    else dnul[i] = (nu[i] - nu[i-1])/2.
    if (i eq nnu-1) then dnuu[i] = (nu[i] - nu[i-1])/2. $
    else dnuu[i] = (nu[i+1] - nu[i])/2.
endfor

;defined redshifts to sample
if not keyword_set(resolution) then r = 2500 else r = resolution
nz = r*2
if ~keyword_set(zrange) then zrange=[0.2,6.0]
z = findgen(nz)/(nz-1)*(zrange[1]-zrange[0])+zrange[0]

;output arrays for S/N
sn = fltarr(nz)
snpair = fltarr(nz)
snerr = fltarr(nz)
snave = fltarr(nz)

;nu range
nu_range = minmax(nu) ;GHz

if ~keyword_set(mol) then begin
;rest-frame nu from CO transitions (LAMDA)
    co_freqs = [115.2712018, $
                230.5380000, $
                345.7959899, $
                461.0407682, $
                576.2679305, $
                691.4730763, $
                806.6518060, $
                921.7997000, $
                1036.9123930, $
                1151.9854520, $
                1267.0144860, $
                1381.9951050, $
                1496.9229090, $
                1611.7935180, $
                1726.6025057, $
                1841.3455060, $
                1956.0181390, $
                2070.6159930, $
                2185.1346800]
;rest-frame nu, other species
    ci = [492.160651, 1301.502620] ;GHz (LAMDA)
    cii = 1900.5369 ;;[659.364,847.903,1507.267,1900.5369]  ;GHz (LAMDA)
    nii = [1461.13180]     ;GHz (Brown and Evenson, ApJL, 428, L37, 1994)
    atoms = [ci, nii, cii]      ;GHz
    
;names of transitions
    cotrans=['1-0','2-1','3-2','4-3','5-4','6-5','7-6','8-7','9-8',$
             '10-9','11-10','12-11','13-12','14-13','15-14','16-15','17-16', $
             '18-17','19-18']
    atrans=['[CI] 1-0','[CI] 2-0','[NII] 1-0','[CII] 2-1']
    
;combine
    co_freqs=[co_freqs,atoms]   ;GHz
    cotrans=[cotrans,atrans]
endif else begin
    readcol, !zspec_pipeline_root+'/line_cont_fitting/zspec_line_table.txt', species, trans, $
      frequency, comment, format='(A,A,D,A)'

    Nmol=n_e(mol)
    for i=0, Nmol-1 do begin
        w=where(species eq mol[i], count)
        if count eq 0 then begin
            print, 'No Entries for ' + mol[i]+' in line table. Exiting'
            return
        endif 

        if i eq 0 then begin
            cotrans=species[w]+' ' +trans[w]
            co_freqs=frequency[w]
        endif else begin
            cotrans=[cotrans, species[w]+' '+trans[w]]
            co_freqs=[co_freqs, frequency[w]]
        endelse
    endfor 
endelse

;S/N of each channel
snspec = spec/specerr

;Define pointer array for indexing
ilines = ptrarr(nz, /allocate_heap)

;***add channel flags

;Loop over redshifts and compute various S/N estimates
zerru = fltarr(nz)
zerrl = fltarr(nz)
for i=0, nz-1 do begin

    ;Pluck out, for a given redshift, which CO lines fall in the band.
    wh_freqs = where(co_freqs/(1.+z[i]) ge nu_range[0] and $
                     co_freqs/(1.+z[i]) le nu_range[1], nwhfreqs)
    
    if nwhfreqs eq 0 then begin
        sn[i]=!values.F_NAN
        continue
    endif 
    
    ;if there are one or more lines in the zspec band at this redshift, 
    ;compute the sum total S/N of the detection
    *ilines(i) = intarr(nwhfreqs)
    if (nwhfreqs gt 0) then begin
        for j=0, nwhfreqs-1 do begin
            whx = find_nearest(nu,(co_freqs/(1.+z[i]))[wh_freqs[j]])
            (*ilines(i))(j) = whx
            snerr[i] += (specerr[whx])^2
            sn[i] += spec[whx]
        endfor
        sn(i) = sn(i)/sqrt(snerr(i))
    
        ;if there are two or more lines, compute median of the average S/N for
        ;each pair of lines
        if (nwhfreqs gt 1) then begin
            n_sn = factorial(nwhfreqs) / factorial(2) / factorial(nwhfreqs-2)
            dumsn2 = fltarr(n_sn)
	
            dumi=0
            for k=0, nwhfreqs-2 do begin
                for l = k+1, nwhfreqs-1 do begin
                    dumsn2(dumi) = (snspec((*ilines(i))(k)) + $
                                    snspec((*ilines(i))(l))) / 2.
                    dumi++
                endfor
            endfor
           
            snpair[i] = median(dumsn2)*sqrt(nwhfreqs)
        endif else snpair[i] = -99

;        ;test, weighted average of S/N
;        snave[i] = total(snspec(*ilines(i)) / (specerr(*ilines(i)))^2) / $
;                   total(1 / (specerr(*ilines(i)))^2)        
        ;test, JZ estimator
        snave[i] = total(snspec(*ilines(i))) / sqrt(nwhfreqs)

        ;compute error on the redshift
        zerru[i] = min((1+z[i]) * dnuu(*ilines(i)) / nu(*ilines(i)))
        zerrl[i] = min((1+z[i]) * dnul(*ilines(i)) / nu(*ilines(i)))

    endif

endfor 

w=where(finite(sn), goodcount)
if goodcount eq 0 then begin
    print, 'No lines in band at any redshift'
    return
endif
sn=sn[w]
snpair=snpair[w]
snave=snave[w]
z=z[w]
ilines=ilines[w]
nz=n_e(z)

;get max En(z), and flag E(z) at ringing points
;first one, max E(z)
mpar = max(sn, cpar)
zmax1 = z[cpar]
zerr1u = zerru[cpar]
zerr1l = zerrl[cpar]
if (keyword_set(z_to_flag) and z_to_flag ne -1) then begin
    ;flag z at user-defined redshift(s)
    n2flag = n_e(z_to_flag)
    cpar = lindgen(n2flag)*0
    for kk = 0, n2flag-1 do begin
        mndiff = min(abs(z - z_to_flag[kk]), whmn)
        cpar[kk] = whmn
    endfor
    cpar_def = cpar
endif else n2flag = 1 ;flag z at max E1(z)
z_flags1 = intarr(nz) + 1
;loop over all z to flag
if (z_to_flag ne -1) then begin
    for kk = 0, n2flag-1 do begin
        whnu = *ilines(cpar[kk])
        for i = 0, nz-1 do begin
            test = *ilines(i)
            for j = 0, n_e(test)-1 do begin
                if (where(whnu eq test[j]))[0] ne -1 then z_flags1[i] = 0
            endfor
        endfor
    endfor
endif
;fit gaussian
wheqmx = where(sn eq mpar)
sp = [mpar, mean(z[wheqmx]), mean([zerr1u,zerr1l])]
snerr = replicate(1.,nz)
fp1 = mpfitfun('mpgaussian', z, sn, snerr, sp, bestnorm=chi2, dof=dof, $
               perror = fperr1, status=status, yfit=yfit, /quiet)
fperr1 = fperr1 * sqrt(chi2/dof)

;second one, max E(z)
mpar = max(snpair, cpar)
zmax2 = z[cpar]
zerr2u = zerru[cpar]
zerr2l = zerrl[cpar]
;second one, ringing
if (keyword_set(z_to_flag) and z_to_flag ne -1) then $
  cpar = cpar_def               ;flag z at user-defined redshift(s)
z_flags2 = intarr(nz) + 1
;loop over all z to flag
if (z_to_flag ne -1) then begin
    for kk = 0, n2flag-1 do begin
        whnu = *ilines(cpar[kk])
        for i = 0, nz-1 do begin
            test = *ilines(i)
            for j = 0, n_e(test)-1 do begin
                if (where(whnu eq test[j]))[0] ne -1 then z_flags2[i] = 0
            endfor
        endfor
    endfor
endif
;fit gaussian
wheqmx = where(snpair eq mpar)
sp = [mpar, mean(z[wheqmx]), mean([zerr2u,zerr2l])]
snerr = replicate(1.,nz)
fp2 = mpfitfun('mpgaussian', z, snpair, snerr, sp, bestnorm=chi2, dof=dof, $
               perror = fperr2, status=status, yfit=yfit, /quiet)
fperr2 = fperr2 * sqrt(chi2/dof)

;third one, max E(z)
mpar = max(snave, cpar)
zmax3 = z[cpar]
zerr3u = zerru[cpar]
zerr3l = zerrl[cpar]
;third one, ringing
if (keyword_set(z_to_flag) and z_to_flag ne -1) then $
  cpar = cpar_def               ;flag z at user-defined redshift(s)
z_flags3 = intarr(nz) + 1
;loop over all z to flag
if (z_to_flag ne -1) then begin
    for kk = 0, n2flag-1 do begin
        whnu = *ilines(cpar[kk])
        for i = 0, nz-1 do begin
            test = *ilines(i)
            for j = 0, n_e(test)-1 do begin
                if (where(whnu eq test[j]))[0] ne -1 then z_flags3[i] = 0
            endfor
        endfor
    endfor
endif
;fit gaussian
wheqmx = where(snave eq mpar)
sp = [mpar, mean(z[wheqmx]), mean([zerr3u,zerr3l])]
snerr = replicate(1.,nz)
fp3 = mpfitfun('mpgaussian', z, snave, snerr, sp, bestnorm=chi2, dof=dof, $
               perror = fperr3, status=status, yfit=yfit, /quiet)
fperr3 = fperr3 * sqrt(chi2/dof)

;plot up estimates
if not keyword_set(noeps) then begin
    if not keyword_set(name) then name = 'MySource'

    if ~keyword_set(png) then begin
        set_plot,'ps'
        device, file=name+suffix+'_zearch.eps', /encap, /color, /portrait
    endif else erase
   
    !p.font=0
    loadct,39
    multiplot,[1,3],/init
;Summed S/N
    multiplot
    whg = where(z_flags1 eq 1)
    plot, z, sn, psym=10, xs=1, xr=[zrange[0], zrange[1]], xtitle=' ', $
      ytit=textoidl('E_{1}(z)'), ytickname=[' '], thick=2, charsize=1.5
    oplot, z[whg], sn[whg], color=100, psym=10
    vline, zmax1, color=240, thick=3, linestyle=2
    legend, ['z(max) = '+sstr(zmax1,prec=3)], box=0, /right, charsize=1.3
;Pair S/N
    multiplot
    whf = where(snpair gt -98)
    whg = where(snpair gt -98 and z_flags2 eq 1)
    plot, z[whf], snpair[whf], psym=10, xs=1, xr=[zrange[0], zrange[1]], xtitle=' ', $
      ytit=textoidl('E_{2}(z)'), thick=2, charsize=1.5
    oplot, z[whg], snpair[whg], color=100, psym=10
    vline, zmax2, color=240, thick=3, linestyle=2
    legend, ['z(max) = '+sstr(zmax2,prec=3)], box=0, /right, charsize=1.3
;Weighted average S/N
    multiplot
    whg = where(z_flags3 eq 1)
    plot, z, snave, psym=10, xs=1, xr=[zrange[0], zrange[1]], xtit='Redshift', $
      ytit=textoidl('E_{3}(z)'), thick=2, charsize=1.5
    oplot, z[whg], snave[whg], color=100, psym=10
    vline, zmax3, color=240, thick=3, linestyle=2
    legend, ['z(max) = '+sstr(zmax3,prec=3)], box=0, /right, charsize=1.3
    legend, [name], box=0, /right, /bottom, charsize=1.3, $
      textcolor=240, pos=[5.3,-2.5]
    !p.multi=0

    if ~keyword_set(png) then begin
        device,/close
        set_plot,'x'
    endif else x2png, name+suffix+'_zearch_est.png', /color,/rev

    multiplot,/reset
endif

if not keyword_set(z_to_flag) then z_to_flag = -1

;save results
save, file=name+suffix+'_zearch.sav', nu, dnuu, dnul, spec_in, spec, specerr, $
  cont, z, zerru, zerrl, sn, snpair, snave, snspec, $
  z_flags1, z_flags2, z_flags3, z_to_flag, zmax1, zerr1u, zerr1l, $
  zmax2, zerr2u, zerr2l, zmax3, zerr3u, zerr3l, fp1, fperr1, fp2, fperr2, $
  fp3, fperr3, zrange

;free pointer
ptr_free, ilines

end
