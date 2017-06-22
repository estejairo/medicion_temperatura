`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 21.04.2017 18:48:11
// Design Name: Selector
// Module Name: selector
// Project Name: Exp7
// Target Devices: NEXYS4DDR
// Description: Permite seleccionar y presionar 3 botones en pantalla mediante teclado
// 
//////////////////////////////////////////////////////////////////////////////////

module selector(
	input clk, //100MHZ
	input reset,
	input [7:0] data,
	input [2:0] data_type,
	input kbs_tot,
	output [1:0] btn_state,
	output reg btn1_pressed,
	output reg btn2_pressed,
	output reg btn3_pressed
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

	assign btn1_pressed_next = (enter&(state==SAMPLE))?1'b1:1'b0 ;
	assign btn2_pressed_next = (enter&(state==SEND))?1'b1:1'b0 ;
	assign btn3_pressed_next = (enter&(state==RESET))?1'b1:1'b0 ;

	always@(posedge clk)
	begin
		btn1_pressed <= btn1_pressed_next;
		btn2_pressed <= btn2_pressed_next;
		btn3_pressed <= btn3_pressed_next;
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

	always @(posedge clk or posedge reset)
		if (reset)
			state <= SEND;
		else
			state <= state_next;


	assign btn_state = state;

	
endmodule
