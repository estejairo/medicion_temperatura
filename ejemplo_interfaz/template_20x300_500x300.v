`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 	Mauricio Solis
// Modified by: Jairo Gonzalez
//
// Create Date: 05/21/2017 05:35:53 PM
// Design Name: 
// Module Name: template_20x300_500x300
//  
// Description: Genera una cuadrilla de 30 niveles con 10 subniveles, para 20 mediciones
// 
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module template_20x300_500x300(clk, hc, vc, matrix_x, matrix_y, lines);
	input clk;
	input [10:0] hc;
	input [10:0] vc;
	output reg[4:0]matrix_x = 5'd0;//desde 0 hasta 19
	output reg[8:0]matrix_y = 9'd0;//desde 0 hasta 2990
	output reg lines;

	localparam d_col=11'b000_0001_1001;		//25
	localparam d_row=11'd1;		//1
	localparam d_row30=11'd10;
	
	reg [10:0]col=d_col   ;	
	reg [10:0]row=d_row;
	reg [10:0]row30=d_row30;
	reg [10:0]col_next;
	reg [10:0]row_next;
	reg [10:0]row30_next;

	
	reg [4:0]matrix_x_next;
	reg [8:0]matrix_y_next;
	
	wire [10:0]hc_template, vc_template;
	
	
	parameter CUADRILLA_XI = 		212;
	parameter CUADRILLA_XF = 		712;
	
	parameter CUADRILLA_YI = 		184;
	parameter CUADRILLA_YF = 		484;
	
	assign hc_template = ( (hc > CUADRILLA_XI) && (hc <= CUADRILLA_XF) )?hc - CUADRILLA_XI: 11'd0;
	assign vc_template = ( (vc > CUADRILLA_YI) && (vc <= CUADRILLA_YF) )?vc - CUADRILLA_YI: 11'd0;
	
	
	
	always@(*)
		if(hc_template == 'd0)//fuera del rango visible
			{col_next, matrix_x_next} = {d_col, 5'd0};
		else if(hc_template > col)
			{col_next, matrix_x_next} = {col + d_col, matrix_x + 5'd1};
		else
			{col_next,matrix_x_next} = {col, matrix_x};
	
	always@(*)
		if(vc_template == 'd0)
			{row_next,matrix_y_next} = {d_row, 9'd0};
		else if(vc_template > row)
			{row_next, matrix_y_next} = {row + d_row, matrix_y + 9'd1};
		else
			{row_next, matrix_y_next} = {row, matrix_y};

	//Para generar lineas cada 10 niveles solamente, teniendo que 10 niveles son un grado
	always@(*)
		if(vc_template == 'd0)
			row30_next = d_row30;
		else if(vc_template > row30)
			row30_next = row30 + d_row30;
		else
			row30_next = row30;
	
	//para generar las líneas divisorias.
	reg lin_v, lin_v_next;
	reg lin_h, lin_h_next;
	
	always@(*)
	begin
		if(hc_template > col)
			lin_v_next = 1'b1;
		else
			lin_v_next = 1'b0;
			
		if(vc_template > row30)
			lin_h_next = 1'b1;
		else if(hc == CUADRILLA_XF)
			lin_h_next = 1'b0;
	
		else
			lin_h_next = lin_h;
		
	end
	
	
	always@(posedge clk)
		{col, row, row30, matrix_x, matrix_y} <= {col_next, row_next, row30_next, matrix_x_next, matrix_y_next};
	
	always@(posedge clk)
	begin
		lin_v <= lin_v_next;
		lin_h <= lin_h_next;
	end
		
	
	always@(*)
		if( (hc == (CUADRILLA_XI + 11'd1)) || (hc == CUADRILLA_XF) ||
		  (vc == (CUADRILLA_YI + 11'd1)) || (vc == CUADRILLA_YF) )
			lines = 1'b0;
		else if ((lin_v == 1'b1) || (lin_h == 1'b1))
			lines = 1'b1;
		else
			lines = 1'b0;

endmodule