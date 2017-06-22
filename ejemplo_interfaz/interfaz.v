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

module interfaz(
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

/////Driver PS/2
	wire [7:0] data;
	wire [2:0] data_type;
	wire parity_error;
	kbd_ms m_kd(CLK100MHZ, rst, PS2_DATA, PS2_CLK, data, data_type, kbs_tot, parity_error);

//////Reloj 82MHZ
	clk_wiz_0 inst(
		// Clock out ports  
		.clk_out1(CLK82MHZ),
		// Status and control signals               
		.reset(rst), 
		.locked(locked),
		// Clock in ports
		.clk_in1(CLK100MHZ)
		);
	
//////Driver VGA
	wire [10:0]vc_visible,hc_visible;
	driver_vga_1024x768 m_driver(CLK82MHZ, VGA_HS, VGA_VS, hc_visible, vc_visible);

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
	wire [6:0] characters;

	//Boton medir
	show_one_line #(.MENU_X_LOCATION(11'd100), .MENU_Y_LOCATION(11'd650))sample(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("  sample  "),
		.in_square(in_sq_sample),
		.in_character(characters[0])
	);

	//Boton enviar
	show_one_line #(.MENU_X_LOCATION(11'd440), .MENU_Y_LOCATION(11'd650)) send(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   send   "),
		.in_square(in_sq_send),
		.in_character(characters[1])
	);

	//Boton reset
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd650))reset(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   reset  "),
		.in_square(in_sq_reset),
		.in_character(characters[2])
	);

	//titulo para el tiempo de muestreo
	show_one_line #(.MENU_X_LOCATION(11'd750), .MENU_Y_LOCATION(11'd36)) sampletime(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("sample tim"),
		.in_square(),
		.in_character(characters[3])
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
		.in_square(in_sq_time),
		.in_character(characters[4])
	);

	//Cuadricula
	show_one_line #(.MENU_X_LOCATION(11'd150), .MENU_Y_LOCATION(11'd100)) grid(
		.clk(CLK82MHZ), 
		.rst(rst), 
		.hc_visible(hc_visible),
		.vc_visible(vc_visible),
		.the_line("   grid    "),
		.in_square(in_sq_grid),
		.in_character(characters[5])
	);

	//Titulo
	wire in_sq;
	hello_world titulo(CLK82MHZ, rst, hc_visible, vc_visible, in_sq, characters[6]);


/////Selector de botones mediante teclado
	wire [1:0] btn_state;
	selector ins_selec(
		.clk(CLK100MHZ), //100MHZ
		.reset(rst),
		.data(data),
		.data_type(data_type),
		.kbs_tot(kbs_tot),
		.btn_state(btn_state),
		.btn1_pressed(btn1_pressed), //en verdad son señales que duran un ciclo de reloj
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

	always @(posedge CLK100MHZ) begin
		VGA_COLOR <= VGA_COLOR_NEXT;
	end

	assign {VGA_R, VGA_G, VGA_B} = VGA_COLOR;
	
endmodule
