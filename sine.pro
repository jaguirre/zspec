function sine, theta, params

return, params[0]*sin(params[1]*theta+params[2]);, $
         ;sin(params[1]*theta+params[2]), $
        ; params[0]*cos(params[1]*theta+params[2])*theta,$
        ; params[0]*cos(params[1]*theta+params[2])]

end
