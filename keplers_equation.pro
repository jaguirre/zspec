function keplers_equation, e

m = 5.d*!dtor
ecc = 0.1

return,m - e + ecc * sin(e)

end
