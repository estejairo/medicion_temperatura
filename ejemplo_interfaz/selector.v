`timescale 1ns / 1ps

module selector(
	input clk, //100MHZ
	input [7:0] data,
	input [2:0] data_type,
	input kbs_tot,
	output [1:0] btn_state,
	output reg btn1_pos,
	output reg btn2_pos,
	output reg btn3_pos
    );
	
	reg enter = 1'b0;
	reg left = 1'b0;
	reg right = 1'b0;
	
	wire enter_next, left_next, right_next;
	assign enter_next = (((data == 8'h5A)&&(data_type == 3'b001))&&kbs_tot)?1'b1:1'b0;
	assign left_next = (((data == 8'h1C)&&(data_type == 3'b001))&&kbs_tot)?1'b1:1'b0;
	assign right_next = (((data == 8'h23)&&(data_type == 3'b001))&&kbs_tot)?1'b1:1'b0;

	always@(posedge clk)
	begin
		enter <=enter_next;
		left <= left_next;
		right <= right_next;
	end

	assign btn1_pos_next = (enter&(state==SAMPLE))?1'b1:1'b0 ;
	assign btn2_pos_next = (enter&(state==SEND))?1'b1:1'b0 ;
	assign btn3_pos_next = (enter&(state==RESET))?1'b1:1'b0 ;

	always@(posedge clk)
	begin
		btn1_pos <= btn1_pos_next;
		btn2_pos <= btn2_pos_next;
		btn3_pos <= btn3_pos_next;
	end

	localparam SAMPLE	= 2'b01;
	localparam SEND		= 2'b10;
	localparam RESET	= 2'b11;

	reg [1:0] state = 2'b01;
	reg [1:0] state_next;

	always @(*) 
	begin
		state_next = SAMPLE;
		case(state)
			SAMPLE: state_next = (right)?SEND:(left)?RESET:SAMPLE;
			SEND: 	state_next = (right)?RESET:(left)?SAMPLE:SEND;
			RESET: 	state_next = (right)?SAMPLE:(left)?SEND:RESET;
		endcase
	end

	always @(posedge clk)
		state <= state_next;


	assign btn_state = state;

	
endmodule
