/*This module describes a 4-bit comparator which compares two 4-bit numbers and outputs: 
    1 if they are equal
    0 if they are not equal
*/

module comparator_4bit(         //Creating a new module for comparator
    input [3:0] A,B,            //Declaring 4-bit bus for each input port
    output      Y               //Declaring 1-bit wire for output port
);
    wire [3:0] w;               //Declaring a 4-bit bus for internal connection
    assign w=~(A^B);            //Taking bitwise XNOR of the two inputs to check if individual bits are equal
    assign Y=&w;                //Taking AND of individual outputs to check if all bits are simultaneously equal
endmodule