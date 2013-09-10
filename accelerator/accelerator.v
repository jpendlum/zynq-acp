/****************************************************************************
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *
 * Author(s):   Jonathon Pendlum (jon.pendlum@gmail.com)
 * Description: 31 tap, fixed point, dual channel, symmetric FIR filter
 *              generated with Xilinx IP.
 *              Input: 2 x 32-bit int
 *              Output: 2 x 32-bit int
 *              Coefficients: 32-bit fixed point (fx1.31)
 *              The default coefficeints implement a half-band filter with
 *              >35 dB of attenuation and <1 dB passband ripple.
 *
 *              Stream0 is used for sample data with 2 32-bit samples
 *              interleaved into the 64-bit wide bus. This lends naturally
 *              to using complex samples.
 *
 *              Steam1 is used for loading new coefficients through the
 *              reload interface of the FIR filter.
 *
 *              FIR filters generated with Xilinx IP have a high degree
 *              of flexibility, including changing the number of channels /
 *              patterns & having different banks of coefficients. This
 *              filter is configured to use only 1 bank of coefficients and
 *              1 input pattern. Due to the filter's simple design, the
 *              config interface is controlled by a state machine instead of
 *              by the configuration stream (aka stream1). See Xilinx's FIR
 *              Filter IP datasheet for more information on the reload /
 *              config interfaces: http://www.xilinx.com/support/
 *              documentation/ip_documentation/fir_compiler/v7_0/
 *              pg149-fir-compiler.pdf
 *
 ***************************************************************************/
 module accelerator
