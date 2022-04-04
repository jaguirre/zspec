function KL_transform,in_array


	;expect in_array to be ~Array[30, 1000] in IDL terms
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;normalize it
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	norm = sqrt(total(in_array*in_array,2))
	nin_arr=in_array
	
	;should only be ~30 iters, but should elim.
	for i=0,n_elements(norm)-1 do begin 
		nin_arr[i,*]=nin_arr[i,*]/norm[i]
	endfor
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; make correlation matrix
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	c = nin_arr # transpose(nin_arr)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;find diagonal transformation for C
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	eval = hqr(elmhes(c))
	Runsorted = eigenvec(c,eval)
	
	;sorts so in descending order of importance
	R = Runsorted(*,reverse(sort(eval)))
	eval=eval(reverse(sort(eval)))
	Runsorted=0

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;now use this to get the eigenbasis
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ebasis = nin_arr ## transpose(R)
	;hope everything's real bec. I'm trashing the imaginary
	;should probably install a check
	return,create_struct('evector',float(ebasis),'evalue',float(eval))
end
