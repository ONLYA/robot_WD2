This is the verilog version of UART. I am going to use the verilog mixed with VHDL.

The usage of the mixture is:
"To Instantiate a Verilog Module in a VHDL Design Unit

     Declare a VHDL component with the same name as the Verilog module **(respecting case sensitivity)** that 
     you want to instantiate.
    For example,

    COMPONENT FD PORT (
    Q : out  STD_ULOGIC;
    D : in   STD_ULOGIC;
    C : in   STD_ULOGIC );
    END COMPONENT;

     Use named association to instantiate the Verilog module.
    For example,

    UUT : FD PORT MAP(
    Q => O,
    D => I,
    C => CLK);

"Since Verilog is case sensitive, named associations and the local port names that you use in the component declaration must match the case of the corresponding Verilog port names. "

Found on : https://www.xilinx.com/itp/xilinx10/isehelp/ism_p_instantiating_verilog_module_mixedlang.htm
