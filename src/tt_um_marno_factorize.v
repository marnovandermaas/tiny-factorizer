`default_nettype none

module tt_um_marno_factorize #( parameter MAX_COUNT = 10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Will go high when the design is enabled
    input  wire       clk,      // Clock
    input  wire       rst_n     // reset_n - Low to reset
);
    // External clock is 10MHz, so need 24 bit counter
    reg [23:0] second_counter;
    reg [3:0] digit;
    reg [3:0] new_digit;
    wire [17:0] factors;

    reg [7:0] old_input;

    // Create reset for convenience
    wire reset = !rst_n;

    // Seven segment LEDs
    wire [6:0] led_out;
    assign uo_out[7] = 1'b0;
    assign uo_out[6:0] = led_out; // Only least significant 7 bits are used for segment display

    // Use bidirectionals as outputs
    assign uio_oe = 8'hFF;

    // Put bottom 8 bits of second counter out on the bidirectional GPIO
    assign uio_out = |ui_in ?
                        {/*19*/ factors[17], /*17*/ factors[15], /*13*/ factors[11], /*11*/ factors[9], /*7*/ factors[5], /*5*/ factors[3], /*3*/ factors[1], /*2*/ factors[0]}
                        : second_counter[7:0];

    // Drive segment display
    always @(posedge clk) begin
        // If reset, set counter and digit to 0
        if (reset) begin
            second_counter <= 0;
            digit <= 0;
            new_digit <= 0;
            old_input <= 0;
        end else begin
            if (ui_in != old_input) begin
                second_counter <= 0;
                new_digit <= 1;
                digit <= 1;
            end else begin
                // If counted up to second
                if (second_counter == MAX_COUNT - 1) begin
                    // Reset counter
                    second_counter <= 0;

                    // Increment digit
                    new_digit <= new_digit + 1'b1;

                    // Only count from 0x1 to 0xF
                    if (new_digit == 4'hF) begin
                        new_digit <= 4'h1;
                    end
                end else begin
                    // Increment counter
                    second_counter <= second_counter + 1'b1;
                    if (new_digit != 0) begin
                        if (new_digit == 1) begin
                            digit <= 1;
                        end else begin
                            if (factors[new_digit - 2]) begin
                                digit <= new_digit;
                            end else begin
                                // Cycle through digits if this is not a factor of the input
                                new_digit <= new_digit + 1'b1;

                                // Only count from 0x1 to 0xF
                                if (new_digit == 4'hF) begin
                                    new_digit <= 4'h1;
                                end
                            end
                        end
                    end
                end
            end
            old_input <= ui_in;
        end
    end

    // Instantiate segment display
    seg7decoder seg7decoder(.counter(digit), .segments(led_out));

    // Instantiate factoring unit
    factorizer factorizer(.clk(clk), .reset(reset), .number(ui_in), .factors(factors));

endmodule
