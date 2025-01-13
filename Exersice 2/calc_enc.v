module calc_enc (
    input btnc,
    input btnl,
    input btnr,
    output [3:0] alu_op
);
    // alu_op[0]
	wire w01, w02, w03;
	not(w01, btnc);
    and(w02, w01, btnr);
    and(w03, btnr, btnl);
    or(alu_op[0], w02, w03);

    // alu_op[1]
	wire w11, w12, w13, w14;
    not(w11, btnl);
	not(w12, btnr);
    and(w13, w11, btnc);
	and(w14, w12, btnc);
    or(alu_op[1], w13, w14);

    // alu_op[2]
	wire w21, w22, w23, w24, w25;
    not(w21, btnc);
	not(w22, btnr);
    and(w23, w21, btnl);
    and(w24, w23, w22);
	and(w25, btnc, btnr);
    or(alu_op[2], w24, w25);

    // alu_op[3]
	wire w31, w32, w33, w34, w35, w36;
    not(w31, btnc);
	not(w32, btnr);
    and(w33, w31, btnl);
    and(w34, btnc, btnl);
    and(w35, w33, btnr);
    and(w36, w32, w34);
    or(alu_op[3], w35, w36);
endmodule