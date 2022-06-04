module j_br_control(out_pc, enable, pc4, mem_out, reg_s, j_diraddr, status0, status1, status2, n, z, v);
input [31:0] mem_out, pc4, reg_s;
input[25:0] j_diraddr;
input status0, status1, status2, n, z, v;
output [31:0] out_pc;
output enable;

reg [31:0] out_pc;
reg enable;
wire [2:0] status_check;

assign status_check = {status2, status1, status0};

always @ (*)
begin

	case(status_check)
		3'b000:
			begin
			out_pc = pc4;
			end
		3'b001: 			// bmn instruction is active
			begin
			out_pc = n ? mem_out : pc4;
            enable = 1;
			end
		3'b010: 			// brz instruction is active
			begin
			out_pc = z ? reg_s : pc4;
            enable = 1;
			end
		3'b011: 			// bz instruction is active
			begin
			out_pc= z ? j_diraddr : pc4;
            enable = 1;
			end
		3'b100: 			// jmor instruction is active
			begin
			out_pc = mem_out;
            enable = 1;
			end
		3'b101: 			// jalm instruction is active
			begin
			out_pc = mem_out;
            enable = 1;
			end
        3'b110: 			// jspal instruction is active
			begin
			out_pc = mem_out;
            enable = 1;
			end
		default: out_pc = pc4;
	endcase
end
endmodule