`include "datapath.v"

module multicycle #(parameter integer INITIAL_PC = 32'h00400000)
               (output wire [31:0] PC,
                output wire [31:0] dAddress, dWriteData, WriteBackData,
                output reg MemRead, MemWrite,
                input clk, rst,
                input [31:0] instr, dReadData);

wire Zero, PCSrc, ALUSrc, MemToReg;
reg RegWrite, loadPC;
wire [3:0] ALUCtrl;

parameter [2:0]     FUNCT3_ADD_SUB  = 3'b000,
                    FUNCT3_SLL  = 3'b001,
                    FUNCT3_SLT  = 3'b010,
                    FUNCT3_XOR  = 3'b100,
                    FUNCT3_SRL_SRA  = 3'b101,
                    FUNCT3_OR   = 3'b110,
                    FUNCT3_AND  = 3'b111;

parameter  [3:0]    ALUOP_AND   = 4'b0000, //AND = Bitwise AND
                    ALUOP_OR    = 4'b0001, //OR  = Bitwise OR
                    ALUOP_ADD   = 4'b0010, //ADD = addition
                    ALUOP_SUB   = 4'b0110, //SUB = subtraction
                    ALUOP_SLT   = 4'b0111, //SLT = Set Less Than
                    ALUOP_SRL   = 4'b1000, //SRL = Shift Right Logical OP2BITS
                    ALUOP_SLL   = 4'b1001, //SLL = Shift Left Logical OP2BITS
                    ALUOP_SRA   = 4'b1010, //SRA = Shift Right Arithmetic OP2BITS
                    ALUOP_XOR   = 4'b1101; //XOR = Exclusive OR

parameter  IF=3'b000, ID=3'b001, EX=3'b010, MEM=3'b011, WB=3'b100;
parameter BRANCH = 7'b1100011, STORE = 7'b0100011, LOAD = 7'b0000011, IMMEDIATE = 7'b0010011, REGISTER = 7'b0110011;

datapath #(INITIAL_PC) datapath_uut (.Zero(Zero), .PC(PC), .dAddress(dAddress), .dWriteData(dWriteData), .WriteBackData(WriteBackData),
                      .clk(clk), .rst(rst), .PCSrc(PCSrc), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemToReg(MemToReg), .loadPC(loadPC),
                      .instr(instr), .ALUCtrl(ALUCtrl), .dReadData(dReadData));

wire [6:0] opcode = instr[6:0];
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];

reg [2:0] current_state,next_state;

//1st for state transition
always @(posedge clk) begin
    if (rst) begin
        current_state <= IF;
    end 
    else begin
        current_state <= next_state;
    end
end

//2nd for output logic
always @(current_state) begin
    case (current_state)
        IF: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0;
            loadPC = 1'b0;
        end
        ID: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0;
            loadPC = 1'b0;
        end
        EX: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0;
            loadPC = 1'b0;
        end 
        MEM: begin
            MemRead = (opcode==LOAD) ? 1'b1 : 1'b0;
            MemWrite = (opcode==STORE) ? 1'b1 : 1'b0;
            RegWrite = 1'b0;
            loadPC = 1'b0;
        end
        WB: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            RegWrite = (opcode==STORE) ? 1'b0 : (opcode==BRANCH) ? 1'b0 : 1'b1;
            loadPC = 1'b1;
        end
        default: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            RegWrite = 1'b0;
            loadPC = 1'b0;
        end
    endcase
end

//3rd for the next state logic
always @(current_state) begin
    case (current_state)
        IF: begin
            next_state = ID;
        end
        ID: begin
            next_state = EX;
        end
        EX: begin
            next_state = MEM;
        end
        MEM: begin
            next_state = WB;
        end
        WB: begin
            next_state = IF;
        end
        default: begin
            next_state = IF;
        end
    endcase
end

//Combinational Logic unspecified by the state machine
assign ALUCtrl =    (funct3 == FUNCT3_AND) ? ALUOP_AND :
                    (funct3 == FUNCT3_OR)  ? ALUOP_OR  :
                    (funct3 == FUNCT3_ADD_SUB) && (funct7 == 7'b0000000) && (opcode == REGISTER ) ? ALUOP_ADD : 
                    // the check for the opcode is necessary to recognize the ADDI command from the SUB command because ADDI doesnt have funct7
                    (funct3 == FUNCT3_ADD_SUB) && (opcode == IMMEDIATE) ? ALUOP_ADD : //ADDI command
                    (opcode == LOAD) ? ALUOP_ADD : //LW command  //FUNCT3_SLT  = 3'b010 
                    (opcode == STORE) ? ALUOP_ADD : //SW command
                    // the check for the funct7 is necessary to recognize the ADD command from the SUB command
                    (funct3 == FUNCT3_ADD_SUB) && (funct7 == 7'b0100000) ? ALUOP_SUB :
                    (funct3 == FUNCT3_SLT) && (funct7 == 7'b0000000) ? ALUOP_SLT :
                    (funct3 == FUNCT3_SLL) ? ALUOP_SLL :
                    (funct3 == FUNCT3_SRL_SRA) && (funct7 == 7'b0000000) ? ALUOP_SRL :
                    (funct3 == FUNCT3_SRL_SRA) && (funct7 == 7'b0100000) ? ALUOP_SRA :
                    (funct3 == FUNCT3_XOR) ? ALUOP_XOR :
                    (opcode == BRANCH)                           ? ALUOP_SUB : //BEQ command BEC has unique opcode
                     0;

assign MemToReg = (opcode==LOAD) ? 1'b1 : 1'b0;
assign ALUSrc = (opcode==IMMEDIATE || opcode==LOAD || opcode==STORE) ? 1'b1 : 1'b0;
assign PCSrc = (opcode==BRANCH && datapath_uut.Zero) ? 1'b1 : 1'b0;


endmodule

