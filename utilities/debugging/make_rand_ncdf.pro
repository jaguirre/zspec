; This proceedure takes the given path to an z-spec ncdf file and replaces the
; sin and cos varibles with 
; random noise + signal + chopper offset + glitches + constant DC level.
; The second argument new_pos_length is optional and if present, then new
; nodding, on_beam, off_beam & acquired flags are created and stored to
; the given ncdf file.  The value of new_pos_length is the number of samples
; in each nod position in the new flags.
;
; Out of necessity, it overwrites the given file and prompts the user to accept.
;
; KEYWORDS: CHANGE_SUFFIX - if set, strips suffix from ncfilepath_in and 
;                           changes it to .rand_nc
;           NO_PROMPT - if set, proceedure automatically overwrites given file
;                       without prompting for confirmation. USE WITH CARE.
;           DIAGNOSTIC - Set to a file name for a diagnostic plot (postscript)

PRO make_rand_ncdf, ncfilepath_in, new_pos_length, $
                    CHANGE_SUFFIX = CHANGE_SUFFIX, $
                    NO_PROMPT = NO_PROMPT, $
                    DIAGNOSTIC = DIAGNOSTIC
  
  IF KEYWORD_SET(CHANGE_SUFFIX) THEN $
     ncfilepath = change_suffix(ncfilepath_in,'_rand.nc') $
  ELSE ncfilepath = ncfilepath_in
                  

; First verify that overwriting file is ok, and be cautious
; Unless NO_PROMPT is set
  IF KEYWORD_SET(NO_PROMPT) THEN BEGIN
     PRINT, 'Overwriting data in given file:'
     PRINT, ncfilepath
     PRINT, 'Hopefully this is what you wanted.  Type Ctrl-C if it is not.'
  ENDIF ELSE BEGIN
     PRINT, 'This proceedure will overwrite data in the given file:'
     PRINT, ncfilepath
     PRINT, 'Is this ok?'
     accept = ''
     READ, accept, PROMPT = '[Y]es/[N]o: '
     CASE 1 OF
        STRCMP(accept, 'y', 1, /FOLD_CASE) : BEGIN
           PRINT, 'Ok, overwriting sin & cos with random data.'
        END
        STRCMP(accept, 'n', 1, /FOLD_CASE) : BEGIN
           PRINT, 'Exiting without overwriting.'
           RETURN
        END
        ELSE: BEGIN
           PRINT, 'Answer not recognized, exiting just to be safe.'
           RETURN
        ENDELSE
     ENDCASE
  ENDELSE
  
; Get size of data to create 
; Assumes sin (and cos) is array with dims nbox x nchan x ntod
  sin = read_ncdf(ncfilepath,'sin')
  sin_size = SIZE(sin)
  nbox = sin_size[1]
  nchan = sin_size[2]
  ntod = sin_size[3]

; Create and store or get the telescope flags & parse
  IF N_PARAMS() EQ 2 THEN BEGIN
     new_flags = make_fake_tel_flags(ntod,new_pos_length)
     cdfid = NCDF_OPEN(ncfilepath,/WRITE)

     nodding = new_flags.nodding
     varid = NCDF_VARID(cdfid,'nodding')
     NCDF_VARPUT,cdfid,varid,nodding

     on_beam = new_flags.on_beam
     varid = NCDF_VARID(cdfid,'on_beam')
     NCDF_VARPUT,cdfid,varid,on_beam

     off_beam = new_flags.off_beam
     varid = NCDF_VARID(cdfid,'off_beam')
     NCDF_VARPUT,cdfid,varid,off_beam

     acquired = new_flags.acquired
     varid = NCDF_VARID(cdfid,'acquired')
     NCDF_VARPUT,cdfid,varid,acquired
     
     NCDF_CLOSE, cdfid
  ENDIF ELSE BEGIN
     nodding = read_ncdf(ncfilepath, 'nodding')
     on_beam = read_ncdf(ncfilepath,'on_beam')
     off_beam = read_ncdf(ncfilepath,'off_beam')
     acquired = read_ncdf(ncfilepath,'acquired')
  ENDELSE
  nod_struct = find_onoff(find_nods(nodding),on_beam,off_beam,acquired)

; Process chopper signal
  chopper = read_ncdf(ncfilepath,'chop_enc')
  chop = make_chop_struct(chopper)

; Parameters of new data
; In future, these should change for different channels (MAYBE)
  sigma = 0.1                   ; standard deviation of random noise
  dc_level = 2.0                ; DC level
  sigamp = 4.0*[1.0,0.25,0.10]  ; signal amplitude (1Hz, 3Hz, & 5Hz)
  chopamp = 0.5                 ; chopper offset amplitude
  chopbolophase = [2.5,3.0,3.5]*1.0*!PI/4.0 
                                ; chopper offset phase shift (wrt chop)
  glitchamp = 10*sigma          ; glitch amplitude
  glitchpercent = 0.0           ; percentage of samples to make glitchy

