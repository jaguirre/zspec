pro npt_obs, file, bolo_phase_file = bolo_phase_file

;Routine to process any form of npt-observation with Z-Spec (five-pt,
;focus, map, etc.)
;
;version of 8/16/2005 (PRM)
;
;Modified so that npt_obs:
;
;(1) ensures that an integral number of chops are contained in each
;    piece of the nod cycle
;(2) sets the mean of the bolometer signals to zero;
;(3) does a proper phase correction between the bolometer and chopper
;    signals, rather than the approximate cosine correction used in the
;    engineering run;
;(4) figures out the length of the chop (in samples) from the data;
;(5) uses the "ticks" parameter to figure out what the sampling rate
;    was; 
;(6) if the acquisition signal is lost once in one of the on-beams
;    and/or in the off-beams, the data will be patched together (using
;    the chopper signal to ensure continuity). At present, the routine
;    can't handle losing the acquisition signal in both of the
;    on-beams: only the first one will be properly patched together.

if not(keyword_set(bolo_phase_file)) then $
  bolo_phase_file=getenv('HOME')+'/zspec_svn/processing/chop_phase_z.dphi'

nbolos=160
bolos=indgen(nbolos)
nu=fltarr(nbolos)

; name extraction assumes file name format is: date_obsnum_source_raw.nc
namearr=strsplit(file,'_',/extract)
outfile=STRING(strjoin(namearr[0:2],'_')+'.sav')
print,outfile

; get sampling rate from ticks
ticks=read_ncdf(file,count=1001,'ticks')
samp=0.0
ntick=n_elements(ticks)
for n=1,1000 do begin
    samp=ticks(n)-ticks(n-1)+samp
endfor
samp=samp/1000
print,'Sample rate = ',1./samp,' Hz'
angcon=5.729578d1

; get the nodding signal, the azimuth and elevation offsets, and the
; focus offsets
observing = read_ncdf(file,'observing')
nodding=read_ncdf(file,'nodding')
azoff=read_ncdf(file,'azimuth_offset')
eloff=read_ncdf(file,'elevation_offset')
focus_val=read_ncdf(file,'secondary_mirror_focus_offset')

; We'll read in the bolo_flags to pass along, but just process
; everything (except that phase corrections are not made to bad bolos)
bolo_flags = read_ncdf(file,'bolo_flags')
goodbolos=where(bolo_flags eq 1)
ngoodbolos=n_elements(goodbolos)
bolos=bolos[goodbolos]

; bolometer/chopper phases
; Modified the first variable read, which was "bolos", to be
; "bolo_nums", because we save bolos at the end.
readcol,bolo_phase_file,format='(i,f,f,f)',bolo_nums,phi1,phi3,phi5

; find out how many nods there were from the nodding signal
nod_trans=find_transitions(nodding)
n_trans_start=n_elements(nod_trans.rise)
n_trans_end=n_elements(nod_trans.fall)
; these had better be the same!
if(n_trans_start eq n_trans_end) then begin
    n_nods=n_trans_start
endif else begin
    print, 'Unequal number of nod starts and ends!'
    stop
endelse

; determine the widths of the nods and the offsets for handling the
; data by nods
nod_width=nod_trans.fall-nod_trans.rise
c_off=lonarr(n_nods)
c_off=nod_trans.rise

; azimuth and elevation and focus offsets; the latter will be constant
; for a 5-pt observation, while the former will be constant for a
; focus observation
; the x and y (az and el) offsets: go part way into the nod just to
; avoid any transitions
xoff=azoff[nod_trans.rise+0.1*nod_width]
yoff=eloff[nod_trans.rise+0.1*nod_width]
; focus offsets
focus_offset=focus_val[nod_trans.rise+0.1*nod_width]

; set up arrays for demodulated signals
demod_nods = fltarr(ngoodbolos,n_nods)
on_beam_demod = fltarr(ngoodbolos,n_nods)
off_beam_demod = fltarr(ngoodbolos,n_nods)
snu=fltarr(nbolos,n_nods)
serr=fltarr(nbolos,n_nods)

; grab the data just one nod-set (LRRL or on-off-off-on) at a time
for i=0,n_nods-1 do begin

; sample offsets for signals
    c_offset=c_off[i]
    b_offset=[0,c_offset]

