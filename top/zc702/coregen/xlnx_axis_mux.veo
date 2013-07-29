/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used solely      *
*     for design, simulation, implementation and creation of design files      *
*     limited to Xilinx devices or technologies. Use with non-Xilinx           *
*     devices or technologies is expressly prohibited and immediately          *
*     terminates your license.                                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" SOLELY     *
*     FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY     *
*     PROVIDING THIS DESIGN, CODE, OR INFORMATION AS ONE POSSIBLE              *
*     IMPLEMENTATION OF THIS FEATURE, APPLICATION OR STANDARD, XILINX IS       *
*     MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION IS FREE FROM ANY       *
*     CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE FOR OBTAINING ANY        *
*     RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY        *
*     DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE    *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A    *
*     PARTICULAR PURPOSE.                                                      *
*                                                                              *
*     Xilinx products are not intended for use in life support appliances,     *
*     devices, or systems.  Use in such applications are expressly             *
*     prohibited.                                                              *
*                                                                              *
*     (c) Copyright 1995-2013 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/

/*******************************************************************************
*     Generated from core with identifier:                                     *
*     xilinx.com:ip:axis_interconnect:1.1                                      *
*                                                                              *
*     The AXI4-Stream Interconnect IP provides the infrastructure to           *
*     connect multiple AXI4-Stream masters and slaves.  The configurable       *
*     interconnect features a 16x16 switch, data FIFOs, register slices,       *
*     data width converters and clock rate converters.                         *
*******************************************************************************/

