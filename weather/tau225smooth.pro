;created 2007-05-08 LE
;basically copied from Darren Dowell's C code which does the same
;thing
;
;Given a text file with tau data it gives a gaussian smoothed mean
;
;You need to define text file with april 06 tau data with the following
;columns:
;UTdate, UTtime (in hours from start of UTdate), tau225, error, flag
;
;date is a string like 20060414 for observation on Apr 14 2006
;time is # of hours from start of the given date (in UT)
;
;Edit 12/15/08 JK: added 200612 and 200701 cases.
;Edit 04/08/10 KSS: added 200911, 200912, 201003, and 201004 cases.
;Edit 04/20/10 KSS: procedure now stops if there are not enough values
;                   for the smooth tau estimate so the user is fully
;                   warned of what's going on and can fix the problem
;Edit 05/10/10 KSS: Added case for May 2010

function tau225smooth,date,time,SIGMA = SIGMA

taudatadir=!zspec_pipeline_root+'/weather/'

yearmo=strmid(date,0,6)

case yearmo of
    '200612':file=taudatadir+'tau225_winter06.txt'
    '200701':file=taudatadir+'tau225_winter06.txt'
    '200705':file=taudatadir+'tau225_May07.txt'
    '200704':file=taudatadir+'apr2007_tau225.txt'
    '200711':file=taudatadir+'tau225_winter07.txt'
    '200712':file=taudatadir+'tau225_winter07.txt'
    '200803':file=taudatadir+'tau225_spring08.txt'
    '200804':file=taudatadir+'tau225_spring08.txt'
    '200901':file=taudatadir+'tau225_jan09.txt'
    '200902':file=taudatadir+'tau225_Feb09.txt'
    '200903':file=taudatadir+'tau225_Feb09.txt'
    '200904':file=taudatadir+'tau225_Apr09.txt'
    '200911':file=taudatadir+'tau225_Nov09.txt'
    '200912':file=taudatadir+'tau225_Dec09.txt'
    '201001':file=taudatadir+'tau225_Jan10.txt'
    '201003':file=taudatadir+'tau225_Mar10.txt'
    '201004':file=taudatadir+'tau225_Apr10.txt'
    '201005':file=taudatadir+'tau225_May10.txt'
    '201010':file=taudatadir+'tau225_fall10.txt'
endcase

savfile = change_suffix(file,'sav')
IF FILE_TEST(savfile) THEN BEGIN
   RESTORE, savfile
ENDIF ELSE BEGIN
   readcol,file,UTdate,UTtime,tau,tauerror,flag,$
           format='(a8,f6.4,f5.3,f5.5,i1)'
   SAVE, UTdate, UTtime, tau, tauerror, flag, FILE = savfile
ENDELSE

want_data=where(UTdate eq date and flag eq 1)
UTdate=UTdate[want_data]
UTtime=UTtime[want_data]
tau=tau[want_data]
tauerror=tauerror[want_data]

datapointsused=n_e(want_data)

IF ~KEYWORD_SET(SIGMA) THEN sigma = 0.5
;sigma=0.5
min_tauerror=0.005
sum0=0.0d
sum1=0.0d
sum2=0.0d
min_weight=1.0

print,'smoothing tau data....'

for i=0, datapointsused-1 do begin

    f=UTtime[i]-time
    f=exp(-0.5*f^2./sigma^2.)
    if tauerror[i] lt min_tauerror then $
      tauerror[i]=min_tauerror
    sum0+=1.0*f
    sum1+=1.0*f/(tauerror[i]*tauerror[i])
    sum2+=tau[i]*f/(tauerror[i]*tauerror[i])

endfor

if sum0 ge min_weight then begin
    smoothed_tau=sum2/sum1
;    print,'The tau is ' & print, smoothed_tau
;    print, 'The weight sum is' & print, sum0
endif else begin

    smoothed_tau=0
    message, 'Not enough data points for smooth tau estimate! Quitting...'
;    print,'Weight sum is = ' & print, sum0

endelse


return,smoothed_tau
end
