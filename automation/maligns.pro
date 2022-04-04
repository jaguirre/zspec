
;_________________________________________________________________
;updated 2007-05-02 LE 
;
;Refers to the appropriate bolo_config_file based on the date of
;observation

;_________________________________________________________________
;updated 2007-04-03 LE

;If it can't find a bze file with the minute # correponding to what
;obs_def is looking for, it will go back one minute at a time (up to
;three minutes) to try and find the correponding bze file, eliminating
;the need to create a softlink in the bze/YYYYMMDD/ directory to point
;to the right data.  If there is no bze file with a minute stamp
;within that range it will print a message saying so and the skip to
;the end.
;
;Also it will check for and gunzip any zipped files as needed.
;_________________________________________________________________


; Improvements:
; Need header which includes simple things:
; epoch
; source RA/Dec
; Source name

; Sample rate!!!!

; Should have just one UTC

; Flags should be named as such

; Don't need rotator information

; Will need to have the date and minutes for a given observation
; specified.  This is a bit of a task all by itself.

pro maligns, date, obs_num, new = new, plot = plot, onebze = onebze

;___________________________________________________________________
;this section modified 2007-05-02 LE

;get year and month out of date
  datestring=strcompress(date,/rem)
  obsyear=0L & obsmonth=0L & obsnight=0L
  reads,datestring,obsyear,obsmonth,obsnight,format='(i4,i2,i2)'

;call up the correct bolo_config file
case 1 of
    obsmonth eq 4 and obsyear eq 2006:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr06.txt'
    end
    obsmonth eq 12 and obsyear eq 2006:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_dec06.txt'
    end
    obsmonth eq 1 and obsyear eq 2007:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_dec06.txt'
    end
    obsmonth eq 4 and obsyear eq 2007:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
    end
    obsmonth eq 5 and obsyear eq 2007:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
    end
    obsmonth eq 11 and obsyear eq 2007:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
    end
    obsmonth eq 12 and obsyear eq 2007:begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
    end
    obsyear ge 2008 and obsyear lt 2014 :begin
        bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
     end
; Default was to always use the april07 bolo_config (at least until we open the
; cryostat again) April 2007 - October 2014.  We did not change the
;                              configuration for APEX.  However, after
;                              2014, we should be using the new one
;                              that reflects the changes Matt made in
;                              early 2014.  
    else:  $
       bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_oct14.txt'
;       bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'
;message,'Tell me which bolo_config to use!'
endcase
;___________________________________________________________________

obs_num_str = make_padded_num_str(obs_num,3)
source_name = ''
sample_rate = 50.

; Up to 20050607
;chop_box = 9
;chop_chan = 19
; 20050608 and After
;chop_box = 0
;chop_chan = 21
; April 06 science run
chop_box = 9
chop_chan = 18

; Modified 6 Apr 07 (JA) to conform to the standard convention for
; finding data files.
rpc_root = !ZSPEC_DATA_ROOT+'/rpc/'+date+'/'+date+'_'
plog_root =!ZSPEC_DATA_ROOT+'/plog/'+date+'/'+date+'_'
bze_root = !ZSPEC_DATA_ROOT+'/bze/'+date+'/'+date+'_'
ncdf_dir = !ZSPEC_DATA_ROOT+'/ncdf/'+date+'/'

obsnum_file = 0L
obsmin = lonarr(2)
obssamp = lonarr(2)
utc = dblarr(2)

;_________________________________________________________________
obs_def_filename=ncdf_dir+obs_num_str+'_obs_def.txt'
zipped_name=obs_def_filename+'.gz'
obs_def_test=file_search(zipped_name)
if (obs_def_test eq zipped_name) then $
  spawn,'gunzip '+zipped_name
;_________________________________________________________________

openr,lun,obs_def_filename,/get_lun

readf,lun,obsnum_file,format='(I10)'
readf,lun,obsmin,format='(2I10)'
readf,lun,obssamp,format='(2I10)'
readf,lun,utc,format='(2D10.2)'

