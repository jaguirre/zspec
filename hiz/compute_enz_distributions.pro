@~/zspec_svn/processing/spectra/calculate_corr.pro
;COMPUTE_ENZ_DISTRIBUTIONS.PRO
;
;PURPOSE:
; This procedure takes in a Z-spec spectrum for a source and a model
; for the continuum and lines, makes simulated data sets from this
; model, and uses them to determine the distribution in the S/N
; estimators (En(z)) from zearch_ks.pro.
;
;CALLING SEQUENCE:
; compute_enz_distributions, spectra_sav, [, $
;                               zearch_sav=zearch_sav, $
;                               output_savfile=output_savfile, $
;                               output_png=output_png, $
;                               nsims=nsims, $
;                               bsize=bsize, $
;                               prob_thresh=prob_thresh, $
;                               flags=flags, $
;                               resolution=resolution, $
;                               noplots=noplots, $
;                               input_savfile=input_savfile, $
;                               line_sims=line_sims, $
;                               averr=averr, $
;                               corr_noise=corr_noise]
;
;INPUTS:
; spectra_sav - [string] An IDL saveset containing the z-spec spectrum
;               for the source (as output from uber_spectrum.pro).
; input_savfile - [string] optional Specify this to use a pre-computed sav file output by 
;                 compute_enz_distributions, to regenerate plots.
;
;OUTPUTS:
; Plot of the En(z) distributions.
;
;OPTIONAL INPUTS:
; zearch_sav - [string] An IDL saveset output from zearch_ks.pro,
;              containing the En(z) calculations for the real data. If
;              set, will overplot the distributions for the real data
;              for comparison.
; nsims - [integer] The number of simulated spectra to make for
;         calculating the En(z) distributions. Default is 100.
; bsize - [float] The binsize to use for making the En(z)
;         distribution. Default is 0.1
; prob_thresh - [float] The probability threshold to determine a
;               limiting value of En(z). For example, for prob_thresh
;               = 0.005, will compute the value of En(z) where
;               P(>En(z)) = 0.005, and will print this to the
;               screen. Default value is 0.001.
; flags - [integer] - A 160-element array containing flags to use for
;         each channel, equal to 1 for good channels, and 0 for bad
;         channels, so use in zearch_ks.pro This ideally should be set
;         such that you're flagging the same channels when using
;         zearch_ks.pro on the real data and the simulated
;         data. Default of flags = 1 for all channels.
; resolution - see zearch_ks.pro for description. Is passed to that
;              procedure, so use same value here as used on real data.
; nocont - see zearch_ks.pro for description. Is passed to that
;          procedure.
; noplots - prevents the program from outputting plots
; z_to_flag - see zearch.pro for full description. To summarize,
;             set this equal to the redshift(s) you want to exclude in
;             determining the En(z) distribution.
; line_sims - [boolean] if set, the simulated spectrum will have the same mean value in 
;             each channel as the input spectrum. The default is 0.
; averr - [boolean] if set, the code will use the uber_spectra instead of uber_psderror structure 
;         from the input .sav file. uber_psderror is the default.
; corr_noise - [boolean] if set, the code will use Cholesky factorization to generate simuated spectra with the 
;              same correlation matrix as the input spectrum
;
;OPTIONAL OUTPUTS:
; output_savfile - [string] - If set, will save variables in output saveset.
; output_png - [string] - If set, will write the on-screen plot to a
;              png file.
;
;MODIFICATION HISTORY
; 06/09/10 - KS - Created
; 06/16/10 - KS - Removed input SPECTRA_MODEL. Now simulations are
;                 drawn from real data.
;               - Added gaussian fit to En(z) distributions
;               - Added keyword Z_TO_FLAG
; 06/25/10 - KS - Fixed error with errors on simulated data.
; 08/03/10 - KS - Added option for user to input savesets,
;                 rather than make simulated data.
; 08/04/10 - KS - Added keyword NOISE_ONLY
; 12/30/10 - KS - Added keyword INPUT_SAVFILE
;               - Modified to find distribution in max(E) values and
;                 redshifts at max E.
; 01/26/10 - KS - Major overhaul for memory allocation problems.
;               - Removed option to to line simulations
;               - Removed option to read from saved simulations
;               - Removed gaussian fit to distributions
; 04/05/10 - KS - Added back in options to do line
;                 simulations through keyword LINE_SIMS
; 04/08/10 - RL - Spot-checking the E distributions for 3 redshfits za=1, zb=2, zc=z_real
; 04/10/10 - RL - Only uber_spectra gives stadard normal noise estimates?!...
;		  Changed everything to use the nod stddev instead of psderror..
;		- Added more-or-less useful plots, fixed multiple plot ranges, text locations
;		- Added the fcount and ffcount variables, but they are probably irrelevant
;		- Calculating correlation coefficients between all E_i pairs.
;		  I don't think I can do this without storing all values for Ei and zmax_i 
;		  generated for each simulation.
;		- Created z12_hist, z23_hist and z13_hist to look at the distribution of 
;		  joint hits in redshift
; 04/14/10 - KS - Added in option to use correlated noise by
;                 CORR_NOISE keyword.
; 05/23/10 - RL - After changing the definition of E2, I am also adding a cut in the minimum value accepted
;                for 1/2(S_i/N_i+S_j/N_j)
;               - added yet more nasty plots to clutter your folders
; 10/10/11 - RL - committed version
;-----------------------------------------
pro compute_enz_distributions, spectra_sav, $
                               zearch_sav=zearch_sav, $
                               output_savfile=output_savfile, $
                               output_png=output_png, $
                               nsims=nsims, $
                               bsize=bsize, $
                               prob_thresh=prob_thresh, $
                               flags=flags, $
                               resolution=resolution, $
                               noplots=noplots, $
                               input_savfile=input_savfile, $
                               line_sims=line_sims, $
                               averr=averr, $
                               corr_noise=corr_noise


;DEFAULT SETTINGS
;if not keyword_set(noplots) then begin
    ;!p.background=!white
    ;!p.color=!black
    ;loadct, 39
;endif


;;>> JUST IN CASE THERE HAVE BEEN CHAGES TO ZEARCH
    ;GET REAL DATA FOR MAKING LINE-FREE SIMULATIONS
    restore, spectra_sav
    nu = freqid2freq()
    pave_cut=3./sqrt(2.)
    if not keyword_set(flags) then flags = intarr(160)+1
    flags(81)=0
    flags(0:10)=0
    if ~keyword_set(averr) then begin
    spec = uber_psderror.in1.avespec
    err = uber_psderror.in1.aveerr
    endif else begin 
    spec = uber_spectra.in1.avespec
    err = uber_spectra.in1.aveerr
    endelse
    nc = n_e(nu)
    whg = where(flags eq 1)
    
                                ;DO CHOLESKY FACTORIZATION OF ERROR
                                ;CORRELATION MATRIX, IF USING
                                ;CORRELATED NOISE
    if keyword_set(corr_noise) then begin
        if ~keyword_set(averr) then psderr_corr = corrscript2(uber_psderror.in1.noderr, $
                                  uber_psderror.in1.mask) else $
                                  psderr_corr = corrscript2(uber_spectra.in1.noderr, $
                                  uber_spectra.in1.mask) 
        A = psderr_corr
        mcholdc, A, D, E, /outfull
        L = transpose(A)
        ind = indgen(nc)
        L[ind,ind] = D[ind,ind]
    endif
    
    ;;;some distribution just for kicks
    simmax=dblarr(30000)
nsim2=n_e(simmax)
for j=0L,nsim2-1 do simmax(j)=max(randomn(seed,5000)*1.5)

