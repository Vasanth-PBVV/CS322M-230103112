/* This module serves as a test bench for 4-bit comparator by applying all possible values of
    of inputs one by one.
*/

`include "myComparator_4bit.v"                  //including the file which contains our comapartor module

module tb;                                      //creating a new module to act as test bench
    reg [3:0] A,B;                              //declaring registries to store values and act as inputs
    wire Y;                                     //declaring a wire to connect to output of comparator
    integer i,j;                                //loop variables for 'for' loop to provide test cases

    comparator_4bit comparator_4bit_module1(    //create an instance of our comparator
        .A(A),                                  //connecting 1st input bus to 1st registry
        .B(B),                                  //connecting 1st input bus to 2nd registry
        .Y(Y)                                   //connecting a wire to output of comparator
    );

    initial                                     //code in this block is sequentially executed to give test conditions
    begin                                       //start of block
        $dumpfile("myComparator_4bit.vcd");     //specifying the file to save the results
        $dumpvars(0,tb);                        //specifying that variables of module 'tb' should be saved
        A[3:0]=0;                               
        B[3:0]=0;                               //give initial values to avoid the inputs being in an unknown state in 1st second
        for(i=0;i<16;i=i+1)                     //nested for loop to sequentially give all possible input combinations
        begin
            for(j=0;j<16;j=j+1)
            begin
                #1
                A[3:0]=i;                       //decimal number is implicitly converted into binary and are stored in registries
                B[3:0]=j;
            end
        end
    end                                         //end of block
endmodule