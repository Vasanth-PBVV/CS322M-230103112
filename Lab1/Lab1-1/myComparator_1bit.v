/*This module describes a 1-bit comparator which compares two 1-bit numbers (A & B) and outputs: 
    1 in o1 if A>B
    1 in o2 if A=B
    1 in o3 if A<B
  outputs remain in 0 except in the above cases
*/

module comparator_1bit(         //Creating a new module for comparator
    input A,B,                  //Declaring two 1-bit input ports
    output o1,o2,o3             //Declaring three 1-bit output ports
);
    assign o1=A&(~B);           //implimented in SOP form using truth table
    assign o2=~(A^B);           //by inspection of truth table, it is the XNOR of A and B
    assign o3=~A&B;             //implimented in SOP form using truth table
endmodule