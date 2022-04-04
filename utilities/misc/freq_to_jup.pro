function freq_to_jup,mol,freq

mol=strlowcase(mol)
jup=INTARR(n_e(freq))

; Just use the floor of the frequency... that's enough to tell them apart!
freq=FLOOR(freq)

for i=0, n_e(freq)-1 do begin
case mol of
   'ci': case freq[i] of
            492: jup[i]=1
            809: jup[i]=2
            1301: jup[i]=3
         endcase
   'cs': case freq[i] of 
            342: jup[i]=7
            293: jup[i]=6
            244: jup[i]=5
            195: jup[i]=4
            146: jup[i]=3
            97: jup[i]=2
            48: jup[i]=1
         endcase
    'c34s': case freq[i] of
            289: jup[i]=6
            241: jup[i]=5
            192: jup[i]=4
            144: jup[i]=3
            96: jup[i]=2
            48: jup[i]=1
        endcase
    'hcn': case freq[i] of
            531: jup[i]=6
            443: jup[i]=5
            354: jup[i]=4
            265: jup[i]=3
            177: jup[i]=2
            88: jup[i]=1
        endcase
    'hnc': case freq[i] of
            543: jup[i]=6
            453: jup[i]=5
            362: jup[i]=4
            271: jup[i]=3
            181: jup[i]=2
            90: jup[i]=1
        endcase
    'hco+': case freq[i] of
            535: jup[i]=6
            445: jup[i]=5
            356: jup[i]=4
            267: jup[i]=3
            178: jup[i]=2
            89: jup[i]=1
        endcase
    'co': case freq[i] of
            115: jup[i]=1
            230: jup[i]=2
            345: jup[i]=3
            461: jup[i]=4
            576: jup[i]=5
            691: jup[i]=6
            806: jup[i]=7
            921: jup[i]=8
            1036: jup[i]=9
            1151: jup[i]=10
            1267: jup[i]=11
            1381: jup[i]=12
            1496: jup[i]=13
            1611: jup[i]=14
            1726: jup[i]=15
            1841: jup[i]=16
            1956: jup[i]=17
        endcase
    '13co': case freq[i] of
            110: jup[i]=1
            220: jup[i]=2
            330: jup[i]=3
            440: jup[i]=4
            550: jup[i]=5
            661: jup[i]=6
            771: jup[i]=7
            881: jup[i]=8
            991: jup[i]=9
            1101: jup[i]=10
            1211: jup[i]=11
            1321: jup[i]=12
            1431: jup[i]=13
            1540: jup[i]=14
            1650: jup[i]=15
        endcase
endcase

endfor

return,jup

end
