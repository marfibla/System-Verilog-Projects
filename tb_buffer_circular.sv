module tb_buffer_circular;

  parameter WIDTH = 32;
  parameter NUMREG = 16;
  parameter INDEX_SIZE = $clog2(NUMREG);
  // Signal declaration
  logic clk, rstn, insercion_i; 	// Senyal de insercion
  logic [WIDTH-1:0] dato_i; 		// Dato a insertar
  logic delecion_i; 	// Senyal de delecion
  logic [WIDTH-1:0] dato_o; 		// Dato leido
  logic vacia_o, llena_o; 		// Senyal de cola llena

  initial begin
    // Initial state of the signals
    clk = '0; rstn = '0; insercion_i = '0; delecion_i = '0;
    vacia_o = '1; llena_o = '0;

  end


  BufferCircular #(.WIDTH(WIDTH), .NUM(NUMREG)) buff (
    .clk_i(clk),
    .rstn_i(rstn),
    .insercion_i(insercion_i),
    .dato_i(dato_i),
    .delecion_i(delecion_i),
    .dato_o(dato_o),
    .vacia_o(vacia_o),
    .llena_o(llena_o)
  );

  // -------------------------------------
  // Clock and reset tasks
  // -------------------------------------
  task tick_clk();
    clk = '1; #500; clk = '0; #500;
  endtask

  task rstn_low();
    rstn = '0; clk = '1; #500; rstn = '1; clk = '0; #500;
  endtask

  // -------------------------------------
  // Pop and push tasks
  // -------------------------------------
  // push data into the buffer
  task push_elem(
    logic [WIDTH-1:0] push_data
  );
    if (llena_o) begin
      $display("\nEl buffer está lleno, no se ha hecho push de el elemento %b", push_data);
    end
    else begin
      rstn = 1; insercion_i = 1; delecion_i = 0; dato_i = push_data; clk = 0;
      #500 clk = 1; #500 clk = 0;

      assert_not_empty();

      #500 $display("\n(%0d) Se ha escrito el valor %b en el buffer", $time, push_data);
    end
    insercion_i = 0; delecion_i = 0;

  endtask

  // pop data from the buffer
  task pop_elem();

    if (vacia_o) begin
      $display("\nEl buffer está vacío, no se ha hecho pop");
    end
    else begin
      #500 $display("\n(%0d) Se lee el valor %b de el buffer", $time, dato_o);
      rstn = 1; delecion_i = 1; insercion_i = 0; clk = 0;
      #500 clk = 1; #500 clk = 0;

      assert_not_full();

    end
    insercion_i = 0; delecion_i = 0;

  endtask

  // push and pop at the same cycle from the buffer
  task push_pop_elem(
    logic [WIDTH-1:0] push_data
  );
    if (llena_o) begin
      #500 $display("\nEl buffer está lleno, no se ha hecho push de el elemento %b (push_pop)", push_data);
      $display("\n(%0d) Se lee el valor %b de el buffer (push_pop)", $time, dato_o);
      rstn = 1; insercion_i = 1; delecion_i = 1; dato_i = push_data; clk = 0;
      #500 clk = 1; #500 clk = 0;

      assert_not_full();

    end
    else if (vacia_o) begin
      #500 $display("\nEl buffer esta vacío, sólo se ha escribe el elemento %b (push_pop)", push_data);
      rstn = 1; insercion_i = 1; delecion_i = 1; dato_i = push_data; clk = 0;
      #500 clk = 1; #500 clk = 0;

      assert_not_empty();

    end
    else begin
      #500 $display("\n(%0d) Se lee el valor %b en el buffer (push_pop)", $time, dato_o);
      $display("\n(%0d) Se ha escrito el valor %b en el buffer (push_pop)", $time, push_data);
      rstn = 1; insercion_i = 1; delecion_i = 1; dato_i = push_data; clk = 0;
      #500 clk = 1; #500 clk = 0;

    end
    insercion_i = 0; delecion_i = 0;

  endtask

  // -------------------------------------
  // Assertions
  // -------------------------------------
  // assert the buffer is empty
  task assert_empty();
    assert (vacia_o == 1)
      else $error("\n(%0d) ERROR ASSERTION: Se esperaba el buffer vacio", $time);
  endtask

  // assert the buffer is full
  task assert_full();
    assert (llena_o == 1)
      else $error("\n(%0d) ERROR ASSERTION: Se esperaba el buffer lleno", $time);
  endtask

  // assert the buffer is not full
  task assert_not_full();
    assert (llena_o == 0)
      else $error("\n(%0d) ERROR ASSERTION: Se esperaba el buffer no lleno", $time);
  endtask

  // assert the buffer is not empty
  task assert_not_empty();
    assert (vacia_o == 0)
      else $error("\n(%0d) ERROR ASSERTION: Se esperaba el buffer no vacio", $time);
  endtask

  // assert the output data is the expected one
  task assert_data(
    logic [WIDTH-1:0] expected_data
  );
    assert (dato_o == expected_data)
      else $error("\n(%0d ns) ERROR ASSERTION: Dato incorrecto en salida. Esperado: 0x%h, Leído: 0x%h", $time, expected_data, dato_o);
  endtask

  // -------------------------------------
  // Tests
  // -------------------------------------
  // Basic test
  task basic_functional_testing();
    $display(" ------------------------------------------------");
    $display(" Basic test ");
    $display(" ------------------------------------------------");

    // TODO: ...

    for (int i = 0; i < NUMREG; i++) begin
      push_elem(i[WIDTH-1:0]);
    end

    for (int i = 0; i < NUMREG; i++) begin
      assert_data(i[WIDTH-1:0]);
      pop_elem();
    end

    #500 $display("\n(%0d) Push_Pop cuando el buffer está vacío", $time);
    push_pop_elem(32'hEEEE_FFFF);  // push pop quan està buit

    while (vacia_o == 0) begin
      pop_elem();
    end
    push_elem(32'hEEEE_FAFF);
    #500 $display("\n(%0d) Push_Pop cuando el buffer no está ni vacío ni lleno", $time);
    push_pop_elem(32'hEEAE_AFFF);  // push pop quan no està plè ni buit

    while (llena_o == 0) begin
      push_elem(32'hEEEE_FFFF);
    end
    #500 $display("\n(%0d) Push_Pop cuando el buffer está lleno", $time);
    push_pop_elem(32'hEEEE_FFAF);  // push pop quan està plè 
    
  endtask

  // Tests for corner cases

  //CORNER CASE: pop en buffer vacio
  task empty_pop();
    while (vacia_o == 0) begin
      pop_elem();
    end
    assert_empty(); //miro que el buffer estigue buit
  #500 $display("\n(%0d) CORNER CASE: Pop cuando el buffer está vacío", $time);

    pop_elem();

    //verifiquem que el buffer segueixi buit
    assert_empty();
    assert_not_full();  

  endtask;

//CORNER CASE: push en buffer vacio
   task full_push();
    while (llena_o == 0) begin
      push_elem(32'hEEE_FFFF);
    end
    assert_full();

  #500 $display("\n(%0d) CORNER CASE: Push cuando el buffer está lleno", $time);
    push_elem(32'hEBEE_FAFF);  

  assert_full();
  assert_not_empty();

  endtask;

// CORNER CASE: ver cómo el puntero pasa de apuntar al último registro al primero
// damos una vuelta a la cola
  task wrap_around();
    for (int i = 0; i < NUMREG+4; ++i) begin
      push_elem(32'hEEEE_FFFF);
      assert_data(32'hEEEE_FFFF);
      pop_elem();
      assert_empty();
    end

  #500 $display("\n(%0d) CORNER CASE: Wrap around. No ha dado error", $time);
  endtask


  task reset_test();

    push_elem(32'hEEEE_FFFF);
    push_elem(32'hEEEE_FFFF);
    assert_not_empty();

    rstn_low();

    assert_empty();
    assert_not_full();
  #500 $display("\n(%0d) CORNER CASE: Reset con cola no vacía. No ha dado error", $time);

  endtask


  // Main execution flow of the testbench
  initial begin 
    // wavefrom generation
    $dumpfile("waveform_buffer_circular.vcd");
    $dumpvars();

    rstn_low();

    // Basic functionality testing 
    basic_functional_testing();
    
    // Corner cases testing
    full_push();
    empty_pop();
    wrap_around();
    reset_test();
    
    $finish();
  end
                 
endmodule
