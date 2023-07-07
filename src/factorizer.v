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
    // Initial bogus implementation
    factors = {1'b0, number};
  end

endmodule