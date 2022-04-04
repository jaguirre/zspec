;+
;===========================================================================
;  NAME:
;                   BLO_DISP_POWERSP
;
;  DESCRIPTION:
;                   Calculate powerspectrum and display in separate graphics
;                     window
;
;  USAGE:
;                   blo_disp_powersp, time, volts, ScanRateHz
;
;
;  INPUT:
;     time         (array double) time in seconds
;     data         (array double) (nchannels x nsignals) signal in Volts
;     ScanRateHz   (double)        scan rate in Hertz
;
;  OUTPUT:         new graphics screen with plot of powerspectrum and
;                  OK widget to terminate
;
;     fftout       (array double) (nchannels x npowerpoints) powers
;     frequ        (array double) frequency
;
;  KEYWORDS:
;     question     (string) question to display on input,
;                                       "Yes" or "No" on output
;                                       if "Yes" fftout is calculated
;     nopower      return simple fourier spectrum without normalization
;                  to W/sqrt[Hz]
;
;
;  AUTHOR:
;                  Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  2002/08/29   initial test version                    B.Schulz
;  2002/10/11   change to produce output                B.Schulz
;  2003/05/16   keyword nopower added                   B.Schulz
;  2003/07/09   keyword deglitch added                  B.Schulz
;  2003/07/10   bugfix keyword deglitch                 B.Schulz
;  2004/02/29   lower frequency limit for fft           B.Schulz
;
;
;===========================================================================
;-

pro blo_disp_powersp, time, data, chan, ScanRateHz, $
                        frequ, fftout, question=question, $
                        nopower=nopower, deglitch=deglitch

winmem = !D.WINDOW              ;save drawing # of window
window, /free, title='Power Spectrum', xsize=600, ysize=600     ;make drawing window
wincur = !D.WINDOW              ;current window

volts = data(chan,*)    ;pick channel

nvolts = n_elements(volts)

nchan = n_elements(data(*,0))   ;number of channels

blo_noise_powersp_f, volts, nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch
;blo_noise_powerspec, volts, nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch

nfrequ = n_elements(stransf)
frequ = findgen(nfrequ)*ScanRateHz/(nfrequ*2+1)
;frequ = findgen(nvolts/2+1L)*ScanRateHz/nvolts

if keyword_set(nopower) then ytitle = 'FFT' else ytitle = 'Power'

ix = where(frequ GT 0, cnt)
if cnt GT 1 then begin
  plot_oi, frequ(ix), stransf(ix), xtitle='Frequency [Hz]', ytitle=ytitle, $
                xstyle=3, ystyle=3, linestyle=0, color=blo_color_get('white')
endif


if keyword_set(question) then begin
  question = dialog_message(question,/default_no, /question)
  if question EQ 'Yes' then begin
    n_data = n_elements(stransf)
    fftout = dblarr(nchan, n_data)      ;calculate all powerspectra if yes
    for i=0, nchan-1 do begin
      blo_noise_powersp_f, data(i,*), nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch
      ;blo_noise_powerspec, data(i,*), nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch
      fftout(i,*) = stransf
    endfor
  endif

endif else begin
  x = dialog_message("Click 'OK' to continue!")
endelse

wdelete, wincur
wset, winmem   ;set back to previous drawing window

end
