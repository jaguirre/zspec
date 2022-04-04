;
;+
;
; This is basically just a copy of save_spectra that's been hacked to
; deal with the very different way APEX hands us data.
; 
; *** bias is not reported via MBFITS.  
;
; 2010/10/21: now saving rel_phase with the rest of the "save_spectra"
; variables, and also saving nc_ticks with the chopphase.
;
;
; This function reads in a particular observation from a particular date
; and does the demodulation and differencing of the rolloff-corrected
; bolometer timestreams.  It saves the results to a save file that strips
; off the '.nc' and adds '_spectra.sav'.  The rel_phase argument is the 
; chopper to bolometer phase to use for demodulation.  If rel_phase is 
; zero then use zero phase shift for all channels.  If rel_phase is a
; single non-zero number, then compute the chopper to bolometer phase from
; the given file and save to a file that takes off the '.nc' from the data
; file and adds '_chopphase.sav'.  If rel_phase has more than one element
; it is used as the chopper to bolometer phases for the demodulation.  After
; execution, if rel_phase is passed as a variable, it will equal the chopper to
; bolometer phases used for demodulation.  rel_phase = 0 is the default, 
; if it is not present in the arguments, then no phase correction is applied.
;
; It also loads in the data from the RPC files and saves it along with
; the spectra.  The structure rpc_params has many tags of telescope
; data with about one sample per second.
;
; If DEGLITCH is set, then a deglitch pass is performed.  If PSD is
; set then an average PSD for each bolometer is calculated (averaged
; over nod & position)
;
; IF SAVE_TS is set then the sliced timestreams are saved in a '_slicedts.sav'
; file
;;
;MODIFIED 2007-03 by LE -
; 1) Degliching is now done at the beginning, before the digital
;    filter.  
; 2) The data is downsampled by a factor of "downfac"
;    after the low-pass filter is applied.  Every nth sample (where n
;    = downfac) is extracted for the logic,chopper, and timestream
;    signals.  The flags are interpolated (so that any bin which
;    contained a "bad" data point has a flag of 0.  "Downfac" may be 
;    defined as a keyword; the default value is 3.  "Downfac" is saved
;    as a variable in the .sav file.  
; 3) The logic signals are converted to "byte" type in the read_ncdf
;    lines (instead of keeping them double-precision.)
;
;MODIFIED 2007-05-04 by LE -
;    The rel_phase input must be equal to 0, 1, a (3 x nbolos) array
;    defining the rel_phase, or a string specifying the name of the save
;    file containing the desired rel_phase (for example
;    '20061222_004_chopphase.sav').
; 
;MODIFIED 2007-08-30 BY LE - keyword error_psd will use Bret's new
;                            estimate_psd_errors function to compute
;                            new errors for each nod based on the psd
;                            white noise level.
;
;
;MODIFIED 2008-03-05 BY LE - keywords /psd and /error_psd now
;                            obsolete.  These will be computed
;                            automatically.
;
;MODIFIED 2009-05-16 BY LE - case statement to get cline removed and
;                            replaced with a call to a more generic function
;                            getcline.pro, which looks up the
;                            correct cline text file according to
;                            month and date of observation.
;12/19/2012 - KSS - Committed latest revision to svn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-

FUNCTION zanalyze, year, month, night, obsnum, file, rel_phase, $
                   samp_int, vr, vi, chop_enc, $
                   nscans, n_nods, n_nod_pos, n_samp_per_scan, $
                   nod_struct, chop_struct, avebias, $
                   nc_ticks, nc_elevation,nc_pwv, $
                   DEGLITCH = DEGLITCH, $
                   SAVE_TS = SAVE_TS,$
                   DOWNFAC = DOWNFAC,BAD=BAD,$
                   save_all=save_all, quad=quad, MS_decorr=MS_decorr, $
                   PCA_decorr=PCA_decorr

