`include "alu.v"
`include "calc_enc.v"

module calc (
	input clk, btnc, btnl, btnu, btnr, btnd,
	input[15:0] sw,
	output[15:0] led
);
	reg[15:0] accumulator;
	wire[31:0] alu_out;
	wire[3:0] alu_op;
	wire zero;

	// Sign extension
	wire[31:0] op1_extended = {{16{accumulator[15]}}, accumulator};
	wire[31:0] op2_extended = {{16{sw[15]}}, sw};

	alu alu (
		.op1(op1_extended),
        .op2(op2_extended),
        .alu_op(alu_op),
        .result(alu_out),
		.zero(zero)
	);

    calc_enc encoder (
        .btnc(btnc),
	    .btnl(btnl),
        .btnr(btnr),
	    .alu_op(alu_op)
    );

	// Accumulator logic
    always @(posedge clk) begin
    	if(btnu)
            	accumulator <= 16'b0;
        else if(btnd)
            	accumulator <= alu_out[15:0];
    end

	// Update LED with the current accumulator value
    assign led = accumulator;

endmodule