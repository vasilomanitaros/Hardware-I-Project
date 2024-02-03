module decoder 
    (output [3:0] alu_op,
    input wire btnl,btnc,btnr);

//alu_op[0]
not(btnr_not,btnr);
and(btnr_not_AND_btnl,btnr_not,btnl);
xor(btnl_XOR_btnc,btnl,btnc);
and(final_and,btnl_XOR_btnc,btnr);
or(alu_op[0],btnr_not_AND_btnl,final_and);

//alu_op[1]
not(btnl_not,btnl);
not(btnc_not,btnc);
and(final_and2,btnl,btnr);
and(final_and3,btnl_not,btnc_not);
or(alu_op[1],final_and2,final_and3);

//alu_op[2]
xor(btnl_XOR_btnr,btnl,btnr);
and(btnr_AND_btnl,btnr,btnl);
or(final_or1,btnl_XOR_btnr,btnr_AND_btnl);
and(alu_op[2],final_or1,btnc_not);

//alu_op[3]
xnor(btnr_XNOR_btnc,btnr,btnc);
and(final_and4,btnc,btnr_not);
or(final_or2,btnr_XNOR_btnc,final_and4);
and(alu_op[3],final_or2,btnl);

endmodule