hsimmax=hist_wrapper(simmax,0.1,min(simmax)-2,max(simmax)+2)
norm=int_tabulated(hsimmax.hb,hsimmax.hc)
hsimmax.hc /= norm

hsimmaxav=total(hsimmax.hc*hsimmax.hb)/total(hsimmax.hc)

for j=0L,nsim2-1 do simmax(j)=max(randomn(seed,5000))

hsimmax2=hist_wrapper(simmax,0.1,min(simmax)-2,max(simmax)+2)
norm=int_tabulated(hsimmax2.hb,hsimmax2.hc)
hsimmax2.hc /= norm

hsimmaxav2=total(hsimmax2.hc*hsimmax2.hb)/total(hsimmax2.hc)
    
    
    ;FIRST, GET RESULTS FROM REAL DATA 
    if keyword_set(zearch_sav) then begin
        restore, zearch_sav
        e1_real = max(sn,whmx)
        z1_real = fp1[1];z[whmx]
        e2_real = max(snpair,whmx)
        z2_real = fp2[1];z[whmx]
        e3_real = max(snave,whmx)
        z3_real = fp3[1];z[whmx]
    endif else begin
    zearch, nu[whg], spec[whg], err[whg], $
          z, sn, snpair, cont, snave=snave, pairave=pairave, resolution=resolution, $
          nocont=0, $
          name='Real_data', /noeps, z_to_flag=-1, $
          fp1=fp1, fp2=fp2, fp3=fp3, fcount=fcount, ffcount=ffcount
    	e1_real = max(sn,whmx)
        z1_real = fp1[1];z[whmx]
        e2_real = max(snpair,whmx)
        z2_real = fp2[1];z[whmx]
        e3_real = max(snave,whmx)
        z3_real = fp3[1];z[whmx]
        errz1_real=fp1[2]
        errz2_real=fp2[2]
        errz3_real=fp3[2]
        print,'Real redshift: ',z3_real,errz3_real
    endelse

    za=1.
    zb=2.
    zc=z(whmx)
    wh_real=whmx

