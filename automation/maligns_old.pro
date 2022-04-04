; $Id$
; $Log$
;
;+
; 
;
;-

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

pro maligns, date, obs_num, new = new, plot = plot, onebze = onebze, $
             svn_root = svn_root, $
             data_root = data_root

; Always the first order of business: need to know where stuff is.
if not(keyword_set(svn_root)) then begin
    defsysv, '!zspec_pipeline_root', exists = exists
    if (exists eq 1) then begin
        svn_root = !zspec_pipeline_root
    endif else begin
        message,'SVN location not known.  Set svn_root keyword or !zspec_pipeline_root system variable.'
    endelse
endif

if not(keyword_set(data_root)) then begin
; Assume that we're on kilauea or wakea with the usual soft links.
    data_root = getenv('HOME')+'/data/observations/'
endif
    
bolo_config_file = svn_root+'/file_io/bolo_config_apr06.txt'

;rpc_root = data_root+'rpc/'+date+'/'+date+'_'
plog_root = data_root+'plog/'+date+'/'+date+'_'
bze_root = data_root+'bze/'+date+'/'+date+'_'
ncdf_dir = data_root+'ncdf/'+date+'/'

obs_num_str = make_padded_num_str(obs_num,3)
source_name = ''
sample_rate = 50.

; Build up netcdf file name ... more stupid tasks
netcdf_file = data_root+'ncdf/'+date+$
  '/'+date+'_'+obs_num_str+'.nc'

; Should find a better way to do this.  Might also want to know where
; the various thermometers and bias and stuff is. 
; Up to 20050607
;chop_box = 9
;chop_chan = 19
; 20050608 and After
;chop_box = 0
;chop_chan = 21
; April 06 science run
chop_box = 9
chop_chan = 18
    
; -----------------------------------------------------------------------------
; Get the information on where the observation is in the PLOG data.  
obsnum_file = 0L
obsmin = lonarr(2)
obssamp = lonarr(2)
utc = dblarr(2)

openr,lun,ncdf_dir+'/'+obs_num_str+'_obs_def.txt',/get_lun

readf,lun,obsnum_file,format='(I10)'
readf,lun,obsmin,format='(2I10)'
readf,lun,obssamp,format='(2I10)'
readf,lun,utc,format='(2D10.2)'

close,lun
free_lun,lun
; -----------------------------------------------------------------------------

; Gotta get this from somewhere ...
nbox = 10

min = obsmin[0]

; Get PLOG, RPC, and BZE data 

; -----------------------------------------------------------------------------
; Make up the filenames.  Yet another little task.
;rpc_files = ['']
plog_files = ['']
bze_files = ['']
minstr = ''
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
; -----------------------------------------------------------------------------

bolo_flags = $
  get_bolo_flags(bolo_config_file=bolo_config_file)

;rpc_files = rpc_files[1:*]
plog_files = plog_files[1:*]
bze_files = bze_files[1:*]

;rpc_data = read_rpc(rpc_files[0])
plog_data = read_plog(plog_files[0])

bze_data = read_bze(bze_files[0],nbox,$
                    def_file=def_file, $
                    ac_bolos = ac_bolos, $
;                    dc_bolos = dc_bolos, $
                    seq = sequ_num, $
                    sec = sec, $
                    utc = utc_bze, $
                    new = new, $
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

; Check for sequence number glitches ... still need to figure out what
; to do about it.  Apparently sequence number runs 0 to 9999 and then
; wraps.
for chk_seq = 0,nbox-1 do begin

    whskip = where(fin_diff(seq_num[chk_seq,*]) ne 1 and $
                   fin_diff(seq_num[chk_seq,*]) ne -9999)

    if (whskip[0] ne -1) then begin
        print,'Box '+strcompress(chk_seq,/rem)+'has skips at samples'
        print,whskip
    endif else begin
        message,/info,'No skips in box '+strcompress(chk_seq,/rem)
    endelse

endfor

sample_rate = 1./find_sample_interval(seconds)
message,/info,'Sample rate set to '+strcompress(sample_rate,/rem)+$
  ' Hz'
wait,1

; Adjust the lockin phases
; Just take quadrature now
nbolos=160
;ntod = n_e(ac_bolos_cos[0,*])

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
; Might be a more precise way to do this ...

master_timebase = utc_bze[0]+(1./sample_rate)*dindgen(n_e(bze_data))
;+50L*60*10)

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

; Clear memory
plog_data = 0
chop = bze_data.cos[chop_box,chop_chan]
bze_data = 0

print,'Did the mondo-interpolation'

tags = strlowcase(tag_names(all_data))
ntags = n_tags(all_data)

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
vid = lonarr(ntags+3)

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

; First do just the bits that are at least chunk_length long
nchnks = n_e(all_data)/chunk_size
; Deal with the leftover
if ((n_e(all_data) mod chunk_size) gt 0 and nchnks ne 1) then nchnks = nchnks+1
; Deal with the special case of 
if (nchnks eq 1) then indx = lindgen(n_e(all_data))
stop
help,nchnks
for chnk = 0,nchnks-1 do begin
    help,chnk
    print,min(indx)/float(n_e(all_data))*100.,'% done ',$
                 format = '(I3,A,$)'

; Not sure why I do this for every chunk ...
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
    print,'.'
    print,offset[0]
    if (offset[0]+2L*chunk_size lt n_e(all_data)) then begin
        print,'Normal chunk'
        offset = [offset[0] + chunk_size]
        indx = indx + chunk_size

    endif else begin
        print,'End chunk'
        end_chunk_size = n_e(all_data)-offset[0]-chunk_size
        help,end_chunk_size
        offset = [offset[0] + chunk_size]
        if (end_chunk_size gt 0) then $
          indx = lindgen(end_chunk_size)+offset[0]
        print,minmax(indx)
    endelse

endfor

ncdf_close,id

print, '100% done'

time_e,t0

end
