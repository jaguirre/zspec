pro coadd_zearch_all,ignore_cal_corr=ignore_cal_corr,whold=whold,plotonly=plotonly,$
  sourcestart=sourcestart

; You can use the keyword ignore_cal_corr file to be passed
; into uber_spectrum if you do not want to use the spectral
; flat corrections.  This saves us the trouble of creating separate
; coadd lists.

; This routine will loop over the following sources.
; All should follow the same name and filename convention
; (as in, the filenames of all the sources should be these names .txt)
;
; JRK 12/4/12: sources is now a [2,x] array where x is number of
; sources.  The first element for each is the actual prefix of the
; .txt file, and then the source name.
;
; JRK 12/10/12: now the PDF file with all coadds has the datestamp
;  on it (YYYYMMDD_coadds.pdf).  Just date, not time, so it 
;  will be overwritten if this is run multiple times in one day.
; KSS 12/19/12: committed latest version to svn

sources=[$
['ADFS_27_nov2012','ADFS_27'],$ ; These are the coadd file names, which may be diff from source.
['MACSJ0717_nov2012','MACSJ0717'],$
['SA.44_nov2012','SA.44'],$
['SD.133_nov2012','SD.133'],$
['SF.100_nov2012','SF.100'],$
['SF.88_nov2012','SF.88'],$
['SG.77_nov2012','SG.77'],$
['SMM2254_nov2012','SMM2254'],$
['SPT_0155-62_nov2012','SPT_0155-62'],$
['SPT_0457-49_nov2012','SPT_0457-49'],$
['SPT_0512-59_nov2012','SPT_0512-59'],$
['SPT_0551-48_nov2012','SPT_0551-48'],$
['SPT_0625-58_nov2012','SPT_0625-58']]

if ~keyword_set(sourcestart) then sourcestart=0


;sources=[ $   ; Commented out by JRK 12/4/12, these are from old run.
;         'SPT_0027-50',$
;         'SPT_0103-45',$
;         'SPT_0202-61_lp',$
;         'SPT_0202-61_all',$
;        ;'SPT_0243-49',$ ; Something is wrong with all these obs???
;         'SPT_0243-49_lp',$
;         'SPT_0346-52',$
;         'SPT_0512-59',$
;         'SPT_0512-59_lp',$
;         'SPT_0512-59_all',$
;         'SPT_0532-50',$
;         'SPT_0532-50_lp',$
;         'SPT_0532-50_all',$
;         'SPT_0538-50',$         
;         'SPT_0538-50_lp',$         
;         'SPT_0538-50_all',$         
;         ;'SPT_2004-44',$ ; No time actually spent on it.
;         'SPT_2031-51',$
;         'SPT_2103-60',$
;         'SPT_2103-60_lp',$
;         'SPT_2103-60_all',$
;         'SPT_2132-58',$
;         'SPT_2134-50',$
;         'SPT_2134-50_lp',$
;         'SPT_2134-50_all',$
;         'SPT_2332-53',$
;         'SPT_2332-53_lp',$
;         'SPT_2332-53_all',$
;         'SPT_2353-50',$
;         'SPT_2353-50_lp',$
;         'SPT_2353-50_all',$
;         'SPT_2357-51',$
;         'SPT_2357-51_lp',$
;         'SPT_2357-51_all']

; only run on lists that actually exist
sources_all=sources[0,*]
nsources=n_e(sources[0,*])
is_new = bytarr(nsources) + 1
if n_elements(whold) gt 0 then is_new[whold] = 0
isthere=bytarr(nsources)
for i=0,nsources-1 do begin
    files=file_search(!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+sources[0,i]+'.txt',count=nfiles)
    if nfiles gt 0 then isthere[i]=1
endfor
whthere=where(isthere)
sources=sources[*,whthere]
is_new=is_new[whthere]

nsources=n_e(sources[0,*])
psfiles=strarr(nsources)
;stop
if keyword_set(plotonly) eq 0 then begin
; Now for one source at a time...
    for i=sourcestart, nsources-1 do begin
        
        if is_new[i] then begin
            case sources[1,i] of 
              'ADFS_27': proj='ATLAS'
              'MACSJ0717': proj='INFANTE'
              'SA.44': proj='ATLAS'
              'SD.133': proj='ATLAS'
              'SF.100': proj='ATLAS'
              'SF.88': proj='ATLAS'
              'SG.77': proj='ATLAS'
              'SMM2254': proj='JOHANSSON'
              'SPT_0155-62': proj='SPT'
              'SPT_0457-49': proj='SPT'
              'SPT_0512-59': proj='SPT'
              'SPT_0551-48': proj='SPT'
              'SPT_0625-58': proj='SPT'
              else: message,'Unknown project? Update case statement.'
             endcase
            
