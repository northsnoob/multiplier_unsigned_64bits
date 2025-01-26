module multiplier_64bits #(parameter  BITS = 64)(
	input clk,reset_n,w_en,
	input [BITS-1:0] a_in,b_in,
	output wire ok_flag,
	output reg [BITS*2-1:0] product_out
);

reg [BITS-1:0] b_in_tmp;
wire [BITS*2-1:0] adder_Ain;
reg [BITS*2-1:0] shift_tmp;
wire [BITS*2-1:0] adder_wire;
reg [$clog2(BITS):0] counter;
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
	.S(counter[$clog2(BITS)-1:0])
);
assign adder_Ain = (adder_flag)?shift_tmp:0;
adder_128bits #(.BITS(BITS*2)) my_adder
	(
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
	end
end
endmodule

module adder_128bits #(parameter BITS = 128)(
	input [BITS-1:0] A_in,B_in,
	output [BITS-1:0] sum_out,
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
