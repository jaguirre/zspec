;Perform the tests
function doTest, nodspec, avespec, aveerr,mask, bin_size=bin_size

resolve_routine, 'mad', /is_function

s=size(nodspec)
;n_good=total(mask,2)
;averages=total(nodspec/mask,2, /nan)/n_good
;n=nodspec/mask-averages#replicate(1.,s[2])
;sigmas=sqrt(total(n^2,2, /nan)/n_good)

;d=n/(sigmas#replicate(1,s[2]))

d=(nodspec/mask-avespec#replicate(1, s[2]))/$
  (aveerr#replicate(1, s[2])) ;Deviation of each nod from mean, in units of error

probs=dblarr(s[1])
for i=0, s[1]-1 do begin
 
    ksone, d[i,*], 'gauss_pdf', t, prob ;Prob of each bolometer being gaussian. 
    
    probs[i]=prob

endfor

if ~keyword_set(bin_size) then bin_size=.1

;Histogram the results, and fit an actual gaussian to them. 
gauss_fits=dblarr(s[1], (max(d, /nan)-min(d, /nan))/bin_size+1)   
gauss_bins=dblarr(s[1],(max(d, /nan)-min(d, /nan))/bin_size+1)
gauss_plots=dblarr(s[1],(max(d, /nan)-min(d, /nan))/bin_size+1)
fit_means=dblarr(s[1])
fit_ampl=dblarr(s[1])
fit_rms=dblarr(s[1])
for i=0,s[1]-1 do begin
    hist=hist_wrapper(d[i,*], bin_size, min(d, /nan), max(d, /nan), /gauss_fit)

    gauss_fits[i,*]=hist.fit_ampl*$
      exp(-.5*(hist.hb-hist.fit_mean)^2/hist.fit_rms^2)
   
    gauss_bins[i,*]=hist.hb ;Save the plot
    gauss_plots[i,*]=hist.hc
    
    fit_means[i]=hist.fit_mean
    fit_ampl[i]=hist.fit_ampl
    fit_rms[i]=hist.fit_rms
endfor

gauss_flag=replicate(1,s[1], s[2])

;Flag on gaussianity by making a Q-Q plot, and flagging out any nods
;more than 2 MAD (median absolute deviation) from that line
for i=0, s[1]-1 do begin
    samp_quants=d[i,sort(d[i,*])]
    samp_cdf=(findgen(s[2])+1)/s[2]
    gauss_quants=sqrt(2)*inverf(2*samp_cdf-1)
   
    dev=mad(samp_quants-gauss_quants)
    w=where(abs(samp_quants-gauss_quants) ge 2.0*dev, badcount)
    if badcount ne 0 then gauss_flag[i, w]=0
endfor


return, {gauss_plots:gauss_plots,gauss_prob:probs, $
         bins:gauss_bins, fits:gauss_fits, fit_means:fit_means,$
        fit_ampl:fit_ampl, fit_rms:fit_rms, gauss_flag:gauss_flag}
end

;Run the tests
function test_gauss, struct, bin_size=bin_size, flag_gauss=flag_gauss

N=N_TAGS(struct)
names=TAG_NAMES(struct)

for alpha=0, N-1 do begin ;Do the test for each harmonic

    curStruct=struct.(alpha)
    nodspec=curStruct.nodspec
    mask=curStruct.mask
    avespec=curStruct.avespec
    aveerr=curStruct.aveerr
    
    ;Perform the tests
    result=doTest(nodspec, avespec, aveerr,mask, bin_size=bin_size)
    
    ;Store the results in the structure.
    subNames=TAG_NAMES(curStruct)
    if 0 then begin
        w=where(subNames eq 'GAUSS_PROBS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'GAUSS_PROBS',result.gauss_prob) $
        else curStruct.gauss_prob=result.gauss_prob
        
        w=where(subNames eq 'GAUSS_BINS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'GAUSS_BINS',result.bins) $
        else curStruct.gauss_bins=result.bins
        
        w=where(subNames eq 'GAUSS_FITS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'GAUSS_FITS',result.fits) $
        else curStruct.gauss_fits=result.fits
        
        w=where(subNames eq 'GAUSS_PLOTS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'GAUSS_PLOTS',result.gauss_plots) $
        else curStruct.gauss_plots=result.gauss_plots
        
        w=where(subNames eq 'FIT_MEANS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'FIT_MEANS',result.fit_means) $
        else curStruct.fit_means=result.fit_means
        
        w=where(subNames eq 'FIT_AMPL')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'FIT_AMPL',result.fit_ampl) $
        else curStruct.fit_ampl=result.fit_ampl
        
        w=where(subNames eq 'FIT_RMS')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'FIT_RMS',result.fit_rms) $
        else curStruct.fit_rms=result.fit_rms
    endif 
    
                                ;If flagging was requested, flag out
                                ;nods that failed and save the flags
    if keyword_set(flag_gauss) then begin
        curStruct.mask*=result.gauss_flag
        
        w=where(subNames eq 'GAUSS_FLAG')
        if w[0] eq -1 then curStruct=$
          create_struct(curStruct,'GAUSS_FLAG',result.gauss_flag) $
        else curStruct.gauss_flag=result.gauss_flag
    endif
    
    if alpha eq 0 then finalStruct=create_struct(names[alpha],curStruct) $
    else finalStruct=create_struct(finalStruct,names[alpha],curStruct)
    
endfor

return, finalStruct

end