;JUST RESTORE AN INPUT SAVESET?
if keyword_set(input_savfile) then restore, input_savfile, /ver  else begin

    ;defaults
    if not keyword_set(nsims) then nsims = 2500
    if not keyword_set(bsize) then bsize = 0.1
    if not keyword_set(prob_thresh) then prob_thresh = 0.005
    


    ;SET UP INITIAL LOCATIONS FOR HISTOGRAMS
    ;WILL ADD MORE BINS LATER IF NEEDED
    mneb = 1 & mxeb = 5
    nebins = (mxeb - mneb)/bsize
    e_loc = findgen(nebins)*bsize + mneb+bsize/2.
    e1_hist = fltarr(nebins)
    e2_hist = fltarr(nebins)
    e3_hist = fltarr(nebins)
    eav_hist = fltarr(nebins)
    e1_hist_cut = -1
    e2_hist_cut = -1
    e3_hist_cut = -1
    fdr_tally1_2 = -1
    fdr_tally1_3 = -1
    fdr_tally3_2 = -1
    fdr_tally1_2cut = -1
    fdr_tally1_3cut = -1
    fdr_tally3_2cut = -1
    
    fdr_tally1_2surf = [-1,-1]
    fdr_tally1_3surf = [-1,-1]
    fdr_tally3_2surf = [-1,-1]
    fdr_tally1_2cutsurf = [-1,-1]
    fdr_tally1_3cutsurf = [-1,-1]
    fdr_tally3_2cutsurf = [-1,-1]
    

    ;LOOP OVER NUMBER OF SIMULATIONS
    for i = 0L, nsims-1 do begin

                                ;GENERATE FAKE LINE-FREE SPECTRUM
                                ;USING PHOTOMETRIC ERRORS (default)
        if not keyword_set(line_sims) then begin
            ;MAKE CORRELATED ERRORS?
            if keyword_set(corr_noise) then begin
                spec_sims = aztec_random(nc, /normal)
                spec_sims = transpose(L##transpose(spec_sims)) * err
                err_sims = err
                nocont = 0
            endif else begin
                spec_sims = aztec_random(nc, /normal)*err
                err_sims = err
                nocont = 1
            endelse
        endif else begin
                                ;GENERATE LINE+NOISE SIMULATIONS
            spec_sims = aztec_random(nc, /normal)*err + spec
            err_sims = err;sqrt(2.)*err
            nocont = 0
        endelse

        ;RUN ZEARCH ON SIMULATED SPECTRUM
        zearch, nu[whg], spec_sims[whg], err_sims[whg], $
          z, sn, snpair, cont, snave=snave, pairave=pairave, resolution=resolution, $
          nocont=nocont, $
          name='Sim_'+string(i+1,format='(I06)'), /noeps, z_to_flag=-1, $
          fp1=fp1, fp2=fp2, fp3=fp3

        ;MAXIMUM VALUES
        e1_max = max(sn,whmx)
        z1_max = fp1[1] & z1_maxp = z[whmx] & pave1_max=pairave[whmx]
        e2_max = max(snpair,whmx)
        z2_max = fp2[1] & z2_maxp = z[whmx] & pave2_max=pairave[whmx]
        e3_max = max(snave,whmx)
        z3_max = fp3[1] & z3_maxp = z[whmx] & pave3_max=pairave[whmx]
        eav_max = max(pairave)
        ;store all and hope it still works... Can this part be made more efficient?
        if (i eq 0) then begin
            	nz = n_e(z)
                e1_all=fltarr(nz,nsims)
                e2_all=fltarr(nz,nsims)
                e3_all=fltarr(nz,nsims)
                zmax1_all=fltarr(nz)
                zmax2_all=fltarr(nz)
                zmax3_all=fltarr(nz)
        endif
        
        e1_all(*,i)=sn & e2_all(*,i)=snpair & e3_all(*,i)=snave
        zmax1_all(i)=z1_max & zmax2_all(i)=z2_max & zmax3_all(i)=z3_max

        
        ;FILL IN HISTOGRAMS FOR E(Z) DISTRIBUTIONS

        ;first, do we need to expand e_loc?
        if (e1_max lt mneb) or (e2_max lt mneb) or (e3_max lt mneb) or (eav_max lt mneb) then begin
            mnemax = min([e1_max, e2_max, e3_max,eav_max])
            n2add = ceil( (e_loc[0] - mnemax)/bsize )
            e_loc = [reverse( e_loc[0] - bsize*(findgen(n2add)+1) ), e_loc]
            e1_hist = [fltarr(n2add), e1_hist]
            e2_hist = [fltarr(n2add), e2_hist]
            e3_hist = [fltarr(n2add), e3_hist]
            eav_hist = [fltarr(n2add), eav_hist]
            e1_hist_cut = [fltarr(n2add), e1_hist_cut]
            e2_hist_cut = [fltarr(n2add), e2_hist_cut]
            e3_hist_cut = [fltarr(n2add), e3_hist_cut]
            nebins += n2add
            mneb = e_loc[0] - bsize/2.
        endif
        if (e1_max gt mxeb) or (e2_max gt mxeb) or (e3_max gt mxeb) or (eav_max gt mxeb) then begin
            mxemax = max([e1_max, e2_max, e3_max,eav_max])
            n2add = ceil( (mxemax - e_loc[nebins-1])/bsize )
            e_loc = [e_loc, e_loc[nebins-1] + bsize*(findgen(n2add)+1)]
            e1_hist = [e1_hist, fltarr(n2add)]
            e2_hist = [e2_hist, fltarr(n2add)]
            e3_hist = [e3_hist, fltarr(n2add)]
            eav_hist = [eav_hist, fltarr(n2add)]
            e1_hist_cut = [e1_hist_cut, fltarr(n2add)]
            e2_hist_cut = [e2_hist_cut, fltarr(n2add)]
            e3_hist_cut = [e3_hist_cut, fltarr(n2add)]
            nebins += n2add
            mxeb = e_loc[nebins-1] + bsize/2.
        endif

        ;e1
        mndiff1 = min( abs(e_loc - e1_max), whmn1)
        e1_hist[whmn1] += 1
        if pave1_max ge pave_cut then e1_hist_cut=[e1_hist_cut,e1_max]
        ;e2
        mndiff2 = min( abs(e_loc - e2_max), whmn2)
        e2_hist[whmn2] += 1
        if pave2_max ge pave_cut then e2_hist_cut=[e2_hist_cut,e2_max]
        ;e3
        mndiff3 = min( abs(e_loc - e3_max), whmn3)
        e3_hist[whmn3] += 1
        if pave3_max ge pave_cut then e3_hist_cut=[e3_hist_cut,e3_max]

        mndiffav = min( abs(e_loc - eav_max), whmnav)
        eav_hist[whmnav] += 1

        ;FILL IN Z HISTOGRAMS
        ;initialize
        if (i eq 0) then begin
            nz = n_e(z)
            z_loc = z
            z1_hist = fltarr(nz)
            z2_hist = fltarr(nz)
            z3_hist = fltarr(nz)
            z1_hist_cut = fltarr(nz)
            z2_hist_cut = fltarr(nz)
            z3_hist_cut = fltarr(nz)
            z12_hist = fltarr(nz)
            z13_hist = fltarr(nz)
            z23_hist = fltarr(nz)
            z12_hist_cut = fltarr(nz)
            z13_hist_cut = fltarr(nz)
            z23_hist_cut = fltarr(nz)
        endif
        ;z1
        mndiff1 = min( abs(z_loc - z1_max), whmn1)
        z1_hist[whmn1] +=1   
        if pave1_max ge pave_cut then z1_hist_cut[whmn1] ++
 ;       z1_hist[where(z_loc eq z1_max)] += 1
        ;z2
        mndiff2 = min( abs(z_loc - z2_max), whmn2)
        z2_hist[whmn2] +=1
        if pave2_max ge pave_cut then z2_hist_cut[whmn2] ++
;        z2_hist[where(z_loc eq z2_max)] += 1
        ;z3
        mndiff3 = min( abs(z_loc - z3_max), whmn3)
        z3_hist[whmn3] +=1
;        z3_hist[where(z_loc eq z3_max)] += 1
        if pave3_max ge pave_cut then z3_hist_cut[whmn3] ++

        ;FALSE DETECTION TALLY
        ;store e1_max values if z1_max = z2_max
        if (z1_maxp eq z2_maxp) then begin
        fdr_tally1_2 = [fdr_tally1_2, e1_max]
        fdr_tally1_2surf = [[fdr_tally1_2surf], [e1_max,e2_max]]
        z12_hist[whmn1] ++
        endif
        ;store e1_max values if z1_max = z3_max
        if (z1_maxp eq z3_maxp) then begin
        fdr_tally1_3 = [fdr_tally1_3, e1_max]
        fdr_tally1_3surf = [[fdr_tally1_3surf], [e1_max,e3_max]]
        z13_hist[whmn1] ++
        endif
        ;store e3_max values if z3_max = z2_max
        if (z3_maxp eq z2_maxp) then begin
        fdr_tally3_2 = [fdr_tally3_2, e3_max]
        fdr_tally3_2surf = [[fdr_tally3_2surf], [e3_max,e2_max]]
        z23_hist[whmn2] ++
        endif

        
        if (z1_maxp eq z2_maxp) and (pave1_max ge pave_cut) then begin
        fdr_tally1_2cut = [fdr_tally1_2cut, e1_max]
        fdr_tally1_2cutsurf = [[fdr_tally1_2cutsurf], [e1_max,e2_max]]
        z12_hist_cut[whmn1] ++
        endif
        ;store e1_max values if z1_max = z3_max
        if (z1_maxp eq z3_maxp) and (pave2_max ge pave_cut) then begin
        fdr_tally1_3cut = [fdr_tally1_3cut, e1_max]
        fdr_tally1_3cutsurf = [[fdr_tally1_3cutsurf], [e1_max,e3_max]]
        z13_hist_cut[whmn1] ++
        endif
        ;store e3_max values if z3_max = z2_max
        if (z3_maxp eq z2_maxp) and (pave3_max ge pave_cut) then begin
        fdr_tally3_2cut = [fdr_tally3_2cut, e3_max]
        fdr_tally3_2cutsurf = [[fdr_tally3_2cutsurf], [e3_max,e2_max]]
        z23_hist_cut[whmn2] ++
        endif


        ;clean up mess as go along
        print, 'Done with ', string(i+1,format='(I6)'), ' out of ', $
          string(nsims,format='(I6)'), ' simulations.'
        f2d = findfile('Sim*zearch*')
        file_delete, f2d

    endfor
    ;normalize distributions
    fdr_tally1_2 = fdr_tally1_2[1:*]
    fdr_tally1_3 = fdr_tally1_3[1:*]
    fdr_tally3_2 = fdr_tally3_2[1:*]
    
    fdr_tally1_2cut = fdr_tally1_2cut[1:*]
    fdr_tally1_3cut = fdr_tally1_3cut[1:*]
    fdr_tally3_2cut = fdr_tally3_2cut[1:*]
    
    fdr_tally1_2surf = fdr_tally1_2surf[*,1:*]
    fdr_tally1_3surf = fdr_tally1_3surf[*,1:*]
    fdr_tally3_2surf = fdr_tally3_2surf[*,1:*]
    
    fdr_tally1_2cutsurf = fdr_tally1_2cutsurf[*,1:*]
    fdr_tally1_3cutsurf = fdr_tally1_3cutsurf[*,1:*]
    fdr_tally3_2cutsurf = fdr_tally3_2cutsurf[*,1:*]
    
    norm1=int_tabulated(e_loc, e1_hist)
    norm2=int_tabulated(e_loc, e2_hist)
    norm3=int_tabulated(e_loc, e3_hist)
    normav=int_tabulated(e_loc, eav_hist)
    e1_hist = e1_hist / norm1
    e2_hist = e2_hist / norm2
    e3_hist = e3_hist / norm3
    eav_hist = eav_hist / normav
    
    e1_hist_cut = e1_hist_cut[1:*]
    e2_hist_cut = e2_hist_cut[1:*]
    e3_hist_cut = e3_hist_cut[1:*]
    
    z1_hist = z1_hist / nsims
    z2_hist = z2_hist / nsims
    z3_hist = z3_hist / nsims
    z1_hist_cut = z1_hist_cut / nsims
    z2_hist_cut = z2_hist_cut / nsims
    z3_hist_cut = z3_hist_cut / nsims
    z12_hist = z12_hist / nsims
    z13_hist = z13_hist / nsims
    z23_hist = z23_hist / nsims
    z12_hist_cut = z12_hist_cut / nsims
    z13_hist_cut = z13_hist_cut / nsims
    z23_hist_cut = z23_hist_cut / nsims


    ;COMPUTE FDR >> false detection rate, given that a larger E is obtained
    e12_fdr = fltarr(nebins)
    e13_fdr = fltarr(nebins)
    e32_fdr = fltarr(nebins)
    e12_fdr_cut = fltarr(nebins)
    e13_fdr_cut = fltarr(nebins)
    e32_fdr_cut = fltarr(nebins)
    e1cut_fdr=fltarr(nebins)
    e2cut_fdr=fltarr(nebins)
    e3cut_fdr=fltarr(nebins)
    
    for i = 0L, nebins-1 do begin
        whm = where(fdr_tally1_2 ge e_loc[i], nmatch)
        e12_fdr[i] = float(nmatch) / nsims
        whm = where(fdr_tally1_3 ge e_loc[i], nmatch)
        e13_fdr[i] = float(nmatch) / nsims
        whm = where(fdr_tally3_2 ge e_loc[i], nmatch)
        e32_fdr[i] = float(nmatch) / nsims

        whm = where(fdr_tally1_2cut ge e_loc[i], nmatch)
        e12_fdr_cut[i] = float(nmatch) / nsims
        whm = where(fdr_tally1_3cut ge e_loc[i], nmatch)
        e13_fdr_cut[i] = float(nmatch) / nsims
        whm = where(fdr_tally3_2cut ge e_loc[i], nmatch)
        e32_fdr_cut[i] = float(nmatch) / nsims

        
        whm = where(e1_hist_cut ge e_loc[i], nmatch)
        e1cut_fdr[i] = float(nmatch) / nsims
        whm = where(e2_hist_cut ge e_loc[i], nmatch)
        e2cut_fdr[i] = float(nmatch) / nsims
        whm = where(e3_hist_cut ge e_loc[i], nmatch)
        e3cut_fdr[i] = float(nmatch) / nsims
    endfor
    
    
    e12_fdrsurf = fltarr(nebins,nebins)
    e13_fdrsurf = fltarr(nebins,nebins)
    e32_fdrsurf = fltarr(nebins,nebins)
    e12_fdr_cutsurf = fltarr(nebins,nebins)
    e13_fdr_cutsurf = fltarr(nebins,nebins)
    e32_fdr_cutsurf = fltarr(nebins,nebins)
    
    for i = 0L, nebins-1 do begin
    	for j= 0L, nebins-1 do begin
        whm = where((fdr_tally1_2surf(0,*) ge e_loc[i]) and (fdr_tally1_2surf(1,*) ge e_loc[j]), nmatch)
        e12_fdrsurf[i,j] = float(nmatch) / nsims
        whm = where((fdr_tally1_3surf(0,*) ge e_loc[i]) and (fdr_tally1_3surf(1,*) ge e_loc[j]), nmatch)
        e13_fdrsurf[i,j] = float(nmatch) / nsims
        whm = where((fdr_tally3_2surf(0,*) ge e_loc[i]) and (fdr_tally3_2surf(1,*) ge e_loc[j]), nmatch)
        e32_fdrsurf[i,j] = float(nmatch) / nsims

        whm = where((fdr_tally1_2cutsurf(0,*) ge e_loc[i]) and (fdr_tally1_2cutsurf(1,*) ge e_loc[j]), nmatch)
        e12_fdr_cutsurf[i,j] = float(nmatch) / nsims
        whm = where((fdr_tally1_3cutsurf(0,*) ge e_loc[i]) and (fdr_tally1_3cutsurf(1,*) ge e_loc[j]), nmatch)
        e13_fdr_cutsurf[i,j] = float(nmatch) / nsims
        whm = where((fdr_tally3_2cutsurf(0,*) ge e_loc[i]) and (fdr_tally3_2cutsurf(1,*) ge e_loc[j]), nmatch)
        e32_fdr_cutsurf[i,j] = float(nmatch) / nsims

        endfor
    endfor
    
    
    e12_loc_fdr0p05 = interpol(e_loc, e12_fdr, 0.05)
    e13_loc_fdr0p05 = interpol(e_loc, e13_fdr, 0.05)
    e32_loc_fdr0p05 = interpol(e_loc, e32_fdr, 0.05)
    
    e12_loc_fdr0p05cut = interpol(e_loc, e12_fdr_cut, 0.05)
    e13_loc_fdr0p05cut = interpol(e_loc, e13_fdr_cut, 0.05)
    e32_loc_fdr0p05cut = interpol(e_loc, e32_fdr_cut, 0.05)
    
    e1cut_loc_fdr0p05 = interpol(e_loc, e1cut_fdr, 0.05)
    e2cut_loc_fdr0p05 = interpol(e_loc, e2cut_fdr, 0.05)
    e3cut_loc_fdr0p05 = interpol(e_loc, e3cut_fdr, 0.05)

    ;COMPUTE LIMIT FOR SPECIFIED PROBABILITY THRESHOLD
    ;e1
    e1_cprob = fltarr(nebins)
    for i=0L, nebins-2 do $
      e1_cprob[i] = int_tabulated(e_loc[i:*], e1_hist[i:*])
    e1_lim = interpol(e_loc, e1_cprob, prob_thresh)
    ;e2
    e2_cprob = fltarr(nebins)
    for i=0L, nebins-2 do $
      e2_cprob[i] = int_tabulated(e_loc[i:*], e2_hist[i:*])
    e2_lim = interpol(e_loc, e2_cprob, prob_thresh)
    ;e3
    e3_cprob = fltarr(nebins)
    for i=0L, nebins-2 do $
      e3_cprob[i] = int_tabulated(e_loc[i:*], e3_hist[i:*])
    e3_lim = interpol(e_loc, e3_cprob, prob_thresh)
    
    eav_cprob = fltarr(nebins)
    for i=0L, nebins-2 do $
      eav_cprob[i] = int_tabulated(e_loc[i:*], eav_hist[i:*])
    eav_lim = interpol(e_loc, eav_cprob, prob_thresh)
    
    
;       e1_cprob_cut = fltarr(nebins)
;    for i=0L, nebins-2 do $
;      e1_cprob_cut[i] = int_tabulated(e_loc[i:*], e1_hist_cut[i:*])
;    e1_lim_cut = interpol(e_loc, e1_cprob_cut, prob_thresh)
;    ;e2
;    e2_cprob_cut = fltarr(nebins)
;    for i=0L, nebins-2 do $
;      e2_cprob_cut[i] = int_tabulated(e_loc[i:*], e2_hist_cut[i:*])
;    e2_lim_cut = interpol(e_loc, e2_cprob_cut, prob_thresh)
;    ;e3
;    e3_cprob_cut = fltarr(nebins)
;    for i=0L, nebins-2 do $
;      e3_cprob_cut[i] = int_tabulated(e_loc[i:*], e3_hist_cut[i:*])
;    e3_lim_cut = interpol(e_loc, e3_cprob_cut, prob_thresh);

    ;;do the correlation analysis:
    pearson=fltarr(3,nz)
    spearman=fltarr(3,nz)
    for j=0,nz-1 do begin
    	pearson(0,j)=correlate(reform(e1_all(j,*)),reform(e2_all(j,*)))
    	spearman(0,j)=(r_correlate(reform(e1_all(j,*)),reform(e2_all(j,*))))(0)
    	pearson(1,j)=correlate(reform(e1_all(j,*)),reform(e3_all(j,*)))
    	spearman(1,j)=(r_correlate(reform(e1_all(j,*)),reform(e3_all(j,*))))(0)
    	pearson(2,j)=correlate(reform(e2_all(j,*)),reform(e3_all(j,*)))
    	spearman(2,j)=(r_correlate(reform(e2_all(j,*)),reform(e3_all(j,*))))(0)
    endfor
    
    en_za=fltarr(3,nsims)
    en_zb=fltarr(3,nsims)
    en_zc=fltarr(3,nsims)
    ;E values at za, zb, zc
        whx=(where(z ge za))(0)
        en_za(0,*) = e1_all(whx,*) & en_za(1,*) = e2_all(whx,*) & en_za(2,*) = e3_all(whx,*)
        whx=(where(z ge zb))(0)
        en_zb(0,*) = e1_all(whx,*) & en_zb(1,*) = e2_all(whx,*) & en_zb(2,*) = e3_all(whx,*)
        whx=wh_real
        en_zc(0,*) = e1_all(whx,*) & en_zc(1,*) = e2_all(whx,*) & en_zc(2,*) = e3_all(whx,*)
        meanjj=fltarr(3)
        meanjj(0)=mean(e1_all(whx,*))
        meanjj(1)=mean(e2_all(whx,*))
        meanjj(2)=mean(e3_all(whx,*))

endelse





;PLOT RESULTS
if not keyword_set(noplots) then begin

    window, 0, xsize=700, ysize=900
    !p.multi=[0,1,3]

       ;;and for the real redshift
    real1_fdr=interpol(e1_cprob,e_loc,e1_real)
    real2_fdr=interpol(e2_cprob,e_loc,e2_real)
    real3_fdr=interpol(e3_cprob,e_loc,e3_real)
eav_lim = interpol(e_loc, eav_cprob, prob_thresh)

    e1av=total(e1_hist*e_loc)/total(e1_hist)
    mxx = max([max(e1_lim),max(e2_lim),max(e3_lim)])+0.5
    plotbin, e_loc, e1_hist, pixcenter=0.5, thick=2, xtitle='max E1(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e1_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog;,title='real-z E1-probability: '+sstr(real1_fdr)

    xyouts, mxx/2., 0.03, 'P(>E1) = '+string(prob_thresh*100,format='(F6.2)')+'% at '+string(e1_lim,format='(F4.1)'), charsize=1.0
    xyouts, 1.2,0.1, 'mean: '+sstr(e1av,prec=3), charsize=1.0

    vline, e1_lim, thick=2,line=2
    
    ;plot, e2
    e2av=total(e2_hist*e_loc)/total(e2_hist)
    plotbin, e_loc, e2_hist, pixcenter=0.5, xtitle='max E2(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e2_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog, thick=2;,title='real-z E2-probability: '+sstr(real2_fdr)

    xyouts, mxx/2., 0.03, 'P(>E2) = '+string(prob_thresh*100,format='(F6.2)')+'% at '+string(e2_lim,format='(F4.1)'), charsize=1.0
    xyouts, 1.2,0.1, 'mean: '+sstr(e2av,prec=3), charsize=1.0
    vline, e2_lim, thick=2,line=2

    ;e3
    e3av=total(e3_hist*e_loc)/total(e3_hist)
    plotbin, e_loc, e3_hist, pixcenter=0.5, xtitle='max E3(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e3_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog, thick=2;,title='real-z E3-probability: '+sstr(real3_fdr)

    xyouts, mxx/2., 0.03, 'P(>E) = '+string(prob_thresh*100,format='(F6.2)')+'% at '+string(e3_lim,format='(F4.1)'), charsize=1.0
    xyouts, 1.2,0.1, 'mean: '+sstr(e3av,prec=3), charsize=1.0
    vline, e3_lim, thick=2,line=2


    ;write png?
    if keyword_set(output_png) then x2png,output_png,/rev,/color

    !p.multi=[0,1,3]
    
    
    ;;;plot the cut distributions
    de1_hist_cut=hist_wrapper(e1_hist_cut,0.1,min(e_loc),max(e_loc))
    normd=int_tabulated(de1_hist_cut.hb,de1_hist_cut.hc)
    de1_hist_cut.hc /= normd
    de2_hist_cut=hist_wrapper(e2_hist_cut,0.1,min(e_loc),max(e_loc))
    normd=int_tabulated(de2_hist_cut.hb,de2_hist_cut.hc)
    de2_hist_cut.hc /= normd
    de3_hist_cut=hist_wrapper(e3_hist_cut,0.1,min(e_loc),max(e_loc))
    normd=int_tabulated(de3_hist_cut.hb,de3_hist_cut.hc)
    de3_hist_cut.hc /= normd
    
    
    plotbin, de1_hist_cut.hb,de1_hist_cut.hc, pixcenter=0.5, thick=2, xtitle='max E1(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e1_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog,tit='E2max cut at 2.12';,title='real-z E1-probability: '+sstr(real1_fdr)
    
    ;plot, e2
    plotbin, de2_hist_cut.hb,de2_hist_cut.hc, pixcenter=0.5, xtitle='max E2(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e2_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog, thick=2,tit='E2max cut at 2.12';,title='real-z E2-probability: '+sstr(real2_fdr)

    ;e3
    plotbin, de3_hist_cut.hb,de3_hist_cut.hc, pixcenter=0.5, xtitle='max E3(z)', $
      ytitle=' ', charsize=2.0, yr = [1e-2,max(e3_hist)+0.1], $
      xr=[mneb,mxx], /xst, /yst, /ylog, thick=2,tit='E2max cut at 2.12';,title='real-z E3-probability: '+sstr(real3_fdr)
    
    if keyword_set(output_png) then begin
        output_png2 = repstr(output_png, '.png', '_cutdist.png')
        x2png,output_png2,/rev,/color
    endif
    ;plot z distributions
    window, 1
;;count false detections for real z
zint=where((z_loc ge z3_real-errz3_real) and (z_loc le z3_real+errz3_real),complement=zfalse)
count_fdr1=1.-total(z1_hist(zint))
count_fdr2=1.-total(z2_hist(zint))
count_fdr3=1.-total(z3_hist(zint))
    ;z1
    mnz = min(z_loc)
    mxz = max(z_loc)
    plotbin, z_loc, z1_hist, pixcenter=0.5, xtitle='z at max E1(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z1_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E1: '+sstr(count_fdr1)
    hline, mean(z1_hist), thick=2, color=!blue,line=2
    ;vline, z1_real, thick=2, color=!red,line=2

    
    plotbin, z_loc, z2_hist, pixcenter=0.5, xtitle='z at max E2(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z2_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E2: '+sstr(count_fdr2)
    hline, mean(z2_hist), thick=2, color=!blue,line=2
    ;vline, z2_real, thick=2, color=!red,line=2

    ;z3
    plotbin, z_loc, z3_hist, pixcenter=0.5, xtitle='z at max E3(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z3_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E3: '+sstr(count_fdr3)
    hline, mean(z3_hist), thick=2, color=!blue,line=2
    ;vline, z3_real, thick=2, color=!red,line=2

    ;write png?
    if keyword_set(output_png) then begin
        output_png2 = repstr(output_png, '.png', '_zdist.png')
        x2png,output_png2,/rev,/color
    endif

    
;;count false detections for real z
zint=where((z_loc ge z3_real-errz3_real) and (z_loc le z3_real+errz3_real),complement=zfalse)
count_fdr1=1.-total(z1_hist_cut(zint))
count_fdr2=1.-total(z2_hist_cut(zint))
count_fdr3=1.-total(z3_hist_cut(zint))
    ;z1
    mnz = min(z_loc)
    mxz = max(z_loc)
    plotbin, z_loc, z1_hist_cut, pixcenter=0.5, xtitle='z at max E1(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z1_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E1 cut: '+sstr(count_fdr1)
    hline, mean(z1_hist_cut), thick=2, color=!blue,line=2
    ;vline, z1_real, thick=2, color=!red,line=2

    
    plotbin, z_loc, z2_hist_cut, pixcenter=0.5, xtitle='z at max E2(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z2_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E2 cut: '+sstr(count_fdr2)
    hline, mean(z2_hist), thick=2, color=!blue,line=2
    ;vline, z2_real, thick=2, color=!red,line=2

    ;z3
    plotbin, z_loc, z3_hist_cut, pixcenter=0.5, xtitle='z at max E3(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z3_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR E3 cut: '+sstr(count_fdr3)
    hline, mean(z3_hist_cut), thick=2, color=!blue,line=2
    ;vline, z3_real, thick=2, color=!red,line=2

    ;write png?
    if keyword_set(output_png) then begin
        output_png2 = repstr(output_png, '.png', '_zdist_cut.png')
        x2png,output_png2,/rev,/color
    endif
    
    
    
        ;plot z distributions for pair statistics
    window, 1
;;count false detections for real z
zint=where((z_loc ge z3_real-errz3_real) and (z_loc le z3_real+errz3_real),complement=zfalse)
count_fdr12=1.-total(z12_hist(zint))
count_fdr13=1.-total(z13_hist(zint))
count_fdr23=1.-total(z23_hist(zint))
    ;z1
    mnz = min(z_loc)
    mxz = max(z_loc)
    plotbin, z_loc, z12_hist, pixcenter=0.5, xtitle='z at max E1(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z12_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E1E2: '+sstr(count_fdr12)
    hline, mean(z1_hist), thick=2, color=!blue,line=2
    ;vline, z1_real, thick=2, color=!red,line=2

    
    plotbin, z_loc, z13_hist, pixcenter=0.5, xtitle='z at max E2(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z13_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E1E3: '+sstr(count_fdr13)
    hline, mean(z13_hist), thick=2, color=!blue,line=2
    ;vline, z2_real, thick=2, color=!red,line=2

    ;z3
    plotbin, z_loc, z23_hist, pixcenter=0.5, xtitle='z at max E3(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z23_hist)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E2E3: '+sstr(count_fdr23)
    hline, mean(z23_hist), thick=2, color=!blue,line=2
    ;vline, z3_real, thick=2, color=!red,line=2

    ;write png?
    if keyword_set(output_png) then begin
        output_png2 = repstr(output_png, '.png', '_joint_zdist.png')
        x2png,output_png2,/rev,/color
    endif

zint=where((z_loc ge z3_real-errz3_real) and (z_loc le z3_real+errz3_real),complement=zfalse)
count_fdr12=1.-total(z12_hist_cut(zint))
count_fdr13=1.-total(z13_hist_cut(zint))
count_fdr23=1.-total(z23_hist_cut(zint))
    ;z1
    mnz = min(z_loc)
    mxz = max(z_loc)
    plotbin, z_loc, z12_hist_cut, pixcenter=0.5, xtitle='z at max E1(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z12_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E1E2 cut: '+sstr(count_fdr12)
    hline, mean(z12_hist_cut), thick=2, color=!blue,line=2
    ;vline, z1_real, thick=2, color=!red,line=2

    
    plotbin, z_loc, z13_hist_cut, pixcenter=0.5, xtitle='z at max E2(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z13_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E1E3 cut: '+sstr(count_fdr13)
    hline, mean(z13_hist_cut), thick=2, color=!blue,line=2
    ;vline, z2_real, thick=2, color=!red,line=2

    ;z3
    plotbin, z_loc, z23_hist_cut, pixcenter=0.5, xtitle='z at max E3(z)', $
      ytitle=' ', charsize=2.0, yr=[0,max(z23_hist_cut)], $
      xr=[mnz,mxz], /xst, /yst, thick=2;,title='COUNT FDR JOINT E2E3 cut: '+sstr(count_fdr23)
    hline, mean(z23_hist_cut), thick=2, color=!blue,line=2
   ; vline, z3_real, thick=2, color=!red,line=2

    ;write png?
    if keyword_set(output_png) then begin
        output_png2 = repstr(output_png, '.png', '_joint_zdist_cut.png')
        x2png,output_png2,/rev,/color
    endif


   ;plot false detection rate
   
   ;contours first
   !p.multi = [0,1,3]
    window, 2, xsize=900, ysize=900
    loadct,0
    
    mxx = max([max(e12_fdrsurf),max(e13_fdrsurf),max(e32_fdrsurf)])
    contour, e12_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E1(z)', ytitle='max E2(z)',/fill,$
      title='FDR vs E1(z) and E2(z) (requiring z1 = z2)', thick=2, nlevels=20,/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]