; Create new timestreams
  dc_level = REPLICATE(dc_level, [nbox,nchan,ntod])

  chopoff = chopamp*(COS(chopbolophase[0])*chop.sin - $
                     SIN(chopbolophase[0])*chop.cos)
  chopoff = REPLICATE(CREATE_STRUCT('foo',chopoff),[nchan,nbox])
  chopoff = TRANSPOSE(chopoff.foo)

  signal =  sigamp[0]*(COS(chopbolophase[0])*chop.sin1 - $
                       SIN(chopbolophase[0])*chop.cos1)
  signal += sigamp[1]*(COS(chopbolophase[1])*chop.sin3 - $
                       SIN(chopbolophase[1])*chop.cos3)
  signal += sigamp[2]*(COS(chopbolophase[2])*chop.sin5 - $
                       SIN(chopbolophase[2])*chop.cos5)

  nnod = N_ELEMENTS(nod_struct)
  npos = N_ELEMENTS(nod_struct[0].pos)
  FOR nod = 0, nnod-1 DO BEGIN
     FOR pos = 0, npos-1 DO BEGIN
        signal[nod_struct[nod].pos[pos].i:nod_struct[nod].pos[pos].f] *= $
           nod_struct[nod].pos[pos].sgn
     ENDFOR
  ENDFOR
  signal = REPLICATE(CREATE_STRUCT('foo',signal),[nchan,nbox])
  signal = TRANSPOSE(signal.foo)
  
; Create random noise & random glitches for sin & cos separately
; and store complete new varibles.
  cdfid = NCDF_OPEN(ncfilepath,/WRITE)
  FOR i = 1,2 DO BEGIN
     CASE i OF
        1: varid = NCDF_VARID(cdfid,'sin')
        2: varid = NCDF_VARID(cdfid,'cos')
     ENDCASE

     noise = sigma*RANDOMN(seed,[nbox,nchan,ntod])

     ; Make a fraction of points positive or negative glitches
     glitches = RANDOMU(seed,[nbox,nchan,ntod])
     glitches[WHERE(glitches LT (1.0 - (glitchpercent/100.)), $
                    COMPLEMENT = whglitches, NCOMPLEMENT = nglitches)] = 0.0
     IF nglitches NE 0 THEN BEGIN
        temp = RANDOMU(seed,nglitches)
        temp[WHERE(temp LT 0.5, nnglitches)] = -glitchamp
        temp[WHERE(temp GE 0.5, npglitches)] = +glitchamp
        glitches[whglitches] = temp
     ENDIF ELSE BEGIN
        nnglitches = 0
        npglitches = 0
     ENDELSE

     npts = N_ELEMENTS(glitches)
     PRINT, 'Asked for       ', glitchpercent, '% glitches'
     PRINT, 'Ended up with   ', 100.*nglitches/FLOAT(npts), '% glitches'
     PRINT, 'Up   Fraction = ', npglitches/FLOAT(nglitches)
     PRINT, 'Down Fraction = ', nnglitches/FLOAT(nglitches)

     total = noise + signal + chopoff + glitches + dc_level
     
     NCDF_VARPUT, cdfid, varid, total
  ENDFOR
  NCDF_CLOSE, cdfid

  IF KEYWORD_SET(DIAGNOSTIC) THEN BEGIN
     SET_PLOT,'ps'
     DEVICE, FILE = DIAGNOSTIC, /COLOR
     DEVICE, /PORTRAIT, /INCHES, $
             XOFFSET=0.5,XSIZE=7.5,$
             YOFFSET=0.5,YSIZE=10
     nnods = N_ELEMENTS(nod_struct)
     FOR nod = 0, nnods-1 DO BEGIN
        ERASE
        multiplot,[1,5]
        xrange = [nod_struct[nod].i-50,nod_struct[nod].f+50]
        PLOT, acquired, XSTY=2, XRANGE=xrange, YSTY=1, YRANGE=[-0.2,1.2]
        OPLOT, on_beam+0.1, color = 2
        OPLOT, off_beam-0.1, color = 4
        FOR pl=0,3 DO OPLOT,[1,1]*nod_struct[nod].pos[pl].i,$
                            [-2.,2.],col=3,line=2
        FOR pl=0,3 DO OPLOT,[1,1]*nod_struct[nod].pos[pl].f,$
                            [-2.,2.],col=4,line=2
        
        multiplot
        PLOT, chop.sin, XSTY=2, XRANGE=xrange, $
              YSTY=1, YRANGE=1.1*MAX([chopamp,sigamp,1.0])*[-1.,1.]
        OPLOT, chopoff[0,0,*], color = 2
        OPLOT, signal[0,0,*], color = 4
        FOR pl=0,3 DO OPLOT,[1,1]*nod_struct[nod].pos[pl].i,$
                            2*MAX([chopamp,sigamp])*[-1.,1.],col=3,line=2
        FOR pl=0,3 DO OPLOT,[1,1]*nod_struct[nod].pos[pl].f,$
                            2*MAX([chopamp,sigamp])*[-1.,1.],col=4,line=2
        
        multiplot
        PLOT, noise[0,0,*], XSTY=2, XRANGE=xrange
        
        multiplot
        PLOT, glitches[0,0,*], XSTY=2, XRANGE=xrange, $
              YSTY=1, YRANGE = glitchamp*[-1.1,1.1]
        
        multiplot
        PLOT, total[0,0,*], XSTY=2, XRANGE=xrange
        OPLOT, dc_level[0,0,*], COLOR=2
     ENDFOR
     DEVICE,/CLOSE
     SET_PLOT,'x'
     multiplot,[1,1],/init,/verbose
     !P.NOERASE = 0 ; should be handled by multiplot,/reset but isn't
                    ; maybe I'm not using multiplot correctly.
  ENDIF

END
