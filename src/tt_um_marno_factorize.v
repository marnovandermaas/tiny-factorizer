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

    wire reset = !rst_n;
    wire [6:0] led_out;
    assign uo_out[6:0] = led_out; // Only least significant 7 bits are used for segment display

    // Use bidirectionals as outputs
    assign uio_oe = 8'hFF;

    // Put bottom 8 bits of second counter out on the bidirectional GPIO
    assign uio_out = second_counter[7:0];

    // External clock is 10MHz, so need 24 bit counter
    reg [23:0] second_counter;
    reg [3:0] digit;

    always @(posedge clk) begin
        // If reset, set counter and digit to 0
        if (reset) begin
            second_counter <= 0;
            digit <= 0;
        end else begin
            // If counted up to second
            if (second_counter == MAX_COUNT - 1) begin
                // Reset counter
                second_counter <= 0;

                // Increment digit
                digit <= digit + 1'b1;

                // Only count from 0 to 9
                if (digit == 9) begin
                    digit <= 0;
                end

            end else begin
                // Increment counter
                second_counter <= second_counter + 1'b1;
            end
        end
    end

    // Instantiate segment display
    seg7decoder seg7decoder(.counter(digit), .segments(led_out));

endmodule
