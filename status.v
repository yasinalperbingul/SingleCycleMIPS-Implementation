module status(n_out, z_out, v_out, alu_zero, alu_result);
input [31:0] alu_result;
input alu_zero;
output n_out, z_out, v_out;

assign n_out = alu_result[31];
assign z_out = alu_zero;
//v_out oluştur
endmodule