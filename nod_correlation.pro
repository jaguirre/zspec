; Calculate the covariance correctly in the presence of flags.
; Really?  is there no better way to do this?

function nod_correlation, avespec, nodspec, mask

nbolos = 160
nnods = n_e(nodspec[0,*])

data = nodspec * mask

nsamps = total(mask,2)

mean = total(data,2)/nsamps

; subtract off the mean (which should be close to the weighted mean)
data -= mean#replicate(1.,nnods)

var = total(data^2,2)

corr = data#transpose(data) / (sqrt(var)#sqrt(var))

return,corr

end
