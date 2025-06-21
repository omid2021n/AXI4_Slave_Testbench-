module axi_slave (
    input wire        ACLK,
    input wire        ARESETn,
   
    input wire [31:0] AWADDR,
    input wire        AWVALID,
    output wire       AWREADY,
    
    input wire [31:0] WDATA,
    input wire        WVALID,
    output wire       WREADY,
  
    output wire       BVALID,
    input wire        BREADY,
  
    input wire [31:0] ARADDR,
    input wire        ARVALID,
    output wire       ARREADY,//"I’m ready for read address" 
    output wire [31:0] RDATA,
    output wire       RVALID,
    input wire        RREADY
);

    // Simple internal register to store write data
    reg [31:0] mem;

    // Write address handshake
    reg awready_reg = 0;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            awready_reg <= 0;
      else if (AWVALID && !awready_reg)//When master sends a write address (AWVALID=1), 
            awready_reg <= 1;
        else
            awready_reg <= 0;
    end
    assign AWREADY = awready_reg;//the slave must reply with AWREADY=1 to say "I’m ready to accept it."

    // Write data handshake
    reg wready_reg = 0;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            wready_reg <= 0;
        else if (WVALID && !wready_reg)
            wready_reg <= 1;
        else
            wready_reg <= 0;
    end
    assign WREADY = wready_reg;// slave responds to write data with WREADY=1

    // Write response logic
    reg bvalid_reg = 0;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            bvalid_reg <= 0;
        else if (awready_reg && AWVALID && wready_reg && WVALID)
            bvalid_reg <= 1;
        else if (BREADY && bvalid_reg)
            bvalid_reg <= 0;
    end
    assign BVALID = bvalid_reg;//"Thanks, write done!"

    // Store write data on write
    always @(posedge ACLK) begin
        if (awready_reg && AWVALID && wready_reg && WVALID)
            mem <= WDATA;//"Thanks, write done!"
    end

    // Read address handshake
    reg arready_reg = 0;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            arready_reg <= 0;
        else if (ARVALID && !arready_reg)
            arready_reg <= 1;
        else
            arready_reg <= 0;
    end
    assign ARREADY = arready_reg;//Slave says "I’m ready for read address" by setting ARREADY.

    // Read data and valid
    reg rvalid_reg = 0;
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn)
            rvalid_reg <= 0;
        else if (arready_reg && ARVALID)
            rvalid_reg <= 1;
        else if (RREADY && rvalid_reg)
            rvalid_reg <= 0;
    end
    assign RVALID = rvalid_reg;
    assign RDATA = mem;

endmodule