close,lun
free_lun,lun

; Gotta get this from somewhere ...
nbox = 10

min = obsmin[0]

; Get PLOG, RPC, and BZE data 

; Make up the filenames.  Yet another little task.
;rpc_files = ['']
plog_files = ['']
bze_files = ['']
minstr = ''
firstmin=min
while (min le obsmin[1]) do begin
    
    minstr = strcompress(min,/rem)
    if (min lt 1000) then minstr = '0'+strcompress(min,/rem)
    if (min lt 100) then minstr = '00'+strcompress(min,/rem)
    if (min lt 10) then minstr = '000'+strcompress(min,/rem)
    
;    rpc_files = [rpc_files,rpc_root+minstr+'_rpc.bin']
    plog_files = [plog_files,plog_root+minstr+'_plog.bin']
    bze_files = [bze_files,bze_root+minstr+'_bze.bin']

    min = min+1
    
endwhile

bolo_flags = $
  get_bolo_flags(bolo_config_file=bolo_config_file)

;rpc_files = rpc_files[1:*]
plog_files = plog_files[1:*]
bze_files = bze_files[1:*]

;_____________________________________________________________
;check to see if any of the plog or bze files need to be gunzipped
;first

for i=0,n_e(plog_files)-1 do begin
    zipped_file=plog_files[i]+'.gz'
    test=file_search(zipped_file)
    if (test eq zipped_file) then spawn,'gunzip '+zipped_file
endfor

for i=0,n_e(bze_files)-1 do begin
    zipped_file=bze_files[i]+'.gz'
    test=file_search(zipped_file)
    if (test eq zipped_file) then spawn,'gunzip '+zipped_file
endfor
;_____________________________________________________________



;rpc_data = read_rpc(rpc_files[0])
plog_data = read_plog(plog_files[0])

;______________________________________________________________
;need to check if bze file matches what obs_def calls for
;if not, go back up to 3 minutes earlier to find bze

bzemin=firstmin & delta_bzemin=0
bze_test=file_search(bze_files[0])
while (bze_test eq '' and firstmin-bzemin le 3) do begin
    delta_bzemin=delta_bzemin+1
    bzemin=firstmin-delta_bzemin
    bzeminstr = strcompress(bzemin,/rem)
    if (bzemin lt 1000) then bzeminstr = '0'+strcompress(bzemin,/rem)
    if (bzemin lt 100) then bzeminstr = '00'+strcompress(bzemin,/rem)
    if (bzemin lt 10) then bzeminstr = '000'+strcompress(bzemin,/rem)
    bze_files[0]=bze_root+bzeminstr+'_bze.bin'

; Check if the earlier file need to be decompressed
    zipped_file=bze_files[0]+'.gz'
    test=file_search(zipped_file)
    if (test eq zipped_file) then spawn,'gunzip '+zipped_file

    bze_test=file_search(bze_files[0])    
endwhile

if (bze_test eq '') then begin
    print, 'Cannot find _bze.bin file within 3 minutes'+$
      ' of the time defined by obs_def.txt.'
    print,'Cannot malign observation # '+strcompress(obs_num_str,/rem)+'.'
    goto,jump1
endif
;_____________________________________________________________


bze_data = read_bze(bze_files[0],nbox,$
                    def_file=def_file, $
                    ac_bolos = ac_bolos, $
;                    dc_bolos = dc_bolos, $
                    seq = sequ_num, $
                    sec = sec, $
                    utc = utc_bze, $
                    new = new, $
                    bolo_config_file=bolo_config_file,$
                    nframes = nframes)



seconds = sec
seq_num = sequ_num
help,nframes

ac_bolos_cos = reform(ac_bolos[0,*,*])
ac_bolos_sin = reform(ac_bolos[1,*,*])

;dc_bolos_cos = reform(dc_bolos[0,*,*])
;dc_bolos_sin = reform(dc_bolos[1,*,*])

