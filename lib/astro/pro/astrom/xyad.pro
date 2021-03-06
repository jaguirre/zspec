pro xyad, hdr, x, y, a, d, PRINT = print, GALACTIC = galactic, ALT = alt, $
         CELESTIAL = celestial, ECLIPTIC = ecliptic, PRECISION = precision
; NAME:
;       XYAD
; PURPOSE:
;       Use a FITS header to convert pixel (X,Y) to astronomical coordinates
; EXPLANATION: 
;       Use astrometry in a FITS image header to compute astronomical
;       coordinates in decimal degrees from X and Y.  
;
; CALLING SEQUENCE:
;       XYAD, HDR               ;Prompt for X and Y positions
;       XYAD, HDR, X, Y, A, D, [ /PRINT, /Galactic, /Celestial, /Ecliptic, 
;                                ALT =, PRECISION=]
; INPUTS:
;       HDR - FITS Image header containing astrometry info
;
; OPTIONAL INPUTS:
;       X     - row position in pixels, scalar or vector
;       Y     - column position in pixels, scalar or vector
;
;       X and Y should be in IDL convention, (first pixel is (0,0) where
;       the integral value corresponds to the center of the pixel.)
;
; OPTIONAL OUTPUT:
;       A - Output longitude in decimal DEGREES, same number of elements as
;               X and Y.    For celestial coordinates, this is the right 
;               ascension.
;       D - Output latitude in decimal DEGREES.   For celestial coordinates,
;               this is the declination.
; OPTIONAL KEYWORD INPUT:
;       ALT -  single character 'A' through 'Z' or ' ' specifying an alternate 
;             astrometry system present in the FITS header.    The default is
;             to use the primary astrometry or ALT = ' '.   If /ALT is set, 
;             then this is equivalent to ALT = 'A'.   See Section 3.3 of 
;             Greisen & Calabretta (2002, A&A, 395, 1061) for information about
;             alternate astrometry keywords.
;       PRECISION - Integer scalar (0-4) specifying the number of digits 
;             displayed after the decimal of declination.   The RA is
;             automatically one digit more.   See ADSTRING() for more info.
;             Default value is 1, and the keyword is ignored if results are not 
;             displayed at the terminal 
;       /PRINT - If this keyword is set and non-zero, then results are displayed
;               at the terminal.in both decimal and sexigesimal notation.
;
;       The default for XYAD is to return the coordinate system present in
;       in the FITS header.    However, the following mutually exclusive 
;       keywords can be used to convert to a particular coordinate system:
;
;       /CELESTIAL - Output is Right Ascension and declination
;       /ECLIPTIC - Output is Ecliptic longitude and latitude
;       /GALACTIC - Output is Galactic longitude and latitude
;    
; OPERATIONAL NOTES:
;       If less than 5 parameters are supplied, or if the /PRINT keyword is
;       set, then the computed astronomical coordinates are displayed at the 
;       terminal.
;
;       If this procedure is to be used repeatedly with the same header,
;       then it would be faster to use XY2AD.
;
; EXAMPLE:
;       A FITS header, hdr, contains astrometric information in celestial
;       coordinates.   Find the RA and Dec corresponding to position X=23.3
;        Y = 100.2 on an image
;        IDL> xyad, hdr, 23.3, 100.2      ;Displays results at the terminal
;       To display the results in Galactic coordinates
;        IDL> xyad, hdr, 23.3, 100.2, /GALACTIC
; PROCEDURES CALLED
;       ADSTRING(), EULER, EXTAST, GSSSXYAD, REPCHR(),  XY2AD
;
; REVISION HISTORY:
;       W. Landsman                 STX          Jan, 1988
;       Use astrometry structure  W. Landsman    Jan, 1994
;       Recognize GSSS header  W. Landsman       June, 1994
;       Changed ADSTRING output format   W. Landsman    September 1995
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Use vector call to ADSTRING() W. Landsman February 2000
;       Added ALT input keyword  W. Landsman June 2003
;       Add precision keyword  W. Landsman February 2004
;       Fix display if 'RA','DEC' reversed in CTYPE  W. Landsman Feb. 2004
;       Handle display of NaN values W. Landsman May 2004
;-
 On_error,2

 npar = N_params()
 if ( npar EQ 0 ) then begin
        print,'Syntax -  XYAD, hdr, [x, y, a, d, /PRINT, Alt=, Precision=, '
        print,'                      /Galactic, /Celestial, /Ecliptic ]'
        print,'HDR - FITS header (string array) containing astrometry'
        print,'X,Y - Input X and Y positions (scalar or vector)'
        print,'A,D - Output RA and Dec in decimal degrees'
        return
 endif                                                         

  extast, hdr, astr, noparams, ALT = alt       ;Extract astrometry structure

  if ( noparams LT 0 ) then $ 
        message,'ERROR - No astrometry info in supplied FITS header'

  if ( npar lt 3 ) then read,'XYAD: Enter X and Y positions: ',x,y

  case strmid(astr.ctype[0],5,3)  of 
        'GSS': gsssxyad, astr, x, y, a, d
         else: xy2ad, x, y, astr, a, d
  endcase
  titname = strmid(astr.ctype,0,4)
  if (titname[0] EQ 'DEC-') or (titname[0] EQ 'ELAT') or $
          (titname[0] EQ 'GLAT') then titname = rotate(titname,2)

  if keyword_set(GALACTIC) then begin
      case titname[0] of 
      'RA--': euler, a,d, select=1
      'ELON': euler, a,d, select=5
      else:
      endcase
      titname = ['GLON','GLAT']
  endif else if keyword_set(ECLIPTIC) then begin 
      case titname[0] of 
      'RA--': euler, a, d, select=3
      'GLON': euler, a,d, select=6
      else: 
      endcase
      titname = ['ELON','ELAT']
  endif else if keyword_set(CELESTIAL) then begin
      case titname[0] of 
      'ELON': euler, a, d, select=4
      'GLON': euler, a,d, select=2
      else: 
      endcase
      titname = ['RA--','DEC-']
  endif 

  if (npar lt 5) or keyword_set(PRINT) then begin
        g = where( finite(d) and finite(a), Ng)
        titname  = repchr(titname,'-',' ')
        npts = N_elements(X)
        fmt = '(2F8.2,2x,2F9.4,2x,A)'
        print,'    X       Y         ' + titname[0] + '     ' + titname[1] +$
	      '       ' + titname[0] + '         ' + titname [1]
        if N_elements(precision) EQ 0 then precision = 1
        str = replicate('    ---          ---    ', Npts)
        if Ng GT 0 then str[g] = adstring(a[g],d[g],precision)
        for i=0l, npts-1 do $
        print,FORMAT=fmt, float(x[i]), float(y[i]), a[i], d[i], str[i]
   endif
   
   return
   end
