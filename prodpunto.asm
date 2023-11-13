MAIN:
    //Registro para iniciar valores
    SUB R0,R15,R15 
    // NOTE: Se evita usar el MOV mediante operacion 0+Immediate
    // Memoria base de arreglo 1 
    ADD R1,R0,#0x070 // base1 = 112
    // Memoria base de arreglo 2
    ADD R2,R0,#0x080 // base2 = 128
    // Direccion final de resultado
    ADD R7,R0,#0xA0 
    // Tamaño de arreglos
    ADD R4,R0,#3 //size=3

    // Ejemplo de inicializacion de valores
    //LDR R8,=0x4096ecc0 //4.7164
    //LDR R9,=0x404ccccd // 3.2
    //LDR R12,=0x00000000 //0

    //LDR R10,=0x40b00000 //5.5
    //LDR R11,=0x40066666 //2.1
    //LDR R7,=0x41073333 // 8.45

    // //arreglo1 = [4.7164, 3.2, 0]
    //STR R8, [R1]
    //STR R9, [R1,#4]
    //STR R12, [R1,#8]

    // //arreglo2 = [5.5, 2.1, 8.45]
    //STR R10, [R2]
    //STR R11, [R2,#4]
    //STR R7,[R2,#8] 
    B PROD_PUNTO

// PROD PUNTO: Halla el producto punto
// de dos arreglos de tamaño size
// R1 = dirección de memoria base
// para arreglo1
// R2 = dirección de memoria base
// para arreglo1 
// R3 = Tamaño de los arreglos (size) 
PROD_PUNTO:
    ADD R3,R0,#0//iterador=0
//Loop para recorrer los arreglos 
//Y realizar las operaciones necesarias
LOOP:
    SUBS R6,R4,R3 // (iterador == 3)?
    BEQ END // IF (iterador == 3) => END
    // A1 = arreglo1[BASE1+4*iterador]
    LDR R5,[R1] 
    // A2 = arreglo2[BASE2+4*iterador]
    LDR R6,[R2] 
    MUL32 R12,R5,R6 // TEMP= A1 * A2
    ADD32 R0,R0,R12 // RESULT=RESULT + TEMP
    ADD R1,R1,#4 // BASE1 + 4
    ADD R2,R2,#4 // BASE2 + 4
    ADD R3,R3,#1 // ITERADOR ++
    B LOOP // REPEAT LOOP
END:
    // Almacenar respuesta en memoria
    STR R0, [R7, #0]