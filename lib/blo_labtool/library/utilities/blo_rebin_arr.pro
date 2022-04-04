;+
;--------------------------------------------------------
; Procedure to reduce number of datapoints in data array
;
; Cuts x axis into equidistant intervals and
; averages x and y pairs found within these intervals.
;
; Input:
;	xin	(float) x-axis data
;	yin	(float) y-axis data
;	n	(int) number of desired bins
;
; Output:
;	rbx	(float) x-axis rebinned
;	rby	(float) y-axis rebinned
;
; Keywords:
;	yerr	(float) y-axis errors
;	weight	if set points are weighted with errors 
;	stdv    (float) y-axis standard deviations
;	nelem	(float) number of elements in each bin
;
; 28/11/97	initial test version		B. Schulz
; 18/02/98	arithm. LE problem fixed	B. Schulz
; 02/03/98	bug for negative x removed	B. Schulz
; 16/02/2000	limit n=50000 message		B. Schulz
; 17/03/2000	standard deviations		B. Schulz
; 26/04/2004	renamed for bolo_software	B. Schulz
;
;
;--------------------------------------------------------
;-

pro blo_rebin_arr, xin, yin, n, rbx, rby, $
	yerr=yerr, weight=weight, stdv=stdv, nelem=nelem

if n GT 50000 then begin
 print, 'Message from rebin_arr.pro:  n > 50000 OK??????'
 print, n
endif

x = double(xin)
y = double(yin)
if keyword_set(yerr) then e = double(yerr)

xmin = min(x)
xmax = max(x)

dx = (xmax - xmin) / n

rbx = fltarr(n)
rby = fltarr(n)
rbf = intarr(n)
if keyword_set(yerr) then rbe = fltarr(n)
if keyword_set(stdv) then stdv = fltarr(n)
if keyword_set(nelem) then nelem = fltarr(n)


for i=0l, n-1 do begin
  binlo = xmin+dx*i
  binhi = xmin+dx*(i+1)

  if i LT n-1 then ix = where(x GE binlo AND x LT binhi,cnt) $
  else 	           ix = where(x GE binlo AND x LE binhi+abs(binhi)*0.1,cnt)
  
  if cnt GT 0 then begin
    rbf(i) = 1
    
    if keyword_set(weight) and keyword_set(yerr) then begin
      xe = e(ix)/y(ix)*x(ix)	;generate error for x-values
      weight_avg, x(ix), xe(ix), tmp1
      rbx(i) = tmp1
      weight_avg, y(ix), e(ix), tmp1, tmp2
      rby(i) = tmp1
      rbe(i) = tmp2 
    endif else begin
      rbx(i) = avg(x(ix))
      rby(i) = avg(y(ix))
      if keyword_set(yerr) then $
        rbe(i) = sqrt(total(e(ix)^2))/cnt
    endelse

     
    if keyword_set(stdv) then $
        stdv(i) = sigma(y(ix))
    if keyword_set(nelem) then begin
        nelem(i) = cnt
    endif

  endif	;if cnt GT 0
endfor


ix = where(rbf NE 0,cnt)
if cnt GT 0 then begin
  rbx = rbx(ix)
  rby = rby(ix)
  if keyword_set(yerr) then $
	yerr = rbe(ix)
      if keyword_set(stdv) then $
        stdv = stdv(ix)
    if keyword_set(nelem) then $
	nelem = nelem(ix)
endif

end