; This part is solved, except for the questions of speed and memory
; (particularly for reading long observations)
for i=1,n_e(plog_files)-1 do begin

;    rpc_data = [rpc_data,read_rpc(rpc_files[i])]
    plog_data = [plog_data,read_plog(plog_files[i])]

    if (not(keyword_set(onebze))) then begin
        
        bze_data = [bze_data, read_bze(bze_files[i],nbox,$
                                       def_file=def_file, $
                                       ac_bolos = ac_bolos, $
;                                      dc_bolos = dc_bolos, $
                                       seq = sequ_num, $
                                       sec = sec, $
                                       new = new,$
                                       nframes = nframes)]
        
        seconds = [seconds, sec]
        seq_num = [[seq_num], [sequ_num]]
        help,nframes
        
        ac_bolos_cos = [[ac_bolos_cos],[reform(ac_bolos[0,*,*])]]
        ac_bolos_sin = [[ac_bolos_sin],[reform(ac_bolos[1,*,*])]]
        
;        dc_bolos_cos = [[dc_bolos_cos],[reform(dc_bolos[0,*,*])]]
;        dc_bolos_sin = [[dc_bolos_sin],[reform(dc_bolos[1,*,*])]] 
        
    endif

endfor

; Create a flagging variable.  This is primarily to deal with dropouts.
time_flags = replicate(1L,(size(ac_bolos))[1:2])

;; Now we've got to get these sequence numbers all lined up.
;
; Check for sequence number glitches ... still need to figure out what
; to do about it.  Apparently sequence number runs 0 to 9999 and then
; wraps.
for chk_seq = 0,nbox-1 do begin

    whskip = where(fin_diff(seq_num[chk_seq,*]) ne 1 and $
                   fin_diff(seq_num[chk_seq,*]) ne -9999)

    if (whskip[0] ne -1) then begin
        print,'Box '+strcompress(chk_seq,/rem)+'has skips at samples'
        print,whskip
; Gotta patch it, man.  The following variables all come from the bze
; file and need help: bze_data, ac_bolos, seq_num, seconds, nframes
;        for patch = 0,n_e(whskip)-1 do begin
; For each place where there's a skip, figure out how many points were
; dropped
;            print,seq_num[chk_seq,whskip[patch]]
;            stop
;            
;        endfor

    endif else begin
        message,/info,'No skips in box '+strcompress(chk_seq,/rem)
    endelse

endfor

;if (keyword_set(new)) then begin

    sample_rate = 1./mean(deglitch(fin_diff(seconds),step=0.001))
    message,/info,'Sample rate set to '+strcompress(sample_rate,/rem)+$
      ' Hz'
    wait,1

;endif

nbolos=160

; Just take quadrature now
ac_bolos = sqrt(ac_bolos_cos^2 + ac_bolos_sin^2)

; Clear memory
ac_bolos_cos = 0
ac_bolos_sin = 0

; The observation will not fill up all the minutes.  Need to have a
; where statement.
; The utc minute of the transition is now calculated by
; slice_observations, and is more accurate than using the sample
; number of the PLOG record.
utcmin = utc[0]
;obsmin[0]*60.+obssamp[0]*.01
utcmax = utc[1]
;obsmin[1]*60.+obssamp[1]*.01

; Set up a timebase.  This is kluged because I don't have a proper
; timestamp yet on the BZE ticks.  IN SECONDS.

; Here's where all the new timestamping comes in ...
; This section changed 2009/04/25 by JA to deal with a new (?) issue
; in which bzed seems to be dropping more data than usual.  It's still
; not perfect, since it determines the number of data samples expected
; from the beginning and end time stamps in the bze data (so if
; samples are dropped at the beginning or end, bad things may still
; happen), but it does a better job than the old method, which just
; took the number of points actually recorded by bzed ... if this was
; substantially less than the number of points which plog attributes
; to the observations, obviously bad things happen.

