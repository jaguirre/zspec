#!/usr/bin/env /usr/bin/python
import sys, types, getopt, string, socket

global host, port, sock
host="localhost"
port=1980
sock=None

def print_help():
  print "Simple UDP Socket telnet program"
  print "Use: udptelnet.py --host host --port port"


def print_fr_help():
  print "Exiting"
  sys.exit(1)

def process_options():
  global host, port
  longopts = ['host=', 'port=', 'help']
  shortopts = 'h:p:?'
  opts, args = getopt.getopt(sys.argv[1:], shortopts, longopts)

  for o,a in opts:
    if o in ('-?', '--help'):
      print_help()
      sys.exit()
    elif o in ('--host', '-h'):
      host = a
    elif o in ('--port', '-p'):
      port = int(a)
    else:
      print "Unknown option " + o
      sys.exit()

def open_socket():
  global sock, host, port
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

process_options()
open_socket()
while (1):
  addr=host,port
  try:
    c = raw_input("UDPtelnet> ")
  except EOFError:
    print "\nExiting.."
    sock.close()
    sys.exit(1)
  if (string.rstrip(c)=='?'):
    print_fr_help()
  else:
    sock.sendto(c+'\n',addr)
    if (len(c)>1):
      resp,fromaddr=sock.recvfrom(1024)
      print string.rstrip(resp)
