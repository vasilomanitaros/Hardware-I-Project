`include "calc.v"
`timescale 1ns / 1ps

module calc_tb ();

wire [15:0] led;
reg [15:0] sw;
reg clk, btnc, btnl, btnu, btnr, btnd;

initial begin
  #50 btnd =1'b0;
end

always begin
    #45 btnd = ~btnd;
    #3  btnd = ~btnd;
end

reg [2:0] btn_state;
//btn_state = {btnl,btnc,btnr};

calc calc_uut(.led(led), .sw(sw), .clk(clk), .btnc(btn_state[1]), .btnl(btn_state[2]), .btnu(btnu), .btnr(btn_state[0]), .btnd(btnd));

initial 
    begin 
        btnu = 1'b0;
    #15 btnu = 1'b1;
    #25 btnu = 1'b0;
end

initial
    begin
    clk=1'b0;
end

always
    begin
    #10 clk = ~clk;
end

initial
    begin
    $dumpfile("calc_tb.vcd");
    $dumpvars(0,calc_tb);
#50 btn_state = 3'b011; sw = 16'h1234;
#50 btn_state = 3'b010; sw = 16'h0ff0;
#50 btn_state = 3'b000; sw = 16'h324f;
#50 btn_state = 3'b001; sw = 16'h2d31;
#50 btn_state = 3'b100; sw = 16'hffff;
#50 btn_state = 3'b101; sw = 16'h7346;
#50 btn_state = 3'b110; sw = 16'h0004;
#50 btn_state = 3'b111; sw = 16'h0004;
#50 btn_state = 3'b101; sw = 16'hffff;

#700 $finish;
end


endmodule