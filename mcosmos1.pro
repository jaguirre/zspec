; Lieko's working on all this, but here's an attempt to kind of do it by hand
datadir = getenv('HOME')+'/data/observations/ncdf/'

; -----------------------------------------------------------------------------
; Uranus observations for calibration
restore,datadir+'20070502/20070502_041_spectra.sav'
uranus070502 = vopt_spectra
uranus070502tau = median(rpc_params.tau_225)
uranus070502el = $
  median(read_ncdf(datadir+'/20070502/20070502_041.nc','elevation'))
; Uranus observations for calibration
restore,datadir+'20070506/20070506_042_spectra.sav'
uranus070506 = vopt_spectra
uranus070506tau = median(rpc_params.tau_225)
uranus070506el = $
  median(read_ncdf(datadir+'/20070506/20070506_042.nc','elevation'))
; Uranus observations for calibration
restore,datadir+'20070508/20070508_024_spectra.sav'
uranus070508 = vopt_spectra
uranus070508tau = median(rpc_params.tau_225)
uranus070508el = $
  median(read_ncdf(datadir+'/20070508/20070508_024.nc','elevation'))
; -----------------------------------------------------------------------------

; Now.  Spectra ave these guys, convert to Jy, and refer to the top of the
; atmosphere.
spectra_ave,uranus070502
uranus070502jy = cal_vec(2007,5,2,source=1,unit=0)
; We actually observe a number of Jy diminished by the atmosphere transmission
uranus070502trans = exp(-sky_zspec(uranus070502tau)/sin(uranus070502el*!dtor))
uranus070502cal = spectra_div(uranus070502,uranus070502trans*uranus070502jy)

spectra_ave,uranus070506
uranus070506jy = cal_vec(2007,5,2,source=1,unit=0)
; We actually observe a number of Jy diminished by the atmosphere transmission
uranus070506trans = exp(-sky_zspec(uranus070506tau)/sin(uranus070506el*!dtor))
uranus070506cal = spectra_div(uranus070506,uranus070506trans*uranus070506jy)

spectra_ave,uranus070508
uranus070508jy = cal_vec(2007,5,2,source=1,unit=0)
;update svn then restore, 'zspec_svn/calibration/fit_to_mars.sav'
;
;--> (160,3,2) array
;
;The V/Jy based on Mars is [ch,0,0]+[ch,0,1]*Vdc
;
;You can get Vdc with zspec_svn/processing/get_quad_sum.pro

; We actually observe a number of Jy diminished by the atmosphere transmission
uranus070508trans = exp(-sky_zspec(uranus070508tau)/sin(uranus070508el*!dtor))
uranus070508cal = spectra_div(uranus070508,uranus070508trans*uranus070508jy)

mcosmos1obs = datadir+[$
                        ['20070502/20070502_009'], $
                        ['20070502/20070502_010'], $
                        ['20070502/20070502_012'], $
                        ['20070502/20070502_013'], $
                        ['20070507/20070507_008'], $
                        ['20070507/20070507_009'], $
                        ['20070507/20070507_012'], $
                        ['20070507/20070507_013'], $
                        ['20070507/20070507_014'], $
                        ['20070508/20070508_003'], $
                        ['20070508/20070508_004'], $
                        ['20070508/20070508_008'], $
                        ['20070508/20070508_013'], $
                        ['20070508/20070508_014'] $
                      ]

; 20050708: 3, 4, 8 before_crash, 3,4 before_sunrise

n_obs = n_e(mcosmos1obs)

for i=0,n_obs-1 do begin

    date = strsplit(mcosmos1obs[i],'/',/extract)
    date = date[n_e(date)-2]

    restore,mcosmos1obs[i]+'_spectra.sav'

    tau = median(rpc_params.tau_225)
    el = median(read_ncdf(mcosmos1obs[i]+'.nc','elevation'))
    trans = exp(-sky_zspec(tau)/sin(el*!dtor))
    
    case date of
        '20070502' : cal = uranus070502cal.in.avespec
        '20070507' : cal = uranus070506cal.in.avespec
        '20070508' : cal = uranus070508cal.in.avespec
    endcase

    vopt_spectra = spectra_div(vopt_spectra,trans*cal)

    if i eq 0 then begin
        uber_spectra=vopt_spectra
;        uber_bolo_flags=bolo_flags
    endif else begin
        uber_spectra=combine_spectra(uber_spectra,vopt_spectra)
;        uber_bolo_flags*=uber_bolo_flags
    endelse

    print,i,'      ',date
    help,uber_spectra.in,/str

endfor  

spectra_ave,uber_spectra

!p.multi = [0,1,2]
ploterror,nu,uber_spectra.in.avespec,uber_spectra.in.aveerr,psy=10,thick=4,/xst
oplot,nu,fltarr(160),col=1
oplot,nu,fltarr(160)+6d-3,col=2
wh = where(nu ge 200 and nu le 300)
print,string('Mean flux density ',mean(uber_spectra.in.avespec[wh])*1000.,$
             ' +/- ',sqrt(total(uber_spectra.in.aveerr[wh]^2)/n_e(wh)),$
             ' mJy',format='(A,F5.1,A,F5.1,A)')

plot,nu,uber_spectra.in.aveerr,psy=10,/xst
oplot,nu,fltarr(160),col=1
oplot,nu,fltarr(160)+6d-3,col=2

end
