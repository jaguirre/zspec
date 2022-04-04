file = get_ncdfpath_Apr06(16,11)

bc_file = !zspec_pipeline_root + '/file_io/bolo_config_apr06.txt'

nbolos = 160
diag_chan = 62

;read = 1
read = 0
if (read) then begin

   nodding = read_ncdf(file,'nodding')
   on_beam = read_ncdf(file,'on_beam')
   off_beam = read_ncdf(file,'off_beam')
   acquired = read_ncdf(file,'acquired')
   chopper = read_ncdf(file,'chop_enc')
;ac_bolos = read_ncdf(file,'ac_bolos')
   out_lia = read_ncdf(file,'cos')
   in_lia= read_ncdf(file,'sin')

   ntod = n_e(nodding)

   ac_bolos = extract_channels(out_lia,in_lia,'optical',bolo=bc_file)
   out_lia = extract_channels(out_lia,'optical',bolo=bc_file)
   in_lia = extract_channels(in_lia,'optical',bolo=bc_file)
endif

; Make a variable of flags to keep track of where things are no good
flags = REPLICATE(1,nbolos,ntod)

nod = find_onoff(find_nods(nodding),on_beam,off_beam,acquired,$
                 flags,diagnostic=change_suffix(file,'nod_diag.ps'))


; Create clean chopper waveform structure
chop = make_chop_struct(chopper,flags)

; Create separate flag varibles for quad, in & out lock-in phases
flags_quad = flags
flags_in = flags
flags_out = flags

; Deglitch before slicing up timestreams
deglitch = 0
IF deglitch THEN BEGIN
   ac_bolos = datadeglitch(ac_bolos,flags_quad,/USESIGMA)
   in_lia = datadeglitch(in_lia,flags_in,/USESIGMA)
   out_lia = datadeglitch(out_lia,flags_out,/USESIGMA)
ENDIF

; Trim nods & slice up data
nod = trim_nods(nod,chop.period,length=nod_length)
channel_quad = slice_data(nod,ac_bolos,flags_quad)
channel_in_lia = slice_data(nod,in_lia,flags_in)
channel_out_lia = slice_data(nod,out_lia,flags_out)

; Do polynomial subtraction
degree = 1 ; degree of polynomial to subtract (if 0, then subtract mean)
poly_subtract, channel_quad, POLY_DEG = degree
poly_subtract, channel_in_lia, POLY_DEG = degree
poly_subtract, channel_out_lia, POLY_DEG = degree

; Calculate psds
psd_on = 0
IF psd_on THEN BEGIN
   samp_int = find_sample_interval(read_ncdf(file,'ticks'))
   psd_calc, channel_quad, samp_int
   psd_calc, channel_in_lia, samp_int
   psd_calc, channel_out_lia, samp_int

; Average all nod position PSDs together
   avgpsd_quad = psd_ave(channel_quad)
   avgpsd_in_lia = psd_ave(channel_in_lia)
   avgpsd_out_lia = psd_ave(channel_out_lia)
ENDIF

t = SYSTIME(1)

;rel_phase = find_chop_bolo_phase(nod, channel_quad,chopper,chop.period)
demods = demodulate(nod,channel_quad,chopper,$
                    chop.period);,rel_phase = rel_phase)

spectra = (-demods.demod_in[*,*,0]+demods.demod_in[*,*,1]+$
           demods.demod_in[*,*,2]-demods.demod_in[*,*,3])/4.

spectra_out = (-demods.demod_out[*,*,0]+demods.demod_out[*,*,1]+$
               demods.demod_out[*,*,2]-demods.demod_out[*,*,3])/4.

del_t = SYSTIME(1) - t
PRINT, 'Old processing used ', STRING(del_t,F='(F0.2)'), ' seconds'

; If we reset the flags to be all unity, demods & demods2 should be the same
;channel_quad.nod.pos.flag = 1

t2 = SYSTIME(1)

;rel_phase2 = find_chop_bolo_phase2(nod,channel_quad,chop)
spectra2 = demod_and_diff(nod,channel_quad,chop);,REL_PHASE = rel_phase2)

del_t2 = SYSTIME(1)-t2
PRINT, 'New processing used ', STRING(del_t2,F='(F0.2)'), ' seconds'

nnods = N_E(nod)
freqs = bolo2freq(FINDGEN(nbolos))
PLOT, freqs, TOTAL(spectra,2)/nnods, /ylog, yrange = [1e-8,1e-4]
OPLOT, freqs, TOTAL(spectra_out,2)/nnods, COLOR = 2
OPLOT, freqs, TOTAL(spectra2.in,2)/nnods, COLOR = 3
OPLOT, freqs, TOTAL(spectra2.out,2)/nnods, COLOR = 4

END
