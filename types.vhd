library ieee;
use ieee.std_logic_1164.all;

package types is

	type ext_op_t  is (ext_op_unsigned, ext_op_signed, ext_op_signed_shifted);
	type alu_op_t  is (alu_op_add, alu_op_neg, alu_op_and, alu_op_or, alu_op_sl, alu_op_sr, alu_op_cmp);
	type fpu_op_t  is (fpu_op_bypass, fpu_op_neg, fpu_op_abs, fpu_op_cmp);
	type fadd_op_t is (fadd_op_add, fadd_op_sub);

	type alu_src_t   is (alu_src_gpr, alu_src_ext);
	type dmem_src_t  is (dmem_src_gpr, dmem_src_fpr);
	type data_src_t  is (data_src_alu, data_src_dmem, data_src_lr, data_src_recv, data_src_fpu, data_src_fadd, data_src_fmul, data_src_finv);
	type lr_src_t    is (lr_src_pc, lr_src_alu);
	type ia_src_t    is (ia_src_pc, ia_src_lr, ia_src_ctr, ia_src_ext);
	type stall_src_t is (stall_src_go, stall_src_stall);

end package;
