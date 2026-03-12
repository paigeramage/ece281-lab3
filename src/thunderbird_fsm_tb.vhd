--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	port(
		i_clk    : in    std_logic;
		i_reset  : in    std_logic;
        i_left   : in    std_logic;
        i_right  : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
	);
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_L : std_logic := '0';
	signal w_R : std_logic := '0';
	signal w_reset : std_logic := '0';
    signal w_clk : std_logic := '0';
    
    --Outputs
    signal w_lights_L : std_logic_vector(2 downto 0) := "000"; --default OFF
    signal w_lights_R : std_logic_vector(2 downto 0) := "000"; --default OFF
	
	-- constants
    constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
        i_left => w_L,
        i_right => w_R,
        i_reset => w_reset,
        i_clk => w_clk,
        o_lights_L => w_lights_L,
        o_lights_R => w_lights_R
    );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	-- Using 220 ns for simulation
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_lights_L = "000" report "bad reset" severity failure;
		
		w_reset <= '0';
		wait for k_clk_period*1;
		
		-- left light sequence
		w_L <= '1';
          assert w_lights_L = "000" report "bad L1" severity failure;
        -- left light 1
        wait for k_clk_period;
            assert w_lights_L = "001" report "skipped L1" severity failure;
        -- left light 2
        wait for k_clk_period;
            assert w_lights_L = "011" report "skipped L2" severity failure;
        -- left light 3 with right off to ensure it stays on
        w_L <= '1'; wait for k_clk_period;
            assert w_lights_L = "111" report "should have all left ON" severity failure;
        
        -- reset and test right light
        w_reset <= '1'; w_L <= '0';
            wait for k_clk_period;
        w_reset <= '0';
        
        --testing OFF
        w_R <= '1';
          assert w_lights_R = "000" report "bad R1" severity failure;
        --testing R1
        wait for k_clk_period;
            assert w_lights_R = "001" report "skipped R1" severity failure;
        --testing R2
        wait for k_clk_period;
            assert w_lights_R = "011" report "skipped R2" severity failure;
        --testing R3
        wait for k_clk_period;
            assert w_lights_R = "111" report "should have all rights ON" severity failure;
	    
	    -- reset and test ON
        w_reset <= '1'; w_R <= '0';
            wait for k_clk_period;
        w_reset <= '0';
        
        --testing R and L
        w_R <= '1'; w_L <= '1'; wait for k_clk_period;
          assert w_lights_R = "111" report "bad Right ON" severity failure;
          assert w_lights_L = "111" report "bad Left ON" severity failure;
        wait for k_clk_period;
          assert w_lights_R = "000" report "bad Right OFF" severity failure;
          assert w_lights_L = "000" report "bad Left OFF" severity failure;
         
		wait;
	end process;
	-----------------------------------------------------	
	
end test_bench;