npts_recorded = n_e(bze_data)
npts_expected_bze = ceil((max(utc_bze)-min(utc_bze)+1)*sample_rate)
master_timebase = utc_bze[0]+(1./sample_rate)* $
;  dindgen(npts_expected_bze)
dindgen(n_e(bze_data))

; If we've dropped more than 0.25 sec of data, make some noise.
time_missed = (npts_expected_bze - npts_recorded)/sample_rate
if (time_missed ge 0.25) then begin
    print
    message,/info,string('bzed appears to have dropped ',time_missed,$
                         ' seconds of data.',format='(A,F6.2,A)')
    message,/info,'Please make a note of it.'
;    message,/info,'Type any key to continue.'
;    blah=''
;    read,blah
endif

;print,'MOMENT OF TRUTH!'
;print,utc_bze[0],plog_data[0].ticks

;plog_data[0].ticks+(1./sample_rate)*dindgen(n_e(bze_data))
print,'Master timebase ',minmax(master_timebase),format='(A20,F20.3,F20.3)'
print,'UTC', utcmin,utcmax,format='(A20,F20.3,F20.3)'
wh = where(master_timebase gt utcmin and master_timebase lt utcmax)
master_timebase = master_timebase[wh]
;print,'Does the master timebase match the desired utc min / max?'
print,'Master timebase ',minmax(master_timebase),format='(A20,F20.3,F20.3)'
print,'UTC', utcmin,utcmax,format='(A20,F20.3,F20.3)'
bze_data = bze_data[wh]
; CRAP.  I never trimmed ac_bolos to match everybody else.  Good thing
; save_spectra doesn't use ac_bolos.

plog_utc = plog_data.ticks
wh_plog_utc = where(plog_utc ge utcmin and plog_utc le utcmax)
plog_utc = plog_utc[wh_plog_utc]
plog_data = plog_data[wh_plog_utc]

;rpc_utc = rpc_data.coordinated_universal_time*3600.
;wh_rpc_utc = where(rpc_utc ge utcmin and rpc_utc le utcmax)
;rpc_utc = rpc_utc[wh_rpc_utc]
;rpc_data = rpc_data[wh_rpc_utc]

; Build up the uber-data
all_data = replicate(create_struct(bze_data[0], plog_data[0]),$;rpc_data[0]), $
                     n_e(master_timebase))

bze_tags = strlowcase(tag_names(bze_data))
n_bze_tags = n_tags(bze_data)

plog_tags = strlowcase(tag_names(plog_data))
n_plog_tags = n_tags(plog_data)

;rpc_tags = strlowcase(tag_names(rpc_data))
;n_rpc_tags = n_tags(rpc_data)

; Do the mondo - interpolation
for i = 0,n_bze_tags-1 do begin
    all_data.(i) = bze_data.(i)
endfor
; This will only work if all PLOG and RPC data is just timestream
; length ...
for i = n_bze_tags, n_bze_tags+n_plog_tags-1 do begin
    all_data.(i) = interpol(plog_data.(i-n_bze_tags),plog_utc,master_timebase)
endfor
;for i = n_bze_tags+n_plog_tags,n_bze_tags+n_plog_tags+n_rpc_tags-1 do begin
;    all_data.(i) = $
;      interpol(rpc_data.(i-n_bze_tags-n_plog_tags),rpc_utc,master_timebase)
;endfor

; Final number of timestream data points
ntod = n_e(all_data)

; Clear memory
plog_data = 0
;chop = bze_data.cos[chop_box,chop_chan]
; Changed 2014/10/06 due to some weird change in the housekeeping box
; digital side that I (JA) do not recall making at APEX
chop = bze_data.sin[chop_box,chop_chan]
bze_data = 0

print,'Did the mondo-interpolation'
;stop
; -----------------------------------------------------------------------------
; From here on, it's just file writing
; -----------------------------------------------------------------------------

tags = strlowcase(tag_names(all_data))
ntags = n_tags(all_data)

