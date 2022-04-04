pro diagnostic_plots, savefile, plotname

f=file_search('/home/local/zspec/zspec_data_svn/coadded_spectra/*/'+savefile)

if f[0] eq '' then begin
    print, 'Cannot find '+savefile+'. Returning'
    return
endif

restore, f[0]

nrow=1
ncol=2

s=size(uber_jackknife)
if s[0] ne 0 then ncol++

s1=size(ms_decorr_psderror)
if s1[0] ne 0 then nrow++
s2=size(pca_decorr_psderror)
if s2[0] ne 0 then nrow++
s3=size(both_decorr_psderror)
if s3[0] ne 0 then nrow++

spectra=ptrarr(nrow, ncol)
rownames=strarr(nrow)
colnames=strarr(ncol)
rownames[0]='No Decorr'
colnames[0]='BSV'
colnames[1]='PSD Errors'
if ncol eq 3 then colnames[2]='Jackknife'

spectra[0,0]=ptr_new(uber_spectra)
spectra[0,1]=ptr_new(uber_psderror)
if s[0] ne 0 then spectra[0,2]=ptr_new(uber_jackknife)

if nrow gt 1 then begin
    if s1[0] ne 0 then begin
        spectra[1,0]=ptr_new(ms_decorr_spectra)
        spectra[1,1]=ptr_new(ms_decorr_psderror)
        if s[0] ne 0 then spectra[1,2]=ptr_new(ms_decorr_jackknife)
        rownames[1]='MS'
    endif else begin
        spectra[0,1]=ptr_new(pca_decorr_spectra)
        spectra[1,1]=ptr_new(pca_decorr_psderror)
        if s[0] ne 0 then spectra[1,2]=ptr_new(pca_decorr_jackknife)
        rownames[1]='PCA'
    endelse
endif 

if nrow eq 4 then begin
    spectra[2,0]=ptr_new(pca_decorr_spectra)
    spectra[2,1]=ptr_new(pca_decorr_psderror)
    if s[0] ne 0 then spectra[2,2]=ptr_new(pca_decorr_jackknife)

    spectra[3,0]=ptr_new(both_decorr_spectra)
    spectra[3,1]=ptr_new(both_decorr_psderror)
    if s[0] ne 0 then spectra[3,2]=ptr_new(both_decorr_jackknife)

    rownames[2]='PCA'
    rownames[3]='BOTH'
endif

set_plot, 'ps'
if keyword_set(plotname) then  $
  device, /color, file=plotname $
else device, /color, file=repstr(savefile, '.sav', '_diagnostics.eps')

;No continuum spectra

; set bad channels to NaN
nu=freqid2freq()
flags=intarr(160)+1
flags[81]=0
flags[86]=0
flags[128]=0
flags[157:159]=0
flags[0:9]=0
r1=0.0 ;;initial guess for redshift
speci=['12CO']
transition=['2-1']
lfwhm=400. ;;km/s
whbad = where(flags eq 0,nbad)

!p.multi=[0,ncol, nrow, 1, 0]
!x.margin=[8.0,2]
for i=0, nrow-1 do begin
    for j=0, ncol-1 do begin
        zspec_spectrum=(*spectra[i,j]).in1.avespec
        zspec_err=(*spectra[i,j]).in1.aveerr
        zspec_spectrum[whbad] = !values.f_nan
        zspec_err[whbad] = !values.f_nan
        fit=zspec_fit_lines_cont(flags,zspec_spectrum,zspec_err,r1,speci,$
                                 transition,lw_value=lfwhm,/z_fixed,/lw_fixed,$
                                 /lw_tied,cont_type='PWRLAW')

        ploterror, nu, (zspec_spectrum-fit.cspec)/uber_bolo_flags, zspec_err/uber_bolo_flags, psym=10, $
          /xst, xtit='Frequency, Hz', ytit='Flux, Jy',$
          tit='Cont-free spectrum: '+colnames[j]+' ' +rownames[i], thick=.5,$
          errthick=.5, charsize=.8
    endfor
endfor

erase
s=size((*spectra[0,0]).in1.corr)
if s[0] ne 0 then begin
    minval=min((*spectra[0,0]).in1.corr, /nan)
    maxval=max((*spectra[0,0]).in1.corr, /nan)
    for i=0, nrow-1 do begin
        for j=0, ncol-1 do begin
            curmin=min((*spectra[i,j]).in1.corr, /nan)
            curmax=max((*spectra[i,j]).in1.corr, /nan)

            if curmin lt minval then minval=curmin
            if curmax gt maxval then maxval=curmax
        endfor
    endfor
    for i=0, nrow-1 do begin
        for j=0, ncol-1 do begin
            rdisplay, (*spectra[i,j]).in1.corr, xtit='Bolo #', $
              ytit='Bolo #', $
              tit='Corr: '+colnames[j]+' ' +rownames[i], charsize=.8,$
              min=minval, max=maxval
        endfor
    endfor
