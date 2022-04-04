pro binplot, savefile,bin_size=bin_size, bin_start=bin_start, $
             bin_stop=bin_stop,plot_title=plot_title, final_freqs=final_freqs,$
             final_spec=final_spec, final_err=final_err

if ~keyword_set(bin_size) then bin_size=10
if ~keyword_set(bin_start) then bin_start=200
if ~keyword_set(bin_stop) then bin_stop=300

nu=freqid2freq()

n_bins=(bin_stop-bin_start)/bin_size
if  (bin_stop-bin_start) mod bin_size ne 0 then n_bins++

w=where(nu ge bin_start and nu le bin_stop,c)

if c eq 0 then begin
    print, 'Bins out of range'
    return
endif

if ~keyword_set(plot_title) then begin
    a=strsplit(savefile, '/.', /extract)
    plot_title=a[1]+'_BIN_'+strcompress(string(bin_size), /remove_all)+'.eps'
endif


if ~keyword_set(plot_title) then begin
    a=strsplit(savefile, '/.', /extract)
    plot_title=a[1]+'_BIN_'+strcompress(string(bin_size), /remove_all)+'.eps'
endif

set_plot, 'ps'
device, /encap, /times, file=plot_title, /color
nu=nu[w]

loadct, 2
for j=0, n_e(savefile)-1 do begin
    
    restore, !zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+$
      savefile[j]

    spec=uber_psderror.in1.avespec/uber_bolo_flags
    errs=uber_psderror.in1.aveerr/uber_bolo_flags
    spec=spec[w]
    errs=errs[w]
    
    final_spec=dblarr(n_bins)
    final_err=dblarr(n_bins)
    final_freqs=dblarr(n_bins)
    
    for i=0, n_bins-1 do begin
        w2=where(nu ge bin_start+i*bin_size and nu lt bin_start+(i+1)*bin_size)
        
        final_freqs[i]=mean(nu[w2])
        
        final_spec[i]=total(spec[w2]/$
                            errs[w2]^2,/nan)/total(1.0/errs[w2]^2,/nan)
        
        final_err[i]=sqrt(1.0/total(1.0/errs[w2]^2,/nan))                
    endfor
    
    if j eq 0 then begin
        plot, final_freqs, final_spec, psym=10, xtitle='Frequency, GHz', ytitle='Flux, Jy'
        oploterr, final_freqs, final_spec, final_err
    endif else begin
        oplot, final_freqs, final_spec, psym=10, col=100*j
        oploterr, final_freqs, final_spec, final_err;, col=i+1
    endelse

endfor

device, /close
set_plot, 'x'
end
