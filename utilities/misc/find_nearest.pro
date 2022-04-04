function find_nearest, array, val

return,where(abs(array-val) eq min(abs(array-val)))

end
