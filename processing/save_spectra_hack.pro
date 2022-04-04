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
; the spectra.  The structure rpc_params has many tags of telescope data
; with about one sample per second.
;
; If DEGLITCH is set, then a deglitch pass is performed.  If PSD is set then
; an average PSD for each bolometer is calculated (averaged over nod & position)
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FUNCTION save_spectra_hack, file, rel_phase, $
                       DEGLITCH = DEGLITCH, $
                       SAVE_TS = SAVE_TS,$
                       DOWNFAC = DOWNFAC

;look for netCDF file or zipped netCDF file
;  waszipped=0
;  file = get_ncdfpath(year,month,night,obsnum)
;  zippedfile = file+'.gz'
;  maligned = file_search(file)
;  zipped = file_search(zippedfile)

;  if maligned eq '' and zipped eq zippedfile then begin
;     print,'Gunzipping....'
;     spawn,'gunzip '+zippedfile
;     waszipped=1
;  endif

;read from netCDF file
  PRINT, 'reading from:'
  PRINT, file
  PRINT, 'Reading Flags'
  nodding = byte(read_ncdf(file,'nodding'))


  on_beam = byte(read_ncdf(file,'on_beam'))
  off_beam = byte(read_ncdf(file,'off_beam'))
  acquired = byte(read_ncdf(file,'acquired'))
  PRINT, 'Reading Chopper Encoder'
  chopper = read_ncdf(file,'chop_enc')
  PRINT, 'Reading Bias'
  bias = get_bias(file)
  samp_int = find_sample_interval(read_ncdf(file,'ticks'))
  avebias = MEAN(bias)
  PRINT, 'Average Bias Voltage = ', avebias*1000, $
         ' mV, Bias Freqency = ', 2.0/samp_int, ' Hz'

  PRINT, 'Reading LIA outpus'
  vr_raw = read_ncdf(file,'sin')
  vi_raw = read_ncdf(file,'cos')
  PRINT, 'Extracting Optical Channels'
 ;; CASE 1 OF
 ;     month EQ 4 AND year EQ 2006:BEGIN
 ;         bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr06.txt'
 ;     END
 ;     month EQ 12 AND year EQ 2006:BEGIN
 ;         bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_dec06.txt'
 ;     END
 ;     month EQ 1 AND year EQ 2007:BEGIN
 ;         bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_dec06.txt'
 ;     END
 ;     month EQ 4 AND year EQ 2007:BEGIN
 ;         bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
 ;     END
 ;     month EQ 5 AND year EQ 2007:BEGIN
 ;         bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
 ;     END
 ;     month EQ 11 AND year EQ 2007:BEGIN
 ;         bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
 ;     END
 ;     month EQ 12 AND year EQ 2007:BEGIN
 ;         bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
 ;     END
 ;     year gt 2007: begin
          bc_file= !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
  ;    end
  ;    ELSE:MESSAGE,'Please define bolo_config for given month and year' 
  ;sENDCASE

  ncid = ncdf_open(file)
  ncdf_attget, ncid, 'telescope', telescope, /GLOBAL
  telescope = string(telescope) ; convert from bytes to chars
  ncdf_close, ncid

  print, telescope
  
  if telescope eq 'APEX' then begin
      vr = vr_raw
      vi = vi_raw
  endif else begin
      vr = extract_channels(vr_raw,'optical',bolo=bc_file)
      vi = extract_channels(vi_raw,'optical',bolo=bc_file)
  endelse
  delvarx, vi_raw, vr_raw

  ts_size = SIZE(vr)
  flags = REPLICATE(1,ts_size[1:2])
  nbolos = ts_size[1]

  n_sec=ts_size[2]*samp_int ;total number of seconds in observation
  	
;__________________________________________________________________
;Deglitch data first

  time_s,"Deglitching data ... ", t0
  
  if keyword_set(deglitch) then begin
      vr=datadeglitch(vr,flags,/usesigma,ave=1000,sigma=3.,/quiet)
      vi=datadeglitch(vi,flags,/usesigma,ave=1000,sigma=3.,/quiet)
  endif

  time_e,t0

;___________________________________________________________________
;The low-pass filter
  
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
;stop
nod_struct = find_onoff(find_nods(nodding),on_beam,off_beam,acquired,$
                          flags,diagnostic=change_suffix(file,'_nod_diag.ps'),vr_filt,vi_filt)
; chop_struct =  make_chop_struct(chopper,flags,sample_interval=samp_int)
; nod_struct = trim_nods(nod_struct,chop_struct.period,length=pos_length)

; time_e,t0
;stop
;____________________________________________________________________

