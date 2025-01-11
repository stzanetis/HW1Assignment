`include "datapath.v"

module top_proc #(
    parameter[31:0] INITIAL_PC = 32'h00400000
) (
    input clk, rst,
    input[31:0] instr,
    input[31:0] dReadData,
    output[31:0] PC,
    output[31:0] dAdress, dWriteData,
    output reg MemRead, MemWrite,
    output[31:0] WriteBackData
);
    // Internal signals
    wire zero;
    wire ALUSource;
    reg pcload, pcSource, registerWrite, dataMemToReg;
    reg[3:0] ALUControl;

    datapath datapath #(.INITIAL_PC(INITIAL_PC)) (
        //.clk(clk),
        //.rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAdress(dAdress),
        .dWriteData(dWriteData)
        //.MemRead(MemRead),
        //.MemWrite(MemWrite),
        //.WriteBackData(WriteBackData)
    );

    // FSM
    reg[4:0] currentstate, nextstate;
    parameter[2:0] IF=3'b000, ID=3'b001, EX=3'b010, MEM=3'b011, WB=3'b100;

    // Memory Logic
    always @(posedge clk) begin: STATE_MEMORY
        if(rst)
            currentstate <= IF;
        else
            currentstate <= nextstate;
    end

    // Next State Logic
    always @(currentstate) begin: NEXT_STATE_LOGIC
        case(currentstate)
            IF: nextstate <= ID;
            ID: nextstate <= EX;
            EX: nextstate <= MEM;
            MEM: nextstate <= WB;
            WB: nextstate <= IF;
        endcase
    end

    // Ouput Logic
    always @(currentstate) begin: OUTPUT_LOGIC
        case(currentstate)
            IF: begin
                pcload <= 0;
                registerWrite <= 0;
                pcSource <= 0;
                dataMemToReg <= 1'b0;
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
                    7'b1100011: registerWrite <= 0;
                    7'b0100011: registerWrite <= 0;
                    default: registerWrite <= 1;
                endcase
                loadPC <= 1;
                //MemRead <= 0;
                //MemWrite <= 0;
                if(instr[6:0] == 7'b0000011)
                    dataMemToReg <= 1'b1;
                else
                    dataMemToReg <= 1'b0;
                if(instr[6:0] == 7'b1100011 && zero)
                    pcSource <= 1;
            end
        endcase
    end

    // ALU Control Logic
    always @(instr) begin
        case(instr[6:0])
            7'b1100011: ALUControl <= 4'b0110;
            7'b0000011: ALUControl <= 4'b0010;
            7'b0100011: ALUControl <= 4'b0010;
            7'b0010011: begin
                case(instr[14:12])
                    3'b111: ALUControl <= 4'b0001;
                    3'b110: ALUControl <= 4'b0010;
                    3'b000: ALUControl <= 4'b0010;
                    3'b010: ALUControl <= 4'b0111;
                    3'b001: ALUControl <= 4'b1001;
                    3'b101: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUControl <= 4'b1000;
                        else if(instr[31:25] == 7'b0100000)
                            ALUControl <= 4'b1010;
                    end
                endcase
            end
            7'b0110011: begin
                case(instr[14:12])
                    3'b000: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUControl <= 4'b0010;
                        else if(instr[31:25] == 7'b0100000)
                            ALUControl <= 4'b0110;
                    end
                    3'b001: ALUControl <= 4'b1001;
                    3'b010: ALUControl <= 4'b0111;
                    3'b100: ALUControl <= 4'b1101;
                    3'b101: begin
                        if(instr[31:25] == 7'b0000000)
                            ALUControl <= 4'b1000;
                        else if(instr[31:25] == 7'b0100000)
                            ALUControl <= 4'b1010;
                    end
                    3'b110: ALUControl <= 4'b0001;
                    3'b111: ALUControl <= 4'b0000;
                endcase  
            end
        endcase
    end

    // ALU Source Logic
    assign ALUSource = (instr[5] == 1'b0 || instr[6:0] == 7'b0100011)?1:0;

endmodule