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
 * Authors:     Moritz Fischer
 *              Jonathon Pendlum (jon.pendlum@gmail.com)
 * Description: Interfaces the Processing System (PS) with the
 *              Programmable Logic (PL) via the AXI ACP bus and
 *              an AXI Datamover IP core.
 *
 ***************************************************************************/

module ps_pl_interface
#(
  parameter integer C_S_AXI_ADDR_WIDTH       = 32,
  parameter integer C_S_AXI_DATA_WIDTH       = 32,
  parameter integer C_M_AXI_ADDR_WIDTH       = 32,
  parameter integer C_M_AXI_DATA_WIDTH       = 64,
  parameter integer C_AXIS_DATA_WIDTH        = 64,
  parameter integer C_AXIS_HOST_DATA_WIDTH   = 32,
  parameter integer C_AXIS_TDEST_WIDTH       = 2,
  parameter integer C_BASEADDR               = 32'h40000000,
  parameter integer C_HIGHADDR               = 32'h4001ffff,
  parameter         C_PROT                   = 3'b010,
  parameter         C_PAGEWIDTH              = 12,
  parameter integer C_H2S_STREAMS_WIDTH      = 2,
  parameter integer C_S2H_STREAMS_WIDTH      = 2)
(
  // Clock & Active High Reset
  input                             clk,
  input                             rst_n,
  // AXI Slave bus for access to control registers
  input  [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
  input                             S_AXI_AWVALID,
  output                            S_AXI_AWREADY,
  input  [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
  input  [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
  input                             S_AXI_WVALID,
  output                            S_AXI_WREADY,
  output [1:0]                      S_AXI_BRESP,
  output                            S_AXI_BVALID,
  input                             S_AXI_BREADY,
  input  [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
  input                             S_AXI_ARVALID,
  output                            S_AXI_ARREADY,
  output [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
  output [1:0]                      S_AXI_RRESP,
  output                            S_AXI_RVALID,
  input                             S_AXI_RREADY,
  // AXI ACP Bus to interface with processor system RAM / cache
  output [C_M_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
  output [2:0]                      M_AXI_AWPROT,
  output                            M_AXI_AWVALID,
  input                             M_AXI_AWREADY,
  output [C_M_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
  output [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
  output                            M_AXI_WVALID,
  input                             M_AXI_WREADY,
  input  [1:0]                      M_AXI_BRESP,
  input                             M_AXI_BVALID,
  output                            M_AXI_BREADY,
  output [7:0]                      M_AXI_AWLEN,
  output [2:0]                      M_AXI_AWSIZE,
  output [1:0]                      M_AXI_AWBURST,
  output [3:0]                      M_AXI_AWCACHE,
  output [4:0]                      M_AXI_AWUSER,
  output                            M_AXI_WLAST,
  output [C_M_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
  output [2:0]                      M_AXI_ARPROT,
  output                            M_AXI_ARVALID,
  input                             M_AXI_ARREADY,
  input [C_M_AXI_DATA_WIDTH-1:0]    M_AXI_RDATA,
  input [1:0]                       M_AXI_RRESP,
  input                             M_AXI_RVALID,
  output                            M_AXI_RREADY,
  input                             M_AXI_RLAST,
  output [3:0]                      M_AXI_ARCACHE,
  output [4:0]                      M_AXI_ARUSER,
  output [7:0]                      M_AXI_ARLEN,
  output [1:0]                      M_AXI_ARBURST,
  output [2:0]                      M_AXI_ARSIZE,
  // Interrupt on successfully completed AXI ACP writes
  output                            irq
);

  // Create active low reset
  wire rst = !rst_n;

  wire accelerator_irq;

  wire [C_S_AXI_ADDR_WIDTH-1:0] set_addr;
  wire [C_S_AXI_DATA_WIDTH-1:0] set_data;
  wire                          set_stb;

  wire [C_S_AXI_ADDR_WIDTH-1:0] get_addr;
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data;
  wire                          get_stb;

  /****************************************************************************
   * axi4_lite_slave
   *
   * Provides access to control registers by converting a AXI4 lite slave
   * interface into a generic address, data, & data valid strobe bus.
   ***************************************************************************/
  axi4_lite_slave #
  (.C_BASEADDR(C_BASEADDR),
   .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)
  )
  axi4_lite_slave
  (
    .S_AXI_ACLK(clk),
    .S_AXI_ARESETN(rst_n),
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),

    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),
    .S_AXI_BRESP(S_AXI_BRESP),
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),

    .set_addr(set_addr),
    .set_data(set_data),
    .set_stb(set_stb),

    .get_addr(get_addr),
    .get_data(get_data),
    .get_stb(get_stb)
  );

  // AXI stream data from AXI datamover i.e. Host to Slave
  wire [C_AXIS_DATA_WIDTH-1:0]         h2s_tdata;
  wire                                 h2s_tlast;
  wire                                 h2s_tvalid;
  wire                                 h2s_tready;
  wire [C_AXIS_TDEST_WIDTH-1:0]        h2s_tdest;
  // AXI stream command and status from AXI datamover i.e. Host to Slave
  wire [C_AXIS_HOST_DATA_WIDTH-1+40:0] h2s_cmd_tdata;
  wire [7:0]                           h2s_sts_tdata;
  wire                                 h2s_cmd_tvalid;
  wire                                 h2s_cmd_tready;
  wire                                 h2s_sts_tvalid;
  wire                                 h2s_sts_tready;
  // AXI stream to AXI datamover i.e. Slave to Host
  wire [C_AXIS_DATA_WIDTH-1:0]         s2h_tdata;
  wire                                 s2h_tlast;
  wire                                 s2h_tvalid;
  wire                                 s2h_tready;
  wire [C_AXIS_TDEST_WIDTH-1:0]        s2h_tdest;
  // AXI stream command and status to AXI datamover i.e. Slave to Host
  wire [C_AXIS_HOST_DATA_WIDTH-1+40:0] s2h_cmd_tdata;
  wire                                 s2h_cmd_tvalid;
  wire                                 s2h_cmd_tready;
  wire [7:0]                           s2h_sts_tdata;
  wire                                 s2h_sts_tvalid;
  wire                                 s2h_sts_tready;

  // There are three pages of control registers:
  // 1. Slave to host (s2h) i.e. PL to PS commands / control registers,
  // 2. Host to slave (s2h) i.e. PS to PL commands  / control registers,
  // 3. Global commands / control registers,
  // The upper 2 MSBs determine the page
  wire [1:0] set_page = set_addr[C_PAGEWIDTH+1:C_PAGEWIDTH];
  wire [1:0] get_page = get_addr[C_PAGEWIDTH+1:C_PAGEWIDTH];

  // Slave to host data valid strobe
  wire set_stb_s2h = set_stb && (set_page == 2'h1);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_s2h;

  // Host to slave data valid strobe
  wire set_stb_h2s = set_stb && (set_page == 2'h0);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_h2s;

  // Global data valid strobe
  wire set_stb_global = set_stb && (set_page == 2'h2);
  wire [C_S_AXI_DATA_WIDTH-1:0] get_data_global;

  // Mux data bus based on which control registers are
  // accessed.
  assign get_data = (get_page == 2'h0) ? get_data_h2s
                  : (get_page == 2'h1) ? get_data_s2h
                  : (get_page == 2'h2) ? get_data_global
                  : 32'hdeadbeef;

  wire soft_reset;
  wire soft_reset_n = !set_stb_global;

  /****************************************************************************
   * global_settings
   *
   * Implements global control registers for AXI ACP bus parameters and
   * soft reset
   ***************************************************************************/
  global_settings #
  (
    .C_DATAWIDTH(C_S_AXI_DATA_WIDTH),
    .C_ADDRWIDTH(C_S_AXI_ADDR_WIDTH),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  global_settings
  (
    .clk(clk),
    .rst(rst || soft_reset),
    .get_addr(get_addr),
    .get_data(get_data_global),
    .set_stb(set_stb_global),
    .set_addr(set_addr),
    .set_data(set_data),
    .arcache(M_AXI_ARCACHE),
    .aruser(M_AXI_ARUSER),
    .awcache(M_AXI_AWCACHE),
    .awuser(M_AXI_AWUSER),
    .soft_reset(soft_reset)
  );

  // The AXI ACP bus data is assigned to 1 of 4 streams based
  // the control register settings when performing read
  // and write commands. This checks each stream of available
  // data.
  reg [C_H2S_STREAMS_WIDTH-1:0] which_stream_h2s;
  always @(posedge clk)
    if (rst)
      which_stream_h2s <= 0;
    else
      which_stream_h2s <= which_stream_h2s + 1'b1;

  /****************************************************************************
   * s2h_master
   * axi4_stream_master
   *
   * Configures the Stream to Memory Mapped (s2mm) interface on the AXI
   * Datamover to issue write commands to memory. Controlled via the Slave to
   * Host control registers.
   ***************************************************************************/
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  s2h_master
  (
    .clk(clk),
    .rst(rst || soft_reset),

    .M_AXIS_CMD_TVALID(s2h_cmd_tvalid),
    .M_AXIS_CMD_TREADY(s2h_cmd_tready),
    .M_AXIS_CMD_TDATA(s2h_cmd_tdata),

    .S_AXIS_STS_TVALID(s2h_sts_tvalid),
    .S_AXIS_STS_TREADY(s2h_sts_tready),
    .S_AXIS_STS_TDATA(s2h_sts_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_s2h),

    .get_data(get_data_s2h),
    .get_addr(get_addr),

    .stream_select(s2h_tdest),
    .stream_valid(1'b1)
  );

  // Destination signals which will mux the AXI Datamover output to the
  // stream set in control registers.
  wire                          h2s_dest_tvalid;
  wire                          h2s_dest_tready;
  wire [C_AXIS_TDEST_WIDTH-1:0] h2s_dest_tdata;

  /****************************************************************************
   * h2s_master
   * axi4_stream_master
   *
   * Configures the Memory Mapped to Stream (mm2s) interface on the AXI
   * Datamover to issue read commands from memory. Controlled via the Slave to
   * Host control registers.
   ***************************************************************************/
  axi4_stream_master #
  ( .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_M_AXIS_CMD_DATA_WIDTH(72),
    .C_M_AXIS_STS_DATA_WIDTH(8),
    .C_PAGEWIDTH(C_PAGEWIDTH)
  )
  h2s_master
  (
    .clk(clk),
    .rst(rst || soft_reset),

    .M_AXIS_CMD_TVALID(h2s_cmd_tvalid),
    .M_AXIS_CMD_TREADY(h2s_cmd_tready),
    .M_AXIS_CMD_TDATA(h2s_cmd_tdata),

    .S_AXIS_STS_TVALID(h2s_sts_tvalid),
    .S_AXIS_STS_TREADY(h2s_sts_tready),
    .S_AXIS_STS_TDATA(h2s_sts_tdata),

    .M_AXIS_DEST_TVALID(h2s_dest_tvalid),
    .M_AXIS_DEST_TREADY(h2s_dest_tready),
    .M_AXIS_DEST_TDATA(h2s_dest_tdata),

    .set_data(set_data),
    .set_addr(set_addr),
    .set_stb(set_stb_h2s),

    .get_data(get_data_h2s),
    .get_addr(get_addr),

    .stream_select(which_stream_h2s),
    .stream_valid(1'b1)
  );

  // AXI stream to FIFO
  wire [C_AXIS_DATA_WIDTH-1:0]  h2s_tdata_fifo;
  wire                          h2s_tlast_fifo;
  wire                          h2s_tvalid_fifo;
  wire                          h2s_tready_fifo;
  wire [C_AXIS_TDEST_WIDTH-1:0] h2s_tdest_fifo;
  // AXI stream to stream mux
  wire [C_AXIS_DATA_WIDTH-1:0]  h2s_tdata_demux;
  wire                          h2s_tlast_demux;
  wire                          h2s_tvalid_demux;
  wire                          h2s_tready_demux;
  wire [C_AXIS_TDEST_WIDTH-1:0] h2s_tdest_demux;
  // Keep these signals incase in the future we need to
  // see if the FIFO is overflowing
  (* KEEP = "TRUE" *) wire h2s_fifo_overflow;
  (* KEEP = "TRUE" *) wire h2s_fifo_underflow;

  /****************************************************************************
   * axi4_stream_dest_generator
   *
   * Generates the TDEST signal needed to mux the AXI4 Streams from the
   * AXI Datamover into multiple streams.
   ***************************************************************************/
  axi4_stream_dest_generator axi4_stream_dest_generator
  (
    .clk(clk),
    .rst(rst || soft_reset),
    .S_AXIS_DEST_TVALID(h2s_dest_tvalid),
    .S_AXIS_DEST_TREADY(h2s_dest_tready),
    .S_AXIS_DEST_TDATA(h2s_dest_tdata),

    .S_AXIS_TVALID(h2s_tvalid),
    .S_AXIS_TREADY(h2s_tready),
    .S_AXIS_TDATA(h2s_tdata),
    .S_AXIS_TLAST(h2s_tlast),

    .M_AXIS_TVALID(h2s_tvalid_fifo),
    .M_AXIS_TREADY(h2s_tready_fifo),
    .M_AXIS_TDATA(h2s_tdata_fifo),
    .M_AXIS_TLAST(h2s_tlast_fifo),
    .M_AXIS_TDEST(h2s_tdest_fifo)
  );

  /****************************************************************************
   * xlnx_axi_fifo
   *
   * Xilinx IP for a 4K deep AXI4 Stream FIFO. The purpose of this FIFO is to
   * compenstate for the asymmetric AXI ACP bus read / write speed. Without
   * the FIFO the AXI Datamover can drop write data due to a faster read
   * interface.
   ***************************************************************************/
  xlnx_axi_fifo xlnx_axi_fifo_demux
  (
    .s_aclk(clk),
    .s_aresetn(rst_n && soft_reset_n),
    .s_axis_tvalid(h2s_tvalid_fifo),
    .s_axis_tready(h2s_tready_fifo),
    .s_axis_tdata(h2s_tdata_fifo),
    .s_axis_tlast(h2s_tlast_fifo),
    .s_axis_tdest(h2s_tdest_fifo),
    .m_axis_tvalid(h2s_tvalid_demux),
    .m_axis_tready(h2s_tready_demux),
    .m_axis_tdata(h2s_tdata_demux),
    .m_axis_tlast(h2s_tlast_demux),
    .m_axis_tdest(h2s_tdest_demux),
    .axis_data_count(),
    .axis_overflow(h2s_fifo_overflow),
    .axis_underflow(h2s_fifo_underflow)
  );

  // Interconnect
  // Stream 0
  wire [C_AXIS_DATA_WIDTH-1:0]  stream0_master_tdata;
  wire                          stream0_master_tvalid;
  wire                          stream0_master_tready;
  wire                          stream0_master_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream0_master_tdest;
  wire [C_AXIS_DATA_WIDTH-1:0]  stream0_slave_tdata;
  wire                          stream0_slave_tvalid;
  wire                          stream0_slave_tready;
  wire                          stream0_slave_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream0_slave_tdest;
  // Stream 1
  wire [C_AXIS_DATA_WIDTH-1:0]  stream1_master_tdata;
  wire                          stream1_master_tvalid;
  wire                          stream1_master_tready;
  wire                          stream1_master_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream1_master_tdest;
  wire [C_AXIS_DATA_WIDTH-1:0]  stream1_slave_tdata;
  wire                          stream1_slave_tvalid;
  wire                          stream1_slave_tready;
  wire                          stream1_slave_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream1_slave_tdest;
  // Stream 2
  wire [C_AXIS_DATA_WIDTH-1:0]  stream2_master_tdata;
  wire                          stream2_master_tvalid;
  wire                          stream2_master_tready;
  wire                          stream2_master_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream2_master_tdest;
  wire [C_AXIS_DATA_WIDTH-1:0]  stream2_slave_tdata;
  wire                          stream2_slave_tvalid;
  wire                          stream2_slave_tready;
  wire                          stream2_slave_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream2_slave_tdest;
  // Stream 3
  wire [C_AXIS_DATA_WIDTH-1:0]  stream3_master_tdata;
  wire                          stream3_master_tvalid;
  wire                          stream3_master_tready;
  wire                          stream3_master_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream3_master_tdest;
  wire [C_AXIS_DATA_WIDTH-1:0]  stream3_slave_tdata;
  wire                          stream3_slave_tvalid;
  wire                          stream3_slave_tready;
  wire                          stream3_slave_tlast;
  wire [C_AXIS_TDEST_WIDTH-1:0] stream3_slave_tdest;

  /****************************************************************************
   * xlnx_axis_demux
   *
   * Xilinx IP to demux a AXI4 Stream into several streams. In this case,
   * the AXI4 Stream originates from the AXI Datamover.
   ***************************************************************************/
  xlnx_axis_demux xlnx_axis_demux
  (
    .ACLK(clk),
    .ARESETN(rst_n && soft_reset_n),
    .S00_AXIS_ACLK(clk),
    .S00_AXIS_ARESETN(rst_n && soft_reset_n),
    .S00_AXIS_TVALID(h2s_tvalid_demux),
    .S00_AXIS_TREADY(h2s_tready_demux),
    .S00_AXIS_TDATA(h2s_tdata_demux),
    .S00_AXIS_TLAST(h2s_tlast_demux),
    .S00_AXIS_TDEST(h2s_tdest_demux),

    .M00_AXIS_ACLK(clk),
    .M01_AXIS_ACLK(clk),
    .M02_AXIS_ACLK(clk),
    .M03_AXIS_ACLK(clk),
    .M00_AXIS_ARESETN(rst_n && soft_reset_n),
    .M01_AXIS_ARESETN(rst_n && soft_reset_n),
    .M02_AXIS_ARESETN(rst_n && soft_reset_n),
    .M03_AXIS_ARESETN(rst_n && soft_reset_n),

    .M00_AXIS_TVALID(stream0_master_tvalid),
    .M01_AXIS_TVALID(stream1_master_tvalid),
    .M02_AXIS_TVALID(stream2_master_tvalid),
    .M03_AXIS_TVALID(stream3_master_tvalid),
    .M00_AXIS_TREADY(stream0_master_tready),
    .M01_AXIS_TREADY(stream1_master_tready),
    .M02_AXIS_TREADY(stream2_master_tready),
    .M03_AXIS_TREADY(stream3_master_tready),
    .M00_AXIS_TDATA(stream0_master_tdata),
    .M01_AXIS_TDATA(stream1_master_tdata),
    .M02_AXIS_TDATA(stream2_master_tdata),
    .M03_AXIS_TDATA(stream3_master_tdata),
    .M00_AXIS_TLAST(stream0_master_tlast),
    .M01_AXIS_TLAST(stream1_master_tlast),
    .M02_AXIS_TLAST(stream2_master_tlast),
    .M03_AXIS_TLAST(stream3_master_tlast),
    .M00_AXIS_TDEST(stream0_master_tdest),
    .M01_AXIS_TDEST(stream1_master_tdest),
    .M02_AXIS_TDEST(stream2_master_tdest),
    .M03_AXIS_TDEST(stream3_master_tdest),
    .S00_DECODE_ERR()
  );

  // Slave & Master TDEST signals are the same
  assign stream0_slave_tdest = stream0_master_tdest; // 2'b00;
  assign stream1_slave_tdest = stream1_master_tdest; // 2'b01;
  assign stream2_slave_tdest = stream2_master_tdest; // 2'b10;
  assign stream3_slave_tdest = stream3_master_tdest; // 2'b11;

  /****************************************************************************
   * xlnx_axis_mux
   *
   * Xilinx IP to mux a several AXI4 Streams into a single streams. In this case,
   * the AXI4 Streams originate from the accelerator(s).
   ***************************************************************************/
  xlnx_axis_mux xlnx_axis_mux
  (
    .ACLK(clk),
    .ARESETN(rst_n && soft_reset_n),
    .S00_AXIS_ACLK(clk),
    .S01_AXIS_ACLK(clk),
    .S02_AXIS_ACLK(clk),
    .S03_AXIS_ACLK(clk),
    .S00_AXIS_ARESETN(rst_n && soft_reset_n),
    .S01_AXIS_ARESETN(rst_n && soft_reset_n),
    .S02_AXIS_ARESETN(rst_n && soft_reset_n),
    .S03_AXIS_ARESETN(rst_n && soft_reset_n),
    .S00_AXIS_TVALID(stream0_slave_tvalid),
    .S01_AXIS_TVALID(stream1_slave_tvalid),
    .S02_AXIS_TVALID(stream2_slave_tvalid),
    .S03_AXIS_TVALID(stream3_slave_tvalid),
    .S00_AXIS_TREADY(stream0_slave_tready),
    .S01_AXIS_TREADY(stream1_slave_tready),
    .S02_AXIS_TREADY(stream2_slave_tready),
    .S03_AXIS_TREADY(stream3_slave_tready),
    .S00_AXIS_TDATA(stream0_slave_tdata),
    .S01_AXIS_TDATA(stream1_slave_tdata),
    .S02_AXIS_TDATA(stream2_slave_tdata),
    .S03_AXIS_TDATA(stream3_slave_tdata),
    .S00_AXIS_TLAST(stream0_slave_tlast),
    .S01_AXIS_TLAST(stream1_slave_tlast),
    .S02_AXIS_TLAST(stream2_slave_tlast),
    .S03_AXIS_TLAST(stream3_slave_tlast),
    .S00_AXIS_TDEST(stream0_slave_tdest),
    .S01_AXIS_TDEST(stream1_slave_tdest),
    .S02_AXIS_TDEST(stream2_slave_tdest),
    .S03_AXIS_TDEST(stream3_slave_tdest),
    .M00_AXIS_ACLK(clk),
    .M00_AXIS_ARESETN(rst_n && soft_reset_n),
    .M00_AXIS_TVALID(s2h_tvalid),
    .M00_AXIS_TREADY(s2h_tready),
    .M00_AXIS_TDATA(s2h_tdata),
    .M00_AXIS_TLAST(s2h_tlast),
    .M00_AXIS_TDEST(s2h_tdest),
    .S00_ARB_REQ_SUPPRESS(1'h0),
    .S01_ARB_REQ_SUPPRESS(1'h0),
    .S02_ARB_REQ_SUPPRESS(1'h0),
    .S03_ARB_REQ_SUPPRESS(1'h0),
    .S00_DECODE_ERR(),
    .S01_DECODE_ERR(),
    .S02_DECODE_ERR(),
    .S03_DECODE_ERR()
  );

  /****************************************************************************
   * xlnx_axi_datamover
   *
   * Xilinx IP that converts the AXI ACP bus to the simpler AXI 4 Stream
   * and facilitates memory reads / writes.
   ***************************************************************************/
  xlnx_axi_datamover xlnx_axi_datamover
  (
    /* Memory Mapped to Stream interface */
    .m_axi_mm2s_aclk(clk),
    .m_axi_mm2s_aresetn(rst_n && soft_reset_n),
    .mm2s_halt(1'b0),
    .mm2s_halt_cmplt(),
    .mm2s_err(),
    // Read from memory command interface
    .m_axis_mm2s_cmdsts_aclk(clk),
    .m_axis_mm2s_cmdsts_aresetn(rst_n && soft_reset_n),
    .s_axis_mm2s_cmd_tvalid(h2s_cmd_tvalid),
    .s_axis_mm2s_cmd_tready(h2s_cmd_tready),
    .s_axis_mm2s_cmd_tdata(h2s_cmd_tdata),
    // Status of memory read commands
    .m_axis_mm2s_sts_tvalid(h2s_sts_tvalid),
    .m_axis_mm2s_sts_tready(h2s_sts_tready),
    .m_axis_mm2s_sts_tdata(h2s_sts_tdata),
    //.m_axis_mm2s_sts_tkeep(),
    .m_axis_mm2s_sts_tlast(),
    .mm2s_allow_addr_req(1'b1),
    .mm2s_addr_req_posted(),
    .mm2s_rd_xfer_cmplt(),
    // AXI AXP interface (Read bus)
    .m_axi_mm2s_arid(),
    .m_axi_mm2s_araddr(M_AXI_ARADDR),
    .m_axi_mm2s_arlen(M_AXI_ARLEN),
    .m_axi_mm2s_arsize(M_AXI_ARSIZE),
    .m_axi_mm2s_arburst(M_AXI_ARBURST),
    .m_axi_mm2s_arprot(M_AXI_ARPROT),
    //.m_axi_mm2s_arcache(M_AXI_ARCACHE),
    .m_axi_mm2s_arvalid(M_AXI_ARVALID),
    .m_axi_mm2s_arready(M_AXI_ARREADY),
    .m_axi_mm2s_rdata(M_AXI_RDATA),
    .m_axi_mm2s_rresp(M_AXI_RRESP),
    .m_axi_mm2s_rlast(M_AXI_RLAST),
    .m_axi_mm2s_rvalid(M_AXI_RVALID),
    .m_axi_mm2s_rready(M_AXI_RREADY),
    // Read data from memory / RAM
    .m_axis_mm2s_tdata(h2s_tdata),
    .m_axis_mm2s_tkeep(),
    .m_axis_mm2s_tlast(h2s_tlast),
    .m_axis_mm2s_tvalid(h2s_tvalid),
    .m_axis_mm2s_tready(h2s_tready),
    // Debug
    .mm2s_dbg_sel(4'b0),
    .mm2s_dbg_data(),
    /* Stream to Memory Mapped interface */
    .m_axi_s2mm_aclk(clk),
    .m_axi_s2mm_aresetn(rst_n && soft_reset_n),
    .s2mm_halt(1'b0),
    .s2mm_halt_cmplt(),
    .s2mm_err(),
    // Write to memory command interface
    .m_axis_s2mm_cmdsts_awclk(clk),
    .m_axis_s2mm_cmdsts_aresetn(rst_n && soft_reset_n),
    .s_axis_s2mm_cmd_tvalid(s2h_cmd_tvalid),
    .s_axis_s2mm_cmd_tready(s2h_cmd_tready),
    .s_axis_s2mm_cmd_tdata(s2h_cmd_tdata),
    // Status of memory write commands
    .m_axis_s2mm_sts_tvalid(s2h_sts_tvalid),
    .m_axis_s2mm_sts_tready(s2h_sts_tready),
    .m_axis_s2mm_sts_tdata(s2h_sts_tdata),
    .m_axis_s2mm_sts_tkeep(),
    .m_axis_s2mm_sts_tlast(),
    .s2mm_allow_addr_req(1'b1),
    .s2mm_addr_req_posted(),
    .s2mm_wr_xfer_cmplt(),
    .s2mm_ld_nxt_len(),
    .s2mm_wr_len(),
    // AXI AXP interface (Write bus)
    .m_axi_s2mm_awid(),
    .m_axi_s2mm_awaddr(M_AXI_AWADDR),
    .m_axi_s2mm_awlen(M_AXI_AWLEN),
    .m_axi_s2mm_awsize(M_AXI_AWSIZE),
    .m_axi_s2mm_awburst(M_AXI_AWBURST),
    .m_axi_s2mm_awprot(M_AXI_AWPROT),
    //.m_axi_s2mm_awcache(M_AXI_AWCACHE),
    .m_axi_s2mm_awvalid(M_AXI_AWVALID),
    .m_axi_s2mm_awready(M_AXI_AWREADY),
    .m_axi_s2mm_wdata(M_AXI_WDATA),
    .m_axi_s2mm_wstrb(M_AXI_WSTRB),
    .m_axi_s2mm_wlast(M_AXI_WLAST),
    .m_axi_s2mm_wvalid(M_AXI_WVALID),
    .m_axi_s2mm_wready(M_AXI_WREADY),
    .m_axi_s2mm_bresp(M_AXI_BRESP),
    .m_axi_s2mm_bvalid(M_AXI_BVALID),
    .m_axi_s2mm_bready(M_AXI_BREADY),
    // Write data to memory / RAM
    .s_axis_s2mm_tdata(s2h_tdata),
    .s_axis_s2mm_tkeep(8'hff), // keep all bytes
    .s_axis_s2mm_tlast(s2h_tlast),
    .s_axis_s2mm_tvalid(s2h_tvalid),
    .s_axis_s2mm_tready(s2h_tready),
    // Debug
    .s2mm_dbg_sel(4'b0),
    .s2mm_dbg_data()
  );

  // Stretch interrupts to several clock cycles.
  // The General Interrupt Controller in the Processor System sporatically misses
  // single clock cycle pulses, most likely due to the GIC using a different clock
  // than the one forwarded to the FPGA fabric. Documentation could not be found
  // on this issue, but stretching the interrupt pulse across 16 clock cycles
  // solved the problem.
  reg         long_irq;
  reg [3:0]   irq_counter;
  always @(posedge clk) begin
    if (!soft_reset_n && !rst_n) begin
      long_irq        <= 1'b0;
      irq_counter     <= 4'h0;
    end
    else begin
      // Detect interrupt and set interrupt counter
      if (s2h_sts_tvalid || accelerator_irq) begin
        irq_counter   <= 4'hF;
      end
      if (irq_counter != 4'h0) begin
        irq_counter   <= irq_counter - 1'b1;
        long_irq      <= 1'b1;
      end
      else begin
        long_irq      <= 1'b0;
      end
    end
  end

  assign irq = long_irq;

  /****************************************************************************
   * accelerator
   *
   * Custom logic added to this module by user for FPGA acceleration
   ***************************************************************************/
  accelerator accelerator
  (
    .clk(clk),
    .rst_n(rst_n && soft_reset_n),
    .stream0_master_tvalid(stream0_master_tvalid),
    .stream0_master_tready(stream0_master_tready),
    .stream0_master_tdata(stream0_master_tdata),
    .stream0_master_tlast(stream0_master_tlast),
    .stream0_slave_tvalid(stream0_slave_tvalid),
    .stream0_slave_tready(stream0_slave_tready),
    .stream0_slave_tdata(stream0_slave_tdata),
    .stream0_slave_tlast(stream0_slave_tlast),
    .stream1_master_tvalid(stream1_master_tvalid),
    .stream1_master_tready(stream1_master_tready),
    .stream1_master_tdata(stream1_master_tdata),
    .stream1_master_tlast(stream1_master_tlast),
    .stream1_slave_tvalid(stream1_slave_tvalid),
    .stream1_slave_tready(stream1_slave_tready),
    .stream1_slave_tdata(stream1_slave_tdata),
    .stream1_slave_tlast(stream1_slave_tlast),
    .stream2_master_tvalid(stream2_master_tvalid),
    .stream2_master_tready(stream2_master_tready),
    .stream2_master_tdata(stream2_master_tdata),
    .stream2_master_tlast(stream2_master_tlast),
    .stream2_slave_tvalid(stream2_slave_tvalid),
    .stream2_slave_tready(stream2_slave_tready),
    .stream2_slave_tdata(stream2_slave_tdata),
    .stream2_slave_tlast(stream2_slave_tlast),
    .stream3_master_tvalid(stream3_master_tvalid),
    .stream3_master_tready(stream3_master_tready),
    .stream3_master_tdata(stream3_master_tdata),
    .stream3_master_tlast(stream3_master_tlast),
    .stream3_slave_tvalid(stream3_slave_tvalid),
    .stream3_slave_tready(stream3_slave_tready),
    .stream3_slave_tdata(stream3_slave_tdata),
    .stream3_slave_tlast(stream3_slave_tlast),
    .irq(accelerator_irq)
  );

endmodule
