pro jupeff,date,lcon,lcoff,output_num=output_num,bos=bos,pps=pps,noplot=noplot
; MB 2009 nov 20, from original code by HN
;looks for two loadcurves (lcon, lcoff as date-time strings in the format of
;hte loadcurve save file -- e.g. '20091118_0551' ) in the date directory of
;telescope_tests, and computes the power difference for two loadcurves, saving
;it to a txt file in the; same directory.   Output will be used by plotjupeff.
; bos is the bias offset, which needs to be adjusted to make th this work right.
; bos should be on the order of a couple of mV, but needs to be tweaked to
; within about 20 uV
; output_num should be a single-digit integer, passed in string format,
; e.g.'2',  this will be the indentifier for the output file for this pair.
 
;12/19/2012 - KSS - Committed revision to svn.

if ~keyword_set(bos) then bos=0.00117
if ~keyword_set(output_num) then output_num='0'


readcol,!zspec_pipeline_root+'/loadcurve_analysis/goodpix2006.txt',$
  box,channel,skipline=0

Rload = 30e6
dcgain = 193.
Amb = 273.
LN2 = 74.

LowR = 2e6
HighR = LowR + 1e6

;tek_color

window, 0, ysize=800.0,xsize=1200.0
!p.multi = [0,6,4]
;!p.multi = 0

rt=!zspec_data_root+'/../telescope_tests/'+date+'/'
;rt = '/home/zspec/data/observations/'+date+'/'
files=rt+'lc_'+date+'_'+[lcon,lcoff]+'.sav' 

close, 1

device, decompose=0




coldt=0

close, 1

        if keyword_set(pps) then begin
             set_plot, 'PS'      ;'metafile'
             device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
;             DEVICE, FILENAME='/home/kilauea/zspec/nguyen/20061219/cal2/amb_LN2_'+dates[i_dates]+'.ps' ;$
;             DEVICE, FILENAME='/home/kilauea/zspec/bradford/sat_sky_'+dates[i_dates]+'.ps' ;$
             DEVICE, FILENAME='/home/zspec/bradford/jup_sky_'+dates[i_dates]+'.ps' ;$
;;;;;;;;;;;;;  YOU SWOULD CHANGE THIS IF YOU WERE MAKING A POSTSCRIPT OUTPUT.
        endif

        openw,1, rt+'/jup_sky'+output_num+'.txt'   ;+$
        n = n_elements(files)
        cofit = ptrarr(n,1, /allocate_heap)
        dummyR = (findgen(4)+6.)/10.*1e6
        low_dummyR = (findgen(4)+2.)/10.*1e6
        meas_powerdiff=fltarr(192)
        pix_powerdiff =fltarr(5)
        for nb = 1, 8 do begin
            kk = where (box eq nb)
            goodpix = channel[kk]
            for nch = 0,23 do begin
                c = 0
                i = 0
                for gp = 0,n_elements(goodpix)-1 do $
                  if nch eq goodpix[gp] then begin
                    nch_temp=nch & nbox_temp=nb
                    fid=boxchan2freqid(nbox_temp,nch_temp)
 ;                   bandwidth=0.5
                    bandwidth=freqid2squarebw(fid)
; 4.  here are the specific file order - must change this for different files
                    for i_file=0,1 do begin ;nfiles-1,20 do begin
;                    time_s,'Restoring ... ',t0 ;        
                        sobj = obj_new('IDL_Savefile',files[i_file])
                        sobj->Restore,'vbias_deglitch'
                        sobj->Restore,'vchannel_deglitch'
                        sobj->Restore,'grt1'
                        sobj->Restore,'grt2'
                        obj_destroy, sobj
                                ;                   time_e,t0
;                        print, files[i_file], mean(grt1+grt2)/2.
;;;;;;;;;;;;;;; AND FINALLY, YOU HAVE TO TWEAK THE BIAS OFFSET (BOS)
;;;;;;;;;;;;;;; IN ORDER TO GET THE TWO SIDES OF THE LOAD CURVE TO LINE UP                        
;;; NOW CALLED IN THE TOP OF THE PROCEDURE
;                        bos=0.00157
;                        bos = 0.00117
                                ; bos = 0.0017
                                ;bos = 0.00135
                                ;bos=0.00124
                        bias = vbias_deglitch-bos
                        vbolo= vchannel_deglitch[nb-1,nch,*]/dcgain
                        
                        k = WHERE(abs(bias) le 0.001)
                        m = linfit(bias[k],vbolo[k])

                        voss = m[0]
                        vbolo = vbolo-voss
