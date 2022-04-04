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

pro $
     maligns_working_20060411, $
     date, obs_num, new = new, plot = plot, onebze = onebze

bolo_config_file = getenv('HOME')+'/zspec_svn/file_io/bolo_config_apr06.txt'

;message,/info,'Variable new set to '+strcompress(new,/rem)

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

;rpc_root = getenv('HOME')+'/data/observations/rpc/'+date+'/'+date+'_'
plog_root = getenv('HOME')+'/data/observations/plog/'+date+'/'+date+'_'
bze_root = getenv('HOME')+'/data/observations/bze/'+date+'/'+date+'_'
ncdf_dir = getenv('HOME')+'/data/observations/ncdf/'+date+'/'

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

; Gotta get this from somewhere ...
nbox = 10

min = obsmin[0]

; Get PLOG, RPC, and BZE data 

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

bolo_flags = $
  get_bolo_flags(bolo_config_file=bolo_config_file)

;rpc_files = rpc_files[1:*]
plog_files = plog_files[1:*]
bze_files = bze_files[1:*]

;rpc_data = read_rpc(rpc_files[0])
plog_data = read_plog(plog_files[0])

bze_data = read_bze_working_20060411(bze_files[0],nbox,$
                        def_file=def_file, $
                        ac_bolos = ac_bolos, $
                        dc_bolos = dc_bolos, $
                        seq = sequ_num, $
                        sec = seconds, $
                        new = new)

ac_bolos_cos = reform(ac_bolos[0,*,*])
ac_bolos_sin = reform(ac_bolos[1,*,*])

dc_bolos_cos = reform(dc_bolos[0,*,*])
dc_bolos_sin = reform(dc_bolos[1,*,*])

; This part is solved, except for the questions of speed and memory
; (particularly for reading long observations)
for i=1,n_e(plog_files)-1 do begin

;    rpc_data = [rpc_data,read_rpc(rpc_files[i])]
    plog_data = [plog_data,read_plog(plog_files[i])]

    if (not(keyword_set(onebze))) then begin

        bze_data = [bze_data, read_bze_working_20060411(bze_files[i],nbox,$
                                       def_file=def_file, $
                                       ac_bolos = ac_bolos, $
                                       dc_bolos = dc_bolos, $
                                       seq = sequ_num, $
                                       sec = seconds, $
                                       new = new)]
        
        ac_bolos_cos = [[ac_bolos_cos],[reform(ac_bolos[0,*,*])]]
        ac_bolos_sin = [[ac_bolos_sin],[reform(ac_bolos[1,*,*])]]
        
        dc_bolos_cos = [[dc_bolos_cos],[reform(dc_bolos[0,*,*])]]
        dc_bolos_sin = [[dc_bolos_sin],[reform(dc_bolos[1,*,*])]] 

    endif

endfor

if (keyword_set(new)) then begin

    sample_rate = 1./mean(deglitch(fin_diff(seconds)))
    message,/info,'Sample rate set to '+strcompress(sample_rate,/rem)+$
      ' Hz'
    wait,1

endif

; Adjust the lockin phases
; Just take quadrature now
nbolos=160
;ntod = n_e(ac_bolos_cos[0,*])

;readcol,getenv('HOME')+'/jaguirre/zspec_svn/lockin_phases.txt', $
;  format = '(I,F)', bolo_num, phase

ac_bolos = sqrt(ac_bolos_cos^2 + ac_bolos_sin^2)

for i=0,nbolos-1 do begin

;    inphase=cos(phase[i])*ac_bolos_cos[i,*]-sin(phase[i])*ac_bolos_sin[i,*]
;    outphase=sin(phase[i])*ac_bolos_cos[i,*]+cos(phase[i])*ac_bolos_sin[i,*]

    ac_bolos[i,*] = sqrt(ac_bolos_sin[i,*]^2 + ac_bolos_cos[i,*]^2)
    ac_bolos[i,*] = ac_bolos[i,*] - mean(ac_bolos[i,*])
;    ac_bolos[i,*] = deglitch(ac_bolos[i,*]) ; DEFAULT STEP WORKING BETTER
;    ac_bolos[i,*] = deglitch(ac_bolos[i,*],step=1.d-4)
;    ac_bolos_sin[i,*] = outphase

endfor

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

master_timebase = plog_data[0].ticks+(1./sample_rate)*dindgen(n_e(bze_data))

wh = where(master_timebase gt utcmin and master_timebase lt utcmax)
master_timebase = master_timebase[wh]

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

print,'Did the mondo-interpolation'

tags = strlowcase(tag_names(all_data))
ntags = n_tags(all_data)

; Build up netcdf file name ... more stupid tasks
netcdf_file = getenv('HOME')+'/data/observations/ncdf/'+date+$
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

nchnks = n_e(all_data)/chunk_size
if ((n_e(all_data) mod chunk_size) gt 0) then nchnks = nchnks+1

if (nchnks eq 1) then indx = lindgen(n_e(all_data))

for chnk = 0,nchnks-1 do begin

    print,min(indx)/float(n_e(all_data))*100.,'% done ',$
                 format = '(I3,A,$)'

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
      (bze_data.cos[chop_box,chop_chan])[indx],offset=offset
    ncdf_varput,id,vid[ntags+1],(ac_bolos[*,wh])[*,indx], $
      offset=[0,offset[0]]
    print,'.'

    if (offset[0]+chunk_size lt n_e(all_data)) then begin

        offset = [offset[0] + chunk_size]
        indx = indx + chunk_size

    endif else begin

        end_chunk_size = n_e(all_data)-offset[0]

        offset = [offset[0]]
        indx = lindgen(end_chunk_size)+offset[0]

    endelse

endfor

ncdf_close,id

print, '100% done'

time_e,t0

end