(
  input               clk,
  input               rst_n,
  input               stream0_master_tvalid,
  output              stream0_master_tready,
  input       [63:0]  stream0_master_tdata,
  input               stream0_master_tlast,
  output reg          stream0_slave_tvalid,
  input               stream0_slave_tready,
  output reg  [63:0]  stream0_slave_tdata,
  output reg          stream0_slave_tlast,
  input               stream1_master_tvalid,
  output              stream1_master_tready,
  input       [63:0]  stream1_master_tdata,
  input               stream1_master_tlast,
  output              stream1_slave_tvalid,
  input               stream1_slave_tready,
  output      [63:0]  stream1_slave_tdata,
  output              stream1_slave_tlast,
  input               stream2_master_tvalid,
  output              stream2_master_tready,
  input       [63:0]  stream2_master_tdata,
  input               stream2_master_tlast,
  output              stream2_slave_tvalid,
  input               stream2_slave_tready,
  output      [63:0]  stream2_slave_tdata,
  output              stream2_slave_tlast,
  input               stream3_master_tvalid,
  output              stream3_master_tready,
  input       [63:0]  stream3_master_tdata,
  input               stream3_master_tlast,
  output              stream3_slave_tvalid,
  input               stream3_slave_tready,
  output      [63:0]  stream3_slave_tdata,
  output              stream3_slave_tlast,
  output              irq
);

  wire          stream0_slave_tvalid_fir;
  wire  [79:0]  stream0_slave_tdata_fir;
  wire          stream0_slave_tlast_fir;
  wire  [31:0]  stream1_master_tdata_trunc = stream1_master_tdata[31:0];
  wire          event_s_reload_tlast_missing;
  wire          event_s_reload_tlast_unexpected;

  // Stream 1 only for input, no output
  assign stream1_slave_tvalid = 1'b0;
  assign stream1_slave_tlast = 1'b0;
  assign stream1_slave_tdata = 64'd0;
  // Streams 2 & 3 unused
  assign stream2_slave_tvalid = 1'b0;
  assign stream2_slave_tlast = 1'b0;
  assign stream2_slave_tdata = 64'd0;
  assign stream3_slave_tvalid = 1'b0;
  assign stream3_slave_tlast = 1'b0;
  assign stream3_slave_tdata = 64'd0;

  (* KEEP = "TRUE" *) reg           config_tvalid;
  (* KEEP = "TRUE" *) wire          config_tready;
  (* KEEP = "TRUE" *) wire  [7:0]   config_tdata = 7'd0;
  (* KEEP = "TRUE" *) reg   [1:0]   state;
  localparam      S_IDLE = 0;
  localparam      S_WAIT_TLAST = 1;
  localparam      S_SET_CONFIG = 2;

  // Loading new filter coefficients is a two step process. First the coefficients must
  // be loaded through the reload interface. Then a configuration word must be loaded
  // for the FIR filter to switch to the new coefficeints. This state machine automates
  // the process.
  always @(posedge clk) begin
    if (!rst_n) begin
      config_tvalid           <= 1'b0;
      state                   <= S_IDLE;
    end
    else begin
      case (state)
        S_IDLE: begin
          config_tvalid       <= 1'b0;
          if (stream1_master_tvalid) begin
            state             <= S_WAIT_TLAST;
          end
        end
        // Wait for coefficients to load
        S_WAIT_TLAST: begin
          // Coefficeints were loaded incorrectly, so abort configuration
          if (event_s_reload_tlast_missing || event_s_reload_tlast_unexpected) begin
            state             <= S_IDLE;
          end
          else if(stream1_master_tlast) begin
            state             <= S_SET_CONFIG;
          end
        end
        S_SET_CONFIG: begin
          // Set tvalid to load coefficients
          config_tvalid       <= 1'b1;
          state               <= S_IDLE;
        end
        default: begin
          state               <= S_IDLE;
        end
      endcase
    end
  end

  // Interrupt after successfully loading coefficients
  assign irq = config_tvalid;

  /****************************************************************************
   * fir_filter
   *
   * 31 tap, fixed point, dual channel, symmetric FIR filter
   ***************************************************************************/
  fir_filter fir_filter
  (
    .aresetn(rst_n),
    .aclk(clk),
    .s_axis_data_tvalid(stream0_master_tvalid),
    .s_axis_data_tready(stream0_master_tready),
    .s_axis_data_tlast(stream0_master_tlast),
    .s_axis_data_tdata(stream0_master_tdata),
    .s_axis_config_tvalid(config_tvalid),
    .s_axis_config_tready(config_tready),
    .s_axis_config_tdata(config_tdata),
    .s_axis_reload_tvalid(stream1_master_tvalid),
    .s_axis_reload_tready(stream1_master_tready),
    .s_axis_reload_tlast(stream1_master_tlast),
    .s_axis_reload_tdata(stream1_master_tdata_trunc),
    .m_axis_data_tvalid(stream0_slave_tvalid_fir),
    .m_axis_data_tready(stream0_slave_tready),    // Notice this signal is not delayed
    .m_axis_data_tlast(stream0_slave_tlast_fir),
    .m_axis_data_tdata(stream0_slave_tdata_fir),
    .event_s_reload_tlast_missing(event_s_reload_tlast_missing),
    .event_s_reload_tlast_unexpected(event_s_reload_tlast_unexpected)
  );

  // The output of the FIR filter includes bit growth. This process removes
  // extra MSBs resulting in a 32-bit integer output. It also include clamping
  // logic to set the output to either the most negative or most positive number
  // if the FIR filter output exceeds the signed 32-bit integer range.
  always @(posedge clk) begin
    // Only update when upstream is ready, otherwise keep the current value
    if (stream0_slave_tready) begin
      // Delay one clock cycle
      stream0_slave_tvalid            <= stream0_slave_tvalid_fir;
      stream0_slave_tlast             <= stream0_slave_tlast_fir;
      // Channel 1
      // Detect overflow
      if ((stream0_slave_tdata_fir[39:32] != 8'hFF) && (stream0_slave_tdata_fir[39:32] != 8'h00)) begin
        // Negative overflow, clamp to most negative 32-bit number
        if (stream0_slave_tdata_fir[39]) begin
          stream0_slave_tdata[31:0]   <= 32'h80000000;
        // Positive overflow, clamp to most positive 32-bit number
        end else begin
          stream0_slave_tdata[31:0]   <= 32'h7FFFFFFF;
        end
      // No overflow detected
      end else begin
        stream0_slave_tdata[31:0]     <= stream0_slave_tdata_fir[31:0];
      end
      // Channel 2
      // Detect overflow
      if ((stream0_slave_tdata_fir[79:72] != 8'hFF) && (stream0_slave_tdata_fir[79:72] != 8'h00)) begin
        // Negative overflow, clamp to most negative 32-bit number
        if (stream0_slave_tdata_fir[79]) begin
          stream0_slave_tdata[63:32]  <= 32'h80000000;
        // Positive overflow, clamp to most positive 32-bit number
        end else begin
          stream0_slave_tdata[63:32]  <= 32'h7FFFFFFF;
        end
      // No overflow detected
      end else begin
        stream0_slave_tdata[63:32]    <= stream0_slave_tdata_fir[71:40];
      end
    end
  end

endmodule