endif

erase
for i=0, nrow-1 do begin
    for j=0, ncol-1 do begin
        ploterror, nu,(*spectra[i,j]).out1.avespec/uber_bolo_flags,$
          (*spectra[i,j]).out1.aveerr/uber_bolo_flags,psym=10, $
          /xst, xtit='Frequency, Hz', ytit='Flux, Jy',$
          tit='Out Phase spectrum: '+colnames[j]+' ' +rownames[i], thick=.5,$
          errthick=.5, charsize=.8
    endfor
endfor
erase
!p.multi=[0,1,4,1,0]
plot, in_out_corrs, psym=10, /xst, $
  xtit='Frequency, Hz', ytit='Flux, Jy',$
  tit='In_out_corrs No Decorr', thick=.5,  charsize=.8

plot, ms_decorr_in_out_corrs, psym=10, /xst, $
  xtit='Frequency, Hz', ytit='Flux, Jy',$
  tit='In_out_corrs MS', thick=.5, charsize=.8

plot, pca_decorr_in_out_corrs, psym=10, /xst, $
  xtit='Frequency, Hz', ytit='Flux, Jy',$
  tit='In_out_corrs PCA', thick=.5, charsize=.8

plot, both_decorr_in_out_corrs, psym=10, /xst, $
  xtit='Frequency, Hz', ytit='Flux, Jy',$
  tit='In_out_corrs Both Decorr', thick=.5, charsize=.8


erase
!p.multi=[0,ncol, nrow, 1, 0]
for i=0, nrow-1 do begin
    for j=0, ncol-1 do begin
        m=max((*spectra[i,j]).in1.nodspec[100,*])
        n=min((*spectra[i,j]).in1.nodspec[100,*])
        
        plot, (*spectra[i,j]).in1.nodspec[100,*], psym=10, $
          /xst,tit='Bolo 100 Nodspec '+colnames[j]+' ' +rownames[i], $
          thick=.5,charsize=.8

        oplot, (*spectra[i,j]).in1.nodspec[100,*]/$
          (*spectra[i,j]).in1.mask[100,*], col=2, psym=10

        percentFlagged=strcompress(100-total((*spectra[i,j]).in1.mask[100,*])/$
          n_e((*spectra[i,j]).in1.mask[100,*])*100, /remove_all)

        xyouts,100, .8*(m-n)+n, percentFlagged +'% of data flagged',charsize=.6
    endfor
endfor

erase
for i=0, nrow-1 do begin
    for j=0, ncol-1 do begin
        m=max((*spectra[i,j]).in1.noderr[100,*])
        n=min((*spectra[i,j]).in1.noderr[100,*])

        plot, (*spectra[i,j]).in1.noderr[100,*], psym=10, $
          /xst,tit='Bolo 100 Noderr '+colnames[j]+' ' +rownames[i], $
          thick=.5,charsize=.8

        oplot, (*spectra[i,j]).in1.noderr[100,*]/$
          (*spectra[i,j]).in1.mask[100,*], col=2, psym=10

        percentFlagged=strcompress(100-total((*spectra[i,j]).in1.mask[100,*])/$
          n_e((*spectra[i,j]).in1.mask[100,*])*100, /remove_all)

        xyouts,100, .8*(m-n)+n, percentFlagged +'% of data flagged',charsize=.6
    endfor
endfor
erase

!p.multi=0
!x.margin=[10,3]

obsString=strcompress(string(n_e(file_list)), /remove_all)+' Observations in this Reduction'+'!C'
obsString+='Dates of Data:'+'!C'

dates=strarr(n_e(file_list))
for i=0, n_e(file_list)-1 do begin
    split=strsplit(file_list[i], '/', /extract)
    str=split(n_e(split)-1)
    split=strsplit(str, '-', /extract)
    year=split[2]
    month=split[3]
    day=split[4]
    dates[i]=month+'/'+day+'/'+year
endfor

while n_e(dates) gt 0 do begin
    curDate=dates[0]
    
    w=where(dates eq curDate, count, complement=c, ncomplement=nc)
    obsString+=strcompress(string(count), /remove_all)+$
                ' Observations taken on '+dates[0]+'!C'

    if nc eq 0 then break
    dates=dates[c]
endwhile
xyouts, .1, .96,  obsString,/normal

device, /close
set_plot, 'x'

ptr_free, spectra

end
