module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,status0, status1, status2);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,status0, status1, status2;
wire rformat,lw,sw,beq;
wire bmn,brz,bz,jmor,jalm;

assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign bmn=~in[5]& in[4]&(~in[3])&in[2]&(~in[1])&(in[0]); // 010101
assign brz=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(~funct[5])&(funct[4])&(~funct[3])&(~funct[2])&(funct[1])&(~funct[0]);
assign bz=~in[5]& in[4]&in[3]&(~in[2])&(~in[1])&(~in[0]); // 011000
assign jmor=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(~funct[2])&(~funct[1])&(funct[0]);
assign jalm=~in[5]& in[4]&(~in[3])&(~in[2])&in[1]&in[0]; // 010011

//Düzenlenecek
assign regdest=rformat;
assign alusrc=lw|sw|bmn;
assign memtoreg=lw;
assign regwrite=rformat|lw;
assign memread=lw|bmn;
assign memwrite=sw;
//assign branch=beq; -> Bu artık branch control unitte

//Düzenlenecek
assign aluop1=rformat;
assign aluop2=beq;

//Tamamlandı-Kontrol edilmeli
assign status0 = beq|bmn|bz|jalm
assign status1 = beq|brz|bz
assign status2 = beq|jmor|jalm

endmodule
