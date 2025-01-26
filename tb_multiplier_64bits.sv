`timescale 10ps/1ps
module tb_multiplier_64bits;
reg clk,reset_n,w_en;
wire ok_flag;
reg [63:0] a_in,b_in;
wire [127:0] product_out;
multiplier_64bits uut(
	.clk,
	.reset_n,
	.a_in,
	.b_in,
	.w_en,
	.ok_flag,
	.product_out
);

always #10 clk = ~clk;
wire [127:0] answer;
integer i;
initial begin
	clk=0;reset_n=0;a_in=1;b_in=2;w_en=0;
	#50 reset_n=1;
	test_multipier(2000,5000);
	#500;
	
	reset_n=0;
	#50 reset_n=1;
	test_multipier(101,202);
	#500;
	
	reset_n=0;
	#50 reset_n=1;
	test_multipier(101000,202001);
	#500;
	
	for (i=0;i<64;i+=1)begin
		reset_n=0;
		#50 reset_n=1;
		test_multipier(101<<i,202<<i);
		#500;
	end
	
	#1000 $finish;
end
assign answer=a_in*b_in;
assign correct=answer==product_out;
task test_multipier(input[63:0]a,b);
	a_in=a;
	b_in=b;
	w_en=1;
	#20 w_en=0;
	wait(ok_flag);
endtask

endmodule
