`timescale 1ps / 1ps

module full_adder (
input logic x_i, // Operando 1
input logic y_i, // Operando 2
input logic c_i, // Carry entrada

output logic s_o, // Resultado
output logic c_o // Carry salida
);

logic xor1;
logic and1;
logic and2;

assign #(100) xor1 = x_i ^ y_i;
assign #100 s_o = xor1 ^ c_i;
assign #50 and1 = x_i & y_i;
assign #50 and2 = xor1 & c_i;
assign #100 c_o = and1 | and2;

endmodule;
