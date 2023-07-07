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
  input wire clk,
  input wire reset,
  input wire [6:0] number,
  output reg [7:0] factors
);
  reg [3:0] mod_three;
  reg [4:0] mod_five;
  reg [4:0] mod_seven;
  reg [4:0] mod_nine;

  always @(posedge clk) begin
    if (reset) begin
      mod_three <= 0;
      mod_five <= 0;
      mod_seven <= 0;
      mod_nine <= 0;
      factors <= 0;
    end else begin
      // Divisible by 2
      factors[0] <= !number[0];
      // Divisible by 3
      mod_three <= number[0] + (2*number[1]) +
                   number[2] + (2*number[3]) +
                   number[4] + (2*number[5]) +
                   number[6];
      factors[1] <= mod_three ==  0 ||
                    mod_three ==  3 ||
                    mod_three ==  6 ||
                    mod_three == 12;
      // Divisible by 4
      factors[2] <= !number[0] && !number[1];
      // Divisible by 5
      mod_five <= number[0] + 2*number[1] + 4*number[2] + 3*number[3] +
                  number[4] + 2*number[5] + 4*number[6];
      factors[3] <= mod_five ==  0 ||
                    mod_five ==  5 ||
                    mod_five == 10 ||
                    mod_five == 15 ||
                    mod_five == 20;
      // Divisible by 6
      factors[4] <= factors[0] && factors[1];
      // Divisible by 7
      mod_seven <= number[0] + 2*number[1] + 4*number[2] +
                   number[3] + 2*number[4] + 4*number[5] +
                   number[6];
      factors[5] <= mod_seven ==  0 ||
                    mod_seven ==  7 ||
                    mod_seven == 14;
      // Divisible by 8
      factors[6] <= !number[0] && !number[1] && !number[2];
      // Divisible by 9
      mod_nine <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 7*number[4] + 5*number[5] +
                  number[6];
      factors[7] <= mod_nine ==  0 ||
                    mod_nine ==  9 ||
                    mod_nine == 18 ||
                    mod_nine == 27;
    end
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
19: 1_0011
20: 1_0100
21: 1_0101
22: 1_0110
23: 1_0111
24: 1_1000
25: 1_1001
*/