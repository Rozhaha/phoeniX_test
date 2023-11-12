module Incrementer
(
    input   [29 : 0] operand_1,
    output  [29 : 0] result
);

    wire [8 : 0] carry_chain;
    assign carry_chain[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < 7; i = i + 1)
        begin
            Lookahead_Adder 
            #(
                .LEN(4)
            )
            incrementer_4bit
            (
                .A(operand_1[(i * 4) + 3 : i * 4]),
                .B(4'b0000),
                .Carry_in(carry_chain[i]),
                .Sum(result[(i * 4) + 3 : i * 4]),
                .Carry_out(carry_chain[i + 1])
            );
        end
    endgenerate

    Lookahead_Adder 
    #(
        .LEN(2)
    )
    incrementer_2bit
    (
        .A(operand_1[29 : 28]),
        .B(2'b00),
        .Carry_in(carry_chain[7]),
        .Sum(result[29 : 28]),
        .Carry_out(carry_chain[8])
    );
endmodule

module Lookahead_Adder 
#(
    parameter LEN = 4
)
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Carry_in,
    output [LEN - 1 : 0] Sum,
    output Carry_out
);
    wire [LEN : 0] Carry;
    wire [LEN : 0] CarryX;
    wire [LEN - 1 : 0] P;
    wire [LEN - 1 : 0] G;
    assign P = A | B;   // Bitwise AND
    assign G = A & B;   // Bitwise OR

    assign Carry[0] = Carry_in;

    genvar i;
    generate
        for (i = 1 ; i <= LEN; i = i + 1)
        begin
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder_Incrementer FA (.A(A[i]), .B(B[i]), .Carry_in(Carry[i]), .Sum(Sum[i]), .Carry_out(CarryX[i + 1]));
        end
    assign Carry_out = Carry[LEN];
    endgenerate
endmodule

module Full_Adder_Incrementer 
(
    input A,
    input B,
    input Carry_in,

    output Sum,
    output Carry_out
);
    assign Sum = A ^ B ^ Carry_in;
    assign Carry_out = (A && B) || (A && Carry_in) || (B && Carry_in); 
endmodule