PRO print_ncdf_vars, ncfile
  cdfid = NCDF_OPEN(ncfile,/NOWRITE)
  cdfinq = NCDF_INQUIRE(cdfid)
  ;; first, get the dimensions
  dimnames = REPLICATE('',cdfinq.ndims)
  PRINT, 'Dimensions'
  PRINT, 'Name, Size'
  PRINT, '----------'
  FOR dim = 0, cdfinq.ndims - 1 DO BEGIN
     NCDF_DIMINQ, cdfid, dim, dimname, dimsize
     dimnames[dim] = dimname
     PRINT, dimname, dimsize
  ENDFOR
  ;; now, print variable information
  PRINT, ''
  PRINT, 'Variables'
  PRINT, 'Name, Type, Attributes, Dimensions'
  PRINT, '----------------------------------'
  FOR var = 0, cdfinq.nvars - 1 DO BEGIN
     infostring = ''
     varinq = NCDF_VARINQ(cdfid,var)
     infostring = STRING(varinq.name) + ', ' + STRING(varinq.datatype) + ', '
     FOR att = 0, varinq.natts - 1 DO $
        infostring += NCDF_ATTNAME(cdfid,var,att) + ', '
     PRINT, infostring, dimnames[varinq.dim]
  ENDFOR
  NCDF_CLOSE, cdfid
END
