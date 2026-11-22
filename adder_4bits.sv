module adder_4bits (
    input logic [3:0] x_i, // Operando 1
    input logic [3:0] y_i, // Operando 2
    input logic c_i, // Carry entrada
    output logic [3:0] s_o, // Resultado
    output logic c_o // Carry salida
);


logic c_temp[4:0];
assign c_temp[0] = c_i;

genvar i;
generate
    for(i = 0; i < 4; i++) begin
        
        full_adder fa_instance (
            .x_i(x_i[i]),
            .y_i(y_i[i]),
            .c_i(c_temp[i]),
            .s_o(s_o[i]),
            .c_o(c_temp[i+1])
        );
    end
endgenerate
assign c_o = c_temp[4];

endmodule
