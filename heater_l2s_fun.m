function heater_l2s_fun(block)

    setup(block);

%endfunction

function setup(block)

    % Register number of ports
    block.NumInputPorts  = 2;
    block.NumOutputPorts = 2;

    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    % Register parameters
    block.NumDialogPrms     = 2;
    block.DialogPrmsTunable = {'Nontunable', ...
                               'Nontunable' ...
                              };

    block.SampleTimes = [block.DialogPrm(1).Data 0];

    block.SimStateCompliance = 'DefaultSimState';

    block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

function SetInputPortSamplingMode(block, idx, fd)
    
    block.InputPort(idx).SamplingMode = fd;
    block.OutputPort(1).SamplingMode = fd;
    block.OutputPort(2).SamplingMode = fd;
    
%end SetInputPortSamplingMode

function DoPostPropSetup(block)
    
    if block.SampleTimes(1) == 0
        throw(MSLException(block.BlockHandle,'Dicrete sampling time required'));
    end

%end DoPostPropSetup

function InitializeConditions(block)
    
    block.OutputPort(1).Data = 0;
    block.OutputPort(2).Data = 0;

%end InitializeConditions

function Start(block)

    global heater;
    
    heater = Heater(block.DialogPrm(2).Data);
    freq = round(1/block.DialogPrm(1).Data);
    heater.setStreamFrequency(freq);
    
%endfunction

function Outputs(block)
    
    global heater;
    
    block.OutputPort(1).Data = heater.getTemperature();
    block.OutputPort(2).Data = heater.getFanSpeed();

%end Outputs

function Update(block)
    
    global heater;
    heater.setFanSpeed(block.InputPort(1).Data);
    heater.setHeaterPower(block.InputPort(2).Data);

%end Update

function Derivatives(block)

%end Derivatives

function Terminate(block)
    
    global heater;
    heater.close();
    
 %end Terminate

