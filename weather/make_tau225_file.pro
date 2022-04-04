;PRO MAKE_TAU225_FILE
;
;PURPOSE:
;  This procedure reads in all of the *spectra.sav files for
;  observations taken during a given month, and outputs a text file
;  containing the necessary tau information for properly doing the tau
;  correction (in uber_spectrum.pro). It is thus necessary to run
;  save_spectra.pro on all observations for that given month prior to
;  this step.
;
;CALLING SEQUENCE:
;  make_tau225_file, yyyymm [, outfile=outfile]
;
;REQUIRED INPUTS:
;  yyyymm - [float or string] The year and month for the observations
;           you want to make a tau table for.
;
;OPTIONAL INPUTS:
;  none
;
;OPTIONAL OUTPUTS:
;  outfile - [string] The name of the output text file. If not
;            specified, the tau table will be stored in a file called
;            'tau225_MMMYY.txt'. Will also save an IDL saveset by the
;            same name.
;
;REVISION HISTORY:
;  04/08/2010 - KSS - Added to SVN.
;  04/20/2010 - KSS - Now also outputs the save file.
;
;====================================================================
;WRITTEN BY: Kimberly Scott, UPenn
;CREATED: April 8, 2010
;====================================================================

pro make_tau225_file, yyyymm, outfile=outfile

;if input is not a string, change it
yyyymm = string(yyyymm,format='(I6)')

;search for all *spectra.sav files within this year/month range
sfiles = file_search(!zspec_data_root+'/ncdf/'+yyyymm+'*/*spectra.sav', $
                     count=nfiles)

;data are already sorted by UT date and time, so just initialize
;variables to read in and store
UTdate = -1L
UTtime = -1.
tau = -1.
tauerror = -1.
flag = -1

;loop over all *spectra.sav files and store UNIQUE tau readings only
for i = 0L, nfiles-1 do begin

    message, /cont, 'Processing file '+string(i)+' out of '+string(nfiles)
    restore, sfiles[i]
    UTi = strsplit(sfiles[i], '/', /extract, count=nsplit)
    UTi = UTi[nsplit-2]

    uind = uniq(rpc_params.tau_225_time)
    Utdate = [UTdate, replicate(UTi, n_elements(uind))]
    UTtime = [UTtime, rpc_params.tau_225_time[uind]]
    tau = [tau, rpc_params.tau_225[uind]]
    tauerror = [tauerror, rpc_params.tau_225_uncertainty[uind]]
    flag = [flag, replicate(1, n_elements(uind))]

endfor
UTdate = UTdate[1:*]
UTtime = UTtime[1:*]
tau = tau[1:*]
tauerror = tauerror[1:*]
flag = flag[1:*]

;avoid repeats
uind = uniq(UTtime)
UTdate = UTdate[uind]
UTtime = UTtime[uind]
tau = tau[uind]
tauerror = tauerror[uind]
flag = flag[uind]
ndata = n_elements(uind)

;print to text file
if not keyword_set(outfile) then begin
    yy = strmid(yyyymm, 2, 2)
    mm = strmid(yyyymm, 4, 2)
    case mm of
        '01':  mml = 'Jan'
        '02':  mml = 'Feb'
        '03':  mml = 'Mar'
        '04':  mml = 'Apr'
        '05':  mml = 'May'
        '06':  mml = 'Jun'
        '07':  mml = 'Jul'
        '08':  mml = 'Aug'
        '09':  mml = 'Sep'
        '10':  mml = 'Oct'
        '11':  mml = 'Nov'
        '12':  mml = 'Dec'
       else:  mml = '???'
    endcase
    outfile=strcompress(!zspec_pipeline_root+'/weather/tau225_'+mml+yy+'.txt',$
                        /remove)
endif
openw, lun, outfile, /get_lun
for i = 0L, ndata-1 do begin

    printf, lun, format='(I8, "       ", F5.2, "    ", F5.3, "   ", F5.3, "   ", I1)', UTdate[i], UTtime[i], tau[i], tauerror[i], flag[i]

endfor
close, lun
free_lun, lun

;and save in saveset
osfile = repstr(outfile, 'txt', 'sav')
save, filename=osfile, UTdate, UTtime, tau, tauerror, flag

end
