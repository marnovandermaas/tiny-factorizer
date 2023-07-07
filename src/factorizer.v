/*
* Module that takes in a number and computes its factors.
* Factor bits:
* - 0: 2
* - 1: 3
* - 2: 4
* ...
* - 7: 9
*/

module factorizer (
  input wire [6:0] number,
  output reg [7:0] factors
);

  always @(*) begin
    // Divisible by 2
    factors[0] = !number[0];
    // Divisible by 3
    factors[1] = 0;//((number % 3) == 0);
    // Divisible by 4
    factors[2] = !number[0] && !number[1];
    // Divisible by 5
    factors[3] = 0;//((number % 5) == 0);
    // Divisible by 6
    factors[4] = factors[0] && factors[1];
    // Divisible by 7
    factors[5] = 0;//((number % 7) == 0);
    // Divisible by 8
    factors[6] = !number[0] && !number[1] && !number[2];
    // Divisible by 9
    factors[7] = 0;//((number % 9) == 0);
  end

endmodule

/* Cheat sheet
 0: 0_0000
 1: 0_0001
 2: 0_0010
 3: 0_0011
 4: 0_0100
 5: 0_0101
 6: 0_0110
 7: 0_0111
 8: 0_1000
 9: 0_1001
10: 0_1010
11: 0_1011
12: 0_1100
13: 0_1101
14: 0_1110
15: 0_1111
16: 1_0000
17: 1_0001
18: 1_0010
*/