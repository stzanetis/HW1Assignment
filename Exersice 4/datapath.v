`include "alu.v"
`include "regfile.v"

module datapath #(
    parameter[31:0] INITIAL_PC = 32'h00400000,
    parameter[6:0]  LW=7'b0000011,
    parameter[6:0]  SW=7'b0100011,
    parameter[6:0]  IMMEDIATE=7'b0010011
) (
    input clk, rst,
    input PCSrc, ALUSrc,
    input RegWrite, MemToReg,
    input loadPC,
    input[31:0] instr,
    input[3:0] ALUCtrl,
    output Zero,
    output reg[31:0] PC,
    output reg[31:0] dAddress, dWriteData, dReadData,
    output reg[31:0] WriteBackData
);
    // Internal signals
    wire[31:0]  alu_op1, alu_op2, ALUResult;
    reg[31:0]   regData1, regData2;
    reg[31:0]   immediateTypeI, immediateStore, writeBackDataIn;
    reg[31:0]   branchOffset, branchOffsetEx;
    reg[4:0]    readReg1, readReg2, writeRegAddr;

    alu alu (
		.op1(regData1),
        .op2(regData2),
        .alu_op(ALUCtrl),
        .result(ALUResult),
		.zero(Zero)
	);

    regfile regfile (
        .clk(clk),
        .write(RegWrite),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeRegAddr),
        .writeData(writeBackDataIn),
        .readData1(alu_op1),
        .readData2(alu_op2)
    );

always @(instr) begin 
    readReg1Addr <= instr[19:15];
    readReg2Addr <= instr[24:20];
    writeRegAddr <= instr[11:7];

    // Immediate instructions 
    immediateTypeI <= {{20{instr[31]}},instr[31:20]};

    // Store instructions
    immediateStore <= {{20{instr[31]}},instr[31:25], instr[11:7]};

    // Branch instructions
    branchOffsetEx <= {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
    branchOffset <= branchOffsetEx<<1;
end

// Multiplexer for deciding the 2nd operand of ALU
always @(*) begin
    if(ALUSrc) begin 
        case(instr[6:0])
            SW : regData2 <= immediateStore; // SW
            LW : regData2 <= immediateTypeI; // LW
            IMMEDIATE : case(ALUCtrl)
                4'b1001, 4'b1000, 4'b1010 :  // SLLI, SRLI, SRAI
                regData2 <= immediateTypeI[4:0]; 
                default : regData2 <= immediateTypeI;  // IMMEDIATE
                endcase
            default : regData2 <= immediateTypeI;  
        endcase 
    end else
        regData2 <= aluOp2; // RR BEQ
    dWriteData <= aluOp2; 
    regData1 <= aluOp1; // First operand always from register
end

// Multiplexer for writing to register file
always @(*) begin
    if(MemToReg) begin
        writeBackDataIn <= dReadData;
        WriteBackData <= dReadData;
    end else begin
        writeBackDataIn <= aluResult;
        WriteBackData <= aluResult;
    end
    dAddress <= aluResult;
end

// Update PC 
always @(posedge clk) begin 
    if(rst)
        PC <= INITIAL_PC;
    else if (loadPC) begin 
        if(PCSrc)
            PC <= PC + branchOffset;
        else
            PC <= PC + 4;
    end
end

endmodule