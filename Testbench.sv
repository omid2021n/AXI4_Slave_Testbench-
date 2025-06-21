`timescale 1ns/1ps

module tb_axi_slave;

    reg ACLK = 0;
    reg ARESETn = 0;

    reg [31:0] AWADDR;
    reg        AWVALID;
    wire       AWREADY;

    reg        WVALID;
    reg [31:0] WDATA;
    wire       WREADY;

    wire       BVALID;
    reg        BREADY;

    reg [31:0] ARADDR;
    reg        ARVALID;
    wire       ARREADY;

    wire [31:0] RDATA;
    wire        RVALID;
    reg         RREADY;

    // Instantiate the axi_slave
    axi_slave dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .WVALID(WVALID),
        .WDATA(WDATA),
        .WREADY(WREADY),
        .BVALID(BVALID),
        .BREADY(BREADY),
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

    // Clock generation: 10ns period
    always #5 ACLK = ~ACLK;

    initial begin
        // Initialize inputs
        ARESETn = 0;
        AWADDR = 0;
        AWVALID = 0;
        WVALID = 0;
        WDATA = 0;
        BREADY = 0;
        ARADDR = 0;
        ARVALID = 0;
        RREADY = 0;

        // Release reset after some time
        #20;
        ARESETn = 1;

        // Write transaction
        @(posedge ACLK);
        AWADDR = 32'h0000_0000;
        AWVALID = 1;
        WDATA = 32'h1234_5678;
        WVALID = 1;

        // Wait for AWREADY and WREADY
        wait (AWREADY);
        wait (WREADY);
        @(posedge ACLK);

        AWVALID = 0;
        WVALID = 0;
        BREADY = 1;  

        // Wait for BVALID
      wait (BVALID);   ////"Thanks, write done!"
        @(posedge ACLK);
        BREADY = 0;

        // Read transaction
        @(posedge ACLK);
        ARADDR = 32'h0000_0000;
        ARVALID = 1;
        RREADY = 1;

      wait (ARREADY);//Slave says "I’m ready for read address" by setting ARREADY.
      
      @(posedge ACLK);

        ARVALID = 0;

        // Wait for RVALID
        wait (RVALID);
      $display("============================================================");
      $display("Read Data: %h",                                        RDATA);
      $display("============================================================");

        @(posedge ACLK);

        RREADY = 0;

        #20;
        $finish;
    end

endmodule
