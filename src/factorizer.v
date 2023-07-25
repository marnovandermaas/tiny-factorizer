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
  input wire [7:0] number,
  output reg [17:0] factors
);
  reg [3:0] mod_three;
  reg [4:0] mod_five;
  reg [4:0] mod_seven;
  reg [4:0] mod_nine;
  reg [5:0] mod_eleven;
  reg [5:0] mod_thirteen;
  reg [6:0] mod_seventeen;
  reg [6:0] mod_nineteen;

  always @(posedge clk) begin
    if (reset) begin
      mod_three     <= 0;
      mod_five      <= 0;
      mod_seven     <= 0;
      mod_nine      <= 0;
      mod_eleven    <= 0;
      mod_thirteen  <= 0;
      mod_seventeen <= 0;
      mod_nineteen  <= 0;
      factors       <= 0;
    end else begin
      // Divisible by 2
      factors[0] <= !number[0];
      // Divisible by 3
      mod_three <= number[0] + (2*number[1]) +
                   number[2] + (2*number[3]) +
                   number[4] + (2*number[5]) +
                   number[6] + (2*number[7]);
      factors[1] <= mod_three ==  0 ||
                    mod_three ==  3 ||
                    mod_three ==  6 ||
                    mod_three ==  9 ||
                    mod_three == 12;
      // Divisible by 4
      factors[2] <= !number[0] && !number[1];
      // Divisible by 5
      mod_five <= number[0] + 2*number[1] + 4*number[2] + 3*number[3] +
                  number[4] + 2*number[5] + 4*number[6] + 3*number[7];
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
                   number[6] + 2*number[7];
      factors[5] <= mod_seven ==  0 ||
                    mod_seven ==  7 ||
                    mod_seven == 14;
      // Divisible by 8
      factors[6] <= !number[0] && !number[1] && !number[2];
      // Divisible by 9
      mod_nine <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 7*number[4] + 5*number[5] +
                  number[6] + 2*number[7];
      factors[7] <= mod_nine ==  0 ||
                    mod_nine ==  9 ||
                    mod_nine == 18 ||
                    mod_nine == 27;
      // Divisible by 10
      factors[8] <= factors[3] && factors[0];
      // Divisible by 11
      mod_eleven <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 5*number[4] + 10*number[5] + 9*number[6] + 7*number[7];
      factors[9] <= mod_eleven ==  0 ||
                    mod_eleven == 11 ||
                    mod_eleven == 22 ||
                    mod_eleven == 33 ||
                    mod_eleven == 44 ||
                    mod_eleven == 55;
      // Divisible by 12
      factors[10] <= factors[2] && factors[1];
      // Divisible by 13
      mod_thirteen <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 3*number[4] + 6*number[5] + 12*number[6] + 11*number[7];
      factors[11] <= mod_thirteen ==  0 ||
                     mod_thirteen == 13 ||
                     mod_thirteen == 26 ||
                     mod_thirteen == 39;
      // Divisible by 14
      factors[12] <= factors[5] && factors[0];
      // Divisible by 15
      factors[13] <= factors[3] && factors[1];
      // Divisible by 16
      factors[14] <= !number[0] && !number[1] && !number[2] && !number[3];
      // Divisible by 17
      mod_seventeen <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 16*number[4] + 15*number[5] + 13*number[6] + 9*number[7];
      factors[15] <= mod_seventeen ==  0 ||
                     mod_seventeen == 17 ||
                     mod_seventeen == 34 ||
                     mod_seventeen == 51 ||
                     mod_seventeen == 68;
      // Divisible by 18
      factors[16] <= factors[7] && factors[0];
      // Divisible by 19
      mod_nineteen <= number[0] + 2*number[1] + 4*number[2] + 8*number[3] + 16*number[4] + 13*number[5] + 7*number[6] + 14*number[7];
      factors[17] <= mod_nineteen ==  0 ||
                     mod_nineteen == 19 ||
                     mod_nineteen == 38 ||
                     mod_nineteen == 57;
    end
  end

endmodule
