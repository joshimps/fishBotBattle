serialportlist("available")'
arduinoObj = serialport("/dev/ttyACM1",9600);
configureTerminator(arduinoObj,"CR/LF");
flush(arduinoObj);
arduinoObj.UserData = struct("Data",[]);

while true
    data = readline(arduinoObj);
    arduinoObj.UserData.Data(1) = data;
    str2double(data)
end