;At this point all the data should be downsampled in a consistent way.
;Proceed with Bret's demodulation routine.
;_____________________________________________________________________

 ; PRINT, 'Slicing up data'
 ; vr_slice = slice_data(nod_struct,vr_filt,flags)
 ; vi_slice = slice_data(nod_struct,vi_filt,flags)

  PRINT, 'Finding optimum phi values'
  cline=getcline(03,2010,08);month,year,night)
  rload = get_load_resistors('optical',bolo=bc_file)
  obsstart = 0;nod_struct[0].i
  obsend = n_e(on_beam)-1;nod_struct[N_E(nod_struct)-1].f
  phi_struct = brm_obs_phifit(vr_filt[*,obsstart:obsend],$
                              vi_filt[*,obsstart:obsend],$
                              avebias,samp_int,rload,cline,$
                              2.0/(samp_int/DOWNFAC))

  phi = phi_struct.value
  opt_sigs = make_optimum_signals(vr_slice,vi_slice,phi)
  theta_opt = opt_sigs.theta_opt

  ;***Deglitching used to happen here in the original code.
  ;***Now it happens at the top.  Changed March 07 by LE.

  vopt = opt_sigs.vopt
  verr = opt_sigs.verr

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
 if rel_phase ne [0] and rel_phase ne [1] then rel_phase_size=size(rel_phase)

 ;Now what is rel_phase? There are 4 cases: 
 ;rel_phase=0 --> no correction
 ;rel_phase=1 --> find rel_phase from this observation
 ;rel_phase=3x160 array --> use this rel_phase
 ;rel_phase=.sav file containing rel_phase --> restore file and use rel_phase

      case 1 of 
          rel_phase eq [0]:begin
              rel_phase=dblarr(3,nbolos)
          end
          rel_phase eq [1]:begin
              print, 'Finding and saving chopper to bolometer phase.'
              rel_phase=find_chop_bolo_phase3(nod_struct,vopt,chop_struct,$
                                              nloops=3)
              save,rel_phase,file=change_suffix(file,'_chopphase.sav');,/verbose
          end
          rel_phase_size[0] eq 0 and rel_phase_size[1] eq 7:begin
              rel_date=''
              reads,rel_phase,rel_date,format='(a8)'
              rel_phase=!zspec_data_root+'/ncdf/'+strcompress(rel_date)+$
                '/'+rel_phase
              print,'Using rel_phase defined in:'
              print, rel_phase
              restore, rel_phase
          end
          rel_phase_size[0] eq 2 and rel_phase_size[1] eq 3 $
            and rel_phase_size[2] eq nbolos:begin
          end
          else:begin
              print,'Your rel_phase request is confusing.'
              stop
          endelse
      endcase         
         
 ;IF N_E(rel_phase) EQ 1 THEN BEGIN
;      IF rel_phase EQ 0 THEN BEGIN
;        rel_phase = DBLARR(3,nbolos)
;      ENDIF ELSE BEGIN
;        PRINT, 'Finding and saving chopper to bolometer phase'
;        rel_phase = find_chop_bolo_phase3(nod_struct,vopt,chop_struct,$
;                                         NLOOPS = 3)
;       SAVE, rel_phase, FILE = change_suffix(file,'_chopphase.sav'), /VERBOSE
;      ENDELSE 
;ENDIF

;___________________________________________________________________

  sliced_chop = $
     make_phased_sliced_chop(nod_struct,chop_struct,rel_phase)
  vopt_spectra = $
     demod_and_diff3(nod_struct,vopt,sliced_chop,$
                     /CHOP_PRECOMPUTE)
  verr_spectra = $
     demod_and_diff3(nod_struct,verr,sliced_chop,$
                     /CHOP_PRECOMPUTE)

  estimate_spec_err, vopt_spectra
  estimate_spec_err, verr_spectra

; Create some additional variables for compatibility with functions that
; used to work with output from npt_obs
  bolos = INDGEN(nbolos)
  n_nods = N_ELEMENTS(nod_struct)
  nu = freqid2freq(bolos)
  nco = WHERE(ABS(nu-230.) EQ MIN(ABS(nu-230.)))
  snu = vopt_spectra.in1.nodspec
  serr = vopt_spectra.in1.noderr

  PRINT, 'Reading bolo_flags'
  bolo_flags = read_ncdf(file,'bolo_flags')

  time_s, 'Reading in RPC Files ... ',t0
  rpc_params = get_rpc_params(year,month,night,obsnum,/ALL_PARAMS,/quiet)
  time_e,t0

  zipped_spectra=change_suffix(file,'_spectra.sav.gz')
  test=file_search(zipped_spectra)
  if test eq zipped_spectra then spawn,'rm '+zipped_spectra

;_____________________________________________________________________
;following modified 2008-03-05 by LE
;removed the "if" statement so that vopt_psderror is always computed

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
    psd_fitparams=plot_psds(vopt_avepsd,change_suffix(file,'_psds.ps'),chop=chopfreq)
;endif

;compute a multiplicative factor to scale the amplitude to
;account for lost signal due to faster chop frequencies
chop_fac=chopper_ineff_factor(chopfreq)

;check if there's a zipped version of _spectra.sav, and remove if
;there is to avoid confusion with old demodulations
  zipped_spectra=change_suffix(file,'_spectra.sav.gz')
  test=file_search(zipped_spectra)
  if test eq zipped_spectra then spawn,'rm '+zipped_spectra


  savefile = change_suffix(file,'_spectra.sav')
  vopt_flags = TRANSPOSE(vopt.nod.pos.flag)
  verr_flags = TRANSPOSE(verr.nod.pos.flag)
  SAVE, vopt_spectra, verr_spectra, nod_struct, chop_struct, $
        vopt_avepsd, verr_avepsd, theta_opt, phi_struct, $
        samp_int, avebias, pos_length, vopt_flags, verr_flags, $
        nco,nbolos,n_nods,bolos,snu,serr,nu,$
        rpc_params,filt_coeffs,$
        bolo_flags,$
        downfac,n_sec,$
        vopt_psderror,$
        psd_fitparams,$
        inttime,nnf,chop_fac,$
        FILENAME = savefile;, /VERBOSE
        
  IF KEYWORD_SET(SAVE_TS) THEN BEGIN
     SAVE,vopt,verr,vr,vi,$
          FILENAME = change_suffix(file,'_slicedts.sav');,/VERBOSE
     zipped_ts=change_suffix(file,'_slicedts.sav.gz')
     test=file_search(zipped_ts)
     if test eq zipped_ts then spawn,'rm '+zipped_ts     
   ENDIF

  ;gzip the netCDF file
  if waszipped eq 1 then spawn,'gzip '+file

  RETURN, savefile
END
