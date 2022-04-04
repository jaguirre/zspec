function get_source_name_from_obsnum, date, obsnum_in

obs_def_file = !zspec_data_root+'/ncdf/'+date+'/'+obsnum_in+'_obs_def.txt'

temp = strsplit(obs_def_file,'/',/extract)
date = temp[n_e(temp)-2]
year = long(strmid(date,0,4))
month = long(strmid(date,4,2))
night = long(strmid(date,6,2))
obsnum = long((strsplit(temp[n_e(temp)-1],'_',/extract))[0])

obsdef = read_obsdef(year, month, night, obsnum)

rpcfile = !zspec_data_root+'/rpc/'+date+'/'+date+'_'+$
  make_padded_num_str(obsdef.min[0],4)+'_rpc.bin'

rpc = read_rpc(rpcfile)

return,string(rpc[10].source_name)

end
