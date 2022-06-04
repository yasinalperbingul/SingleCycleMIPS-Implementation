module control(in,funct,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,status0, status1, status2);
input [5:0] in,funct;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,status0, status1, status2;
wire rformat,lw,sw,beq;
wire bmn,brz,bz,jmor,jalm,jspal;

assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign bmn=~in[5]& in[4]&(~in[3])&in[2]&(~in[1])&(in[0]); // 010101 opcode = 21
assign brz=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(~funct[5])&(funct[4])&(~funct[3])&(funct[2])&(~funct[1])&(~funct[0]); // 010100  func code = 20
assign bz=~in[5]& in[4]&in[3]&(~in[2])&(~in[1])&(~in[0]); // 011000 opcode = 24
assign jmor=~in[5]& (~in[4])&(~in[3])&(~in[2])&(~in[1])&(~in[0])&(funct[5])&(~funct[4])&(~funct[3])&(funct[2])&(~funct[1])&(funct[0]); // 100001 func code = 37
assign jalm=~in[5]& in[4]&(~in[3])&(~in[2])&in[1]&in[0]; // 010011 opcode = 19
assign jspal=(~in[5])& in[4]&(~in[3])&in[2]&in[1]&(~in[0]); // 010110 opcode = 22

//Düzenlenecek
assign regdest=rformat;
assign alusrc=lw|sw|bmn|jalm;
assign memtoreg=lw|bmn|jmor|jalm|jspal;
assign regwrite=rformat|lw|jmor|jalm;
assign memread=lw|bmn|jmor|jalm|jspal;
assign memwrite=sw|jspal;
assign aluop1=rformat;
assign aluop2=beq;

//Tamamlandı-Kontrol edilmeli
assign status0 = beq|bmn|bz|jalm;
assign status1 = beq|brz|bz|jspal;
assign status2 = beq|jmor|jalm|jspal;

endmodule
