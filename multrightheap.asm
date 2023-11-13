MAIN: 
    SUB R5,R15,R15 //Registro para iniciar valores
    // NOTE: Se evita usar el MOV mediante operacion 0+Immediate
    ADD R0,R5,#28// NWord=28
    ADD R1,R5,#3 // n=3,Profundidad del heap
    ADD R10,R5,#0xA0  // Direccion final de resultado
    B MULT_RIGHT_HEAP

//MULT RIGHT HEAP: Halla el multiplicatorio de todos los
//elementos derechos de un un heap
//R0 = Numero de word
//R1 = Nieveles de profundidad del heap
MULT_RIGHT_HEAP:
  // Constante utilizada para cambiar el offset
  ADD R7,R5,#2 // Constante2  = 2
  // Inicializar el registro de respuesta  
  LDR R2,[R10] //Total = 1
  // Inicializar variable de loop
  ADD R3,R5,#1 // i = 1 iterador
  // Inicializar Offset
  ADD R4,R5,#8 // Constante8 = 8
  // Valor temporal 
  ADD R5,R5,#4 // temp = 4
  // Transformar numero de word  proporcionado a direccion de memoria
  UMULL R0, R0, R5, R9 // Dir = NWord * 4 
// Loop para recorrer los nodos derechos del heap
LOOP:
  SUBS R9, R1, R3 // alternativa de CMP
  BLT END // IF (n < iterador) => END
  LDR R5, [R0] // temp = Load(Mem)
  // Total = Total x temp
  SMULL R2, R2, R5, R9
  ADD R0, R0, R4 // Mem = Mem + offset
  MUL R4, R4, R7 // offest = offset * 2
  ADD R3, R3, #1 //i++
  B LOOP
END:
  // Almacenar respuesta en memoria
  STR R2,[R10,#0]
// NOTE: R9 = Garbage for multiplication 
//and comparison