; sample counts for 1-d (e.g., chopper) and 2-d (bolo) variables
    c_count=nod_width[i]
    b_count=[nbolos,nod_width[i]]

; get logic signals
    acquired=read_ncdf(file,count=c_count,offset=c_offset,'acquired')
    on_beam=read_ncdf(file,count=c_count,offset=c_offset,'on_beam')
    off_beam=read_ncdf(file,count=c_count,offset=c_offset,'off_beam')

; get chopper data
    chop_enc=read_ncdf(file,count=c_count,offset=c_offset,'chop_enc')

; get bolometer data
    ac_bolos=read_ncdf(file,count=b_count,offset=b_offset,'ac_bolos')

; Set the mean of all bolometer signals to zero (this step should not(?)
; be necessary once high-pass filtering has been implemented)
    bolo_ave=total(ac_bolos,2)/n_elements(chop_enc)
    bolo_temp=bolo_ave#(replicate(1.,n_elements(chop_enc)))
    ac_bolos=ac_bolos-bolo_temp

; phase correction
    nstot=c_count
    n21=(nstot)/2+1
    m=(lindgen(nstot)-(nstot/2-1))
    f=m/(nstot*samp)
    tau=phi1/(2.*!pi)/angcon#replicate(1.,c_count)
    arg=COMPLEX(0.,2.*!pi*replicate(1.,ngoodbolos)#f*tau)
    phi_func=EXP(-arg)
    ac_bolos_corr=ac_bolos
    ac_bolo_fft=FFT(ac_bolos[goodbolos,*],dimension=2)
    ac_bolo_fft_corr=SHIFT(ac_bolo_fft,0,-n21)*phi_func
    ac_bolo_fft_corr=SHIFT(ac_bolo_fft_corr,0,n21)
    ac_bolos_corr[goodbolos,*]=DOUBLE(FFT(ac_bolo_fft_corr,/inverse,$
                                          dimension=2))

    sig=ac_bolos_corr

; Normalize the chopper signal to +/- 0.5
    chop_ave=total(chop_enc)/n_elements(chop_enc)
    chop=chop_enc-chop_ave
    chmax=max(chop)
    chop=chop/(2.*chmax)

; Figure out the length of a chopper cycle from the data
; This is done using a square version of the chopper signal, finding
; the rises and falls, and then differencing them. First try just the
; first two pairs; if there is a discrepancy between these numbers,
; then the routine uses all of the chopper data to get an average
; value. Unless something really strange is going on, the rise and
; fall averages should agree
    squarechop = FLTARR(N_ELEMENTS(chop))
    squarechop[WHERE(chop GE 0.0)] = 1.0
    choptrans = find_transitions(squarechop)

;  Sometimes even the first two pairs will agree, yet be incorrect, so
;  for now always average over the whole timestream to get length.
;    nl_chop1a=choptrans.rise[1]-choptrans.rise[0]
;    nl_chop2a=choptrans.fall[1]-choptrans.fall[0]
;    nl_chop1b=choptrans.rise[1]-choptrans.rise[0]
;    nl_chop2b=choptrans.fall[1]-choptrans.fall[0]
;    if(nl_chop1a EQ nl_chop2a AND nl_chop1b eq nl_chop1a AND $
;      nl_chop2b EQ nl_chop2a) then begin 
;        nl_chop=nl_chop1a
;        print, 'chop cycle length = ',nl_chop,' samples'
;    endif else begin
;        print, 'Found a discrepancy in chop cycle length:'
        print, 'Using average over all chopper data to get chop length'
        nl_chop1=0
        for n=1,n_elements(choptrans.rise)-1 do begin
            nl_chop1=choptrans.rise[n]-choptrans.rise[n-1]+nl_chop1
        endfor
        chop1_test=FLOAT(nl_chop1)/(n_elements(choptrans.rise)-1)
        nl_chop1=nl_chop1/(n_elements(choptrans.rise)-1)
        if(chop1_test GT FLOAT(nl_chop1)) then nl_chop1=nl_chop1+1
        nl_chop2=0
        for n=1,n_elements(choptrans.fall)-1 do begin
            nl_chop2=choptrans.fall[n]-choptrans.fall[n-1]+nl_chop2
        endfor
        chop2_test=FLOAT(nl_chop2)/(n_elements(choptrans.fall)-1)
        nl_chop2=nl_chop2/(n_elements(choptrans.fall)-1)
        if(chop2_test GT FLOAT(nl_chop2)) then nl_chop2=nl_chop2+1
        if(nl_chop1 EQ nl_chop2) then begin 
            nl_chop=nl_chop1
            print, 'Adopted chop cycle length = ',nl_chop,' samples'
        endif else begin
            print, 'Mysterious discrepancy between chopper rises and falls'
            nl_chop=MIN(nl_chop1,nl_chop2)
            print, 'Using smaller of the two values'
            print, 'Adopted chop cycle length = ',nl_chop,' samples'
        endelse
;    endelse

; Now figure out where the on-beam and off-beam data are. We use the
; length of the chopper cycle determined above to ensure that we have
; an integral number of chops in each part of the nod cycle, so that
; we are not producing any offsets due to incomplete cycles when we do
; the demodulation. This is slightly trickier for the on-beams, since
; these are broken into two pieces in a LRRL nodding scheme.
    on_beams_pretrim=where(on_beam eq 1 and acquired eq 1)
    off_beams_pretrim=where(off_beam eq 1 and acquired eq 1)
    nsamp_on=n_elements(on_beams_pretrim)
    nsamp_off=n_elements(off_beams_pretrim)

; We need to know where the on-beams are:
    on_beam_trans=find_transitions(on_beam*acquired)
    on_trans=find_transitions(on_beam)
    off_trans=find_transitions(off_beam)
    off_beam_trans=find_transitions(off_beam*acquired)

; If there is only one rise and fall, then we are starting on and
; ending on, and so the important samples are just the end of the
; first on-beam and the start of the second on-beam
    if(n_elements(on_beam_trans.rise) eq 1 AND $
       n_elements(on_beam_trans.fall eq 1)) then begin
        nbeam1=on_beam_trans.fall[0]
        nbeam2=nsamp_on-nbeam1
    endif else begin
; We can run into trouble here: there may be more than one rise and
; fall because we didn't start on, OR because the acquisition signal 
; was lost at some point during an on-beam. 
;   if the first on_beam*acq fall is identical to the first on_beam
;   fall, then this should just mean that we didn't start on. In this
;   case we should also always have that the first fall exceeds the
;   first rise. However, this still leaves the possibility that the
;   acquisition signal was lost in the second on-beam.
        if(on_trans.fall[0] eq on_beam_trans.fall[0] and $
           on_beam_trans.fall[0] gt on_beam_trans.rise[0]) then begin
            nbeam1=on_beam_trans.fall[0]-on_beam_trans.rise[0]
            nbeam2=nsamp_on-nbeam1
        endif else if (on_beam_trans.fall[0] lt on_trans.fall[0]) then begin
;   if the above if statement is satisfied but the preceding one was
;   not then we must have lost the acquisition signal in the first
;   on-beam, so we need to patch the segment prior to the loss to the
;   segment after re-acquisition 
            n_end=on_beam_trans.fall[0]-1
            n_end1=on_beam_trans.fall[1]-1
            n_start=on_beam_trans.rise[0]
            nbeam1=on_beam_trans.fall[1]-(n_start-n_end)+1
            on_beam1_temp=on_beams_pretrim[0:n_end]
            test=ABS(chop[on_beams_pretrim[n_start:n_start+50]] $
                     -chop[on_beams_pretrim[n_end]])
            dmin=min(test,nmatch)
            nmatch=nmatch+n_start
            on_beam1_temp=[on_beam1_temp,on_beams_pretrim[nmatch:nbeam1]]  
            on_beam2_temp=[on_beams_pretrim[nbeam1:*]]
            on_beams_pretrim=[on_beam1_temp,on_beam2_temp]
            nbeam1=n_elements(on_beam1_temp)
            nsamp_on=nsamp_on-(nmatch-n_start)
            nbeam2=nsamp_on-nbeam1
;            n_arg=where(on_beam_trans.fall eq on_trans.fall[0])
;            nbeam1=on_beam_trans.fall[n_arg]
        endif else begin
;   if not, did we lose the acquisition signal in the second on-beam? 
            nb_2a=where(on_beam_trans.rise gt off_trans.fall[0])
            nb_2b=where(on_beam_trans.fall gt off_trans.fall[0])
            narg_2=n_elements(nb_2a)
            if(narg_2 eq 2) then begin
                n_ref=on_beam_trans.fall[0]
                n_start=on_beam_trans.rise[nb_2a[0]]
                n_end=on_beam_trans.fall[nb_2b[0]]-1-n_start+n_ref
                n_start2=on_beam_trans.rise[nb_2a[1]]-n_start+n_ref
                n_end2=n_elements(on_beams_pretrim)-1
                on_beam2_temp=on_beams_pretrim[n_ref:n_end]
                test=ABS(chop[on_beams_pretrim[n_start2:n_start2+50]] $
                     -chop[on_beams_pretrim[n_end]])
                dmin=min(test,nmatch)
                nmatch=nmatch+n_start2
                on_beam1_temp=on_beams_pretrim[0:n_ref-1]
                on_beam2_temp=on_beams_pretrim[n_ref:n_end]
                on_beam2_temp=[on_beam2_temp,on_beams_pretrim[nmatch:n_end2]]
                nbeam2=n_elements(on_beam2_temp)
                on_beams_pretrim=[on_beam1_temp,on_beam2_temp]
                nsamp_on=nsamp_on-(nmatch-n_start2)-(n_start2-n_end)+1
                nbeam1=nsamp_on-nbeam2
            endif else begin
;     if not, something really weird must be happening
                print, 'Cannot make sense of where the on-beams are: '
                print, 'Maybe you should look at the logic signals? '
                break
            endelse
        endelse
    endelse

; Determine the integral number of chops that fit into each on-beam,
; and size them accordingly
    nchop1=nbeam1/nl_chop
    nchop2=nbeam2/nl_chop
    nsamp_on1=nchop1*nl_chop
    nsamp_on2=nchop2*nl_chop
    on_beam1=on_beams_pretrim[0:nsamp_on1-1]
    on_beam2=on_beams_pretrim[nbeam1:nbeam1+nsamp_on2-1]
    on_beams=[on_beam1,on_beam2]

; for the off-beams this is easy, since they are already conjoined
; However, we may have lost the acquisition signal here also
    if(n_elements(off_beam_trans.rise eq 1)) then begin
        nchop_off=(n_elements(off_beams_pretrim-1))/nl_chop
        nsamp_off=nchop_off*nl_chop
        off_beams=off_beams_pretrim[0:nsamp_off-1]
    endif else begin
        n_ref=off_beam_trans.rise[0]
        n_end=off_beam_trans.fall[0]-1-n_ref
        n_start=off_beam_trans.rise[1]-n_ref
        off_beams_temp=off_beams_pretrim[0:n_end]
        test=ABS(chop[off_beams_pretrim[n_start:n_start+50]] $
                 -chop[off_beams_pretrim[n_end]])
        dmin=min(test,nmatch)
        nmatch=nmatch+n_start
        off_beams_temp=[off_beams_temp,off_beams_pretrim[nmatch:*]]
        nchop_off=(n_elements(off_beams_temp-1))/nl_chop
        nsamp_off=nchop_off*nl_chop
        off_beams=off_beams_temp[0:nsamp_off-1]
    endelse

; Demodulate and integrate
; Had to change this syntax because IDL is stupid
    temp = (replicate(1.,ngoodbolos)#chop[on_beams]) * $
      (sig[goodbolos,*])[*,on_beams]
;      sig[goodbolos,on_beams]
    on_beam_demod[*,i] = total(temp,2)/nsamp_on

; Demodulate and integrate
    temp = (replicate(1.,ngoodbolos)#chop[off_beams]) * $
      (sig[goodbolos,*])[*,off_beams]
;      sig[goodbolos,off_beams]
    off_beam_demod[*,i] = total(temp,2)/nsamp_off

; Difference (note additional factor of 0.5 to get correct signal amplitude)
; Note sign change after phase correction!
    demod_nods[*,i] = -(on_beam_demod[*,i] - off_beam_demod[*,i])/2.

endfor

snu=demod_nods

; Where is the CO line?
nco = where(abs(bolo2freq(bolos)-230.) eq min(abs(bolo2freq(bolos)-230.)))
nu = bolo2freq(bolos)

; Set flux errors to unity, since we don't have any yet
serr[*]=1.0

save,filename=outfile,$
  nco,nbolos,n_nods,bolos,snu,serr,nu,xoff,yoff,focus_offset,bolo_flags


end
