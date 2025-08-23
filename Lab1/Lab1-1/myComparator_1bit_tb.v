/* This module serves as a test bench for 1-bit comparator by applying all possible values of
    of inputs one by one.
*/

`include "myComparator_1bit.v"                  //including the file which contains our comapartor module

module tb;                                      //creating a new module to act as test bench
    reg A,B;                                    //declaring registries to store values and act as inputs
    wire o1,o2,o3;                              //declaring a wires to connect to outputs of comparator

    comparator_1bit comparator_1bit_module1(    //create an instance of our comparator
        .A(A),                                  //connecting registries to inputs of comparator
        .B(B),
        .o1(o1),                                //connecting a wire to each output of comparators
        .o2(o2), 
        .o3(o3)
    );

    initial                                     //code in this block is sequentially executed to give test conditions
    begin                                       //start of block
        $dumpfile("myComparator_1bit.vcd");     //specifying the file to save the results
        $dumpvars(0,tb);                        //specifying that variables of module 'tb' should be saved

        A=0;                                    //give all the four possible input combinations one by one by changing the values stored in the registry
        B=0;
        #1                                      //delay of 1s, to view results clearly, with sufficient time gap between transitions
        A=0;
        B=1;
        #1
        A=1;
        B=0;
        #1
        A=1;
        B=1;
    end                                         //end of block
endmodule