contour, e12_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E1(z)', ytitle='max E2(z)',/overplot,c_labels=[1,1,1,1,1,1],$
      title='FDR vs E1(z) and E2(z) (requiring z1 = z2)', thick=2, levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]

contour, e13_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E1(z)', ytitle='max E3(z)', /fill,$
      title='FDR vs E1(z) and E3(z) (requiring z1 = z3)', thick=2, nlevels=20,/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]
contour, e13_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E1(z)', ytitle='max E3(z)', /overplot,c_labels=[1,1,1,1,1,1],$
      title='FDR vs E1(z) and E3(z) (requiring z1 = z3)', thick=2, levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]

contour, e32_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E3(z)', ytitle='max E2(z)',/fill, $
      title='FDR vs E3(z) and E2(z) (requiring z3 = z2)', thick=2, nlevels=20,/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]
 contour, e32_fdrsurf, e_loc, e_loc, charsize=2., xtitle='max E3(z)', ytitle='max E2(z)',/overplot,c_labels=[1,1,1,1,1,1], $
      title='FDR vs E3(z) and E2(z) (requiring z3 = z2)', thick=2, levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow,/xs,/ys;,xr=[2,6],yr=[2,6]
    
   
   
   ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr_surf.png')
        x2png,output_png3,/rev,/color
    endif
    
    
    contour, e12_fdr_cutsurf, e_loc, e_loc, charsize=1.5,xtitle='max E1(z)' , ytitle='max E2(z)',/fill,$
      title='FDR vs E1(z) and E2(z) (requiring z1 = z2, and E2max cut)', thick=2, nlevels=20,/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]
