function pinknoise_fun, x, a

f0 = a[0]

alpha = a[1]

white = a[2]

freq = x

f = (f0/abs(freq))^alpha + white

dfda0 = alpha/abs(freq)^alpha * f0^(alpha-1.)

dfda1 = (f0/abs(freq))^alpha * alog(f0/abs(freq))

dfda2 = replicate(1.,n_e(x))

pder = [[dfda0],[dfda1],[dfda2]]

return, f

end


