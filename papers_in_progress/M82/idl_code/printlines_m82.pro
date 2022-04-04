; This takes some code from the original printlines and also
; printlines_uber_spectra and adds the lines seen in m82
; Lines are color coded and text is vertical (always to lower frequency)

PRO printlines_m82, levels, redshift_in, ymin, ymax, $
                NOTEXT = NOTEXT
  redshift = redshift_in

  TOP = levels[0]
  MIDDLE = levels[1]
  BOTTOM = levels[2]
  IF N_E(levels) GT 3 THEN BEGIN
     BBOTTOM = levels[3]
  ENDIF ELSE BEGIN
     BBOTTOM = BOTTOM
  ENDELSE

  ON = 1
  OFF = 0

  BLUE = 4
  RED = 2
  GREEN = 3

; CO 2-1, 13CO 2-1, C180 2-1
  linenames = ['CO!D2!M61!N','!E13!NCO!D2!M61!N','C!E18!NO!D2!M61!N']
  linefreqs = [230.5380000  ,220.3986765        ,219.5603568        ]
  liney     = [TOP          ,TOP                ,MIDDLE             ]
  lineprint = [ON           ,ON                 ,ON                 ]
  linecol   = [BLUE         ,BLUE               ,RED                ]

; CS 4-3, CS 5-4, CS 6-5
  linenames = [linenames,'CS!D4!M63!N','CS!D5!M64!N','CS!D6!M65!N']
  linefreqs = [linefreqs,195.9542260  ,244.9356435  ,293.9122440  ]
  liney     = [liney    ,TOP          ,TOP          ,TOP          ]
  lineprint = [lineprint,ON           ,ON           ,ON           ]
  linecol   = [linecol  ,BLUE         ,BLUE         ,BLUE         ]

; HCN 3-2, HNC 3-2, HCO+ 3-2  
  linenames = [linenames,'HCN!D3!M62!N','HNC!D3!M62!N','HCO!E+!D3!M62!N']
  linefreqs = [linefreqs,265.8861800   ,271.9811420   ,267.5576190      ]
  liney     = [liney    ,MIDDLE        ,MIDDLE        ,TOP              ]
  lineprint = [lineprint,ON            ,ON            ,ON               ]
  linecol   = [linecol  ,BLUE          ,BLUE          ,RED              ]

; CN 2-1, C2H 3-2
  linenames = [linenames,'CN!D2!M61!N','C!D2!NH!D3!M62!N']
  linefreqs = [linefreqs,226.8747813  ,262.0042600       ]
  liney     = [liney    ,TOP          ,TOP               ]
  lineprint = [lineprint,ON           ,ON                ]
  linecol   = [linecol  ,BLUE         ,RED               ]

; CH3CCH 11-10, CH3CCH 12-11
;;   linenames = [linenames,'CH!D3!NCCH!D11!M610!N','CH!D3!NCCH!D12!M611!N']
;;   linefreqs = [linefreqs,187.9936450            ,205.0807322            ]
;;   liney     = [liney    ,BOTTOM                ,BOTTOM                ]
;;   lineprint = [lineprint,ON                     ,ON                     ]
;;   linecol   = [linecol  ,RED                    ,RED                    ]
; CH3CCH 12-11
  linenames = [linenames,'CH!D3!NCCH!D12!M611!N']
  linefreqs = [linefreqs,205.0807322            ]
  liney     = [liney    ,BOTTOM                 ]
  lineprint = [lineprint,ON                     ]
  linecol   = [linecol  ,RED                    ]
; CH3CCH 13-12, CH3CCH 14-13
  linenames = [linenames,'CH!D3!NCCH!D13!M612!N','CH!D3!NCCH!D14!M613!N']
  linefreqs = [linefreqs,222.1669711            ,239.2522938            ]
  liney     = [liney    ,BBOTTOM                ,BBOTTOM                ]
  lineprint = [lineprint,ON                     ,ON                     ]
  linecol   = [linecol  ,RED                    ,RED                    ]
; CH3CCH 15-14, CH3CCH 16-15
  linenames = [linenames,'CH!D3!NCCH!D15!M614!N','CH!D3!NCCH!D16!M615!N']
  linefreqs = [linefreqs,256.3366289            ,273.4199058            ]
  liney     = [liney    ,BBOTTOM                ,BBOTTOM                ]
  lineprint = [lineprint,ON                     ,ON                     ]
  linecol   = [linecol  ,RED                    ,RED                    ]
; CH3CCH 17-16, CH3CCH 18-17
  linenames = [linenames,'CH!D3!NCCH!D17!M616!N','CH!D3!NCCH!D18!M617!N']
  linefreqs = [linefreqs,290.5020540            ,307.5830029            ]
  liney     = [liney    ,BBOTTOM                ,BBOTTOM                ]
  lineprint = [lineprint,ON                     ,ON                     ]
  linecol   = [linecol  ,RED                    ,RED                    ]
; H2CO 3_13-2_12 & 3_03-2_02b
  linenames = [linenames,'H!D2!NC0(3!D13!N!M62!D12!N)','H!D2!NC0(3!D03!N!M62!D02!N)']
  linefreqs = [linefreqs,211.2114680            ,218.2221920            ]
  liney     = [liney    ,TOP                 ,BOTTOM                 ]
  lineprint = [lineprint,ON                     ,ON                     ]
  linecol   = [linecol  ,BLUE                  ,BLUE                  ]
; H2CO 3_12-2_11 & 4_14-3_13
;;   linenames = [linenames,'H!D2!NC0(3!D12!N!M62!D11!N)','H!D2!NC0(4!D14!N!M63!D13!N)']
;;   linefreqs = [linefreqs,225.6977750            ,281.5269290            ]
;;   liney     = [liney    ,BOTTOM                 ,BOTTOM                 ]
;;   lineprint = [lineprint,ON                     ,ON                     ]
;;   linecol   = [linecol  ,GREEN                  ,GREEN                  ]
; H2CO 4_14-3_13
  linenames = [linenames,'H!D2!NC0(4!D14!N!M63!D13!N)']
  linefreqs = [linefreqs,281.5269290            ]
  liney     = [liney    ,TOP                 ]
  lineprint = [lineprint,ON                     ]
  linecol   = [linecol  ,BLUE                  ]
; H2CO 4_04-3_03b & 4_13-3_12
  linenames = [linenames,'H!D2!NC0(4!D04!N!M63!D03!N)','H!D2!NC0(4!D13!N!M63!D12!N)']
  linefreqs = [linefreqs,290.6234050            ,300.8366350            ]
  liney     = [liney    ,TOP                 ,TOP                 ]
  lineprint = [lineprint,ON                     ,ON                     ]
  linecol   = [linecol  ,BLUE                  ,BLUE                  ]

  nlines = N_E(linenames)
  FOR line = 0, nlines - 1 DO BEGIN
     IF lineprint[line] EQ ON THEN BEGIN
        currfreq = linefreqs[line]*(1./(1.+redshift))
        OPLOT, [currfreq,currfreq],[ymin,ymax],col=linecol[line],line=2,thick=2.
        IF ~KEYWORD_SET(NOTEXT) THEN $
           XYOUTS, currfreq-1.5, liney[line], linenames[line], $
                   ALIGN = 1.0, ORIENTATION = 90, COLOR = linecol[line]
     ENDIF
  ENDFOR
END
