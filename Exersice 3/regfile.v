module regfile #( parameter DATAWIDTH = 32 ) (
    input clk,
    input write,
    input[4:0] readReg1, readReg2,
    input[4:0] writeReg,
    input[DATAWIDTH-1:0] writeData,
    output reg[DATAWIDTH-1:0] readData1, readData2
);
    // Internal registers
    reg [DATAWIDTH-1:0] registers [31:0];

    // Initialize registers
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = {DATAWIDTH{1'b0}};
    end

    always @(posedge clk) begin
        if (write && (writeReg != 5'b00000))
            registers[writeReg] <= writeData;
    end

    always @(*) begin
        if(write && (writeReg == readReg1) && (writeReg != 5'b00000))
            readData1 <= writeData;
        else
            readData1 <= registers[readReg1];

        if(write && (writeReg == readReg2) && (writeReg != 5'b00000))
            readData2 <= writeData;
        else
            readData2 <= registers[readReg2];
    end

endmodule