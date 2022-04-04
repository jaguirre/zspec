rt = getenv('HOME')+'/data/observations/'
dt = '20060422'
files = file_search(rt+'plog/'+dt+'/'+dt+'*.bin')
nfiles = n_e(files)

obs = 0
utc = 0

for i = 0,nfiles-1 do begin

    print,i,format='(10I," ",$)'

    temp = read_plog(files[i])
    obs = [obs,temp.observing]
    utc = [utc,temp.ticks]

endfor
print

obs = obs[1:*]
utc = utc[1:*]

obs_deglitch = digital_deglitch(obs)

observations = find_contiguous(where(obs_deglitch eq 1))

write_out = 1

for i=0,n_e(observations)-1 do begin
    
;    print,i-1,format='(I10)'
    print,i,long(utc[observations[i].i]/60.),$
      long(utc[observations[i].f]/60.),$
      (sixty(utc[observations[i].i]/3600.d))[0:1],$
      (sixty(utc[observations[i].f]/3600.d))[0:1],$
      format='(I3," ",I4," ",I4," ",I2.2,":",I2.2," ",I2.2,":",I2.2)'

;    print,-1,-1,format='(2I10)'
;    print,utc[observations[i].i],utc[observations[i].f],$
;      format='(2D10.2)'
    
    if (write_out) then begin

        openw,lun,rt+'ncdf/'+dt+'/'+$
          make_padded_num_str(i,3)+'_obs_def.txt',$
          /get_lun
        printf,lun,i,format='(I10)'
        printf,lun,long(utc[observations[i].i]/60.),$
          long(utc[observations[i].f]/60.),$
          format='(2I10)'
        printf,lun,-1,-1,format='(2I10)'
        printf,lun,utc[observations[i].i],utc[observations[i].f],$
          format='(2D10.2)'
        close,lun
        free_lun,lun
        
    endif

endfor

plot,utc/60.,obs,/xst,/yst,yr=[-.2,1.2]
xyouts,long(utc[observations[*].i]/60.),1.1,strcompress(lindgen(n_e(observations)),/rem)

end
