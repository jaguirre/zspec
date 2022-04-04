file = $
  '/home/jaguirre/data/observations/ncdf/20060417/20060417_003.nc'
;getenv('HOME')+'/data/observations/ncdf/20060414/20060414_016.nc'
; '/home/kilauea/zspec/data/observations/ncdf/20060414/'+$
;'/data2/zspec/200604/ncdf/20060428/'+$
;  '20060428_003.nc'

bc_file = '/home/jaguirre/zspec_svn/file_io/bolo_config_apr06.txt'

nbolos = 160
diag_chan = 62

read = 0
if (read) then begin

nodding = read_ncdf(file,'nodding')
on_beam = read_ncdf(file,'on_beam')
off_beam = read_ncdf(file,'off_beam')
acquired = read_ncdf(file,'acquired')
chopper = read_ncdf(file,'chop_enc')
ac_bolos = read_ncdf(file,'ac_bolos')
out_lia = read_ncdf(file,'cos')
in_lia= read_ncdf(file,'sin')

ntod = n_e(nodding)

ac_bolos = extract_channels(out_lia,in_lia,'optical',bolo=bc_file)
out_lia = extract_channels(out_lia,'optical',bolo=bc_file)
in_lia = extract_channels(in_lia,'optical',bolo=bc_file)

; Make a variable of flags to keep track of where things are no good
flags = intarr(nbolos,ntod) + 1
flags[*,where(acquired eq 0)] = 0

endif

nod = find_nods(nodding)

nod = find_onoff(nod,on_beam,off_beam,acquired,diagnostic=file+'nod_diag.ps')

; The chopper period, in SAMPLES
chopper = normalize_chopper(chopper)
chop_period = find_chop_period(chopper)
chop_phase = find_chop_phase(chopper,chop_period)

nod = trim_nods(nod,chop_period,length=nod_length)

nnods = n_e(nod)
npos = n_e(nod[0].pos)

freq = (psd(ac_bolos[0,nod[0].pos[0].i : nod[0].pos[0].f],$
            samp = 0.02)).freq

channel_quad = slice_data(nod,ac_bolos,0.02)
channel_in_lia = slice_data(nod,in_lia,0.02)
channel_out_lia = slice_data(nod,out_lia,0.02)

avgpsd_quad = dblarr(nbolos,n_e(channel_quad[0].nod[0].pos[0].freq))
avgpsd_in_lia = avgpsd_quad
avgpsd_out_lia = avgpsd_quad
for i = 0,nbolos-1 do begin
    for j = 0,nnods-1 do begin
        for k = 0,npos-1 do begin
            avgpsd_quad[i,*] = $
              avgpsd_quad[i,*] + channel_quad[i].nod[j].pos[k].psd_raw^2
            avgpsd_in_lia[i,*] = $
              avgpsd_in_lia[i,*] + channel_in_lia[i].nod[j].pos[k].psd_raw^2
            avgpsd_out_lia[i,*] = $
              avgpsd_out_lia[i,*] + channel_out_lia[i].nod[j].pos[k].psd_raw^2
        endfor
    endfor
    avgpsd_quad[i,*] = sqrt(avgpsd_quad[i,*]/double(nnods*npos))
    avgpsd_in_lia[i,*] = sqrt(avgpsd_in_lia[i,*]/double(nnods*npos))
    avgpsd_out_lia[i,*] = sqrt(avgpsd_out_lia[i,*]/double(nnods*npos))
endfor

;print,'Sliced up the data ... now flipping through nods for bolometer '+$
;  strcompress(diag_chan,/rem)
;for i = 0,nnods-1 do begin
;    for j=0,npos-1 do begin
;        print,i,j
;        indx = lindgen(nod_length) + nod[i].pos[j].i
;        print,nod[i].pos[j].i
;        temp = ac_bolos[diag_chan,indx] - mean(ac_bolos[diag_chan,indx])
;        temp = temp / max(temp)
;        plot,temp,/xst
;        temp2 = channel_quad[diag_chan].nod[i].pos[j].time
;        temp2 = temp2 -mean(temp2)
;        temp2 = temp2 / max(temp2)
;        oplot,temp2,col=2
;        oplot,chopper[indx],col=3
;        blah = ''
;        read, blah
;    endfor
;endfor
;
rel_phase = find_chop_bolo_phase(nod, channel_quad,chopper,chop_period)

demods = demodulate(nod,channel_quad,chopper,chop_period,diag=diag_chan,$
                    rel_phase = rel_phase)

spectra = (-demods.demod_in[*,*,0]+demods.demod_in[*,*,1]+demods.demod_in[*,*,2]-demods.demod_in[*,*,3])/4.

spectra_out = (-demods.demod_out[*,*,0]+demods.demod_out[*,*,1]+demods.demod_out[*,*,2]-demods.demod_out[*,*,3])/4.

;
;psdnod = fltarr(nbolos,nnods,npos,n_e(freq))
;
;for i=0,nbolos-1 do begin
;    for j=0,nnods-1 do begin
;        for k=0,npos-1 do begin
;            psdnod[i,j,k,*] = $
;              (psd(ac_bolos[i,nod[j].pos[k].i : nod[j].pos[k].f])).psd
;        endfor
;    endfor
;endfor
;
;plot,nodding,/xst,/yst,yr=[-.2,1.2]
;
;cols = [2,3,4,5]
;yoff = [0.15,0.35,0.55,0.75]
;
;for i=0,n_e(nod)-1 do begin
;    for j = 0,3 do begin
;        oplot,[nod[i].pos[j].i,nod[i].pos[j].f],[1,1]*yoff[j],col=cols[j]
;    endfor
;endfor
;
;
;for i = 0L,n_e(chopper)/200 - 1 do begin
;
;    t = lindgen(200)+i*200
;
;    plot,t,chopper[t],/xst
;
;    oplot,t,sin(2.*!pi/chop_period * t + chop_phase) + $
;      1./3.*sin(3.*(2.*!pi/chop_period * t + chop_phase)) + $
;      1./5.*sin(5.*(2.*!pi/chop_period * t + chop_phase)), $
;      col=2
;
;    blah = ''
;    read, blah
;
;endfor
;



end
