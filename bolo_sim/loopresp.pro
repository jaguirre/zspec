pro loopresp
;freqids=[2,25,46,63,75,86,99,113,132,155]
freqids=[41] 
itrans=[0.215]
for i=0,n_elements(freqids)-1 do begin
zspec_response,freqids[i],itrans=itrans[i]
end


end
