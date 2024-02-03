`include "alu.v"
`include "calc_enc.v"

module calc 
    (output reg [15:0] led ,
    input wire [15:0] sw ,
    input wire clk, btnc, btnl, btnu, btnr, btnd);

wire [31:0] sw_32;
assign sw_32 = {{16{sw[15]}},sw};
wire [31:0] alu_result;
wire alu_zero;
reg [15:0] accumulator;
wire [31:0] op1_calc;
assign op1_calc = {{16{accumulator[15]}},accumulator};
wire [3:0] alu_op;
decoder decoder_calc(.alu_op(alu_op), .btnl(btnl), .btnc(btnc), .btnr(btnr));
alu alu_calc(.result(alu_result), .zero(alu_zero), .op1(op1_calc), .op2(sw_32), .alu_op(alu_op));

always @(posedge btnd) begin
    led = accumulator[15:0];
    accumulator <= alu_result[15:0];
end

always @(posedge clk) begin
    if (btnu) begin
        accumulator <= 16'b0000000000000000;
        end 
end

endmodule