print,'rel_phase',rel_phase
;-------------------
; JRK 10/21/10
; sin and cos from the .nc files are here as vr and vi.
; Use these to find tbath and record it in the .sav file.
; As done in file_io/get_temps
; EXCEPT, this is wrong, the dimensions of vr and vi are 2D
; not 3D.
; REL 01/03/2011 Alright, I hope this is the last place where I have
; to add pwv.
;REL 01/03/2011 added badflag variable to the sav file to exclude from
;the coadd the scans that have all the subscans unusable 
badflag=bad
if bad then goto,writesav
sin=vr
cos=vi

jfet_diode = tempconvert(sin[9,1,*],'diode','')
cernox = tempconvert(sin[9,8,*],'cerx31187','log')
ruox = tempconvert(sin[9,9,*],'roxu01434','log')
grt1 = tempconvert(sin[9,10,*],'grt29177','log')
grt2 = tempconvert(sin[9,11,*],'grt29178','log')

nc_tbath = create_struct('jfet_diode',jfet_diode,$
                    'cernox',cernox,$
                    'ruox',ruox,$
                    'grt1',grt1,$
                    'grt2',grt2)
;-------------------

;;;;look for netCDF file or zipped netCDF file
;;;  waszipped=0
;file = get_ncdfpath(year,month,night,obsnum)
print,file
;;;  zippedfile = file+'.gz'
;;;  maligned = file_search(file)
;;;  zipped = file_search(zippedfile)
;;;
;;;  if maligned eq '' and zipped eq zippedfile then begin
;;;     print,'Gunzipping....'
;;;     spawn,'gunzip '+zippedfile
;;;     waszipped=1
;;;  endif
;;;
;;;;read from netCDF file
;;;  PRINT, 'reading from:'
;;;  PRINT, file
;;;  PRINT, 'Reading Flags'
;;;  nodding = byte(read_ncdf(file,'nodding'))
;;;
;;;
;;;  on_beam = byte(read_ncdf(file,'on_beam'))
;;;  off_beam = byte(read_ncdf(file,'off_beam'))
;;;  acquired = byte(read_ncdf(file,'acquired'))
;;;  PRINT, 'Reading Chopper Encoder'
;;;  chopper = read_ncdf(file,'chop_enc')
;;;  PRINT, 'Reading Bias'
;;;  bias = get_bias(file)
;;;  samp_int = find_sample_interval(read_ncdf(file,'ticks'))
;;;  avebias = MEAN(bias)
;;;  PRINT, 'Average Bias Voltage = ', avebias*1000, $
;;;         ' mV, Bias Freqency = ', 2.0/samp_int, ' Hz'
;;;
;;;  PRINT, 'Reading LIA outpus'
;;;  vr_raw = read_ncdf(file,'sin')
;;;  vi_raw = read_ncdf(file,'cos')
;;;  PRINT, 'Extracting Optical Channels'
;;;  CASE 1 OF
;;;      month EQ 4 AND year EQ 2006:BEGIN
;;;          bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr06.txt'
;;;      END
;;;      month EQ 12 AND year EQ 2006:BEGIN
;;;          bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_dec06.txt'
;;;      END
;;;      month EQ 1 AND year EQ 2007:BEGIN
;;;          bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_dec06.txt'
;;;      END
;;;      month EQ 4 AND year EQ 2007:BEGIN
;;;          bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
;;;      END
;;;      month EQ 5 AND year EQ 2007:BEGIN
;;;          bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
;;;      END
;;;      month EQ 11 AND year EQ 2007:BEGIN
;;;          bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
;;;      END
;;;      month EQ 12 AND year EQ 2007:BEGIN
;;;          bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
;;;      END
;;;      year gt 2007: begin
;;;          bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
;;;      end
;;;      ELSE:MESSAGE,'Please define bolo_config for given month and year' 
;;;  ENDCASE
;;;
;;;  ncid = ncdf_open(file)
;;;; If there is not "telescope" attribute, assume we're dealing with an
;;;; old CSO file.
;;;  tel_varid = ncdf_varid(ncid,'telescope')
;;;  if (tel_varid ne -1) then begin
;;;      ncdf_attget, ncid, 'telescope', telescope, /GLOBAL
;;;      telescope = string(telescope) ; convert from bytes to chars
;;;  endif else telescope = 'CSO'
;;;  ncdf_close, ncid
;;;
;;;  print, telescope
;;;  
;;;  if telescope eq 'APEX' then begin
;;;      vr = vr_raw
;;;      vi = vi_raw
;;;  endif else begin
;;;      vr = extract_channels(vr_raw,'optical',bolo=bc_file)
;;;      vi = extract_channels(vi_raw,'optical',bolo=bc_file)
;;;  endelse
;;;  delvarx, vi_raw, vr_raw
;;;
ts_size = SIZE(vr)
flags = REPLICATE(1,ts_size[1:2])
nbolos = ts_size[1]

