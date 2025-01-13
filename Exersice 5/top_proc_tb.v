`include "top_proc.v"
`include "ram.v"
`include "rom.v"

module top_proc_tb;
    reg clk, rst;
    wire[31:0] instruction;
    wire[31:0] addressROM, addressRAM, dWriteData;
    wire[8:0] addressROM9bit, addressRAM9bit;
    wire[31:0] dReadData, WriteBackData,PC;
    wire MemRead, MemWrite;

    top_proc my_top_proc (
        .clk(clk),
        .rst(rst),
        .instr(instruction),
        .PC(addressROM),
        .dAddress(addressRAM),
        .dWriteData(dWriteData),
        .dReadData(dReadData),
        .WriteBackData(WriteBackData),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    assign addressROM9bit = addressROM[8:0];
    assign addressRAM9bit = addressRAM[8:0];

    INSTRUCTION_MEMORY urom (
        .clk(clk),
        .dout(instruction),
        .addr(addressROM9bit)
    );

    DATA_MEMORY uram (
        .clk(clk),
        .addr(addressRAM9bit),
        .din(dWriteData),
        .dout(dReadData),
        .we(MemWrite)
    );

    // Clock generation
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // Stimulus generation
    initial begin  
        rst = 1'b1;
        #20
        rst = 1'b0;
        #12600;
        $finish;
    end
endmodule