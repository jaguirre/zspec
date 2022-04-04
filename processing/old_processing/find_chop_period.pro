function find_chop_period, chop

pchop = psd(chop,sample=1)

chop_period = 1./pchop.freq[where(pchop.psd eq max(pchop.psd))]

return, chop_period[0]

end
