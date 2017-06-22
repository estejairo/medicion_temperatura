`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFSM
// Engineer: Jairo Gonzalez
// 
// Create Date: 21.04.2017 18:48:11
// Design Name: Ejemplo Sensor de Temperatura
// Module Name: ejemplo_sensor_de_temperatura
// Project Name: Exp7
// Target Devices: NEXYS4DDR
// Description: Muestra temperatura en el display, con precision de 0.1 grados C.
// 
//////////////////////////////////////////////////////////////////////////////////


module ejemplo_sensor_de_temperatura
(
	input CLK100MHZ,
	inout TMP_SCL, //la linea debe se 'inout' para comunicarse bidireccionalmente
	inout TMP_SDA,	//la linea debe se 'inout' para comunicarse bidireccionalmente
	output CA, CB, CC, CD, CE, CF, CG, DP, 
	output [7:0] AN
);


	//Modulo Medicion de Temperatura
	wire [12:0] temperatura; //Temperatura entregada por el sensor. 
							//Para tener el valor en grados celsius se debe desplazar 4 bits hacia la derecha.

	TempSensorCtl insttempPort (
		.TMP_SCL(TMP_SCL),// Linea de reloj para el sensor de temperatura
		.TMP_SDA(TMP_SDA),// Linea de datos para el sensor de temperatura		
		.TEMP_O(temperatura),// Temperatura en 13 bits, donde el mas significativo corresponde al signo de la temperatura
		.RDY_O(ready),// '1' cuando hay un valor de temperatura listo para leer
		.ERR_O(error),// '1' si es que hay un error de comunicacion
		
		.CLK_I(CLK100MHZ),// Reloj para el medidor de templeratura
		.SRST_I(1'b0)// //Senial de reset
	);

	
	wire [15:0] tmp_celcius_adaptado_para_pantalla; //Temperatura en grados celcius 
													//y multiplicado por 10, para tener 1 decima de grado de precicion

	assign tmp_celcius_adaptado_para_pantalla = (temperatura[11:0]*10)>>4; //Al multiplicarlo por 10, se tienen 300
																			//niveles de temperatura entre 0 y 30 grados,
																			//que calza con el template del grafico. 
																			//Se tomaron solo 12 bits de la variable
																			//'temperatura', ya que no nos interesa el signo



	//Transformar la temperatura a BCD para mostrarla en el display
	wire convertir;
	assign  convertir = (idle)?1'd1:1'd0;
	wire [31:0] bcd;
	unsigned_to_bcd utb_inst(
		.clk(CLK100MHZ),            // Reloj
		.trigger(convertir),        // Inicio de conversión
		.in({16'd0,tmp_celcius_adaptado_para_pantalla}),	      // Número binario de entrada
		.idle(idle),      // Si vale 0, indica una conversión en proceso
		.bcd(bcd) 
	);


	//Reloj para el display
	clk_divider #(.O_CLK_FREQ(1000)) clk_display_inst
	(
		.clk_in(CLK100MHZ), 
		.reset(1'b0), 
		.clk_out(clk_display)
	);	

	//Display
	wire [31:0] string;
	wire [7:0] AN_tmp;
	ss_mux ss_mux_inst(
		.clk(clk_display),
		.clk_enable(1'b1),
		.bcd(bcd),
		.dots(8'b00000010),
		.ss_value({DP,CG, CF, CE, CD, CC, CB, CA}),
		.ss_select(AN_tmp)
	);

	assign AN = {5'b11111,AN_tmp[2:0]};

endmodule
