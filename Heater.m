classdef Heater < handle
    
    properties
        SerialPort
        SerialObject
        VerboseMode = 0
        Data
        LastMessage
    end
    
    properties (Constant=true)
        BAUDRATE = 115200
    end
    
    methods (Access = public)
    
        function obj = Heater(port)
            obj.Data = struct;
            obj.Data.temperature = [];
            obj.Data.fanSpeed = [];
            obj.SerialPort = port;
            obj.configureSerialPort();
            pause(1)
            obj.streamData(1);
            
        end
        
        function streamData(obj, option)
            if(option==1)
                obj.sendToDevice('P',1);
            elseif(option==0)
                obj.sendToDevice('P',0);
            else
                warning('Stream Data Command only works with number: 1 (turn on), and 0 (turn off).');
            end
        end
        
        function setStreamFrequency(obj, freq)
            if(freq < 3.814639)
                warning('Frequenci must be bigger than 3.814639 Hz.');
            elseif(freq > 100)
                warning('Frequenci is too high, the simulation will be inaccurate.');
            else
                obj.sendToDevice('S',freq);
            end
        end
        
        function setFanSpeed(obj, speed)
            speed = round(speed);
            if(speed < 0 || speed > 100)
                warning('Fan speed command is accepted in range 0-100. This command was ignored.');
            else
                obj.sendToDevice('F',speed);
            end
        end
        
        function setHeaterPower(obj, option)
            option = round(option);
            if(option < 0 || option > 100)
                warning('Heater Power command is accepted in range 0-100. This command was ignored.');
            else
                obj.sendToDevice('H',option);
            end
        end
        
        function setVerboseMode(obj, option)
            if(option==1)
                obj.VerboseMode = 1;
            elseif(option==0)
                obj.VerboseMode = 0;
            else
                warning('Verbose Mode Command only works with number: 1 (turn on), and 0 (turn off).');
            end
        end
        
        function out = getTemperature(obj)
            out = obj.Data.temperature;
        end
        
        function out = getFanSpeed(obj)
            
            out = movmean(obj.Data.fanSpeed,7);
        end
        
        function close(obj)
            obj.setFanSpeed(0)
            obj.setHeaterPower(0)
            delete(obj.SerialObject)
        end
        
        function reopen(obj)
            obj.configureSerialPort();
            pause(1)
            obj.streamData(1);
        end
        
    end
    
    methods (Access = private)
    
        function configureSerialPort(obj)
            obj.SerialObject = serialport(obj.SerialPort, obj.BAUDRATE);
            configureTerminator(obj.SerialObject, 'CR/LF');
            flush(obj.SerialObject);
            configureCallback(obj.SerialObject,"terminator",@obj.readData);
        end
        
        function readData(obj, ser, ~)
            data = readline(ser);
            obj.LastMessage = data;
            if(obj.VerboseMode == 1)
                disp(data);
            end
            [~, d12] = strtok(data,':');
            [d1, d2]= strtok(d12,',');
            obj.Data.temperature = str2double(extractAfter(d1,':'));
            obj.Data.fanSpeed = str2double(extractBetween(d2,',','>'));
            
        end
        
        function sendToDevice(obj, command, value)
            obj.SerialObject.writeline(['<' command ':' num2str(value) '>']);
        end
        
    end
    
end