;restore,'/home/zspec/data/observations/ncdf/20050603/obs_log.sav'

for k =14,14 do begin

obs_num = k
obs_num_str = '0'+strcompress(obs_num,/rem)
source_name = 'G34.3'
sample_rate = 50.
date = '20050604'

rpc_root = getenv('HOME')+'/data/observations/rpc/'+date+'/'+date+'_'
plog_root = getenv('HOME')+'/data/observations/plog/'+date+'/'+date+'_'
bze_root = getenv('HOME')+'/data/observations/bze/'+date+'/'+date+'_'
ncdf_dir = getenv('HOME')+'/data/observations/ncdf/'+date+'/'

; Figure out where the observations are
find_observations,getenv('HOME')+'/data/observations/plog/'+date+'/',$
  obsmin = obsmin, obssamp = obssamp

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

; Gotta get this from somewhere ...
nbox = 10

minute_range = obsmin[obs_num,*]

min = minute_range[0]

; Get PLOG, RPC, and BZE data 
read = 1
if (read) then begin
; Make up the filenames.  Yet another little task.
rpc_files = ['']
plog_files = ['']
bze_files = ['']
minstr = ''
while (min le minute_range[1]) do begin

    minstr = strcompress(min,/rem)
    if (min lt 1000) then minstr = '0'+strcompress(min,/rem)
    if (min lt 100) then minstr = '00'+strcompress(min,/rem)
    if (min lt 10) then minstr = '000'+strcompress(min,/rem)
    
    rpc_files = [rpc_files,rpc_root+minstr+'_rpc.bin']
    plog_files = [plog_files,plog_root+minstr+'_plog.bin']
    bze_files = [bze_files,bze_root+minstr+'_bze.bin']

    min = min+1

endwhile

bolo_flags = get_bolo_flags(bolo_config_file=bolo_config_20050604.txt)

rpc_files = rpc_files[1:*]
plog_files = plog_files[1:*]
bze_files = bze_files[1:*]

rpc_data = read_rpc(rpc_files[0])
plog_data = read_plog(plog_files[0])
bze_data = read_bze(bze_files[0],nbox,ac_bolos = ac_bolos, $
                    dc_bolos = dc_bolos)

ac_bolos_cos = reform(ac_bolos[0,*,*])
ac_bolos_sin = reform(ac_bolos[1,*,*])

dc_bolos_cos = reform(dc_bolos[0,*,*])
dc_bolos_sin = reform(dc_bolos[1,*,*])

; This part is solved, except for the questions of speed and memory
; (particularly for reading long observations)
for i=1,n_e(rpc_files)-1 do begin

    rpc_data = [rpc_data,read_rpc(rpc_files[i])]
    plog_data = [plog_data,read_plog(plog_files[i])]
    bze_data = [bze_data,read_bze(bze_files[i],nbox,ac_bolos = ac_bolos, $
                                  dc_bolos = dc_bolos)]

    ac_bolos_cos = [[ac_bolos_cos],[reform(ac_bolos[0,*,*])]]
    ac_bolos_sin = [[ac_bolos_sin],[reform(ac_bolos[1,*,*])]]

    dc_bolos_cos = [[dc_bolos_cos],[reform(dc_bolos[0,*,*])]]
    dc_bolos_sin = [[dc_bolos_sin],[reform(dc_bolos[1,*,*])]] 

endfor

; The observation will not fill up all the minutes.  Need to have a
; where statement.
utcmin = obsmin[obs_num,0]*60.+obssamp[obs_num,0]*.01
utcmax = obsmin[obs_num,1]*60.+obssamp[obs_num,1]*.01

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

rpc_utc = rpc_data.coordinated_universal_time*3600.
wh_rpc_utc = where(rpc_utc ge utcmin and rpc_utc le utcmax)
rpc_utc = rpc_utc[wh_rpc_utc]
rpc_data = rpc_data[wh_rpc_utc]

; Build up the uber-data
all_data = replicate(create_struct(bze_data[0], plog_data[0], rpc_data[0]), $
                     n_e(master_timebase))

bze_tags = strlowcase(tag_names(bze_data))
n_bze_tags = n_tags(bze_data)

plog_tags = strlowcase(tag_names(plog_data))
n_plog_tags = n_tags(plog_data)

rpc_tags = strlowcase(tag_names(rpc_data))
n_rpc_tags = n_tags(rpc_data)

; Do the mondo - interpolation
for i = 0,n_bze_tags-1 do begin
    all_data.(i) = bze_data.(i)
endfor
; This will only work if all PLOG and RPC data is just timestream
; length ...
for i = n_bze_tags, n_bze_tags+n_plog_tags-1 do begin
    all_data.(i) = interpol(plog_data.(i-n_bze_tags),plog_utc,master_timebase)
endfor
for i = n_bze_tags+n_plog_tags,n_bze_tags+n_plog_tags+n_rpc_tags-1 do begin
    all_data.(i) = $
      interpol(rpc_data.(i-n_bze_tags-n_plog_tags),rpc_utc,master_timebase)
endfor

endif

print,'Did the mondo-interpolation'

tags = strlowcase(tag_names(all_data))
ntags = n_tags(all_data)

; Build up netcdf file name ... more stupid tasks
netcdf_file = getenv('HOME')+'/data/observations/ncdf/'+date+$
  '/'+date+'_'+obs_num_str+'_'+source_name+'_raw.nc'

; Open up a netcdf file and create some variables.  Also, we will
; eventually not want to put ALL of these signals in there.
; Clobber is very dangerous
id = ncdf_create(netcdf_file,/clobber)

; Define dimensions
time = ncdf_dimdef(id, 'time', /unlimited)
nboxes = ncdf_dimdef(id, 'nboxes', nbox)
nchan = ncdf_dimdef(id, 'nchannels', 24)
nbolos = ncdf_dimdef(id, 'nbolos', 160)

print,'Defining netdcf ...'
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

; End the define mode and write the data
ncdf_control, id, /endef
print,'Beginning data write ... '

; Write the data
for i=0,ntags-1 do begin
    print,string('Writing tag ',i,' of ',ntags,format='(A,I,A,I)')
    ncdf_varput,id,vid[i],all_data.(i)
endfor
ncdf_varput,id,vid[ntags],bze_data.cos[9,19]
ncdf_varput,id,vid[ntags+1],ac_bolos_cos[*,wh]
ncdf_varput,id,vid[ntags+2],bolo_flags

ncdf_close,id

endfor

;IDL> id = ncdf_open('/home/zspec/data/observations/ncdf/20050603/20050603_039_mars_raw.nc',/write)
;IDL> vid = ncdf_varid(id,'nodding')
;IDL> ncdf_varput,id,vid,nodding
;IDL> ncdf_close,id


end