n_sec=ts_size[2]*samp_int      ;total number of seconds in observation

;;;__________________________________________________________________
;;;Deglitch data first
;;;
;;; time_s,"Deglitching data ... ", t0
;;; 
;;; if keyword_set(deglitch) then begin
vr=datadeglitch(vr,flags,/usesigma,ave=n_samp_per_scan,sigma=3.,/quiet)
vi=datadeglitch(vi,flags,/usesigma,ave=n_samp_per_scan,sigma=3.,/quiet)

;;; endif
;;;
;;; time_e,t0
;;;
;;;___________________________________________________________________
;The low-pass filter
; Skip this because we don't really have a continuous time series
if (0) then begin
  lp_freq = 4.5

  time_s, string('Low-Pass Filtering Data - ',lp_freq,' Hz Cutoff ... ',$
                 format='(A,F5.1,A)'),t0
  filt_coeffs = DIGITAL_FILTER(0,4.5/(1.0/(2.0*samp_int)),$
                               50,1.0/samp_int,/DOUBLE)
  vr_filt = vr
  vi_filt = vi
  
  FOR bolo = 0, nbolos - 1 DO BEGIN
      vr_filt[bolo,*] = CONVOL(REFORM(vr[bolo,*]),filt_coeffs,/EDGE_TRUNCATE)
      vi_filt[bolo,*] = CONVOL(REFORM(vi[bolo,*]),filt_coeffs,/EDGE_TRUNCATE)
  ENDFOR
  
  time_e,t0

;___________________________________________________________________________
;Downsample data by factor of "downfac" (default factor is 3)

 time_s,"Downsampling filtered data ... ",t0

 if keyword_set(downfac) then downfac=downfac else downfac=3

;chopper also needs to be low-pass filtered before downsampling
 chopper=convol(chopper,filt_coeffs,/edge_truncate)

;defining size of new arrays & sample interval
 original_samp_n=n_e(vr_filt[0,*])
 make_divisible=original_samp_n-(original_samp_n mod downfac)
 reduced_samp_n=make_divisible/downfac
 samp_int=samp_int*downfac