// Interfaces:
//    S00_AXIS
//    S01_AXIS
//    S02_AXIS
//    S03_AXIS
//    S04_AXIS
//    S05_AXIS
//    S06_AXIS
//    S07_AXIS
//    S08_AXIS
//    S09_AXIS
//    S10_AXIS
//    S11_AXIS
//    S12_AXIS
//    S13_AXIS
//    S14_AXIS
//    S15_AXIS
//    M00_AXIS
//    M01_AXIS
//    M02_AXIS
//    M03_AXIS
//    M04_AXIS
//    M05_AXIS
//    M06_AXIS
//    M07_AXIS
//    M08_AXIS
//    M09_AXIS
//    M10_AXIS
//    M11_AXIS
//    M12_AXIS
//    M13_AXIS
//    M14_AXIS
//    M15_AXIS
//    RSTIF
//    CLKIF
//    CLKENIF
//    S00_RSTIF
//    S00_CLKIF
//    S00_CLKENIF
//    M00_RSTIF
//    M00_CLKIF
//    M00_CLKENIF
//    S01_RSTIF
//    S01_CLKIF
//    S01_CLKENIF
//    M01_RSTIF
//    M01_CLKIF
//    M01_CLKENIF
//    S02_RSTIF
//    S02_CLKIF
//    S02_CLKENIF
//    M02_RSTIF
//    M02_CLKIF
//    M02_CLKENIF
//    S03_RSTIF
//    S03_CLKIF
//    S03_CLKENIF
//    M03_RSTIF
//    M03_CLKIF
//    M03_CLKENIF
//    S04_RSTIF
//    S04_CLKIF
//    S04_CLKENIF
//    M04_RSTIF
//    M04_CLKIF
//    M04_CLKENIF
//    S05_RSTIF
//    S05_CLKIF
//    S05_CLKENIF
//    M05_RSTIF
//    M05_CLKIF
//    M05_CLKENIF
//    S06_RSTIF
//    S06_CLKIF
//    S06_CLKENIF
//    M06_RSTIF
//    M06_CLKIF
//    M06_CLKENIF
//    S07_RSTIF
//    S07_CLKIF
//    S07_CLKENIF
//    M07_RSTIF
//    M07_CLKIF
//    M07_CLKENIF
//    S08_RSTIF
//    S08_CLKIF
//    S08_CLKENIF
//    M08_RSTIF
//    M08_CLKIF
//    M08_CLKENIF
//    S09_RSTIF
//    S09_CLKIF
//    S09_CLKENIF
//    M09_RSTIF
//    M09_CLKIF
//    M09_CLKENIF
//    S10_RSTIF
//    S10_CLKIF
//    S10_CLKENIF
//    M10_RSTIF
//    M10_CLKIF
//    M10_CLKENIF
//    S11_RSTIF
//    S11_CLKIF
//    S11_CLKENIF
//    M11_RSTIF
//    M11_CLKIF
//    M11_CLKENIF
//    S12_RSTIF
//    S12_CLKIF
//    S12_CLKENIF
//    M12_RSTIF
//    M12_CLKIF
//    M12_CLKENIF
//    S13_RSTIF
//    S13_CLKIF
//    S13_CLKENIF
//    M13_RSTIF
//    M13_CLKIF
//    M13_CLKENIF
//    S14_RSTIF
//    S14_CLKIF
//    S14_CLKENIF
//    M14_RSTIF
//    M14_CLKIF
//    M14_CLKENIF
//    S15_RSTIF
//    S15_CLKIF
//    S15_CLKENIF
//    M15_RSTIF
//    M15_CLKIF
//    M15_CLKENIF

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
xlnx_axis_mux your_instance_name (
  .ACLK(ACLK), // input ACLK
  .ARESETN(ARESETN), // input ARESETN
  .S00_AXIS_ACLK(S00_AXIS_ACLK), // input S00_AXIS_ACLK
  .S01_AXIS_ACLK(S01_AXIS_ACLK), // input S01_AXIS_ACLK
  .S02_AXIS_ACLK(S02_AXIS_ACLK), // input S02_AXIS_ACLK
  .S03_AXIS_ACLK(S03_AXIS_ACLK), // input S03_AXIS_ACLK
  .S00_AXIS_ARESETN(S00_AXIS_ARESETN), // input S00_AXIS_ARESETN
  .S01_AXIS_ARESETN(S01_AXIS_ARESETN), // input S01_AXIS_ARESETN
  .S02_AXIS_ARESETN(S02_AXIS_ARESETN), // input S02_AXIS_ARESETN
  .S03_AXIS_ARESETN(S03_AXIS_ARESETN), // input S03_AXIS_ARESETN
  .S00_AXIS_TVALID(S00_AXIS_TVALID), // input S00_AXIS_TVALID
  .S01_AXIS_TVALID(S01_AXIS_TVALID), // input S01_AXIS_TVALID
  .S02_AXIS_TVALID(S02_AXIS_TVALID), // input S02_AXIS_TVALID
  .S03_AXIS_TVALID(S03_AXIS_TVALID), // input S03_AXIS_TVALID
  .S00_AXIS_TREADY(S00_AXIS_TREADY), // output S00_AXIS_TREADY
  .S01_AXIS_TREADY(S01_AXIS_TREADY), // output S01_AXIS_TREADY
  .S02_AXIS_TREADY(S02_AXIS_TREADY), // output S02_AXIS_TREADY
  .S03_AXIS_TREADY(S03_AXIS_TREADY), // output S03_AXIS_TREADY
  .S00_AXIS_TDATA(S00_AXIS_TDATA), // input [63 : 0] S00_AXIS_TDATA
  .S01_AXIS_TDATA(S01_AXIS_TDATA), // input [63 : 0] S01_AXIS_TDATA
  .S02_AXIS_TDATA(S02_AXIS_TDATA), // input [63 : 0] S02_AXIS_TDATA
  .S03_AXIS_TDATA(S03_AXIS_TDATA), // input [63 : 0] S03_AXIS_TDATA
  .S00_AXIS_TLAST(S00_AXIS_TLAST), // input S00_AXIS_TLAST
  .S01_AXIS_TLAST(S01_AXIS_TLAST), // input S01_AXIS_TLAST
  .S02_AXIS_TLAST(S02_AXIS_TLAST), // input S02_AXIS_TLAST
  .S03_AXIS_TLAST(S03_AXIS_TLAST), // input S03_AXIS_TLAST
  .S00_AXIS_TDEST(S00_AXIS_TDEST), // input [1 : 0] S00_AXIS_TDEST
  .S01_AXIS_TDEST(S01_AXIS_TDEST), // input [1 : 0] S01_AXIS_TDEST
  .S02_AXIS_TDEST(S02_AXIS_TDEST), // input [1 : 0] S02_AXIS_TDEST
  .S03_AXIS_TDEST(S03_AXIS_TDEST), // input [1 : 0] S03_AXIS_TDEST
  .M00_AXIS_ACLK(M00_AXIS_ACLK), // input M00_AXIS_ACLK
  .M00_AXIS_ARESETN(M00_AXIS_ARESETN), // input M00_AXIS_ARESETN
  .M00_AXIS_TVALID(M00_AXIS_TVALID), // output M00_AXIS_TVALID
  .M00_AXIS_TREADY(M00_AXIS_TREADY), // input M00_AXIS_TREADY
  .M00_AXIS_TDATA(M00_AXIS_TDATA), // output [63 : 0] M00_AXIS_TDATA
  .M00_AXIS_TLAST(M00_AXIS_TLAST), // output M00_AXIS_TLAST
  .M00_AXIS_TDEST(M00_AXIS_TDEST), // output [1 : 0] M00_AXIS_TDEST
  .S00_ARB_REQ_SUPPRESS(S00_ARB_REQ_SUPPRESS), // input S00_ARB_REQ_SUPPRESS
  .S01_ARB_REQ_SUPPRESS(S01_ARB_REQ_SUPPRESS), // input S01_ARB_REQ_SUPPRESS
  .S02_ARB_REQ_SUPPRESS(S02_ARB_REQ_SUPPRESS), // input S02_ARB_REQ_SUPPRESS
  .S03_ARB_REQ_SUPPRESS(S03_ARB_REQ_SUPPRESS), // input S03_ARB_REQ_SUPPRESS
  .S00_DECODE_ERR(S00_DECODE_ERR), // output S00_DECODE_ERR
  .S01_DECODE_ERR(S01_DECODE_ERR), // output S01_DECODE_ERR
  .S02_DECODE_ERR(S02_DECODE_ERR), // output S02_DECODE_ERR
  .S03_DECODE_ERR(S03_DECODE_ERR) // output S03_DECODE_ERR
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file xlnx_axis_mux.v when simulating
// the core, xlnx_axis_mux. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

