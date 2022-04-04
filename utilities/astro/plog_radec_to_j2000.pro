; Input & output coordinates should be in arcseconds

PRO plog_radec_to_j2000, ra_in, dec_in, mjd_in, ra_out, dec_out
  raplog = ra_in
  decplog = dec_in
  
  jd = mjd_in + 2400000.5d 
  epoch = epoch(mjd_in,/mjd)
  
; Calculate & subtract off aberration and nutation corrections 
  co_aberration, jd, raplog, decplog, d_ra_ab, d_dec_ab
  co_nutate, jd, raplog, decplog, d_ra_nu, d_dec_nu
  raplog -= (d_ra_ab + d_ra_nu)/3600.D
  decplog -= (d_dec_ab + d_dec_nu)/3600.D

  precess, raplog, decplog, epoch, 2000.D

  ra_out = raplog
  dec_out = decplog
END
  
