serialportlist("available")'
arduinoObj = serialport("/dev/ttyACM0",9600);
configureTerminator(arduinoObj,"CR/LF");
flush(arduinoObj);
arduinoObj.UserData = struct("Data",[]);

while true
    data = readline(arduinoObj)
    str2double(data)
end