;now use rebin fxn to downsample
 nodding=rebin(nodding[0:make_divisible-1],reduced_samp_n,/sample)
 on_beam=rebin(on_beam[0:make_divisible-1],reduced_samp_n,/sample)
 off_beam=rebin(off_beam[0:make_divisible-1],reduced_samp_n,/sample)
 acquired=rebin(acquired[0:make_divisible-1],reduced_samp_n,/sample)
 chopper=rebin(chopper[0:make_divisible-1],reduced_samp_n,/sample)
 vr_filt=rebin(vr_filt[*,0:make_divisible-1],nbolos,reduced_samp_n,/sample)
 vi_filt=rebin(vi_filt[*,0:make_divisible-1],nbolos,reduced_samp_n,/sample)

 ;flags get interpolated so that any bad data in the bin turns flag to zero
 ;if downfac is an even number it will use downfac+1 for the rebin boxcar	 
 ends=replicate(1,nbolos)
 if (downfac mod 2 eq 0) then flagsfac=downfac+1 else flagsfac=downfac
 firstextra=flagsfac/2
 for i=0, firstextra-1 do flags=[[ends],[flags]]
 flags=rebin(flags[*,0:make_divisible-1],nbolos,reduced_samp_n)
 flags=byte(flags)    ;this makes any average less than 1 turn into 0.

 ;if there's zipped version of this file, erase it to avoid confusion
 zipped_nod_diag_file=change_suffix(file,'_nod_diag.ps.gz')
 test=file_search(zipped_nod_diag_file)
 if test eq zipped_nod_diag_file then $
     spawn,'rm '+zipped_nod_diag_file

 nod_struct = find_onoff(find_nods(nodding),on_beam,off_beam,acquired,$
                         flags,diagnostic=change_suffix(file,'_nod_diag.ps'),$
                         vr_filt,vi_filt)
 chop_struct =  make_chop_struct(chopper,flags,sample_interval=samp_int)
 nod_struct = trim_nods(nod_struct,chop_struct.period,length=pos_length)

 time_e,t0
endif
vr_filt = vr
vi_filt = vi
nyquist = 2.0/samp_int
;____________________________________________________________________

;At this point all the data should be downsampled in a consistent way.
;Proceed with Bret's demodulation routine.
;_____________________________________________________________________

  PRINT, 'Slicing up data'
  vr_slice = slice_data(nod_struct,vr_filt,flags)
  vi_slice = slice_data(nod_struct,vi_filt,flags)

  PRINT, 'Finding optimum phi values'
  cline=getcline(month,year,night)
  rload = get_load_resistors('optical',bolo=bc_file)
  obsstart = nod_struct[0].i
  obsend = nod_struct[N_E(nod_struct)-1].f
  phi_struct = brm_obs_phifit(vr_filt[*,obsstart:obsend],$
                              vi_filt[*,obsstart:obsend],$
                              avebias,samp_int,rload,cline,$
                              nyquist)

  phi = phi_struct.value
  opt_sigs = make_optimum_signals(vr_slice,vi_slice,phi, quad=quad)
  theta_opt = opt_sigs.theta_opt

  ;***Deglitching used to happen here in the original code.
  ;***Now it happens at the top.  Changed March 07 by LE.

  vopt = opt_sigs.vopt	
  verr = opt_sigs.verr	

  iters=['base']
  if keyword_set(MS_decorr) then iters=[iters, 'MS']
  if keyword_set(PCA_decorr) then iters=[iters, 'PCA']
  if keyword_set(MS_decorr) and keyword_set(MS_decorr) $
    then iters=[iters, 'both']

  saved_phase=rel_phase
  for iter=0, n_e(iters)-1 do begin
      
      if iters[iter] eq 'MS' or iters[iter] eq 'both' then  $
        vopt=MS_decorrscript(vopt, chop_struct.period,coeffs=decorr_coeffs, $
                             timestreams=decorr_timestreams)

      if iters[iter] eq 'PCA' or iters[iter] eq 'both' then $
        vopt=PCA_decorrscript(vopt, period=chop_struct.period)
      
      vopt_corr=calculate_corr(vopt)

      degree = 1
      poly_subtract, vopt, POLY_DEG = degree, /quiet
      poly_subtract, verr, POLY_DEG = degree, /quiet

  ;_________________________________________________________________
;following modified 2008-03-05 by LE
;the "if" statements were removed; PSDs now always computed

;  IF KEYWORD_SET(PSD) THEN BEGIN
      psd_calc, vopt, samp_int, /quiet
      psd_calc, verr, samp_int, /quiet
      vopt_avepsd = CREATE_STRUCT('psd',psd_ave(vopt,/POS),$
                                  'freq',vopt[0].nod[0].pos[0].freq)
      verr_avepsd = CREATE_STRUCT('psd',psd_ave(verr,/POS),$
                                  'freq',vopt[0].nod[0].pos[0].freq)
