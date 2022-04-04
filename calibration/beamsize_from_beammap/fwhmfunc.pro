function fwhmfunc,x,A

;F=(1.02*x/A[0])*206265.

F=206265.*(1.02+(A[1]*x))*x/A[0]

return,F

end
