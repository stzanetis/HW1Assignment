`include "alu.v"
`include "regfile.v"

module datapath #(
    parameter[31:0] INITIAL_PC = 32'h00400000
) (
    input clk, rst,
    input[31:0] instr,
    input PCSrc, ALUSrc,
    input RegWrite, MemToReg,
    input[3:0] ALUCtrl,
    input loadPC,
    input[31:0] dReadData,
    output Zero,
    output reg[31:0] PC,
    output[31:0] dAddress, dWriteData,
    output[31:0] WriteBackData
);
    // Internal signals
    wire[31:0] alu_op1, alu_op2, alu_result;
    wire[31:0] write_back_data;
    wire[11:0] input_i, input_i_sw, input_i_addi, input_i_beq;
    wire[11:0] output_i, output_i_sw, output_i_addi, output_i_beq;
    wire[31:0] left_add, sum_pc_i;

    // Register File
    regfile my_regfile (
        .clk(clk),
        .write(RegWrite),
        .readReg1(instr[19:15]),
        .readReg2(instr[24:20]),
        .writeReg(instr[11:7]),
        .writeData(write_back_data),
        .readData1(alu_op1),
        .readData2(alu_op2)
    );

    // Imediate Generation
    assign input_i_addi = instr[31:20];
    assign output_i_addi = {{20{input_i_addi[11]}}, input_i_addi};
    assign input_i_sw = {instr[31:25], instr[11:7]};
    assign output_i_sw = {{20{input_i_sw[11]}}, input_i_sw};
    assign input_i_beq = {instr[31], instr[7], instr[30:25], instr[11:8]};
    assign output_i_beq = {{19{input_i_beq[11]}}, input_i_beq, 1'b0};

    // Multiplexer for (S) or (I) command
    assign output_i = (instr[6:0]==7'b0100011) ? output_i_sw : output_i_addi;

    // Multiplexer for choosing the 2nd operand of ALU
    wire[31:0] mux_result_op2;
    assign mux_result_op2 = ALUSrc ? output_i : alu_op2;

    // ALU
    alu my_alu (
		.op1(alu_op1),
        .op2(mux_result_op2),
        .alu_op(ALUCtrl),
        .result(alu_result),
		.zero(Zero)
	);
    
    // Branch Target
    assign left_add = output_i_beq << 1;
    assign sum_pc_i = left_add + PC;

    // Write Back
    assign write_back_data = MemToReg ? dReadData : alu_result;

    // Outputs
    assign WriteBackData = write_back_data;
    assign dWriteData = alu_op2;
    assign dAddress = alu_result;

    // Update PC 
    always @(posedge clk) begin 
        if(rst)
            PC <= INITIAL_PC;
        else if(loadPC) begin 
            if(PCSrc)
                PC <= sum_pc_i;
            else
                PC <= PC + 4;
        end
    end
endmodule