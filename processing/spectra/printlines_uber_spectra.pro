
; This function adds vertical lines to a plot to indicate spectral lines
; and adds text labels to those vertical lines.
;
; levels - 3 element vector with the desired y-coordinates for the labels
; redshift - redshift of source 
;
; ALL_LINES - set this keyword to print all lines
; LINES_ON - array which specifies which lines should be plotted
; the order is:
;
; CO 2-1
; 13CO 2-1
; C18O 2-1
; 
; CN 2-1
; CCH 3-2
; HNO 3-2
; 
; HCNH 3-2
; HCNH 4-3
;
; CS 4-3
; CS 5-4
; CS 6-5
;
; SiO 5-4
; SiO 6-5
; SiO 7-6
;
; HCN 3-2
; HNC 3-2
; HCO+ 3-2
;
; CO 3-2
; CO 4-3
; CI 1-0
; CO 5-4
; CO 6-5
; CO 7-6
; CI 2-1
;
; CO 8-7
; CO 9-8
; CO 10-9
; CO 11-10
; CO 12-11
; CO 13-12

; EDIT JRK 3/19/09: lines are now vertical, and color coded to reduce
; confusing.  Also charthick changed to 2.  linealign now obsolete.
;
; EDIT JRK 10/22/10: keyword NO_LINES to print no lines.

PRO printlines_uber_spectra, levels, redshift_in, $
                ymin,ymax,$
                LINES_ON = LINES_ON, $
                ALL_LINES = ALL_LINES, $
                NO_LINES = NO_LINES
  redshift=redshift_in
  RIGHT = 0
  LEFT = 1
  CENTER = 0.5

  TOP = levels[0]
  MIDDLE = levels[1]
  BOTTOM = levels[2]

  ORIENT = 90
  
  BLUE = 4
  RED = 2

  ON = 1
  OFF = 0

  linenames = ['CO!D2!M61!N','!E13!NCO!D2!M61!N','C!E18!NO!D2!M61!N']
  linefreqs = [230.5380000  ,220.3986765        ,219.5603568        ]
  linealign = [RIGHT        ,LEFT               ,LEFT               ]   
  liney     = [TOP          ,TOP             ,BOTTOM             ]
  lineprint = [ON           ,ON                 ,ON                 ]
  linecol   = [BLUE         ,BLUE               ,RED                ]
  
  linenames = [linenames,'CN!D2!M61!N','CCH!D3!M62!N','HN0!D3!M62!N']
  linefreqs = [linefreqs,226.8747450  ,262.0042266   ,244.3640880   ]
  linealign = [linealign,LEFT         ,LEFT          ,RIGHT         ]   
  liney     = [liney    ,TOP          ,TOP           ,BOTTOM        ]
  lineprint = [lineprint,ON           ,ON            ,OFF           ]
  linecol   = [linecol  ,BLUE         ,RED           ,BLUE          ]
  
  linenames = [linenames,'HCNH!E+!D3!M62!N','HCNH!E+!D4!M63!N']
  linefreqs = [linefreqs,222.3294010       ,296.4336811       ]
  linealign = [linealign,RIGHT             ,RIGHT             ]   
  liney     = [liney    ,MIDDLE            ,MIDDLE            ]
  lineprint = [lineprint,OFF               ,OFF               ]
  linecol   = [linecol  ,RED               ,BLUE              ]
  
  linenames = [linenames,'CS!D4!M63!N','CS!D5!M64!N','CS!D6!M65!N']
  linefreqs = [linefreqs,195.9542260  ,244.9356435  ,293.9122440  ]
  linealign = [linealign,RIGHT        ,RIGHT        ,RIGHT        ]   
  liney     = [liney    ,TOP          ,TOP          ,TOP          ]
  lineprint = [lineprint,ON           ,ON           ,ON           ]
  linecol   = [linecol  ,BLUE         ,RED          ,BLUE         ]
  
  linenames = [linenames,'SiO!D5!M64!N','SiO!D6!M65!N','SiO!D7!M66!N']
  linefreqs = [linefreqs,217.1049800   ,260.5180200   ,303.9269600   ]
  linealign = [linealign,LEFT          ,LEFT          ,LEFT          ]   
  liney     = [liney    ,MIDDLE        ,BOTTOM        ,BOTTOM        ]
  lineprint = [lineprint,OFF           ,OFF           ,OFF           ]
  linecol   = [linecol  ,BLUE          ,BLUE          ,BLUE          ]
  
  linenames = [linenames,'HCN!D3!M62!N','HNC!D3!M62!N','HCO!E+!D3!M62!N']
  linefreqs = [linefreqs,265.8861800   ,271.9811420   ,267.5576190      ]
  linealign = [linealign,LEFT          ,LEFT          ,RIGHT            ]   
  liney     = [liney    ,BOTTOM           ,MIDDLE        ,TOP              ]
  lineprint = [lineprint,ON            ,ON            ,ON               ]
  linecol   = [linecol  ,BLUE          ,BLUE          ,RED              ]

  linenames = [linenames,'3-2','4-3','CI 1-0', '5-4','6-5','7-6','CI 2-1']
  linefreqs = [linefreqs,345.8,461.0,492.16,576.3,691.47,806.65, 809.34  ]
  linealign = [linealign,LEFT ,LEFT ,RIGHT , LEFT,RIGHT ,LEFT,RIGHT]   
  liney     = [liney    ,TOP  ,MIDDLE,TOP, TOP, TOP ,TOP ,BOTTOM  ]
  lineprint = [lineprint,ON   ,ON   ,ON ,ON  , ON ,ON ,ON]
  linecol   = [linecol  ,BLUE ,BLUE ,BLUE, BLUE, BLUE ,BLUE,RED      ]
  
  linenames = [linenames,'8-7','9-8', '10-9', '11-10','12-11', '13-12']
  linefreqs = [linefreqs,921.800,1036.912,1152.,1267.,1381.995 ,1496.92     ]
  linealign = [linealign,LEFT ,LEFT ,RIGHT , RIGHT , RIGHT, RIGHT    ]   
  liney     = [liney    ,TOP   ,MIDDLE ,TOP , TOP , TOP , TOP    ]
  lineprint = [lineprint,ON   ,ON   ,ON    , ON  , ON, ON   ]
  linecol   = [linecol  ,BLUE,BLUE,BLUE,BLUE,BLUE,BLUE   ]
    
  IF KEYWORD_SET(LINES_ON) THEN lineprint = LINES_ON

  IF KEYWORD_SET(NO_LINES) THEN lineprint = REPLICATE(OFF,N_E(linenames))

  IF KEYWORD_SET(ALL_LINES) THEN lineprint = REPLICATE(ON,N_E(linenames))

  nlines = N_E(linenames)
  FOR line = 0, nlines - 1 DO BEGIN
     IF lineprint[line] EQ ON THEN BEGIN
        currfreq = linefreqs[line]*(1./(1.+redshift))
        OPLOT, [currfreq,currfreq],[ymin,ymax],col=linecol[line],line=2,thick=2.
        XYOUTS, currfreq-1, liney[line], linenames[line], $
                ALIGN = 1.0,col=linecol[line],charsize=1.0,$
                charthick=2,orientation=orient
     ENDIF
  ENDFOR
END
