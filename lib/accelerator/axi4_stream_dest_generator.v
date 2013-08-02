//
// Copyright 2013 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

module axi4_stream_dest_generator
#(
  parameter C_AXIS_DEST_WIDTH = 2,
  parameter C_AXIS_DATA_WIDTH = 64
)
(
  input clk,
  input rst,

  input                          S_AXIS_DEST_TVALID,
  output                         S_AXIS_DEST_TREADY,
  input [C_AXIS_DEST_WIDTH-1:0]  S_AXIS_DEST_TDATA,

  input                          S_AXIS_TVALID,
  output                         S_AXIS_TREADY,
  input [C_AXIS_DATA_WIDTH-1:0]  S_AXIS_TDATA,
  input                          S_AXIS_TLAST,


  output                         M_AXIS_TVALID,
  input                          M_AXIS_TREADY,
  output [C_AXIS_DATA_WIDTH-1:0] M_AXIS_TDATA,
  output                         M_AXIS_TLAST,
  output [C_AXIS_DEST_WIDTH-1:0] M_AXIS_TDEST,

  output [127:0]                 debug

);

  localparam STATE_GET_DEST = 2'h0;
  localparam STATE_XFER     = 2'h1;

  reg [1:0] state;

  reg [C_AXIS_DEST_WIDTH-1:0] tdest;

  always @(posedge clk) begin
    if (rst) begin
      state <= STATE_GET_DEST;
      tdest <= 2'h3;
    end

    else case (state)
      STATE_GET_DEST: begin
        if (S_AXIS_DEST_TVALID && S_AXIS_DEST_TREADY) begin
          state <= STATE_XFER;
          tdest <= S_AXIS_DEST_TDATA;
        end
      end

      STATE_XFER: begin
        if (S_AXIS_TVALID && S_AXIS_TLAST)
          state <= STATE_GET_DEST;
      end

      default:
        state <= STATE_GET_DEST;

    endcase
  end


  assign S_AXIS_DEST_TREADY = (state == STATE_GET_DEST);

  assign S_AXIS_TREADY = (state == STATE_XFER) && M_AXIS_TREADY;

  assign M_AXIS_TVALID = (state == STATE_XFER) && S_AXIS_TVALID;
  assign M_AXIS_TDATA  = S_AXIS_TDATA;
  assign M_AXIS_TLAST  = S_AXIS_TLAST;
  assign M_AXIS_TDEST  = ((state == STATE_XFER) && S_AXIS_TVALID) ? tdest : 2'h3;


  //assign debug[63:0]    = M_AXIS_TDATA;
  //assign debug[64]      = M_AXIS_TVALID;
  //assign debug[65]      = M_AXIS_TREADY;
  //assign debug[66]      = M_AXIS_TLAST;
  //assign debug[70:67]   = M_AXIS_TDEST;

  //assign debug[71]      = S_AXIS_DEST_TVALID;
  //assign debug[72]      = S_AXIS_DEST_TREADY;
  //assign debug[76:73]   = S_AXIS_DEST_TDATA;
  //assign debug[78:77]   = state;

endmodule
