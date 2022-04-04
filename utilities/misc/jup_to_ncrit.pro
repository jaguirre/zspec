function jup_to_ncrit,mol,jup

; Ncrits for temperature of 30K, for CS temp 40K
mol=strlowcase(mol)
ncrit=FLTARR(n_e(jup))

for i=0, n_e(jup)-1 do begin
case mol of
   'cs': case jup[i] of 
            6: ncrit[i]=1.3e7
            5: ncrit[i]=7.3e6
            4: ncrit[i]=2.9e6
            3: ncrit[i]=1.3e6
            2: ncrit[i]=3.4e5
            1: ncrit[i]=5.1e4
	    else: ncrit[i]=0
         endcase
;    'c34s': case jup[i] of
;            6: ncrit[i]=
;            5: ncrit[i]=
;            4: ncrit[i]=
;            3: ncrit[i]=
;            2: ncrit[i]=
;            1: ncrit[i]=
;        endcase
    'hcn': case jup[i] of
            1: ncrit[i]=2.9e6
            2: ncrit[i]=1.5e7
            3: ncrit[i]=5.2e7
            4: ncrit[i]=1.2e8
	    else: ncrit[i]=0
        endcase
    'hnc': case jup[i] of
            1: ncrit[i]=2.6e6
            3: ncrit[i]=4.8e7
	    else: ncrit[i]=0
        endcase
    'hco+': case jup[i] of
            1: ncrit[i]=2.0e5
            3: ncrit[i]=3.7e6
            4: ncrit[i]=9.3e6
	    else: ncrit[i]=0
          endcase
     else: ncrit[i]=0
endcase

endfor

return,ncrit

end
