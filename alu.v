module alu
    (output wire [31:0] result,
     output wire zero,
     input wire [31:0] op1,op2,
     input wire [3:0] alu_op
     );
    
    //signed operands
    wire signed [31:0] op1_signed, op2_signed;
    assign op1_signed = op1;
    assign op2_signed = op2;

    //ALU operations declaration
    parameter [3:0] ALUOP_AND = 4'b0000, //bitwise and
                    ALUOP_OR  = 4'b0001, //bitwise or
                    ALUOP_ADD = 4'b0010, //addition
                    ALUOP_SUB = 4'b0110, //subtraction
                    ALUOP_SLT = 4'b0111, //set less than
                    ALUOP_SRL = 4'b1000, //shift right logical
                    ALUOP_SLL = 4'b1001, //shift left logical
                    ALUOP_SRA = 4'b1010, //shift right arithmetic
                    ALUOP_XOR = 4'b1101; //bitwise xor
    //ALU multiplexer
    assign result = (alu_op == ALUOP_AND) ? (op1 & op2) :
                    (alu_op == ALUOP_OR)  ? (op1 | op2) :
                    (alu_op == ALUOP_ADD) ? (op1 + op2) :
                    (alu_op == ALUOP_SUB) ? (op1 - op2) :
                    (alu_op == ALUOP_SLT) ? (op1_signed < op2_signed) :
                    (alu_op == ALUOP_SRL) ? (op1 >> op2[4:0]) :
                    (alu_op == ALUOP_SLL) ? (op1 << op2[4:0]) :
                    (alu_op == ALUOP_SRA) ? (op1_signed >>> op2[4:0]) :
                    (alu_op == ALUOP_XOR) ? (op1 ^ op2) : 0;
    
    assign zero = (result == 0) ? 1 : 0;
endmodule