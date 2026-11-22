module accum_nbits #(
        parameter WIDTH = 8
    ) (
    input logic clk_i,
    input logic nrst_i, // Se~nal de reset
    input logic [WIDTH-1:0] x_i, // Operando 1
    output logic [WIDTH-1:0] y_o // Resultado
);

//assign y_o = 0;

always_ff @(posedge clk_i, nrst_i) begin
    if (~nrst_i) begin
        y_o <= '0;
    end
    else begin
        y_o <= x_i + y_o;
    end
end

endmodule
