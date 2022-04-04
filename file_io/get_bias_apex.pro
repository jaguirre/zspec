; Fucking stupid

function get_bias_apex, ncdf_file

cos = read_ncdf(ncdf_file,'cos_extra')
sin = read_ncdf(ncdf_file,'sin_extra')

bias = sqrt(cos[0,*]^2 + sin[0,*]^2)

return,REFORM(bias)

end

