function zspec_2d_gauss, x, y, p

   F1 = exp( -(x - p[1])^2 / 2. / p[3]^2 )
   F2 = exp( -(y - p[2])^2 / 2. / p[4]^2 )

   return, p[0] * F1 * F2

end