; Build up netcdf file name ... more stupid tasks
netcdf_file = !ZSPEC_DATA_ROOT+'/ncdf/'+date+$
  '/'+date+'_'+obs_num_str+'.nc'

; Open up a netcdf file and create some variables.  Also, we will
; eventually not want to put ALL of these signals in there.
; Clobber is very dangerous
id = ncdf_create(netcdf_file,/clobber)

; Define dimensions
time = ncdf_dimdef(id, 'time', /unlimited)
nboxes = ncdf_dimdef(id, 'nboxes', nbox)
nchan = ncdf_dimdef(id, 'nchannels', 24)
nbolos = ncdf_dimdef(id, 'nbolos', 160)

time_s,'Defining netdcf ...',t0
; Define variables
vid = lonarr(ntags+4)

for i=0,ntags-1 do begin
; This is NOT general
    if (i eq 0 or i eq 1) then begin
        bs = [nboxes, nchan, time]
    endif else begin
        bs = [time]
    endelse
    vid[i] = ncdf_vardef(id, tags[i], bs, /double)
    ncdf_attput, id, vid[i], 'units', 'Volts'
endfor
vid[ntags] = ncdf_vardef(id, 'chop_enc', [time], /double)
vid[ntags+1] = ncdf_vardef(id, 'ac_bolos', [nbolos, time], /double)
vid[ntags+2] = ncdf_vardef(id, 'bolo_flags', [nbolos], /double)
vid[ntags+3] = ncdf_vardef(id, 'time_flags', [nbolos, time], /double)

time_e,t0

chunk_size = 20000L
indx = lindgen(chunk_size)

count = [chunk_size]
offset = [0L]

; End the define mode and write the data
time_s,'Timing write ... ',t0
ncdf_control, id, /nofill
ncdf_control, id, /endef 
print,'Beginning data write ... '


print,'Total number of timestream points:'
print,ntod

nchnks = ntod/chunk_size

if ((n_e(all_data) mod chunk_size) gt 0) then nchnks = nchnks+1
if (nchnks eq 1) then indx = lindgen(n_e(all_data))

for chnk = 0,nchnks-1 do begin

    print,min(indx)/float(n_e(all_data))*100.,'% done ',$
                 format = '(I3,A,$)'
    print,max(indx)

    ncdf_varput,id,vid[ntags+2],bolo_flags
    
; Write the data
    for i=0,1 do begin
        print,'.',format ='(A,$)'
        ncdf_varput,id,vid[i],(all_data.(i))[*,*,indx],$
          offset=[0,0,offset[0]]
    endfor
    
    for i=2,ntags-1 do begin
        print,'.',format ='(A,$)'
        ncdf_varput,id,vid[i],(all_data.(i))[indx],offset=offset
    endfor
    ncdf_varput,id,vid[ntags],$
      chop[indx],offset=offset
    ncdf_varput,id,vid[ntags+1],(ac_bolos[*,wh])[*,indx], $
      offset=[0,offset[0]]
    ncdf_varput,id,vid[ntags+3],(time_flags[*,wh])[*,indx], $
      offset=[0,offset[0]]
    print,'.'

;    if (offset[0]+chunk_size lt n_e(all_data)) then begin

; The offset always steps along by the chunk size
    offset = [offset[0] + chunk_size]
; But how much data remaining is there?
    remaining = min([chunk_size,ntod-(max(indx)+1)])
    if (remaining ne 0) then $
      indx = lindgen(remaining)+offset[0]

;    endif else begin
;
;        print,'Last chunk'
;        end_chunk_size = n_e(all_data)-offset[0]
;        print,end_chunk_size
;
;        offset = [offset[0]]
;        indx = lindgen(end_chunk_size)+offset[0]
;        print,max(indx)
;
;    endelse
;
endfor

ncdf_close,id

print, '100% done'

time_e,t0

;stop
jump1:print,' '

end
