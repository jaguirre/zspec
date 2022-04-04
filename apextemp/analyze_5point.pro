pro analyze_5point,scans,yrange

cleanplot
erase
multiplot,[1,5],/init
multiplot

for i=0,n_e(scans)-1 do begin

    analyze_pointing_scan,scans[i],yrange
    multiplot

endfor

end
