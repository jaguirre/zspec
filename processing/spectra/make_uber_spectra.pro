;basically re-written 2007-05-08 LE
;created 2007-03-27 LE
;
;This routine takes a bunch of separate observations of a source and
;concatenates the vopt_spectra structures into one structure
;called uber_spectra, calibrates it, and takes the average.
;
;It reads in a list of observations created in
;zspec_svn/processing/spectra/coadd_lists/
;See UGC5101.txt for an example.
;
;It will plot weighted and unweighted averages & error bars.
;Correction for sky transmission is based on Matt's sky_zspec function
;and (for the moment) median tau and ZA values for each observation.  
;These will be corrected later to use an appropriate tau and elevation
;for each separate nod.
;
;To get tau value, it does one of 2 things:
;1) if rpc_params exist, it reads in the tau value for that
;observation
;2) if not, it uses get_time to get the UT time for the middle of the
;observation and then uses the funtion tau225smooth.pro to get a
;gaussian smoothed mean of tau.
;
;Save_spectra has been modified to keep track of the total number of
;seconds of integration, so you may find that you need to rerun
;save_spectra on some observations before make_uber_spectra can deal
;with them.  (You'll know when you get an error complaining that the
;variable n_sec is not defined.
;
;Optional keyword /allspec will plot the unweighted avespec for each
;observation that goes into the coadd.  These plots will be in a
;separate .ps file.
;
;Optional keyword /lines lets you use Bret's printlines routine to
;overplot the lines.  Printlines_uber_spectra has been committed to
;the archive.  By default it will print all the lines.  You may want
;to change the label_positions to make them legible.

;At the end it creates a save file in the ncdf/uber_spectra/ 
;directory.  If uber_spectra subdirectory doesn't exist it will make
;one.  
;
;********************* NOTE ON CALIBRATION***************************
;This section of the routine is under construction.  The function 
;mv_per_jy.pro (which lives in zspec_svn/calibration) returns an array
;of V/Jy for each channel which is used together with spectra_div
;to turn units of uber_spectra into Jansky.  Eventually we will change
;this function to give a calibration as a function of the DC levels.
;For now, it simply ignores the dc_volts input and spits out a result
;based on planet and cal_vec.  Sky transmission correction added.
;************THIS MEANS THAT YOU HAVE TO MAKE*************************
;********CHANGES TO MV_PER_JY.PRO ACCORDING TO WHICH****************** 
;***********CALIBRATION OBSERVATION YOU WANT TO USE*******************.

;______________________________________________________________________


pro make_uber_spectra,obs_list,allspec=allspec,lines=lines

;_______________________________________________________________________
;first read in text file defining observations

  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
  readcol,file,date,obs,flag,format='(a8,a3,i1)'
  readcol,file,header,format='(a)'
  source_name=header[0] & z=header[1]
  n_obs=n_e(date)

  ;break up the date into year, month, night        
     a=0L & b=0L & c=0L
     year=strarr(n_obs) & month=year & night=year
     for i=0, n_obs-1 do begin
       reads,date[i],a,b,c,format='(a4,a2,a2)'
       year[i]=a & month[i]=b & night[i]=c
     endfor

     wantdata=where(flag eq 1)
     n_obs=n_e(wantdata)
     year=year(wantdata)
     month=month(wantdata)
     night=night(wantdata)
     obs=obs(wantdata)

;______________________________________________________________________                                
;check to make sure demodulated data exists

     file_list=strarr(n_obs)
     ncfile_list=strarr(n_obs)
     for i=0,n_obs-1 do begin
         ncfile=get_ncdfpath(year[i],month[i],night[i],obs[i])
         save_spectra_file=change_suffix(ncfile,'_spectra.sav')
         test_nc=file_search(save_spectra_file)
         if (test_nc eq '') then begin
             print,'Cannot find: '+save_spectra_file+'.'
             print,'Please run save_spectra on all observations first!'
             stop
         endif
         file_list[i]=save_spectra_file
         ncfile_list[i]=ncfile
     endfor

;_________________________________________________________________________
;now shove them all together

     print,'Performing uber-concatenation....'

     ;keep track of how many observations in each nod & total time
        nods_in_obs=intarr(n_obs)
        total_n_sec=0.

        for i=0,n_obs-1 do begin

            restore,file_list[i]
            nods_in_obs[i]=n_e(vopt_spectra.in1.nodspec[0,*])
            total_n_sec+=n_sec
    

;************temporary kluge - calibrate each obs with planet first so we can
;                  coadd obs from different seasons
;*************************************************************************

    dc_volts=1

    case 1 of
        year[i] eq 2006 and month[i] eq 4:begin
            run='apr06'
            ticks=read_ncdf(ncfile_list[i],'ticks')
            time=mean(ticks/3600.)
            print,'smoothing tau data...'
            tau_this_obs=tau225smooth(date[i],time)
        end
        year[i] eq 2006 and month[i] eq 12:begin
            run='dec06'
            tau_this_obs=median(rpc_params.tau_225)
        end
        year[i] eq 2007 and month[i] eq 1:begin
            run='dec06'
            tau_this_obs=median(rpc_params.tau_225)
        end
        year[i] eq 2007 and month[i] eq 4:begin
            run='spring07'
            tau_this_obs=median(rpc_params.tau_225)
        end
        year[i] eq 2007 and month[i] eq 5:begin
            run='spring07'
            tau_this_obs=median(rpc_params.tau_225)
        end
        else:message,'Please update this routine to handle this observation year and month.'
    endcase
    
    ;median elevation angle for this observation
    ;change later to look up for each nod
    elev_this_obs=median(read_ncdf(get_ncdfpath(year[i],month[i],night[i],obs[i]),'elevation'))
    airmass_this_obs=1./sin(elev_this_obs*(!pi/180.))

    cal=mv_per_jy(dc_volts,run)
    trans_this_obs=exp(-1.*airmass_this_obs*sky_zspec(tau_this_obs))
    vopt_spectra=spectra_div(vopt_spectra,cal*trans_this_obs)
    
;_________________________________________________________________________________________
;now if keyword allspec is set then it makes a plot of all the
;observations

        if keyword_set(allspec) then begin

            if i eq 0 then begin
                set_plot,'ps',/copy
                xr=[180,310]
                allspec_plotfile=!zspec_data_root+'/ncdf/uber_spectra/'+$
                  strcompress(source_name)+'.ps'
    
                device,file=allspec_plotfile,/color,/inches,$
                  xoffset=0.5,yoffset=0.5,xsize=7.5,ysize=8,/portrait

                !p.multi=[0,1,2]
                !p.thick=1
                !p.charthick=1
                !x.thick=1
                !y.thick=1
            endif

            thisobs_id=source_name+' '+$
              strcompress(year[i],/rem)+$
              strcompress(month[i],/rem)+$
              strcompress(night[i],/rem)+'_'+$
              strcompress(obs[i],/rem)+' '+$
              'unweighted average'

            thisobs=vopt_spectra & spectra_ave,thisobs,/unweighted
            
            plot,freqid2freq(indgen(160)),thisobs.in1.avespec,xrange=xr,$
              psym=10,yrange=[0.007,5],/yst,/ylog,/yno,tit=thisobs_id,$
              /xst

            uppererror=thisobs.in1.avespec+thisobs.in1.aveerr
            lowererror=thisobs.in1.avespec-thisobs.in1.aveerr

            errplot,freqid2freq(indgen(160)),uppererror,lowererror,width=0.006,col=2  
            
            if i eq n_obs-1 then begin
                !p.multi=0 & device,/close
            endif

        endif

;___________________________________________________________________________________________
    
    if i eq 0 then begin
        uber_spectra=vopt_spectra
        uber_bolo_flags=bolo_flags
        transmission=trans_this_obs
        for j=1,nods_in_obs[i]-1 do begin
            transmission=[[transmission],[transmission]]
        endfor
    endif else begin
        uber_spectra=combine_spectra(uber_spectra,vopt_spectra)
        uber_bolo_flags*=uber_bolo_flags
        for j=0,nods_in_obs[i]-1 do begin
            transmission=[[transmission],[trans_this_obs]]
        endfor
    endelse

endfor  

;________________________________________________________________________
;here's where we want to do the calibration

;********THIS SECTION TEMPORARILY MOVED UP TO DEAL WITH CALIBRATION
;BEFORE CONCATENATION**********************2007-05-02 LE


;THIS SECTION UNDER CONSTRUCTION

;Calibration curve should be fxn of dc volts
;Since we don't have said fxn use spectra_div and cal_vec
;for now

;so basically want a dummy function that reads in V_dc, ignores
;it, and spits out the cal_vec value.

;mv_per_jy.pro lives in zspec_svn/calibration

;dc_volts=1

;cal=mv_per_jy(dc_volts)
;uber_spectra=spectra_div(uber_spectra,cal)

;________________________________________________________________________
;now average over all the nods

;here are unweighted averages
uber_spectra_unweighted=uber_spectra
spectra_ave,uber_spectra_unweighted,/unweighted
uber_spectra_unweighted.in1.avespec*=uber_bolo_flags

;and the weighted averages
;temporary test for weighted average
;   transmission[*,*]=1.
spectra_ave,uber_spectra,transmission=transmission
uber_spectra.in1.avespec*=uber_bolo_flags

totalnods=n_e(uber_spectra.in.nodspec[0,*])

;_________________________________________________________________________
;create save file of all of the above

now=bin_date(systime(0,/utc))
suffix=string(now[0],now[1],now[2],now[3],now[4],$
              format='(i4,i2.2,i2.2,"_",i2.2,i2.2)')

want_dir=!zspec_data_root+'/ncdf/uber_spectra/'
test=file_search(want_dir)
if (test eq '') then spawn, 'mkdir '+want_dir

ubername=want_dir+source_name+'_'+suffix+'.sav'

save,uber_spectra,uber_spectra_unweighted,transmission,$
  file_list,source_name,uber_bolo_flags,filename=ubername
print,'Save file at: '+ubername+'.'

if keyword_set(allspec) then begin
    newsuffix='_individual_obs_'+suffix+'.ps'
    newname=change_suffix(allspec_plotfile,newsuffix)
    spawn, 'cp '+allspec_plotfile+' '+newname
    spawn, 'rm '+allspec_plotfile
endif

;_________________________________________________________________________
;make ps plots

!p.thick=1
!p.charthick=1
!x.thick=1
!y.thick=1

set_plot,'ps',/copy
xr=[180,310]

;********MAY NEED TO ADJUST FOR EACH PLOT************
yr=[0.008,.3] 
label_postions=[.09,.12,.2]
;****************************************************

ymin=yr[0]
ymax=yr[1]

weighted_plottitle=source_name+' weighted average over '+strcompress(floor(total_n_sec))+' seconds'
unweighted_plottitle=source_name+' unweighted average over '+strcompress(floor(total_n_sec))+' seconds'

plotfile=change_suffix(ubername,'.ps')

device,file=plotfile,/color,/inches,$
  xoffset=0.5,yoffset=0.5,xsize=7.5,ysize=8,/portrait

;plot weighted averages

  uppererror=uber_spectra.in1.avespec+uber_spectra.in1.aveerr
  lowererror=uber_spectra.in1.avespec-uber_spectra.in1.aveerr

  multiplot,[1,3],/verbose
  plot,freqid2freq(indgen(160)),uber_spectra.in1.avespec,$
    psym=10,/ylog,/yno,/yst,ytit='Flux Density [Jy]',$
    xrange=xr,tit=weighted_plottitle,/xst,yrange=yr

  errplot,freqid2freq(indgen(160)),uppererror,lowererror,width=.006,col=2

if keyword_set(lines) then $
    printlines_uber_spectra,label_positions,z,ymin,ymax,$
      /all_lines

  multiplot,/verbose
  plot,freqid2freq(indgen(160)),uber_spectra.in1.avespec,$
    psym=10,ytit='Flux Density [Jy]',$
    xrange=xr,/yst,/xst,/yno

  errplot,freqid2freq(indgen(160)),uppererror,lowererror,width=.006,col=2

  multiplot,/verbose
  plot,freqid2freq(indgen(160)),uber_spectra.in1.aveerr,$
    xtit='Frequency [GHz]',ytit='Average Error Bars [Jy]',$
    /yno,/yst,/xst,/ylog,/nodata
  oplot,freqid2freq(indgen(160)),uber_spectra.in1.aveerr,$
    psym=4,col=4

;go to next page
  multiplot,/reset,/verbose
  erase

;next plot unweighted averages

  uppererror=uber_spectra_unweighted.in1.avespec+uber_spectra_unweighted.in1.aveerr
  lowererror=uber_spectra_unweighted.in1.avespec-uber_spectra_unweighted.in1.aveerr

  multiplot,[1,3],/verbose
  plot,freqid2freq(indgen(160)),uber_spectra_unweighted.in1.avespec,$
    psym=10,/ylog,/yno,/yst,ytit='Flux Density [Jy]',$
    xrange=xr,tit=unweighted_plottitle,/xst,yrange=yr

  errplot,freqid2freq(indgen(160)),uppererror,lowererror,width=.006,col=2
  
  if keyword_set(lines) then $
    printlines_uber_spectra,label_positions,z,ymin,ymax,$
    /all_lines

  multiplot,/verbose
  plot,freqid2freq(indgen(160)),uber_spectra_unweighted.in1.avespec,$
    psym=10,ytit='Flux Density [Jy]',$
    xrange=xr,/yst,/xst,/yno

  errplot,freqid2freq(indgen(160)),uppererror,lowererror,width=.006,col=2

  multiplot,/verbose
  plot,freqid2freq(indgen(160)),uber_spectra_unweighted.in1.aveerr,$
    xtit='Frequency [GHz]',ytit='Average Error Bars [Jy]',$
    /yno,/yst,/xst,/ylog,/nodata
  oplot,freqid2freq(indgen(160)),uber_spectra_unweighted.in1.aveerr,$
    psym=4,col=4


  multiplot,/reset,/verbose
  !p.multi=0
  device,/close
  set_plot,'x',/copy

print,'Coadds at: '+plotfile+'.'
print,'Spectra saved at '+change_suffix(ubername,'.sav')+'.'
if keyword_set(allspec) then print,$
  'Individual observations plotted at: '+newname+'.'

;stop
end
