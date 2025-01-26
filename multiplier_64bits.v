module multiplier_64bits(
	input clk,reset_n,w_en,
	input [63:0] a_in,b_in,
	output wire ok_flag,
	output reg [127:0] product_out
);
reg [63:0] b_in_tmp;
wire [127:0] adder_Ain;
reg [127:0] shift_tmp;
wire [127:0] adder_wire;
reg [6:0] counter;
wire adder_flag;
assign ok_flag = counter[6]; // complete multiplication with 64 clk

always@(posedge clk)begin
	if(w_en)begin
		b_in_tmp<=b_in; // hold input
		shift_tmp<=a_in;// hold input
	end else begin
		shift_tmp<=shift_tmp<<1;
	end
end


mux64to1 my_mux1(
	.I(b_in_tmp),
	.O(adder_flag),
	.S(counter[5:0])
);
assign adder_Ain = (adder_flag)?shift_tmp:128'd0;
adder_128bits my_adder(
	.A_in(adder_Ain),
	.B_in(product_out),
	.sum_out(adder_wire),
	.carry_out()
);

always@(posedge clk or negedge reset_n)begin
	if(!reset_n) begin
		counter<=0;
		product_out<=0;
	end else begin
		if(!ok_flag && !w_en)begin
			product_out<=adder_wire;
			counter<=counter+1;
		end
		//end else begin
		//	product_out<=product_out; // 
		//end
	end
end
endmodule

module adder_128bits(
	input [127:0] A_in,B_in,
	output [127:0] sum_out,
	output carry_out
);
assign {carry_out,sum_out}=A_in+B_in;
endmodule

module mux64to1 (
	input [63:0] I,
	output O,
	input [5:0] S
);
assign O=I[S];
endmodule
