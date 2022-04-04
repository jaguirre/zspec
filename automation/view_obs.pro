pro view_obs, ncdfdir, plogdir, obsnum

; Grab all the PLOG data for a given putative observation and plot it up

openr,lun,ncdfdir+'/'+make_obsnum_str(obsnum)+'_obs_def.txt',/get_lun

obsnum_file = 0L
obsmin = lonarr(2)
obssamp = lonarr(2)

readf,lun,obsnum_file,format='(I10)'
readf,lun,obsmin,format='(2I10)'
readf,lun,obssamp,format='(2I10)'

close,lun
free_lun,lun

plog_files = ['']
observing = [0]
ticks = [0]

min = obsmin[0]

while (min le obsmin[1]) do begin

    newfile = plogdir+'/20050606_'+make_padded_num_str(min,4)+'_plog.bin'
    plog_files = [plog_files,newfile]
    
    observing = [observing,(read_plog(newfile)).observing]
    ticks = [ticks,(read_plog(newfile)).ticks]

    min = min + 1

endwhile

observing = observing[1:*]
ticks = ticks[1:*]

plot,ticks,observing,/xst,/yst,yr=[-.2,1.2]
oplot,[1,1]*obsmin[0]*60.+obssamp[0]/100.,[-1,1],col=2,line=2
oplot,[1,1]*(obsmin[1]*60.+obssamp[1]/100.),[-1,1],col=2,line=2

blah = ''
read, blah

end
