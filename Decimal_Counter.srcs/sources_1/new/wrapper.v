`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2023 15:00:45
// Design Name: 
// Module Name: wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrapper(CLK, RESET, ENABLE, SEG_SELECT, DEC_OUT, INDICATOR
    );
    
    input CLK, RESET, ENABLE;
    output [3:0] SEG_SELECT;
    output [7:0] DEC_OUT;
    output INDICATOR; //if the counting is reached the max, this is a carry

    wire Bit17TriggOut;
    wire [16:0]Bit17Count;
    wire [1:0] Bit2CounterControl;
    wire Bit4TriggOutBase, Bit4TriggOut0, Bit4TriggOut1, Bit4TriggOut2, Bit4TriggOut3;
    wire [4:0] Bit4CountValueDot0, Bit4CountValueDot1, Bit4CountValueDot2, Bit4CountValueDot3;
    wire [3:0] Bit4CountValue0, Bit4CountValue1, Bit4CountValue2, Bit4CountValue3;
    wire [4:0] Mux4Out;
    wire Enableand;


    Generic_Counter #   (.COUNTER_WIDTH(17), .COUNTER_MAX(11999))
                        Bit17Counter (.CLK(CLK), .RESET(1'b0), .ENABLE_IN(1'b1), .COUNT(Bit17Count), .TRIG_OUT(Bit17TriggOut));


    Generic_Counter #   (.COUNTER_WIDTH(2), . COUNTER_MAX(3))
                        Bit2Counter (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Bit17TriggOut), .COUNT(Bit2CounterControl));
    

    Generic_Counter #   (.COUNTER_WIDTH(4), .COUNTER_MAX(9))
                    Bit4CounterBase (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Enableand), .TRIG_OUT(Bit4TriggOutBase));

    
    Generic_Counter #   (.COUNTER_WIDTH(4), .COUNTER_MAX(9))
                    Bit4Counter0 (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Bit4TriggOutBase), .COUNT(Bit4CountValue0), .TRIG_OUT(Bit4TriggOut0));

    
    Generic_Counter #   (.COUNTER_WIDTH(4), .COUNTER_MAX(9))
                    Bit4Counter1 (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Bit4TriggOut0), .COUNT(Bit4CountValue1), .TRIG_OUT(Bit4TriggOut1));


    Generic_Counter #   (.COUNTER_WIDTH(4), .COUNTER_MAX(9))
                    Bit4Counter2 (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Bit4TriggOut1), .COUNT(Bit4CountValue2), .TRIG_OUT(Bit4TriggOut2));

    
    Generic_Counter #   (.COUNTER_WIDTH(4), .COUNTER_MAX(9))
                    Bit4Counter3 (.CLK(CLK), .RESET(RESET), .ENABLE_IN(Bit4TriggOut2), .COUNT(Bit4CountValue3), .TRIG_OUT(Bit4TriggOut3));


    Mux4 Mux4(.CONTROL(Bit2CounterControl), .IN0(Bit4CountValueDot0), .IN1(Bit4CountValueDot1), .IN2(Bit4CountValueDot2), .IN3(Bit4CountValueDot3), .OUT(Mux4Out));


    seven_seg seven_seg(.x(Mux4Out[3:0]), .SEG_SELECT_IN(Bit2CounterControl), .dot(Mux4Out[4]), .cat(SEG_SELECT), .seg(DEC_OUT));

    assign INDICATOR = Bit4TriggOut3;

    assign Bit4CountValueDot0 = {1'b0, Bit4CountValue0};
    assign Bit4CountValueDot1 = {1'b0, Bit4CountValue1};
    assign Bit4CountValueDot2 = {1'b1, Bit4CountValue2};
    assign Bit4CountValueDot3 = {1'b0, Bit4CountValue3};
    assign Enableand = ~ENABLE & Bit17TriggOut;  //"not" logic because it is a button
endmodule
