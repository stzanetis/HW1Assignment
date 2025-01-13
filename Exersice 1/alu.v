module alu (
	input[31:0] op1,
	input[31:0] op2,
	input[3:0] alu_op,
	output zero,
	output[31:0] result
);
	// Parameters
	parameter[3:0] ALUOP_AND 		= 4'b0000;
	parameter[3:0] ALUOP_OR			= 4'b0001;
	parameter[3:0] ALUOP_ADD 		= 4'b0010;
	parameter[3:0] ALUOP_SUB 		= 4'b0110;
	parameter[3:0] ALUOP_LTHAN		= 4'b0100;
	parameter[3:0] ALUOP_LSHIFTR 	= 4'b1000;
	parameter[3:0] ALUOP_LSHIFTL	= 4'b1001;
	parameter[3:0] ALUOP_ASHIFTR	= 4'b1010;
	parameter[3:0] ALUOP_XOR 		= 4'b0101;

	// Multiplexer
	assign result = (alu_op == ALUOP_AND) ? (op1 & op2):					// AND
			(alu_op == ALUOP_OR) 	  	  ? (op1 | op2):					// OR
			(alu_op == ALUOP_ADD) 	  	  ? (op1 + op2):					// ADD
			(alu_op == ALUOP_SUB) 	  	  ? (op1 - op2):					// SUB
			(alu_op == ALUOP_LTHAN)	  	  ? ($signed(op1) < $signed(op2)):  // LESS THAN
			(alu_op == ALUOP_LSHIFTR) 	  ? (op1 >> op2[4:0]):				// LOGICAL RIGHT SHIFT
			(alu_op == ALUOP_LSHIFTL) 	  ? (op1 << op2[4:0]):				// LOGICAL LEFT SHIFT
			(alu_op == ALUOP_ASHIFTR) 	  ? ($signed(op1) >>> op2[4:0]):	// ARITHMETIC RIGHT SHIFT
			(alu_op == ALUOP_XOR)	  	  ? (op1 ^ op2):					// XOR
			32'b0;															// DEFAULT

	// Assign zero if needed
	assign zero = (result == 32'b0) ? 1'b1 : 1'b0;
endmodule
