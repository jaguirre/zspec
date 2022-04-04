;Gaussian function for fit to En(z) distributions
function enz_gauss, x, p

   return, p[2] * exp( -(x-p[0])^2 / 2. / p[1]^2 ); / sqrt( 2.*!pi*p[1]^2 )

end
