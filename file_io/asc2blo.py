#!/usr/bin/env python
#
# ASC2BLO
#
# Convert netdatatest asc output files into so-called "blo" format
# (so that the ZSPEC folks can read them with their IDL tools).
#
# Type "asc2blo.py" for more details
#
# Created:  Apr  5 2005 GSG
# Modified: Apr 20 2005 GSG : added AC and DC modes for Hien
#
# In AC mode, outputs the quadrature sum of the modulations for each channel
# In DC mode, outputs the 1st modulation (the 2nd is just the negative of that)

import math, string, struct, sys

########################################################################
# die - print an exit message, then quit

def die( retvalue, str ):
    sys.stderr.write(str + "\n")
    sys.exit(retvalue)


########################################################################
# dumpfloat - output a floating-point number in binary format

def dumpfloat(fp, x):
    fp.write(struct.pack("!f",x))

########################################################################
# These three modes are selectable, via the 3rd command-line argument

(NONE, AC, DC)= range(3)

########################################################################
# Parse arguments

if len(sys.argv) < 3 or len(sys.argv) > 4:
    die(1, "                                                   \n\
usage:   asc2blo.py [ascii filein] [binary fileout] [option]   \n\
example: asc2blo.py noise_ac_2.dat noise_ac_2.bin              \n\
         asc2blo.py noise_ac_2.dat noise_ac_2_ac.bin ac        \n\
         asc2blo.py noise_ac_2.dat noise_ac_2_dc.bin dc        \n\
")

infile, outfile= sys.argv[1:3]
mode= NONE
if len(sys.argv)==4:
    option= string.upper(sys.argv[3])
    if   (option[0]=="D"): mode= DC
    elif (option[0]=="A"): mode= AC

########################################################################
# Determine nsample and ncol, then rewind the input file

try: fin= open(infile, "r")
except: die(2, "Could not open input file " + infile)

nsample=1
ncol= len( string.split( fin.readline() ) )
while fin.readline(): nsample+=1
if mode!=NONE: ncol= 1+(ncol-1)/2
fin.seek(0)

print "ncol: " + `ncol`

########################################################################
# This is the default frequency for the datasystem. If necessary,
# we could compute this using the time column in the input data.

freq=100
period=nsample/freq

    
########################################################################
# Compose a 5-line output header

header= [""]*5
header[0]= "1/1/2005 1:11:11 AM\tBoDAC DAS Code Version 1.01\tAIDS\tBoDAC"
header[1]= "No.Pts/Chan\tScan Rate (Hz)\tSample Time (S)\tBias Freq (Hz)\tBias Vpp\tWaveform\tDcbiasequivalen"
header[2]= "%d\t%d\t%d\t%d\t%d\tsquare\t%d"%(nsample,100,period,0,0,0)
fields=["TIME"]
units=["(sec)"]
for i in range(1,ncol):
        fields.append( "CHAN 1-%d"%(i,) )
        units.append("(V)")
header[3]= string.join(fields,"\t")
header[4]= string.join(units,"\t")

########################################################################
# Write the header

try: fout= open(outfile, "w")
except: die(3, "Could not open output file " + outfile)
fout.write( string.join(header,"\r\n") )
fout.write("\r\n")

########################################################################
# Output binary data

line= fin.readline()
while line:
    
    # Break input line into fields of floating-point data
    field= map(float, string.split(line))

    # Dump binary output fields, depending on what mod we're in
    if mode==NONE: 
        for x in field: dumpfloat(fout, x)

    else:
        # Dump the time
        dumpfloat(fout, field[0])

        # Go through fields, grabing sine/cosine pairs
        # In AC mode, dump the quadrature sum of x and y
        # In DC mode, dump only x (y is just the negative of x anyway)
        for i in range(1,ncol*2-1,2):
            x,y= field[i], field[i+1]
            if   mode==AC: z= math.hypot(x,y)
            elif mode==DC: z=x
            dumpfloat( fout, z )
    
    # grab the next line
    line= fin.readline()
    
########################################################################
# Close both files

fin.close() 
fout.close()

