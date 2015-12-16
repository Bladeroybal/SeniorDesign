import SCPI

freyjr = SCPI.SCPI()
while True:
  cmd = raw_input('Freyjr >>> ')
  if(cmd == "preset"):
    freyjr.preset()
    print("*Will set up and run predetermined frequency sweep*")
  elif(cmd == "identify"):
    freyjr.identify()
  #...
  elif(cmd == "exit"):
    print("Exiting...")
    freyjr.closeConnection()
    break
  else:
    print("Error: invalid command")
