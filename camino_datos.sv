module CaminoDatos #(
  parameter WIDTH = 64,
  parameter NUMREG = 8,
  localparam INDEX_SIZE = $clog2(NUMREG)
)(
  input logic 					clk_i, 			// Senyal de reloj
  input logic 					rstn_i, 		// Senyal negada de reset
  input logic 					inicio_i,       // Senyal de inicio
  output logic  				fin_o,			// Senyal de finalizacion
  output logic [WIDTH-1:0]  	data_o,			// Senyal de debug de datos
  output logic [INDEX_SIZE-1:0]	regId_o         // Senyal de debug de id registro escrito
);



logic [INDEX_SIZE-1:0] id_wr; 		// Id de registro de escritura
logic 					we; 		// Senyal de permiso de escritura
logic [INDEX_SIZE-1:0] id_A; 		// Id de registro de lectura A
logic [INDEX_SIZE-1:0] id_B;		// Id de registro de lectura B

logic [WIDTH-1:0]      data_A; // Registro A       
logic [WIDTH-1:0]      data_B; // Registro B       

logic [WIDTH-1:0]    data_sum;



controlador #(.WIDTH(WIDTH), .NUMREG(NUMREG), .NUMSUMA(7)) CONT (
  .clk_i(clk_i),
  .rstn_i(rstn_i),
  .inicio_i(inicio_i),
  .fin_o(fin_o),
  .id_o(id_wr),
  .we_o(we),
  .A_o(id_A),
  .B_o(id_B)
);


bancoRegistros #(.WIDTH(WIDTH), .NUM(NUMREG)) BR (
  .clk_i(clk_i),
  .rstn_i(rstn_i),
  .A_i(id_A),
  .B_i(id_B),
  .we_i(we),
  .dato_i(data_sum),
  .wid_i(id_wr),
  .RegA_o(data_A),
  .RegB_o(data_B)
);


sumador #(.WIDTH(WIDTH)) SUM (
  .x_i(data_A),
  .y_i(data_B),
  .s_o(data_sum)
);


assign data_o  = data_sum;
assign regId_o = id_wr;


endmodule