;  ENDIF ELSE BEGIN
;     vopt_avepsd = -1
;     verr_avepsd = -1
; ENDELSE

;__________________________________________________________________
;this section modified 2007-05-04 by LE
;rel_phase input can now be name of save file containing desired
;rel_phase array

      IF N_PARAMS() EQ 4 THEN rel_phase = 0
 ;if rel_phase ne [0] and rel_phase ne [1] then 
      rel_phase_size=size(rel_phase)

 ;Now what is rel_phase? There are 4 cases: 
 ;rel_phase=0 --> no correction
 ;rel_phase=1 --> find rel_phase from this observation
 ;rel_phase=3x160 array --> use this rel_phase
 ;rel_phase=.sav file containin grel_phase --> restore file and use rel_phase
;MJRR: added option to use rel_phase scan number
      rel_phase=saved_phase
      case 1 of 
          (rel_phase_size[1] eq 2 or rel_phase_size[1] eq 3) :begin
              
               if (rel_phase eq [0]) then rel_phase=dblarr(3,nbolos) $
               else if (rel_phase eq [1])then begin
              print, 'Finding and saving chopper to bolometer phase.'
              rel_phase=find_chop_bolo_phase3(nod_struct,vopt,chop_struct,$
                                              nloops=3)
              save,rel_phase,nc_ticks,file=file+'_chopphase.sav'
          endif else begin
              rel_phase_f=file_search(!zspec_data_root+'/apexnc/*/APEX-'+ $
                                      strcompress(string(rel_phase(0)), /remove_all)+'-*_chopphase.sav')
              
              if rel_phase_f[0] eq '' then begin
                  print, 'ERROR: no chopper phase file found for scan '+$
                    strcompress(string(rel_phase(0)), /remove_all)
                  stop
              endif

              print,'Using rel_phase defined in:'
              print, rel_phase_f
              restore, rel_phase_f
          endelse
          end
          rel_phase_size[0] eq 0 and rel_phase_size[1] eq 7:begin

            ;  rel_date=''
             ; reads,rel_phase,rel_date,format='(a8)'
              ;rel_phase_f=!zspec_data_root+'/ncdf/'+strcompress(rel_date)+$
                                ; '/'+rel_phase
                                ;rel_phase_f=file_search(!zspec_data_root+'/apexnc/*/'+ rel_phase(0))
                rel_phase_f=!zspec_data_root+'/apexnc/*/APEX-'+rel_phase+'*_chopphase.sav'

                if rel_phase_f(0) ne '' then begin 
		 print,'Using rel_phase defined in:'
                 print, rel_phase_f
                 restore, rel_phase_f
		endif else begin 
                print,rel_phase_f
                print,'Chopper phase file not found. Make sure it is computed.'
		stop
		endelse
          end
          rel_phase_size[0] eq 2 and rel_phase_size[1] eq 3 $
            and rel_phase_size[2] eq nbolos:begin
          end
          else:begin
              print,'Your rel_phase request is confusing.'
              stop
          endelse
      endcase         
      
;___________________________________________________________________


      
      sliced_chop = $
        make_phased_sliced_chop(nod_struct,chop_struct,rel_phase)
      
      structure=demod_and_diff3(nod_struct,vopt,sliced_chop,$
                                /CHOP_PRECOMPUTE)
      vopt_spectra = structure.signal
      chopper_spectra=structure.chopper
      
      structure=demod_and_diff3(nod_struct,verr,sliced_chop,$
                                /CHOP_PRECOMPUTE)
      verr_spectra = structure.signal
      chopper_error=structure.chopper
      
      estimate_spec_err, vopt_spectra
      estimate_spec_err, verr_spectra
      estimate_spec_err, chopper_spectra
      estimate_spec_err, chopper_error
      
