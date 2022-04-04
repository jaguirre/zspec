; Histogram plotting procedure, from Gumley,
; Practical IDL programming, p. 261
;
; Typed up by JK 11/13/08

PRO hist_plot, data, MIN=MIN_VALUE, MAX=MAX_VALUE, $
  BINSIZE=BINSIZE, NORMALIZE=NORMALIZE, FILL=FILL, $
  _EXTRA=EXTRA_KEYWORDS
  
;- Check arguments
if (n_params() ne 1) then message, 'Usage: hist_plot, data'
if (n_elements(data) eq 0) then message, 'Data is undefined.'

;- Check keywordsy.
if (n_elements(min_value) eq 0) then min_value=min(data,/Nan) ;NaN added by JRK 5/18/09
if (n_elements(max_value) eq 0) then max_value=max(data,/Nan) ;NaN added by JRK 5/18/09
if (n_elements(binsize) eq 0) then $
  binsize = (max_value - min_value)*0.01
binsize = binsize > ((max_value - min_value)*1.0e-5)

;- Compute histogram
hist=histogram(float(data),binsize=binsize,$
  min=min_value, max=max_value ,/NAN)  ;NaN added by JRK 5/18/09
hist=[hist, 0L]
nhist=n_elements(hist)

;- Normalize histogram if required
if keyword_set(normalize) then $
  hist = hist/float(n_elements(data))
  
;- Compute bin values
bins = lindgen(nhist) * binsize + min_value

;- Create plot arrays
x = fltarr(2*nhist)
x[2*lindgen(nhist)]=bins
x[2*lindgen(nhist)+1]=bins
y = fltarr(2*nhist)
y[2*lindgen(nhist)]=hist
y[2*lindgen(nhist)+1]=hist
y = shift(y,1)

;- Plot the histogram
plot,x,y,_extra=extra_keywords

;- Fill the histogram if required
if keyword_set(fill) then $
  polyfill,[x,[x0]],[x,y[0]],_extra=extra_keywords
  
END

