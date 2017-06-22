`timescale 1ns / 1ps
module pantalla(
	input CLK100MHZ,
	input SW,
	input PS2_CLK,
	input PS2_DATA,
	//input rst,
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);

	localparam CUADRILLA_XI = 		212;
	localparam CUADRILLA_XF = 		712;
	
	localparam CUADRILLA_YI = 		184;
	localparam CUADRILLA_YF = 		484;

	wire [10:0]vc_visible,hc_visible;
	wire CLK82MHZ;
	
	clk_wiz_0 inst(
		// Clock out ports  
		.clk_out1(CLK82MHZ),
		// Status and control signals               
		.reset(1'b0), 
		//.locked(locked),
		// Clock in ports
		.clk_in1(CLK100MHZ)
		);
	
	wire [7:0] data;
	wire [2:0] data_type;
	wire parity_error;
	//driver_vga_640x480 m_driver(CLK82MHZ, VGA_HS, VGA_VS,hc_visible,vc_visible);
	driver_vga_1024x768 m_driver(CLK82MHZ, VGA_HS, VGA_VS, hc_visible, vc_visible);
	kbd_ms m_kd(CLK100MHZ, 1'b0, PS2_DATA, PS2_CLK, data, data_type, kbs_tot, parity_error);
	
	//wire kbs_tot;
	
	
	/*
	wire [10:0]hc_template, vc_template;
	wire [4:0]matrix_x;
	wire [5:0]matrix_y;
	wire lines;
	
	matrix_reloaded_20x300 template_1(CLK82MHZ, hc_visible, vc_visible, matrix_x, matrix_y, lines);
	*/
	

	wire [6:0] characters;
	show_one_line #(.MENU_X_LOCATION(11'd100), .MENU_Y_LOCATION(11'd650))sample(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("  sample  "),
		.in_square(in_sq_sample),
		.in_character(characters[0])
	);

	show_one_line #(.MENU_X_LOCATION(11'd440), .MENU_Y_LOCATION(11'd650)) send(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   send   "),
		.in_square(in_sq_send),
		.in_character(characters[1])
	);

	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd650))reset(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   reset  "),
		.in_square(in_sq_reset),
		.in_character(characters[2])
	);

	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd36)) sampletime(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("sample tim"),
		.in_square(),
		.in_character(characters[3])
	);

	show_one_line #(.MENU_X_LOCATION(11'd150), .MENU_Y_LOCATION(11'd36)) grid(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   grid   "),
		.in_square(),
		.in_character(characters[4])
	);

	wire [79:0] tiempox;
	assign tiempox = "    10s   " ;
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd100)) tiempo(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line(tiempox),
		.in_square(in_sq_time),
		.in_character(characters[5])
	);

	show_one_line #(.MENU_X_LOCATION(11'd150), .MENU_Y_LOCATION(11'd100)) grid_sw(
		.clk(CLK82MHZ), 
		.rst(1'b0), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("          "),
		.in_square(in_sq_grid),
		.in_character()
	);


	wire in_sq;
	hello_world m_hw(CLK82MHZ, 1'b0, hc_visible, vc_visible, in_sq, characters[6]);

	wire [1:0] btn_state;
	selector ins_selec(
		.clk(CLK100MHZ), //100MHZ
		.data(data),
		.data_type(data_type),
		.kbs_tot(kbs_tot),
		.btn_state(btn_state),
		.btn1_pos(btn1_pos), //en verdad son señales que duran un ciclo de reloj
		.btn2_pos(btn2_pos),
		.btn3_pos(btn3_pos)
    );

	wire [4:0]matrix_x;
	wire [8:0]matrix_y;
	//wire lines;
    template_20x300_500x300 template(
    	.clk(CLK82MHZ),
    	.hc(hc_visible), 
    	.vc(vc_visible),
    	.matrix_x(matrix_x),
    	.matrix_y(matrix_y),
    	.lines(lines)
    );

	reg [11:0]VGA_COLOR, VGA_COLOR_NEXT;
	always@(*)
		if((hc_visible != 0) && (vc_visible != 0))
		begin
			if (SW&&in_sq_grid)
				VGA_COLOR_NEXT = {12'hC33};
			else if (in_sq_grid)
				VGA_COLOR_NEXT = {12'h999};
			else if(|characters == 1'b1)
				VGA_COLOR_NEXT = {12'h000};
			else if (in_sq_sample && (btn_state==2'b01))
				VGA_COLOR_NEXT = {12'hC33};
			else if (in_sq_sample)
				VGA_COLOR_NEXT = {12'h8C6};
			else if (in_sq_send && (btn_state==2'b10))
				VGA_COLOR_NEXT = {12'hC33};
			else if (in_sq_send)
				VGA_COLOR_NEXT = {12'h8C6};
			else if (in_sq_reset && (btn_state==2'b11))
				VGA_COLOR_NEXT = {12'hC33};
			else if (in_sq_reset)
				VGA_COLOR_NEXT = {12'h8C6};
			else if (in_sq_time)
				VGA_COLOR_NEXT = {12'hF66};
			else if((hc_visible > CUADRILLA_XI) && (hc_visible <= CUADRILLA_XF) && (vc_visible > CUADRILLA_YI) && (vc_visible <= CUADRILLA_YF))
				if(lines&&SW)
					VGA_COLOR_NEXT = {12'h666};
				else if (lines)
					VGA_COLOR_NEXT = {12'hCCC};
				else
					VGA_COLOR_NEXT = {12'hCCC};
			
			else
				VGA_COLOR_NEXT = {12'h0C6};
		end
		else
			VGA_COLOR_NEXT = {12'd0};

	always @(posedge CLK100MHZ) begin
		VGA_COLOR <= VGA_COLOR_NEXT;
	end

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
	
endmodule
