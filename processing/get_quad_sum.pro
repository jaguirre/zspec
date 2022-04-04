;created 2007-05-31 by LE

;returns the quadrature sum of bolometer voltages in an array of size
;(n_nods x n_bolos)

;data is deglitched and sliced

function get_quad_sum,year,month,night,obs,update=update

file=get_ncdfpath(year,month,night,obs)
savefile=change_suffix(file,'_vdc.sav')

already_done=file_search(savefile)
if keyword_set(update) then already_done=''
if already_done eq '' then begin

;____________________________________________________________________
;identify ncdf file

waszipped = 0

zippedfile = file+'.gz'

maligned = file_search(file)
zipped = file_search(zippedfile)

if maligned eq '' and zipped eq zippedfile then begin
    print,'Gunzipping....'
    spawn,'gunzip ' + zippedfile
    waszipped = 1
endif

;_____________________________________________________________________
;read ncdf file

  print,'Reading data from:'
  print,file

  nodding = byte(read_ncdf(file,'nodding'))
  on_beam = byte(read_ncdf(file,'on_beam'))
  off_beam = byte(read_ncdf(file,'off_beam'))
  acquired = byte(read_ncdf(file,'acquired'))
  chopper = read_ncdf(file,'chop_enc')
  avebias = mean(get_bias(file)) 
  samp_int = find_sample_interval(read_ncdf(file,'ticks'))
  biasfreq = 2.0/samp_int

  bolosin = read_ncdf(file,'sin')
  bolocos = read_ncdf(file,'cos')

  if waszipped eq 1 then begin
      print,'Zipping netCDF file back up....'
      spawn,'gzip ' + file
      waszipped = 0
  endif

;_____________________________________________________________________
;extract channels according to bolo_config

  print, 'Extracting Optical Channels...'
    case 1 of
        month eq 4 and year eq 2006:begin
            bc_file = !zspec_pipeline_root + '/file_io/bolo_config_apr06.txt'
        end
        month eq 12 and year eq 2006:begin
            bc_file = !zspec_pipeline_root + '/file_io/bolo_config_dec06.txt'
        end
        month eq 1 and year eq 2007:begin
            bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_dec06.txt'
        end
        month eq 4 and year eq 2007:begin
            bc_file = !zspec_pipeline_root + '/file_io/bolo_config_apr07.txt'
        end
	month eq 5 and year eq 2007:begin
            bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
        end
        month eq 11 and year eq 2007:begin
            bc_file = !zspec_pipeline_root + '/file_io/bolo_config_apr07.txt'
        end
	month eq 12 and year eq 2007:begin
            bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
        end
	year gt 2007:begin
            bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr07.txt'
        end
        else:message,'Please define bolo_config for given month and year' 
    endcase

    vbolo_sin = extract_channels(bolosin,'optical',bolo=bc_file)
    vbolo_cos = extract_channels(bolocos,'optical',bolo=bc_file)

    ts_size = size(vbolo_sin)
    quadflags = replicate(1,ts_size[1:2])
    n_bolos = ts_size[1]

;____________________________________________________________________________
;deglitch data

    time_s,"Deglitching data....",t0
    vbolo_sin = datadeglitch(vbolo_sin,quadflags,/usesigma,ave=1000,sigma=3.,/quiet)
    vbolo_cos = datadeglitch(vbolo_cos,quadflags,/usesigma,ave=1000,sigma=3.,/quiet)
    time_e,t0
    
;___________________________________________________________________________
;take quadrature sum

    vbolo_quad = sqrt(vbolo_sin^2. + vbolo_cos^2.)

;____________________________________________________________________________
;slice data

    quad_nod_struct = find_onoff(find_nods(nodding),on_beam,off_beam,acquired,$
                                 quadflags)
    quad_chop_struct = make_chop_struct(chopper,quadflags,sample_interval=samp_int)
    quad_nod_struct = trim_nods(quad_nod_struct,quad_chop_struct.period,length=pos_length)

    vbolo_quad = slice_data(quad_nod_struct,vbolo_quad,quadflags,/just_data)
;_____________________________________________________________________________
;take the average of nod positions

    vbolo_quad_size = size(vbolo_quad.nod.pos.time)
    n_points = vbolo_quad_size[1]*vbolo_quad_size[2]
    vbolo_quad = total(total(vbolo_quad.nod.pos.time,1),1)/n_points

save,vbolo_quad,quadflags,filename=savefile

endif else restore,savefile

return,vbolo_quad
end

