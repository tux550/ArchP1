// 

module add_fp (
	a,
	b,
	res_add,
    flags_add
);
  // Parameteres
  parameter MANTISA_WIDTH = 23;
  parameter EXPONENT_WIDTH = 8;

  // Inputs & Outputs
  input wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] a;
  input wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] b;  
  output wire [MANTISA_WIDTH+EXPONENT_WIDTH:0] res_add;
  output wire [3:0] flags_add; // NZCV

  // Division de flags
  wire neg;
  reg zero;
  reg carry;
  reg overflow;

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
  

  // Ajuste de mantisa
  reg [EXPONENT_WIDTH-1:0]diff_exponente;
  reg [EXPONENT_WIDTH-1:0]big_exponent;
  reg [MANTISA_WIDTH:0]mant_a;
  reg [MANTISA_WIDTH:0]mant_b;

  always @(*) begin
      if (exponent_a > exponent_b) begin
          big_exponent = exponent_a;
          diff_exponente =  exponent_a-exponent_b;
          mant_a = mantisa_a;
          mant_b = mantisa_b>>diff_exponente;
      end
      else begin
          big_exponent = exponent_b;
          diff_exponente =  exponent_b-exponent_a;
          mant_a = mantisa_a>>diff_exponente;
          mant_b = mantisa_b;
      end
  end

  // Suma de mantisas
  reg [MANTISA_WIDTH+1:0]mant_sum;
  reg res_sign;

  always @(*) begin
      // Signos distintos
      if (sign_a^sign_b) begin
          if (mant_b > mant_a) begin
              res_sign = sign_b;
              mant_sum = mant_b-mant_a;
          end
          else begin
              res_sign = sign_a;
              mant_sum = mant_a-mant_b;
          end
      end
      // Signos iguales
      else begin
        mant_sum = mant_a+mant_b;
        res_sign = sign_a;
      end
  end
  
  // Ajuste de mantisa y exponente post suma (carry)
  reg [MANTISA_WIDTH-1:0]adjust_mant;
  reg [EXPONENT_WIDTH:0]adjust_exponent; // NOTE: aca es donde podria haber overflow de exponente (?). Como solucionar?
  always @(*) begin
      if(mant_sum[MANTISA_WIDTH+1]==1'b1) begin
          // CARRY
          carry = 1'b1;
          // Ajuste de mantisa
          adjust_mant = mant_sum[MANTISA_WIDTH:1]; // NOTE: aca se esta truncando la mantisa. Deberia ser aproximacion (?)
          // Ajuste de exponente
          adjust_exponent = big_exponent+1'b1;
      end
      else begin
          // SIN CARRY
          carry = 1'b0;
          // Ajuste de mantisa
          adjust_mant = mant_sum[MANTISA_WIDTH-1:0]; // NOTE: aca se esta truncando la mantisa. Deberia ser aproximacion (?)
          // Ajuste de exponente
          adjust_exponent = big_exponent;
      end
  end

  // Deteccion de overflow
  reg [MANTISA_WIDTH-1:0]res_mant;
  reg [EXPONENT_WIDTH-1:0] res_exponent;
  always @(*) begin
      //                Oveflow                 or            Infinite/Nan result
      if ( (adjust_exponent[EXPONENT_WIDTH]==1'b1) || (adjust_exponent[EXPONENT_WIDTH-1:0]== { EXPONENT_WIDTH {1'b1}}) ) begin
          // OVERFLOW
          overflow = 1'b1;
          // Infinite result
          res_exponent = {EXPONENT_WIDTH{1'b1}};
          res_mant = {MANTISA_WIDTH{1'b0}};
      end
      else begin
          // No overflow
          overflow = 1'b0;
          // Normal result
          res_exponent = adjust_exponent[EXPONENT_WIDTH-1:0];
          res_mant = adjust_mant;
      end
  end
  
  // Deteccion de flags NZ
  assign neg = res_sign;
  always @(*) begin
      if (
          res_exponent[EXPONENT_WIDTH-1:0]=={EXPONENT_WIDTH{1'b0}}
          &&
          res_mant=={MANTISA_WIDTH{1'b0}}
          ) begin
          zero = 1'b1;
      end
      else begin
          zero = 1'b0;
      end
  end

  // Obtencion de resultado
  assign res_add = {res_sign, res_exponent, res_mant};
  assign flags_add = {neg, zero, carry, overflow};
endmodule