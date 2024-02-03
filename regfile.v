module regfile(
    output reg [31:0] readData1, readData2,
    input wire [31:0] writeData,
    input wire [4:0] readReg1, readReg2, writeReg,
    input wire write, clk
    );
    integer i;
    reg [31:0] registers[31:0];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (write && writeReg != 0) begin
            registers[writeReg] <= writeData;
            end

        readData1 = registers[readReg1];
        readData2 = registers[readReg2];
    end

endmodule