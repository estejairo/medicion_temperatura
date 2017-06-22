`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 21.04.2017 18:48:11
// Design Name: Interfaz
// Module Name: interfaz
// Project Name: Exp7
// Target Devices: NEXYS4DDR
// Description: Muestra una interfaz con botones, titulos y un template para un grafico,
// incluye un selector de botones mediante PS/2.
// 
//////////////////////////////////////////////////////////////////////////////////

module pantalla(
	input CLK100MHZ,
	input SW,
	input PS2_CLK,
	input PS2_DATA,
	input CPU_RESETN,
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
	);

	assign rst = ~CPU_RESETN;

//////Reloj 82MHZ
	clk_wiz_0 clock_inst(
	  // Clock out ports
	  .clk_out1(CLK82MHZ),
	  .clk_out2(CLK100),
	  // Status and control signals
	  .reset(rst),
	  .locked(),
	 	// Clock in ports
	  .clk_in1(CLK100MHZ)
 	)	;

/////Driver PS/2
	wire [7:0] data;
	wire [2:0] data_type;
	wire parity_error;
	kbd_ms m_kd(CLK82MHZ, rst, PS2_DATA, PS2_CLK, data, data_type, kbs_tot, parity_error);

//////Driver VGA
	wire [10:0]vc_visible_next,hc_visible_next;
	driver_vga_1024x768 m_driver(CLK82MHZ, VGA_HS, VGA_VS, hc_visible_next, vc_visible_next);
	reg [10:0] vc_visible = 11'd0, hc_visible = 11'd0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			vc_visible <= 11'd0;
			hc_visible <=  11'd0;
		end
		else begin
			vc_visible <= vc_visible_next;
			hc_visible <= hc_visible_next;
		end
	end

/////Parametros para la ubicacion del grafico
	localparam CUADRILLA_XI = 		212;
	localparam CUADRILLA_XF = 		712;
	
	localparam CUADRILLA_YI = 		184;
	localparam CUADRILLA_YF = 		484;

/////Matriz para el grafico en pantalla
	wire [4:0]matrix_x;
	wire [8:0]matrix_y;
    template_20x300_500x300 template(
    	.clk(CLK82MHZ),
    	.hc(hc_visible), 
    	.vc(vc_visible),
    	.matrix_x(matrix_x),
    	.matrix_y(matrix_y),
    	.lines(lines)
    );

/////Interfaz
	wire [6:0] characters_next;
	reg [6:0] characters = 7'd0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			characters <= 7'd0;
		end
		else begin
			characters <= characters_next;
		end
	end

	//Boton medir
	show_one_line #(.MENU_X_LOCATION(11'd100), .MENU_Y_LOCATION(11'd650))sample(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("  sample  "),
		.in_square(in_sq_sample_next),
		.in_character(characters_next[0])
	);

	reg in_sq_sample = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq_sample <= 1'b0;
		end
		else begin
			in_sq_sample <= in_sq_sample_next;
		end
	end

	//Boton enviar
	show_one_line #(.MENU_X_LOCATION(11'd440), .MENU_Y_LOCATION(11'd650)) send(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   send   "),
		.in_square(in_sq_send_next),
		.in_character(characters_next[1])
	);

	reg in_sq_send = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq_send <= 1'b0;
		end
		else begin
			in_sq_send <= in_sq_send_next;
		end
	end

	//Boton reset
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd650))reset(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   reset  "),
		.in_square(in_sq_reset_next),
		.in_character(characters_next[2])
	);

	reg in_sq_reset = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq_reset <= 1'b0;
		end
		else begin
			in_sq_reset <= in_sq_reset_next;
		end
	end

	//titulo para el tiempo de muestreo
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd36)) sampletime(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("sample tim"),
		.in_square(),
		.in_character(characters_next[3])
	);


	//Indicador del tiempo de muestreo
	wire [39:0] tiempo_muestreo_ascii;
	assign tiempo_muestreo_ascii = "10000" ; //5 digitos
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd100)) tiempo(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line({"  ",tiempo_muestreo_ascii,"ms " }),
		.in_square(in_sq_time_next),
		.in_character(characters_next[4])
	);

	reg in_sq_time = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq_time <= 1'b0;
		end
		else begin
			in_sq_time <= in_sq_time_next;
		end
	end

	//Cuadricula
	show_one_line #(.MENU_X_LOCATION(11'd150), .MENU_Y_LOCATION(11'd100)) grid(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   grid    "),
		.in_square(in_sq_grid_next),
		.in_character(characters_next[5])
	);

	reg in_sq_grid = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq_grid <= 1'b0;
		end
		else begin
			in_sq_grid <= in_sq_grid_next;
		end
	end

	//Titulo
	hello_world titulo(CLK82MHZ, rst, hc_visible, vc_visible, in_sq_next, characters_next[6]);

	reg in_sq = 1'b0;
	always @(posedge CLK82MHZ or posedge rst) begin
		if (rst) begin
			in_sq <= 1'b0;
		end
		else begin
			in_sq <= in_sq_next;
		end
	end


/////Selector de botones mediante teclado
	wire [1:0] btn_state;
	selector ins_selec(
		.clk(CLK82MHZ), 
		.reset(rst),
		.data(data),
		.data_type(data_type),
		.kbs_tot(kbs_tot),
		.btn_state(btn_state),
		.btn1_pressed(btn1_pressed), //Señales que duran un ciclo de reloj
		.btn2_pressed(btn2_pressed),
		.btn3_pressed(btn3_pressed)
    );

/////Pintar la pantalla
	reg [11:0]VGA_COLOR, VGA_COLOR_NEXT;
	always@(*)
		if((hc_visible != 0) && (vc_visible != 0))
		begin
			if(|characters == 1'b1)
				VGA_COLOR_NEXT = {12'h000};
			else if (SW&&in_sq_grid)
				VGA_COLOR_NEXT = {12'hC33};
			else if (in_sq_grid)
				VGA_COLOR_NEXT = {12'h999};
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

	always @(posedge CLK82MHZ) begin
		VGA_COLOR <= VGA_COLOR_NEXT;
	end

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
	
endmodule
