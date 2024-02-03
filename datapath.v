`include "alu.v"
`include "regfile.v"

module datapath #(parameter integer INITIAL_PC = 32'h00400000)
               (output wire Zero,  
                output reg [31:0] PC,
                output wire [31:0] dAddress, dWriteData, WriteBackData,
                input clk, rst, PCSrc, ALUSrc, RegWrite, MemToReg, loadPC,
                input [31:0] instr, input [3:0] ALUCtrl, input [31:0] dReadData);


// PC Incrementer
always @(posedge clk) begin
    if (rst) begin
        PC <= INITIAL_PC;
    end else if (loadPC) begin
        if (PCSrc) begin
            PC <= PC + branch_offset;
            end
        else begin
            PC <= PC + 4;
        end
    end
end

// Register File Functions
wire [4:0] readReg1, readReg2, writeReg;
wire [31:0] readData1, readData2;
assign readReg1 = instr[19:15];
assign readReg2 = instr[24:20];
assign writeReg = instr[11:7];
regfile regfile_inst(.readData1(readData1), .readData2(readData2), .writeData(WriteBackData), .readReg1(readReg1), .readReg2(readReg2), .writeReg(writeReg), .write(RegWrite), .clk(clk));


//Immediate Generator
parameter   BRANCH = 7'b1100011, 
            STORE = 7'b0100011, LOAD = 7'b0000011, 
            IMMEDIATE = 7'b0010011,
            IMMEDIATE_SLLI = 3'b001, 
            IMMEDIATE_SRLI_SRAI = 3'b101;

wire [31:0] sign_extended_imm = (instr[6:0]==IMMEDIATE && instr[14:12]==IMMEDIATE_SRLI_SRAI && instr[31:25]==7'b0000000) ? {{27{instr[31]}}, instr[24:20]} : //SRLI
                                (instr[6:0]==IMMEDIATE && instr[14:12]==IMMEDIATE_SRLI_SRAI && instr[31:25]==7'b0100000) ? {27'b0, instr[24:20]} : //SRAI (i only have to add zeroes)
                                (instr[6:0]==IMMEDIATE && instr[14:12]==IMMEDIATE_SLLI) ? {{27{1'b0}}, instr[24:20]} : //SLLI
                                (instr[6:0]==IMMEDIATE || instr[6:0]==LOAD) ? {{20{instr[31]}}, instr[31:20]} :
                                (instr[6:0]==STORE) ? {{20{instr[31]}}, instr[31:25], instr[11:7]} :
                                (instr[6:0]==BRANCH) ? {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]} : 0;

// ALU Operations
wire [31:0] alu_op1, alu_op2;
wire [3:0] alu_op;
assign alu_op = ALUCtrl;
assign alu_op1 = readData1;
assign alu_op2 = ALUSrc ? sign_extended_imm : readData2;
alu alu_inst(.result(dAddress), .zero(Zero), .op1(alu_op1), .op2(alu_op2), .alu_op(alu_op));

//Branch Target
wire [31:0] branch_offset = sign_extended_imm << 1;

//Write Back
assign WriteBackData = MemToReg ? dReadData : dAddress;
assign dWriteData = readData2;


endmodule
