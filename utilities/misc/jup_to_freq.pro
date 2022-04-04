function jup_to_freq,mol,jup

mol=strlowcase(mol)
freq=FLTARR(n_e(jup))

for i=0, n_e(jup)-1 do begin
case mol of
   'cs': case jup[i] of 
            1: freq[i]=48.991
            2: freq[i]=97.981
            3: freq[i]=146.969
            4: freq[i]=195.954
            5: freq[i]=244.936
            6: freq[i]=293.912
            7: freq[i]=342.883
            8: freq[i]=391.847
	    9: freq[i]=440.803
           10: freq[i]=489.751
           11: freq[i]=538.689
           12: freq[i]=587.616
	   13: freq[i]=636.532
	   14: freq[i]=685.436
	   15: freq[i]=734.326
	   16: freq[i]=783.202
	   17: freq[i]=832.062
	   18: freq[i]=880.906
	   19: freq[i]=929.732
	   20: freq[i]=978.540
	   21: freq[i]=1027.330
	   22: freq[i]=1076.098
	   23: freq[i]=1124.846
	   24: freq[i]=1173.572
	   25: freq[i]=1222.274
	   26: freq[i]=1270.953
	   27: freq[i]=1319.606
	   28: freq[i]=1368.234
	   29: freq[i]=1416.835
	   30: freq[i]=1465.408
	   31: freq[i]=1513.952
	   32: freq[i]=1562.466
         endcase
    'c34s': case jup[i] of
            1: freq[i]=48.207
            2: freq[i]=96.413
            3: freq[i]=144.617
            4: freq[i]=192.819
            5: freq[i]=241.016
            6: freq[i]=289.209
	    7: freq[i]=337.396
	    8: freq[i]=385.577
	    9: freq[i]=433.751
	   10: freq[i]=481.916
	   11: freq[i]=530.072
	   12: freq[i]=578.217
	   13: freq[i]=626.351
	   14: freq[i]=674.474
	   15: freq[i]=722.583
	   16: freq[i]=770.678
	   17: freq[i]=818.758 
	   18: freq[i]=866.823
	   19: freq[i]=914.871
	   20: freq[i]=962.901
	   21: freq[i]=1010.912
	   22: freq[i]=1058.904
	   23: freq[i]=1106.876
	   24: freq[i]=1154.826
	   25: freq[i]=1202.753
	   26: freq[i]=1250.658
	   27: freq[i]=1298.538
	   28: freq[i]=1346.393
	   29: freq[i]=1394.222
	   30: freq[i]=1442.025
	   31: freq[i]=1489.799
	   32: freq[i]=1537.544
	   33: freq[i]=1585.260
        endcase
    'hcn': case jup[i] of
            1: freq[i]=88.6316
            2: freq[i]=177.2611
            3: freq[i]=265.8864
            4: freq[i]=354.5055
            5: freq[i]=443.1161
            6: freq[i]=531.7163
            7: freq[i]=620.304
            8: freq[i]=708.877
            9: freq[i]=797.433
            10: freq[i]=885.97
            11: freq[i]=974.487
            12: freq[i]=1062.980
            13: freq[i]=1151.449
            14: freq[i]=1239.890
            15: freq[i]=1328.302
            16: freq[i]=1416.682
            17: freq[i]=1505.030
	    18: freq[i]=1593.312
        endcase
    'hnc': case jup[i] of
            1: freq[i]=90.6636
            2: freq[i]=181.3248
            3: freq[i]=271.9811
            4: freq[i]=362.6303
            5: freq[i]=453.2699
            6: freq[i]=543.8476
            7: freq[i]=634.51
            8: freq[i]=725.107
            9: freq[i]=815.685
            10: freq[i]=906.240
            11: freq[i]=996.772
            12: freq[i]=1087.278
            13: freq[i]=1177.755
            14: freq[i]=1268.200
            15: freq[i]=1358.513
            16: freq[i]=1448.989
            17: freq[i]=1539.327
        endcase
    'hco+': case jup[i] of
            1: freq[i]=89.1885
            2: freq[i]=178.3751
            3: freq[i]=267.5576
            4: freq[i]=356.7343
            5: freq[i]=445.9030
            6: freq[i]=535.0618
            7: freq[i]=624.209
            8: freq[i]=713.342
            9: freq[i]=802.458
            10: freq[i]=891.558
            11: freq[i]=980.637
            12: freq[i]=1069.694
            13: freq[i]=1158.73
            14: freq[i]=1247.735
            15: freq[i]=1336.714
            16: freq[i]=1425.663
            17: freq[i]=1514.579
          endcase
endcase

endfor

return,freq

end
