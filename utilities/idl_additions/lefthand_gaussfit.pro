; Computes a left-hand gaussian fit to a given set of points (x,y).
; It first computes the weighted mean of the histogram as the
; approximate mean of the data, runs gaussfit over x,y where x < mean,
; then returns a fit vector extended over all x, using gaussfit's
; returned parameters.  The final fit parameters are returned in a.
function lefthand_gaussfit,x,y,a,neg_valid=neg_valid

mean=double(total(x*y))/total(y)
if(not keyword_set(neg_valid)) then neg_valid=where(x lt mean)
lh_fit=gaussfit(x[neg_valid],y[neg_valid],a,nterms=3)

; Use parameters to extend fit
z=(x-a[1])/a[2]
return,a[0]*exp(-z^2.0/2.0)

end
