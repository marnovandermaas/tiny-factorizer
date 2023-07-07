/*
* Module that takes in a number and computes its factors.
* Factor bits:
* - 0: 2
* - 1: 3
* - 2: 4
* ...
* - 7: 9
*
* Method for calculating modulus where n is b bits wide:
* n % k = (
*           (2^0 % k) * n[0] +
*           (2^1 % k) * n[1] +
*           ... +
*           (2^(b-2) % k) * n[b-2] +
*           (2^(b-1) % k) * n[b-1]
*         ) % k
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
                    mod_three ==  9 ||
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