contour, e12_fdr_cutsurf, e_loc, e_loc, charsize=1.5,xtitle='max E1(z)' , ytitle='max E2(z)',/overplot,c_labels=[1,1,1,1,1,1],$
      title='FDR vs E1(z) and E2(z) (requiring z1 = z2, and E2max cut)', thick=2, levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]

contour, e13_fdr_cutsurf, e_loc, e_loc, charsize=1.5, xtitle='max E1(z)', ytitle='max E3(z)',/fill,$
      title='FDR vs E1(z) and E3(z) (requiring z1 = z3, and E2max cut)', thick=2, nlevels=20,/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]
contour, e13_fdr_cutsurf, e_loc, e_loc, charsize=1.5, xtitle='max E1(z)', ytitle='max E3(z)',/overplot,c_labels=[1,1,1,1,1,1],$
      title='FDR vs E1(z) and E3(z) (requiring z1 = z3, and E2max cut)', thick=2, levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]

contour, e32_fdr_cutsurf, e_loc, e_loc, charsize=1.5, xtitle='max E3(z)', ytitle='max E2(z)',/fill,$
      title='FDR vs E3(z) and E2(z) (requiring z3 = z2, and E2max cut)', thick=2 , nlevels=20,/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]
contour, e32_fdr_cutsurf, e_loc, e_loc, charsize=1.5, xtitle='max E3(z)', ytitle='max E2(z)',/overplot,c_labels=[1,1,1,1,1,1],$
      title='FDR vs E3(z) and E2(z) (requiring z3 = z2, and E2max cut)', thick=2 , levels=reverse([0.5,0.3,0.1,0.05,0.01,0.001]),/iso,/follow ,/xs,/ys;,xr=[2,6],yr=[2,6]
    
   
   
   ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr_surfcut.png')
        x2png,output_png3,/rev,/color
    endif
    
    ;;;now the arrays
       !p.multi = [0,1,3]
    window, 2, xsize=900, ysize=900
    
    
    
    plot, fdr_tally1_2surf(0,*), fdr_tally1_2surf(1,*), charsize=2., xtitle='max E1(z)', ytitle='max E2(z)', $
      title='FDR points (requiring z1 = z2)', thick=2, psym=3 ,/iso

