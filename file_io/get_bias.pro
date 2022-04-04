; Fucking stupid

function get_bias, ncdf_file

cos = read_ncdf(ncdf_file,'cos')
sin = read_ncdf(ncdf_file,'sin')

bias = sqrt(cos[0,12,*]^2 + sin[0,12,*]^2)

return,REFORM(bias)

end