; Create some additional variables for compatibility with functions that
; used to work with output from npt_obs
      bolos = INDGEN(nbolos)
      n_nods = N_ELEMENTS(nod_struct)
      nu = freqid2freq(bolos)
      nco = WHERE(ABS(nu-230.) EQ MIN(ABS(nu-230.)))
      snu = vopt_spectra.in1.nodspec
      serr = vopt_spectra.in1.noderr
      
;;;  PRINT, 'Reading bolo_flags'
;;;  bolo_flags = read_ncdf(file,'bolo_flags')
;;;
;;;  time_s, 'Reading in RPC Files ... ',t0
;;;  rpc_params = get_rpc_params(year,month,night,obsnum,/ALL_PARAMS,/quiet)
;;;  time_e,t0
;;;
;;;  zipped_spectra=change_suffix(file,'_spectra.sav.gz')
;;;  test=file_search(zipped_spectra)
;;;  if test eq zipped_spectra then spawn,'rm '+zipped_spectra
;;;
;_____________________________________________________________________
;following modified 2008-03-05 by LE
;removed the "if" statement so that vopt_psderror is always computed

      pos_length = n_samp_per_scan
;if keyword_set(error_psd) then begin
      chopfreq=1./(chop_struct.period*samp_int)
      inttime=4.*pos_length*samp_int
      vopt_psderror=$
        estimate_psd_errs(vopt_spectra,vopt_avepsd,chopfreq,inttime)

      nnf=vopt_psderror.in3.noderr
      vopt_psderror.in3.noderr=-1

;endif else begin
;vopt_psderror='not_computed'
;endelse

;this is where James's psd-fitting routine happens.  
;if keyword_set(psd) then begin
      chopfreq=1./(chop_struct.period*samp_int)
;    plot_psds,vopt_avepsd,change_suffix(file,'_psds.ps'),chop=chopfreq
      print, obsnum, keyword_set(MS_decorr), keyword_set(PCA_decorr)
      psd_fitparams=plot_psds(vopt_avepsd,file+'_psds.ps',chop=chopfreq)
;endif

;;;;compute a multiplicative factor to scale the amplitude to
;;;;account for lost signal due to faster chop frequencies
;;;chop_fac=chopper_ineff_factor(chopfreq)
;;;
;;;;check if there's a zipped version of _spectra.sav, and remove if
;;;;there is to avoid confusion with old demodulations
;;;  zipped_spectra=change_suffix(file,'_spectra.sav.gz')
;;;  test=file_search(zipped_spectra)
;;;  if test eq zipped_spectra then spawn,'rm '+zipped_spectra
;;;

    ; Compute the DC levels
      vdc = total(sqrt((reform(vr_slice.nod[*].pos[*].time,$
                               n_samp_per_scan*n_nod_pos,n_nods,nbolos))^2 + $
                       (reform(vi_slice.nod[*].pos[*].time,$
                         n_samp_per_scan*n_nod_pos,n_nods,nbolos))^2),1) / $
        double(n_samp_per_scan*n_nod_pos)

; Define the bolo_flags
      bolo_flags = replicate(1,160)
      bolo_flags[[81,86]] = 0

