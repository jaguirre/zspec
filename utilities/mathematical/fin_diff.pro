function fin_diff, array

; Do a finite difference on an array

fd = array[1:*]-array[0:n_e(array)-2]
fd = [fd[0],fd]

return, fd

end
