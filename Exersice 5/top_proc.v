`include "datapath.v"

module top_proc #(
    parameter[31:0] INITIAL_PC = 32'h00400000
) (
    input clk, rst,
    input[31:0] instr,
    input[31:0] dReadData,
    output[31:0] PC,
    output[31:0] dAddress, dWriteData,
    output reg MemRead, MemWrite,
    output[31:0] WriteBackData
);
    // Internal signals
    wire zero;
    reg pcload, pcsource, mem_reg, reg_write;
    reg[3:0] ALUCtrl;
    wire ALUSrc;

    // FSM
    reg[2:0] currentstate, nextstate;
    parameter[2:0] IF=3'b000, ID=3'b001, EX=3'b010, MEM=3'b011, WB=3'b100;

    // State Memory Logic
    always @(posedge clk) begin: STATE_MEMORY
        if(rst)
            currentstate <= IF;
        else
            currentstate <= nextstate;
    end

    // Next State Logic
    always @(currentstate) begin: NEXT_STATE_LOGIC
        case(currentstate)
            IF: nextstate = ID;
            ID: nextstate = EX;
            EX: nextstate = MEM;
            MEM: nextstate = WB;
            WB: nextstate = IF;
        endcase
    end

    // Ouput Logic
    always @(currentstate) begin: OUTPUT_LOGIC
        case(currentstate)
            IF: begin
                pcload <= 0;
                pcsource <= 0;
                reg_write <= 0;
                mem_reg <= 0;
            end
            ID: begin
            end
            EX: begin
            end
            MEM: begin
                case(instr[6:0])
                    7'b0000011: MemRead <= 1;
                    7'b0100011: MemWrite <= 1;
                endcase
            end
            WB: begin
                case(instr[6:0])
                    7'b1100011: reg_write <= 0;
                    7'b0100011: reg_write <= 0;
                    default: reg_write <= 1;
                endcase
                pcload <= 1;
                MemRead <= 0;
                MemWrite <= 0;
                if(instr[6:0] == 7'b0000011)
                    mem_reg <= 1;
                else
                    mem_reg <= 0;
                if(instr[6:0] == 7'b1100011 && zero)
                    pcsource <= 1;
            end
        endcase
    end

    // ALUCtrl
    always @(instr) begin
        case(instr[6:0])
            7'b1100011: ALUCtrl <= 4'b0110;
            7'b0000011: ALUCtrl <= 4'b0010;
            7'b0100011: ALUCtrl <= 4'b0010;
            7'b0010011: begin
                case(instr[14:12])
                    3'b111: ALUCtrl <= 4'b0000;
                    3'b110: ALUCtrl <= 4'b0001;
                    3'b000: ALUCtrl <= 4'b0010;
                    3'b010: ALUCtrl <= 4'b0111;
                    3'b001: ALUCtrl <= 4'b1001;
                    3'b100: ALUCtrl <= 4'b1101;
                    3'b101: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUCtrl <= 4'b1000;
                        else if(instr[31:25] == 7'b0100000)
                            ALUCtrl <= 4'b1010;
                    end
                endcase
            end
            7'b0110011: begin
                case(instr[14:12])
                    3'b000: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUCtrl <= 4'b0010;
                        else if(instr[31:25] == 7'b0100000)
                            ALUCtrl <= 4'b0110;
                    end
                    3'b001: ALUCtrl <= 4'b1001;
                    3'b010: ALUCtrl <= 4'b0111;
                    3'b100: ALUCtrl <= 4'b1101;
                    3'b101: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUCtrl <= 4'b1000;
                        else if(instr[31:25] == 7'b0100000)
                            ALUCtrl <= 4'b1010;
                    end
                    3'b110: ALUCtrl <= 4'b0001;
                    3'b111: ALUCtrl <= 4'b0000;
                endcase  
            end
        endcase
    end

    // ALUSrc
    assign ALUSrc = (instr[5] == 1'b0 || instr[6:0] == 7'b0100011) ? 1:0;

    // Datapath
    datapath #(.INITIAL_PC(INITIAL_PC)) my_datapath (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData),
        .ALUCtrl(ALUCtrl),
        .ALUSrc(ALUSrc),
        .Zero(zero),
        .loadPC(pcload),
        .PCSrc(pcsource),
        .RegWrite(reg_write),
        .MemToReg(mem_reg)
    );
endmodule