; Average the spectra.  I mean, come on.
      ndtemp = size(vopt_spectra.in.nodspec,/n_dim)
      if ndtemp gt 1 then begin
          spectra_ave, vopt_spectra
          spectra_ave, vopt_psderror
          spectra_ave, chopper_spectra
          spectra_ave, chopper_error
      endif

      if iters[iter] eq 'base' then begin
          base_vopt_spectra=vopt_spectra
          base_vopt_err=verr_spectra
          base_vopt_avepsd=vopt_avepsd
          base_vopt_psderror=vopt_psderror
          base_vopt_psd_fitparams=psd_fitparams
          base_vopt_corr=vopt_corr
      endif else if iters[iter] eq 'MS' then begin
          MS_decorr_vopt_spectra=vopt_spectra
          MS_decorr_vopt_err=verr_spectra
          MS_decorr_vopt_avepsd=vopt_avepsd
          MS_decorr_vopt_psderror=vopt_psderror
          MS_decorr_vopt_psd_fitparams=psd_fitparams
          MS_decorr_vopt_corr=vopt_corr
      endif else if iters[iter] eq 'PCA' then begin
          PCA_decorr_vopt_spectra=vopt_spectra
          PCA_decorr_vopt_err=verr_spectra
          PCA_decorr_vopt_avepsd=vopt_avepsd
          PCA_decorr_vopt_psderror=vopt_psderror
          PCA_decorr_vopt_psd_fitparams=psd_fitparams
          PCA_decorr_vopt_corr=vopt_corr
      endif else begin
          both_decorr_vopt_spectra=vopt_spectra
          both_decorr_vopt_err=verr_spectra
          both_decorr_vopt_avepsd=vopt_avepsd
          both_decorr_vopt_psderror=vopt_psderror
          both_decorr_vopt_psd_fitparams=psd_fitparams
          both_decorr_vopt_corr=vopt_corr
       endelse

       
   endfor                       ;Decorr iterations

   vopt_spectra=base_vopt_spectra
   verr_spectra=base_vopt_err
   vopt_avepsd=base_vopt_avepsd
   vopt_psderror=base_vopt_psderror
   psd_fitparams=base_vopt_psd_fitparams



writesav:savefile = file+'_spec.sav'
print,'File saved as '+ savefile
if bad then begin
save,badflag,filename=savefile
goto,outa
endif
vopt_flags = TRANSPOSE(vopt.nod.pos.flag)
verr_flags = TRANSPOSE(verr.nod.pos.flag)

SAVE, vopt_spectra, verr_spectra, nod_struct, chop_struct, $
  vopt_avepsd, verr_avepsd, theta_opt, phi_struct, $
  samp_int, avebias, pos_length, vopt_flags, verr_flags, $
  nco,nbolos,n_nods,bolos,snu,serr,nu,$
  n_sec,$
  vopt_psderror,$
  psd_fitparams,$
  inttime,nnf,$
  nc_ticks, nc_elevation, nc_pwv, $
  vdc, $
  bolo_flags,$
  nc_tbath,$
  rel_phase,badflag, decorr_coeffs, decorr_timestreams,$
  vopt_corr,chopper_spectra, chopper_error,$
  both_decorr_vopt_spectra,both_decorr_vopt_err,both_decorr_vopt_avepsd,$
  both_decorr_vopt_psderror,both_decorr_vopt_psd_fitparams,$
  PCA_decorr_vopt_spectra, PCA_decorr_vopt_err,PCA_decorr_vopt_avepsd,$
  PCA_decorr_vopt_psderror,$
  MS_decorr_vopt_spectra, MS_decorr_vopt_err,MS_decorr_vopt_avepsd,$
  MS_decorr_vopt_psderror, MS_decorr_vopt_psd_fitparams,$
  FILENAME = savefile           ;, /VERBOSE

; chop_fac,$
;        rpc_params,filt_coeffs,$
;        bolo_flags,$
;        downfac,$
        
  savefile = file+'_vdc.sav'
  vbolo_quad = vdc
  quadflags = flags
  save,file=savefile,vbolo_quad,quadflags

  IF KEYWORD_SET(SAVE_TS) THEN BEGIN
     SAVE,vopt,verr,vr,vi, $
          FILENAME = change_suffix(file,'_slicedts.sav');,/VERBOSE
     zipped_ts=change_suffix(file,'_slicedts.sav.gz')
     test=file_search(zipped_ts)
     if test eq zipped_ts then spawn,'rm '+zipped_ts     
   ENDIF

   if keyword_set(save_all) then begin
       save, vopt, verr, chop_struct, chop_enc, $
     filename=change_suffix(file, '_alldata.sav')

   endif

;;;  ;gzip the netCDF file
;;;  if waszipped eq 1 then spawn,'gzip '+file
;;;
   savefile = file+'_spec.sav'
 outa: RETURN, savefile
END
