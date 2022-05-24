module status(out_pc, pc, pc_br, mem_out, reg_s, j_diraddr, j_indaddr alu_result, alu_zero, status0, status1, status2);
input [31:0] alu_result, mem_out, pc, pc_br, reg_s, j_diraddr, j_indaddr;
input alu_zero, status0, status1, status2;
output [31:0] out_pc;

reg [31:0] out_pc;
wire [2:0] status_check;
wire n,z;

assign n = alu_result[31];
assign z = alu_zero;
assaign status_check = {status2, status1, status0};

always @ (*)
begin

	case(status_check)
		3'b000:
			begin
			out_pc = pc
			end
		3'b001: 			// bmn instruction is active
			begin
			out_pc = n ? mem_out : pc;
			end
		3'b010: 			// brz instruction is active
			begin
			out_pc = z ? reg_s : pc;
			end
		3'b011: 			// bz instruction is active
			begin
			out_pc= z ? j_diraddr : pc;
			end
		3'b100: 			// jmor instruction is active
			begin
			out_pc = mem_out;
			end
		3'b101: 			// jalm instruction is active
			begin
			out_pc = mem_out;
			end
		3'b110: 			// beq instruction is active
			begin
			out_pc = alu_zero ? pc_br : pc;
			end
		default: out_pc = out;
	endcase
end
endmodule