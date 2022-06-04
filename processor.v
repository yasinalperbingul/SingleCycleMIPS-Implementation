module processor;
reg [31:0] prev_sum;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:127]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0]
dataa,		//Read data 1 output of Register File
datab,		//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad;	//Output of shift left 2 unit

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0]
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1;		//Write data input of Register File

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

//****************************************************
wire[31:0]
out5,		// Input of Reg[Write data]
out6,
out_pc,
jspal_res3;

wire n, z, v, enable, select, jspal_signal, jmor_signal, jalm_signal;

wire [25:0] inst25_0;
wire [5:0] inst5_0;
wire [4:0] jspal_res1, jspal_res2, jmor_res, jalm_res;

//Status signals
wire status0,status1,status2,status_select;

//*****************************************************

// datamemory connections
always @(posedge clk)
//write data to memory
if (memwrite)
begin
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=jspal_res3[7:0];
datmem[sum[4:0]+2]=jspal_res3[15:8];
datmem[sum[4:0]+1]=jspal_res3[23:16];
datmem[sum[4:0]]=jspal_res3[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[6:0]],mem[pc[6:0]+1],mem[pc[6:0]+2],mem[pc[6:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst25_0=instruc[25:0];
 assign inst5_0= instruc[5:0];


// registers
assign dataa=registerfile[jspal_res1];//Read register 1
assign datab=registerfile[jspal_res2];//Read register 2




always @(posedge clk)
 registerfile[out1]= regwrite ? out5:registerfile[out1];//Write data to register

//read data from memory, sum stores address
assign dpack=datmem[sum[5:0]];

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, jalm_res,jmor_res,regdest);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//mux5
mult2_to_1_32 mult5(out5, out3, adder1out, status2);

//mux6
mult2_to_1_32 mult6(out6, out4, out_pc, select);

//mux7
mult2_to_1_32 mult7(jspal_res1, inst25_21 , 29, jspal_signal); //!!

//mux8
mult2_to_1_32 mult8(jspal_res2, inst20_16 , 21, jspal_signal); //!!

//mux9
mult2_to_1_32 mult9(jalm_res, inst20_16 , 31, jalm_signal); //!!

//mux10
mult2_to_1_32 mult10(jmor_res, inst15_11 , 31, jmor_signal); //!!

//mux11
mult2_to_1_32 mult11(jspal_res3, datab , adder1out, jspal_signal); //!!


// load pc
always @(negedge clk)
prev_sum = sum;

always @(negedge clk)
pc=out6;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],inst5_0,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,status0,status1,status2);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[5],instruc[4],instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//status module
status stat(n,z,v,zout,prev_sum);

//j br controller
j_br_control jbrcont(out_pc,enable,adder1out,dpack, dataa, inst25_0,status0,status1,status2,n,z,v);

//AND gate
assign pcsrc=branch && zout;

//For select bit
assign status_select = status0|status1|status2;
assign select = enable && status_select;

//For jspal
assign jspal_signal = (~status0) & status1 & status2;
assign jalm_signal = status0 & (~status1) & status2;
assign jmor_signal = status0 & status1 & (~status2);


//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("data/data_memory.dat",datmem); //read Data Memory
$readmemh("data/instruction_memory.dat",mem);//read Instruction Memory
$readmemh("data/registers.dat",registerfile);//read Register File

	for(i=0; i<64; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;

end
initial
begin
clk=1;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial
begin
  $monitor($time, "PC %h", pc, "  SUM %h", sum, "   INST %h\n", instruc[31:0],
  "Register[%0d]= %h",0,registerfile[0],"  Register[%0d]= %h\n",1,registerfile[1],
  "Register[%0d]= %h",2,registerfile[2],"  Register[%0d]= %h\n",3,registerfile[3],
  "Register[%0d]= %h",4,registerfile[4],"  Register[%0d]= %h\n",5,registerfile[5],
  "Register[%0d]= %h",6,registerfile[6],"  Register[%0d]= %h\n",7,registerfile[7],
  "Register[%0d]= %h",8,registerfile[8],"  Register[%0d]= %h\n",9,registerfile[9],
  "Register[%0d]= %h",10,registerfile[10],"  Register[%0d]= %h\n",11,registerfile[11],
  "Register[%0d]= %h",12,registerfile[12],"  Register[%0d]= %h\n",13,registerfile[13],
  "Register[%0d]= %h",14,registerfile[14],"  Register[%0d]= %h\n",15,registerfile[15],
  "Register[%0d]= %h",16,registerfile[16],"  Register[%0d]= %h\n",17,registerfile[17],
  "Register[%0d]= %h",18,registerfile[18],"  Register[%0d]= %h\n",19,registerfile[19],
  "Register[%0d]= %h",20,registerfile[20],"  Register[%0d]= %h\n",21,registerfile[21],
  "Register[%0d]= %h",22,registerfile[22],"  Register[%0d]= %h\n",23,registerfile[23],
  "Register[%0d]= %h",24,registerfile[24],"  Register[%0d]= %h\n",25,registerfile[25],
  "Register[%0d]= %h",26,registerfile[26],"  Register[%0d]= %h\n",27,registerfile[27],
  "Register[%0d]= %h",28,registerfile[28],"  Register[%0d]= %h\n",29,registerfile[29],
  "Register[%0d]= %h",30,registerfile[30],"  Register[%0d]= %h\n",31,registerfile[31],
  "Data Memory[%0d]= %h",0,datmem[0]);

end

endmodule
