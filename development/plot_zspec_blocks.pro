pro plot_zspec_blocks, spec, err

; Make a Z-Spec spectrum plot that I like better 

; Get the rectangular bandwidth of each channel
bw = freqid2squarebw()
nu = freqid2freq()  

top = spec+err
bottom = spec-err
left = nu-0.5*bw
right = nu+0.5*bw

for i = 0,160-1 do begin
   polyfill,[left[i],right[i],right[i],left[i]],$
            [top[i],top[i],bottom[i],bottom[i]],col=200,noclip=0
endfor

end
