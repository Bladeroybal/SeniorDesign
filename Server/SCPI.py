import socket

class SCPI:
  HOST = "freyjr.ece.tamu.edu"
  PORT = 5025
  START = 1000000000
  STOP = 1500000000
  STEP = 2000

  def __init__(self, host=HOST, port=PORT):
    self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.s.connect((host, port))
    print("Connected to Freyjr")

  def preset(self):
    self.s.send("*IDN?\n")
    identity = self.s.recv(4096)
    print(identity)
    #To be added

  def identify(self):
    self.s.send("*IDN?\n")
    identity = self.s.recv(4096)
    print(identity)

  def closeConnection(self):
    self.s.close()

  def sweep(self, start=START, stop=STOP):
    print("Initializing sweep...")
    self.s.send("CALC2:PAR:SEL 'CH2_S21'\n")
    self.s.send("SENS1:FREQ:STAR %.2f\n"%(start,))
    self.s.send("SENS1:FREQ:STOP %.2f\n"%(stop,))
    self.s.send("SENS1:SWE:POIN %.2f\n"%(STEP,))
    self.s.send("INIT:IMM; *OPC?\n")

  def getData(self):
    print("Gathering data...")
    self.s.settimeout(1)
    buff = []
    self.s.send("CALC2:DATA? FDATA")

    while True:
      try:
	data = self.s.recv(1024)
	buf.append(data)
      except:
	socket.timeout
	break

    self.s.settimeout(None)
    records = "".join(buf).split(',')
    data = list()

    for entry in records:
      try:
	data.append(float(entry.strip(' \r\n')))
      except ValueError:
	print "Error: ", entry
    return data

  def reset(self):
    self.s.send("*RST\n")
    self.s.send("*CLS\n")

