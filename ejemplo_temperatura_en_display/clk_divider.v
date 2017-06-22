/*
 * clk_divider.v
 * 2017/04/17 - Felipe Veas <felipe.veasv [at] usm.cl>
 * 2017/04/21 - Modified by Jairo Gonzalez <jairo.gonzalez.13 [at] sansano.usm.cl
 *
 * Divisor de reloj basado en un contador para una frecuencia de entrada
 * de 100 [MHz]
 *
 * Recibe como parámetro opcional la frecuencia de salida que debe entregar.
 *
 * Valores por defecto:
 *     O_CLK_FREQ:   1  [Hz] (reloj de salida)
 *
 * Rango de operación:
 *     1 <= clk_out <= 50_000_000 [Hz]
 */

`timescale 1ns / 1ps

module clk_divider
#(
	parameter O_CLK_FREQ = 1
)(
	input clk_in,
	input reset,
	output reg clk_out
);

	/*
	 * Calculamos el valor máximo que nuestro contador debe alcanzar en función
	 * de O_CLK_FREQ
	 */
	localparam COUNTER_MAX = 'd100_000_000/(2 * O_CLK_FREQ) - 1;

	reg [26:0] counter = 'd0;

	/*
	 * Los siguientes bloques procedurales que resetea el contador e invierte el valor del reloj de salida
	 * cada vez que el contador llega a su valor máximo.
	 */
	always @(posedge(clk_in) or posedge(reset))
	begin
		if (reset == 1'b1)
			counter <= 'd0;
		else if (counter == COUNTER_MAX)
			counter <= 'd0;
		else 
			counter <= counter + 'd1;
	end

	always @(posedge(clk_in) or posedge(reset))
	begin
		if (reset == 1'b1)
			clk_out <= 0;
		else if (counter == COUNTER_MAX)
			clk_out <= ~clk_out;
		else
			clk_out <= clk_out;
	end
endmodule
