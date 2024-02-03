`include "top_proc.v"
`include "ram.v"
`include "rom.v"
`timescale 1ns / 1ps


module cpu_tb();

wire [8:0] addr;
reg clk,rst;
wire [31:0] instr, dReadData;

multicycle cpu(.clk(clk),.rst(rst), .instr(instr), .dReadData(dReadData));
INSTRUCTION_MEMORY imem(.clk(clk), .addr(cpu.PC[8:0]), .dout(instr));
DATA_MEMORY dmem(.clk(clk), .we(cpu.MemWrite), .addr(cpu.dAddress[8:0]), .din(cpu.dWriteData), .dout(dReadData));

initial
    begin
    clk=1'b0;
end

initial
    begin
    rst=1'b1;
#40 rst=1'b0;
end

always
    begin
    #10 clk = ~clk;
end

initial
    begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0,cpu_tb);
#2800   $finish;

end


endmodule