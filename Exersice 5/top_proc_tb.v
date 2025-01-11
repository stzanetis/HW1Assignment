`include "top_proc.v"
`include "ram.v"
`include "rom.v"

module top_proc_tb;
    reg clk,rst;
    wire [31:0]instruction;
    wire [31:0]addressrom, addressram,writedata;
    wire [8:0] addressrom9bits, addressram9bits;
    wire [31:0] dReadData,WriteBackData,PC;
    wire MemRead,MemWrite;

    //WE is 1 when writing to memory

    top_proc umul (
        .clk(clk),
        .instr(instruction),
        .PC(addressrom),
        .dAddress(addressram),
        .dWriteData(writedata),
        .dReadData(dReadData),
        .rst(rst),
        .WriteBackData(WriteBackData),
        .MemRead(MemRead),.MemWrite(MemWrite)
    );

    assign addressrom9bits=addressrom[8:0];
    assign addressram9bits=addressram[8:0];

    INSTRUCTION_MEMORY urom (
        .clk(clk),
        .dout(instruction),
        .addr(addressrom9bits)
    );

    DATA_MEMORY uram (
        .clk(clk),
        .addr(addressram9bits),
        .din(writedata),
        .dout(dReadData),
        .we(MemWrite)
    );

    // Clock generation
    initial clk=1'b0;
    always #10 clk = ~clk;

    // Stimulus generation
    initial begin
        $dumpfile("top_proc_tb.vcd");
        $dumpvars(0,top_proc_tb);
    
        rst=1;
        #20
        rst=0;
        #12600; // 512/4=128 Instructions    128 *5 =640 Clocks  640 * 20 Time per clock =12800
        $finish;
    end  
     
endmodule