module calc_tb;
    reg clk, btnc, btnl, btnu, btnr, btnd;
    reg [15:0] sw;
    wire [15:0] led;

    calc my_calc (
        .clk(clk),
     	.btnc(btnc),
        .btnl(btnl),
        .btnu(btnu),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
	);
    
	initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        btnc = 0; btnl = 0; btnu = 0; btnr = 0; btnd = 0;
        sw = 16'h0;
		
		#10 btnd = 1;	// RESET
		#10 btnu = 1;
        #10 btnu = 0;
		$display("Reset: LED = %h (Expected: 0x0)", led);

        sw = 16'h354A;	// ADD
		btnd = 1;
        btnl = 0; btnc = 1; btnr = 0; #10;
        $display("ADD: LED = %h (Expected: 0x354A)", led);

        sw = 16'h1234;	// SUB
		btnd = 1;
        btnl = 0; btnc = 1; btnr = 1; #10;
        $display("SUB: LED = %h (Expected: 0x2316)", led);

        sw = 16'h1001;	// OR
		btnd = 1;
        btnl = 0; btnc = 0; btnr = 1; #10;
        $display("OR: LED = %h (Expected: 0x3317)", led);

        sw = 16'hF0F0;	// AND
		btnd = 1;
        btnl = 0; btnc = 0; btnr = 0; #10;
        $display("AND: LED = %h (Expected: 0x3010)", led);

        sw = 16'h1FA2;	// XOR
		btnd = 1;
        btnl = 1; btnc = 1; btnr = 1; #10;
        $display("XOR: LED = %h (Expected: 0x2FB2)", led);

        sw = 16'h6AA2;	// ADD
		btnd = 1;
        btnl = 0; btnc = 1; btnr = 0; #10;
        $display("ADD: LED = %h (Expected: 0x9A54)", led);

        sw = 16'h0004;	// Logical Shift Left
		btnd = 1;
        btnl = 1; btnc = 0; btnr = 1; #10;
        $display("LogicalShiftLeft: LED = %h (Expected: 0xA540)", led);

        sw = 16'h0001;	// Arithmetic Shift Right
		btnd = 1;
        btnl = 1; btnc = 1; btnr = 0; #10;
        $display("ShiftRight Arithmetic: LED = %h (Expected: 0xD2A0)", led);

        sw = 16'h46FF;	// Less Than
		btnd = 1;
        btnl = 1; btnc = 0; btnr = 0; #10;
        $display("LessThan: LED = %h (Expected: 0x0001)", led);

        // Finish simulation
        #100;
        $stop;
    end
endmodule