;                        plot, abs(bias*1e3),abs(vbolo*1e3),title=nch
;                        oplot,abs(bias*1e3),abs(vbolo*1e3),color=3
                        
                        Rbolo = vbolo/(bias-vbolo)*2.*rload
                        ibolo = vbolo/(Rbolo+1e-9)
                        Pbolo = vbolo^2/(Rbolo+1e-9)         
                
                        kbolo = WHERE(Rbolo ge .8e6 and Rbolo le 1.2e6 and Pbolo gt 5e-13)
                        
                        if kbolo ne [-1] then begin
                            cof = (Robust_Poly_fit(Rbolo[kbolo],Pbolo[kbolo],3))
                            *cofit[i_file] = cof
                            endif else begin
                            cof=[0.,0.,0.]
                        endelse

                        if i eq 0 then $
;                          if NOT keyword_set(noplot) then begin                       
                        plot,Rbolo/1e6,Pbolo*1e12,psym=5,yrange=[0,5],xrange=[.8,1.2], $
                          title=jpix,xtitle='R (1 MOhm)',ytitle='power (pW)'
                        oplot, Rbolo/1e6,Pbolo*1e12,psym=5,color=i+2
 ;                         endif
                        
                        if kbolo ne [-1] then begin

                        Pbolofit = cof[0]+cof[1]*Rbolo[kbolo]+cof[2]*Rbolo[kbolo]^2+ $
                          cof[3]*Rbolo[kbolo]^3
                    endif else begin
                        pbolofit=0.
                    endelse

                        
                       if NOT keyword_set(noplot) and kbolo ne [-1] then oplot, Rbolo[kbolo]/1e6,Pbolofit*1e12
                    
                        i = 1
                    endfor
                              
                   ; coldT = 1 ; the file for the cold load?  DEFINED above
                    cof0= *cofit[coldT]

                    for i_file = 0, 1 do begin
                        cofj = *cofit[i_file]
                        dummyR=(findgen(5)/10.+.8)*1e6
                        
                        if i_file ne coldT then begin
;                            powerdiffj = (cofj[0]+cofj[1]*dummyR+cofj[2]*dummyR^2+ cofj[3]*dummyR^3) $
;                              -(cof0[0]+cof0[1]*dummyR+cof0[2]*dummyR^2+cof0[3]*dummyR^3)
;                            oe = mean(powerdiffj)/( (amb-LN2)*1.38e-23*1e9*freqid2squarebw(boxchan2freqid(nb,nch)))
;                            printf, 1, nb,nch, freqid2squarebw(boxchan2freqid(nb,nch)), $ 
;                              freqid2squarebw(boxchan2freqid(nb,nch)),mean(powerdiffj),stdev(powerdiffj),oe, $
;                              format='(I3,I3,F12.5,F12.5, G12.5,G12.5, F12.5)'
;                            print, nb,nch,freqid2freq(boxchan2freqid(nb,nch)), $ 
;                              freqid2squarebw(boxchan2freqid(nb,nch)),mean(powerdiffj),stdev(powerdiffj),oe, $
;                              format='(I3,I3,F12.5,F12.5, G12.5,G12.5, F12.5)'

                            powerdiffj = (cofj[0]+cofj[1]*dummyR+cofj[2]*dummyR^2+ cofj[3]*dummyR^3) $
                              -(cof0[0]+cof0[1]*dummyR+cof0[2]*dummyR^2+cof0[3]*dummyR^3)
                            oe = mean(powerdiffj)/( (amb-LN2)*1.38e-23*1e9*bandwidth)
                            printf, 1, nb,nch, bandwidth, $ 
                              bandwidth,mean(powerdiffj),stdev(powerdiffj),oe, $
                              format='(I3,I3,F12.5,F12.5, G12.5,G12.5, F12.5)'
                            print, nb,nch,bandwidth, $ 
                              bandwidth,mean(powerdiffj),stdev(powerdiffj),oe, $
                              format='(I3,I3,F12.5,F12.5, G12.5,G12.5, F12.5)'
                        endif
                    endfor
                    c = 1
                endif
              ;  stop
                if c eq 0 then plot,[1,8],[0.,5e-11],/nodata,title=string(nch)
            endfor              ; loop on nch
        endfor ; loop on nb (box)
;     endfor




close, 1
close, 2
close, 3
if keyword_set(pps) then device,/close
set_plot, 'X'

END
