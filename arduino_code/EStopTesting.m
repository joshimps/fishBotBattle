serialportlist("available")'
arduinoObj = serialport("/dev/ttyACM0",9600);
configureTerminator(arduinoObj,"CR/LF");
flush(arduinoObj);

while true
    arduinoObj.UserData = struct("Data",[],"Count",1);
    data = readline(arduinoObj)
    arduinoObj.UserData.Data(end+1) = str2double(data); 
    arduinoObj.UserData.Count = arduinoObj.UserData.Count + 1;
    display(data)
end