; First, run_zapex on all sources
; This step is done first for all because it requires
; you to enter the password for paruma to get the
; raw files for each new observation.
; And in case one of the observations is messed up :-)
          
            run_zapex,sources[0,i]+'.txt',proj=proj
    
            ;; Run uber_spectrum to coadd the spectrum.
            uber_spectrum,sources[0,i]+'.txt',/apex,$;/at_telescope,$
              plot_obs=sources[0,i]+'_indv_obs.ps',$
              ignore_cal_corr=ignore_cal_corr
            
            ;; Plot uber_spectrum result; must first find the latest coadd.
            ;; Relies on assuming the files still all have their timestamps,
            ;; and thus the last file alphabetically is the truly the most
            ;; updated file.
            
            dir=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+sources[1,i]
            savefile=file_search(dir+'/'+sources[1,i]+'_20*.sav',count=nsav)
            savefile=savefile[nsav-1]
            
            savefile_split=strsplit(savefile,'/',/extract)
            nsplit=n_e(savefile_split)
            
            arg1=savefile_split[nsplit-2]+'/'+savefile_split[nsplit-1]
           if n_e(strsplit(sources[1,i],'.',/extract)) EQ 1 then $
              arg2=change_suffix(savefile_split[nsplit-1],'.ps') $
             else begin ; The sources that include periods will get messed up by change_suffix.
              arg2=strsplit(savefile_split[nsplit-1],'.',/extract)
              if n_e(arg2) NE 3 then stop
              arg2=arg2[0]+'.'+arg2[1]+'.ps'
            endelse

            
            plot_uber_spectrum_jk,arg1,arg2,/plot_sens,/plot_sig
            
            ;; Run zearch
            ;; Unclear which channels to exclude... 81 is the only definite
            ;; choice because it is dead.
           ; zearch_wrap,sources[1,i],flagchan=[INDGEN(5),81,86, 128] ;... hmmm
        endif
    endfor
endif else begin
    for i=0,nsources-1 do begin
        dir=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+sources[1,i]
        savefile=file_search(dir+'/'+sources[1,i]+'_201?????_????.sav',count=nsav)
        savefile=savefile[nsav-1]
        
        savefile_split=strsplit(savefile,'/',/extract)
        nsplit=n_e(savefile_split)
        
        arg1=savefile_split[nsplit-2]+'/'+savefile_split[nsplit-1]
        if n_e(strsplit(sources[1,i],'.',/extract)) EQ 1 then $
           arg2=change_suffix(savefile_split[nsplit-1],'.ps') $
          else begin ; The sources that include periods will get messed up by change_suffix.
           arg2=strsplit(savefile_split[nsplit-1],'.',/extract)
           if n_e(arg2) NE 3 then stop
           arg2=arg2[0]+'.'+arg2[1]+'.ps'
        endelse        

        plot_uber_spectrum_jk,arg1,arg2,/plot_sens,/plot_sig

    endfor
endelse


; Combine all spectra postscript files into one pdf, which is saved
; in the main coadded_spectra directory as YYYYMMDD_coadds.pdf'
spawn,'pwd',currdir
cd,!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'

pdffiles=psfiles
for i=0, nsources-1 do begin
    cd,sources[1,i]
    allpsfiles = file_search(sources[1,i]+'_201?????_????.ps',count=nfiles)
    psfiles[i] = allpsfiles[nfiles-1]
    
    if n_e(strsplit(sources[1,i],'.',/extract)) EQ 1 then $
         pdffiles[i]=change_suffix(psfiles[i],'.pdf') $
    else begin ; The sources that include periods will get messed up by change_suffix.
         temppdf=strsplit(psfiles[i],'.',/extract)
     if n_e(temppdf) NE 3 then stop
         pdffiles[i]=temppdf[0]+'.'+temppdf[1]+'.pdf'
     endelse

    ;temp=strsplit(psfiles[i],'/',/extract)
    ;psfiles[i]=temp[n_e(temp)-1]
    spawn,'ps2pdf '+psfiles[i]
    cd,'..'
endfor
command='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile='
now=bin_date(systime(0,/utc))
pdffile=string(now[0],now[1],now[2],format='(i4,i2.2,i2.2)')+'_coadds.pdf '
command+=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+pdffile
for i=0, nsources-1 do command+=sources[1,i]+'/'+pdffiles[i]+' '
spawn,command
for i=0, nsources-1 do spawn,'rm '+sources[1,i]+'/'+pdffiles[i]

; All functionality of quick_look should now be in 
; plot_uber_spectrum_JK, so these next two lines no longer used.
;cd,'~/data/observations/apex/'
;quick_look

cd,currdir

end