plot, fdr_tally1_3surf(0,*), fdr_tally1_3surf(1,*), charsize=2., xtitle='max E1(z)', ytitle='max E3(z)', $
      title='FDR points (requiring z1 = z3)', thick=2, psym=3,/iso

plot, fdr_tally3_2surf(0,*), fdr_tally3_2surf(1,*), charsize=2., xtitle='max E3(z)', ytitle='max E2(z)', $
      title='FDR points (requiring z3 = z2)', thick=2, psym=3,/iso
    
   
   
   ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr_pts.png')
        x2png,output_png3,/rev,/color
    endif
    
    
    plot, fdr_tally1_2cutsurf(0,*), fdr_tally1_2cutsurf(1,*), charsize=2.,xtitle='max E1(z)' , ytitle='max E2(z)', $
      title='FDR points (requiring z1 = z2), and E2max cut', thick=2,psym=3,/iso

plot, fdr_tally1_3cutsurf(0,*), fdr_tally1_3cutsurf(1,*), charsize=2., xtitle='max E1(z)', ytitle='max E3(z)', $
      title='FDR points (requiring z1 = z3), and E2max cut', thick=2, psym=3,/iso

plot, fdr_tally3_2cutsurf(0,*), fdr_tally3_2cutsurf(1,*), charsize=2., xtitle='max E3(z)', ytitle='max E2(z)', $
      title='FDR points (requiring z3 = z2), and E2max cut', thick=2, psym=3,/iso
    
   
   
   ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr_ptscut.png')
        x2png,output_png3,/rev,/color
    endif
    
    setplotcolors,3
    
   
    !p.multi = 0
    window, 2
    
    if n_elements(e1_fdr) ne 0 then begin
    mxx = max(e1_fdr)
    plot, e_loc, e1_fdr, charsize=1.5, xtitle='max E1(z)', $
      ytitle='FDR', yr=[1.e-4,mxx], $
      title='FDR versus limiting E1(z) (requiring z1 = z2)', thick=2
    vline, e1_loc_fdr0p05, thick=2, linestyle=2
    xyouts, min(e_loc)+0.1, max(e1_fdr)-0.01, 'Limiting E1(z), z1=z2; FDR = 0.05 at '+string(e1_loc_fdr0p05,format='(F3.1)');, color=!black
    endif else begin
    mxx = max([max(e12_fdr),max(e13_fdr),max(e32_fdr)])
    plot, e_loc, e12_fdr, charsize=1.5, xtitle='max Ei(z)', $
      ytitle='FDR', yr=[1.e-4,mxx], $
      title='FDR versus limiting Ei(z) (requiring zi = zj)', thick=2
    vline, e12_loc_fdr0p05, thick=2, linestyle=2
    oplot, e_loc, e13_fdr, thick=2, color=!red
    vline, e13_loc_fdr0p05, thick=2, color=!red, linestyle=2
    oplot, e_loc, e32_fdr, thick=2, color=!blue
    vline, e32_loc_fdr0p05, thick=2, color=!blue, linestyle=2
    ;vline,e3_real,linestyle=3
    xyouts, min(e_loc)+0.1, max(e12_fdr)-0.04, 'Limiting E1(z), z1=z2; FDR = 0.05 at '+string(e12_loc_fdr0p05,format='(F3.1)');, color=!black
    xyouts, min(e_loc)+0.1, max(e13_fdr)-0.04, 'Limiting E1(z), z1=z3; FDR = 0.05 at '+string(e13_loc_fdr0p05,format='(F3.1)'), color=!red
    xyouts, min(e_loc)+0.1, max(e32_fdr)+0.03, 'Limiting E3(z), z3=z2; FDR = 0.05 at '+string(e32_loc_fdr0p05,format='(F3.1)'), color=!blue
    ;;and for the real redshift
    real12_fdr=interpol(e12_fdr,e_loc,e3_real)
    real13_fdr=interpol(e13_fdr,e_loc,e3_real)
    real23_fdr=interpol(e32_fdr,e_loc,e3_real)
    endelse
    
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr.png')
        x2png,output_png3,/rev,/color
    endif
    
  
        mxx = max([max(e12_fdr_cut),max(e13_fdr_cut),max(e32_fdr_cut)])
    plot, e_loc, e12_fdr_cut, charsize=1.5, xtitle='max Ei(z)', $
      ytitle='FDR', yr=[1.e-4,mxx], $
      title='FDR versus limiting Ei(z) (requiring zi = zj) and E2max cut of 2.12', thick=2
    vline, e12_loc_fdr0p05cut, thick=2, linestyle=2
    oplot, e_loc, e13_fdr_cut, thick=2, color=!red
    vline, e13_loc_fdr0p05cut, thick=2, color=!red, linestyle=2
    oplot, e_loc, e32_fdr_cut, thick=2, color=!blue
    vline, e32_loc_fdr0p05cut, thick=2, color=!blue, linestyle=2
    ;vline,e3_real,linestyle=3
    xyouts, min(e_loc)+0.1, max(e12_fdr_cut)+0.004, 'Limiting E1(z), z1=z2; FDR = 0.05 at '+string(e12_loc_fdr0p05cut,format='(F3.1)');, color=!black
    xyouts, min(e_loc)+0.1, max(e13_fdr_cut)+0.007, 'Limiting E1(z), z1=z3; FDR = 0.05 at '+string(e13_loc_fdr0p05cut,format='(F3.1)'), color=!red
    xyouts, min(e_loc)+0.1, max(e32_fdr_cut)+0.007, 'Limiting E3(z), z3=z2; FDR = 0.05 at '+string(e32_loc_fdr0p05cut,format='(F3.1)'), color=!blue
    ;;and for the real redshift
    real12_fdrcut=interpol(e12_fdr_cut,e_loc,e3_real)
    real13_fdrcut=interpol(e13_fdr_cut,e_loc,e3_real)
    real23_fdrcut=interpol(e32_fdr_cut,e_loc,e3_real)
    
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_fdr_cut.png')
        x2png,output_png3,/rev,/color
    endif

    ;plot false detection rate for each estimator idependently
    !p.multi = 0
    window, 2
    e1_lim5 = interpol(e_loc, e1_cprob, 0.05)
    e2_lim5 = interpol(e_loc, e2_cprob, 0.05)
    e3_lim5 = interpol(e_loc, e3_cprob, 0.05)
    
    mxx = max([max(e1_cprob),max(e2_cprob),max(e3_cprob)])
    plot, e_loc, e1_cprob, charsize=1.5, xtitle='max Ei(z)', $
      ytitle='FDR', yr=[1.e-4,mxx], $
      title='FDR versus limiting Ei(z)', thick=2
    vline, e1_lim5, thick=2, linestyle=2
    oplot, e_loc, e2_cprob, thick=2, color=!red
    vline, e2_lim5, thick=2, color=!red, linestyle=2
    oplot, e_loc, e3_cprob, thick=2, color=!blue
    vline, e3_lim5, thick=2, color=!blue, linestyle=2
    xyouts, min(e_loc)+0.1, max(e1_cprob)-0.04, 'Limiting E1(z); FDR = 0.05 at '+string(e1_lim5,format='(F3.1)');, color=!black
    xyouts, min(e_loc)+0.1, max(e2_cprob)-0.08, 'Limiting E2(z); FDR = 0.05 at '+string(e2_lim5,format='(F3.1)'), color=!red
    xyouts, min(e_loc)+0.1, max(e3_cprob)+0.03, 'Limiting E3(z); FDR = 0.05 at '+string(e3_lim5,format='(F3.1)'), color=!blue
     
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_single_fdr.png')
        x2png,output_png3,/rev,/color
    endif

    
    mxx = max([max(e1cut_fdr),max(e2cut_fdr),max(e3cut_fdr)])
    plot, e_loc, e1cut_fdr, charsize=1.5, xtitle='max Ei(z)', $
      ytitle='FDR', yr=[1.e-4,mxx], $
      title='FDR versus limiting Ei(z) with E2max cut of 2.12', thick=2
    vline, e1cut_loc_fdr0p05, thick=2, linestyle=2
    oplot, e_loc, e2cut_fdr, thick=2, color=!red
    vline, e2cut_loc_fdr0p05, thick=2, color=!red, linestyle=2
    oplot, e_loc, e3cut_fdr, thick=2, color=!blue
    vline, e3cut_loc_fdr0p05, thick=2, color=!blue, linestyle=2
    ;vline,e3_real,linestyle=3
    xyouts, min(e_loc)+0.1, max(e1cut_fdr)-0.004, 'Limiting E1(z), z1=z2; FDR = 0.05 at '+string(e1cut_loc_fdr0p05,format='(F3.1)');, color=!black
    xyouts, min(e_loc)+0.1, max(e2cut_fdr)-0.004, 'Limiting E1(z), z1=z3; FDR = 0.05 at '+string(e2cut_loc_fdr0p05,format='(F3.1)'), color=!red
    xyouts, min(e_loc)+0.1, max(e3cut_fdr)+0.003, 'Limiting E3(z), z3=z2; FDR = 0.05 at '+string(e3cut_loc_fdr0p05,format='(F3.1)'), color=!blue
    ;;and for the real redshift
    real1cut_fdr=interpol(e1cut_fdr,e_loc,e3_real)
    real2cut_fdr=interpol(e2cut_fdr,e_loc,e3_real)
    real3cut_fdr=interpol(e3cut_fdr,e_loc,e3_real)
     
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_single_fdr_cut.png')
        x2png,output_png3,/rev,/color
    endif
    
    
    ;;;plot correlation coefficients
    !p.multi = [0,3,2]
    window, 2
    
    pname=['E1E2','E1E3','E2E3']
	for jj=0,2 do begin
	plot,z_loc,pearson(jj,*),xs=1,xr=[0,max(z_loc)],psym=10,ys=1,yr=[0,1.1],xtit='z',ytit=pname(jj)+' corr coeff',charsize=1.5,$
		title='Median Pearson: '+sstr(median(pearson(jj,*)))+', Spearman: '+sstr(median(spearman(jj,*)))
	hline,0.5,linestyle=2,color=!red
	hline,1.,linestyle=2,color=!red
	oplot,z_loc,spearman(jj,*),psym=10,color=!blue
	endfor
	plot,zmax1_all,zmax2_all,xtit='z max E1',ytit='z max E2',charsize=1.5,psym=3,/yst,/xst,xr=[0,max(z_loc)],yr=[0,max(z_loc)],$
		title='Pearson: '+sstr(correlate(zmax1_all,zmax2_all))+', Spearman: '+sstr((r_correlate(zmax1_all,zmax2_all))(0))
	vline,median(zmax1_all),line=2
	hline,median(zmax2_all),line=2
	plot,zmax1_all,zmax3_all,xtit='z max E1',ytit='z max E3',charsize=1.5,psym=3,/yst,/xst,xr=[0,max(z_loc)],yr=[0,max(z_loc)],$
		title='Pearson: '+sstr(correlate(zmax1_all,zmax3_all))+', Spearman: '+sstr((r_correlate(zmax1_all,zmax3_all))(0))
	vline,median(zmax1_all),line=2
	hline,median(zmax3_all),line=2
	plot,zmax2_all,zmax3_all,xtit='z max E2',ytit='z max E3',charsize=1.5,psym=3,/yst,/xst,xr=[0,max(z_loc)],yr=[0,max(z_loc)],$
		title='Pearson: '+sstr(correlate(zmax2_all,zmax3_all))+', Spearman: '+sstr((r_correlate(zmax2_all,zmax3_all))(0))
	vline,median(zmax2_all),line=2
	hline,median(zmax3_all),line=2
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png3 = repstr(output_png, '.png', '_corrs.png')
        x2png,output_png3,/rev,/color
    endif
    
    ;;plot the za,zb,zc distributions
    ;;do a K-S test for each
    ;;calculate mean E1, E2 and E3 for real z, to determine which one has higher significance
    ;;can I show this analitically?
    ;;for noise simulations, they all should have mean 0 at all redshifts
    ;;prove that the new E2 has variance 1
    
    
    pars=[0.0,1.0,100.0]
    gh=findgen(8000)/1000.-4.
    enzgauss=enz_gauss(gh,pars)
    
    !p.multi = [0,3,3]
    window, 3
    for jj=0,2 do begin;if jj ne 1 then begin
     ksone, reform(en_za(jj,*)), 'gaussint', Da, proba
     ksone, reform(en_zb(jj,*)), 'gaussint', Db, probb
     ksone, reform(en_zc(jj,*)-meanjj(jj)), 'gaussint', Dc, probc
     
     hist_plot,reform(en_za(jj,*)),binsize=0.1,title='E'+sstr(jj+1)+'(za), probability='+sstr(proba,prec=4),charsize=1.5
     oplot,gh,enzgauss,color=!red,thick=2
     hist_plot,reform(en_zb(jj,*)),binsize=0.1,title='E'+sstr(jj+1)+'(zb), probability='+sstr(probb,prec=4),charsize=1.5
     oplot,gh,enzgauss,color=!red,thick=2
     hist_plot,reform(en_zc(jj,*)),binsize=0.1,$
     	     title='E'+sstr(jj+1)+'(zc), probability='+sstr(probc,prec=4)+', mean: '+sstr(meanjj(jj)),charsize=1.5
     oplot,gh,enzgauss,color=!red,thick=2
     ;endif
    endfor
    
    ;write png?
    if keyword_set(output_png) then begin
        output_png4 = repstr(output_png, '.png', '_zazbzc.png')
        x2png,output_png4,/rev,/color
    endif
    
    
    !p.multi=0

