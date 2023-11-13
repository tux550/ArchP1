// 

module mult_fp (
	a,
	b,
	res_mult,
  flags_mult
);

  // Parameteres
  parameter MANTISA_WIDTH = 23;
  parameter EXPONENT_WIDTH = 8;

  // Inputs & Outputs
  input wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] a;
  input wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] b;  
  output wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] res_mult;
  output wire [3:0] flags_mult;// NZCV
  
  // Division de flags
  wire neg;
  reg zero;
  wire carry;
  wire overflow;

  // Extraccion de elementos de inputs
  wire [MANTISA_WIDTH:0] mantisa_a;
  wire [EXPONENT_WIDTH-1:0]  exponent_a;
  wire sign_a;
  wire [MANTISA_WIDTH:0] mantisa_b;
  wire [EXPONENT_WIDTH-1:0]  exponent_b;
  wire sign_b;


  assign sign_a = a[MANTISA_WIDTH+EXPONENT_WIDTH];
  assign exponent_a = a[MANTISA_WIDTH+EXPONENT_WIDTH-1:MANTISA_WIDTH];
  assign mantisa_a = {1'b1, a[MANTISA_WIDTH-1:0]};

  assign sign_b = b[MANTISA_WIDTH+EXPONENT_WIDTH];
  assign exponent_b = b[MANTISA_WIDTH+EXPONENT_WIDTH-1:MANTISA_WIDTH];
  assign mantisa_b = {1'b1, b[MANTISA_WIDTH-1:0]};

  // Signo resultante
  wire res_sign;
  assign res_sign = sign_a ^ sign_b;

  // Calculo de exponente
  wire [EXPONENT_WIDTH:0] mult_exponent;
  //                                                        BIAS
  assign mult_exponent = exponent_a + exponent_b - {EXPONENT_WIDTH-1{1'b1}};

  // Multiplicacion de Mantisas
  wire [2*MANTISA_WIDTH +1:0] long_mult_mantisa;
  wire [MANTISA_WIDTH:0] mult_mantisa;
  assign long_mult_mantisa = mantisa_a*mantisa_b;
  assign mult_mantisa = long_mult_mantisa[2*MANTISA_WIDTH+1:MANTISA_WIDTH+1];

  // Normalizacion del exponente y mantisa
  wire [EXPONENT_WIDTH-1:0] norm_exponent;
  assign norm_exponent = (mult_mantisa[MANTISA_WIDTH]==1'b1) ? mult_exponent + 1'b1 : mult_exponent; // NOTE: aca es donde podria haber overflow de exponente (?). Como solucionar?
  wire [MANTISA_WIDTH-1:0] norm_mant;
  assign norm_mant = (mult_mantisa[MANTISA_WIDTH]==1'b1) ? mult_mantisa[MANTISA_WIDTH-1:0] :  {mult_mantisa[MANTISA_WIDTH-2:0], long_mult_mantisa[MANTISA_WIDTH]}; // Recuperando bit perdido de long mult en caso de normalizar
  //assign res_mant = (mult_mantisa[MANTISA_WIDTH]==1'b1) ? mult_mantisa[MANTISA_WIDTH:1] : mult_mantisa[MANTISA_WIDTH-1:0];

  // Edge case - ZERO
  reg [EXPONENT_WIDTH-1:0] res_exponent;
  reg [MANTISA_WIDTH-1:0] res_mant;
  always @(*) begin
    if (
      (exponent_a[EXPONENT_WIDTH-1:0] == {EXPONENT_WIDTH{1'b0}} && mantisa_a[MANTISA_WIDTH-1:0] == {MANTISA_WIDTH{1'b0}})
      ||
      (exponent_b[EXPONENT_WIDTH-1:0] == {EXPONENT_WIDTH{1'b0}} && mantisa_b[MANTISA_WIDTH-1:0] == {MANTISA_WIDTH{1'b0}})
    ) begin
      // Edge case. Multiplicacion por zero
      res_exponent = {EXPONENT_WIDTH{1'b0}};
      res_mant = {MANTISA_WIDTH{1'b0}};
    end
    else begin
      // Comportarmiento normal
      res_exponent = norm_exponent;
      res_mant = norm_mant;
    end
  end

  // Deteccion de flags
  assign neg = res_sign;
  always @(*) begin
      if ( 
            res_exponent[EXPONENT_WIDTH-1:0]=={EXPONENT_WIDTH{1'b0}}
            &&
            res_mant[MANTISA_WIDTH-1:0]=={MANTISA_WIDTH{1'b0}}
          ) begin
          zero = 1'b1;
      end
      else begin
          zero = 1'b0;
      end
  end
  assign carry = 1'b0;
  assign overflow = 1'b0;

  // Obtencion de resultado
  assign res_mult = {res_sign, res_exponent, res_mant};
  assign flags_mult = {neg, zero, carry, overflow};
endmodule