endif

;save results?
if keyword_set(output_savfile) then begin
    save, filename=output_savfile, e_loc, e1_hist, e2_hist, e1_hist_cut, e2_hist_cut, pearson, spearman, $
      e3_hist, e1_lim, e2_lim, e3_lim, e3_hist_cut, e1_real, e2_real, e3_real, z12_hist, z23_hist, z13_hist, $
      e1_cprob, e2_cprob, e3_cprob, z_loc, z1_hist, z2_hist, z3_hist, en_za, en_zb, en_zc, wh_real, meanjj, $
      z1_real, z2_real, z3_real, e12_fdr, e12_loc_fdr0p05, mneb, mxeb, zmax1_all, zmax2_all, zmax3_all, $
      prob_thresh, e13_fdr, e13_loc_fdr0p05, e32_fdr, e32_loc_fdr0p05, fcount, ffcount, z1_hist_cut, z2_hist_cut, z3_hist_cut, $
      e1cut_fdr, e1cut_loc_fdr0p05, e3cut_fdr, e3cut_loc_fdr0p05, e2cut_fdr, e2cut_loc_fdr0p05, $
      e13_fdr_cut,e32_fdr_cut,e12_fdr_cut,e12_loc_fdr0p05cut,e13_loc_fdr0p05cut,e32_loc_fdr0p05cut, $
      z12_hist_cut,z13_hist_cut,z23_hist_cut,eav_hist,eav_cprob,fdr_tally1_2surf,fdr_tally1_3surf,fdr_tally3_2surf, $
    fdr_tally1_2cutsurf, fdr_tally1_3cutsurf, fdr_tally3_2cutsurf,e12_fdrsurf, e13_fdrsurf, e32_fdrsurf,$ 
    e12_fdr_cutsurf, e13_fdr_cutsurf, e32_fdr_cutsurf
endif


end
