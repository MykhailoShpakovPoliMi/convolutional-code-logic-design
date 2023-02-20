-- Composizione del gruppo che ha svolto il progetto --
-- Mykhailo Shpakov - 10656977 / 937848 --
-- Davide Preatoni - 10696246 / 939259 --
-- Data di consengna 15/09/22 --
-- Politecnico di Milano --

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR(7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR(7 downto 0)
           );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

component datapath_module is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           in_load: in STD_LOGIC;
           d1_load: in STD_LOGIC;
           d2_load: in STD_LOGIC;
           i_psel: in STD_LOGIC;
           psel_load: in STD_LOGIC;
           out_load: in STD_LOGIC;
           wm_sel: in STD_LOGIC;
           cnt_sel: in STD_LOGIC;
           cnt_load: in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_end : out STD_LOGIC
           );
end component;

component datapath_address_logic is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_rsel: in STD_LOGIC;
           rsel_load: in STD_LOGIC;
           raddr_load:in STD_LOGIC;
           rw_sel: in STD_LOGIC;
           i_wsel: in STD_LOGIC;
           wsel_load: in STD_LOGIC;
           waddr_load: in STD_LOGIC;
           o_address: out STD_LOGIC_VECTOR(15 downto 0);
           o_is_first_read: out STD_LOGIC
           );
end component;

signal in_load: STD_LOGIC;
signal d1_load: STD_LOGIC;
signal d2_load: STD_LOGIC;
signal i_psel: STD_LOGIC;
signal psel_load: STD_LOGIC;
signal out_load: STD_LOGIC;
signal wm_sel: STD_LOGIC;
signal cnt_sel: STD_LOGIC;
signal cnt_load: STD_LOGIC;
signal raddr_load: STD_LOGIC;
signal i_rsel: STD_LOGIC;
signal rsel_load: STD_LOGIC;
signal waddr_load: STD_LOGIC;
signal i_wsel: STD_LOGIC;
signal wsel_load: STD_LOGIC;
signal rw_sel: STD_LOGIC;
signal o_end: STD_LOGIC;
signal o_is_first_read: STD_LOGIC;

type S is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9);
signal cur_state, next_state: S;

begin
    DATAPATH_MOD: datapath_module port map(
               i_clk => i_clk,
               i_rst => i_rst,
               i_data => i_data,
               in_load => in_load,
               d1_load => d1_load,
               d2_load => d2_load,
               i_psel => i_psel,
               psel_load => psel_load,
               out_load => out_load,
               wm_sel => wm_sel,
               cnt_sel => cnt_sel,
               cnt_load => cnt_load,
               o_data => o_data,
               o_end => o_end
    );
    
    DATAPATH_ADDR: datapath_address_logic port map(
                   i_clk => i_clk,
                   i_rst => i_rst,
                   i_rsel => i_rsel,
                   rsel_load => rsel_load,
                   raddr_load => raddr_load,
                   rw_sel => rw_sel,
                   i_wsel => i_wsel,
                   wsel_load => wsel_load,
                   waddr_load => waddr_load,
                   o_address => o_address,
                   o_is_first_read => o_is_first_read
    );
    

    process(i_clk, i_rst)
        begin
            if(i_rst = '1') then
                cur_state <= S0;
            elsif i_clk'event and i_clk = '1' then
                cur_state <= next_state;
            end if;
    end process;
    
    --NEXT STATE FUNCTION--
    delta: process(i_start, o_is_first_read, o_end, i_clk)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 => 
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 => 
                if o_is_first_read = '1' then
                    next_state <= S3;
                elsif o_is_first_read = '0' then
                    next_state <= S5;
                end if;
            when S3 =>
                next_state <= S4;
            when S4 => 
                if o_end = '1' then
                    next_state <= S9;
                elsif o_end = '0' then
                    next_state <= S1;
                end if;
            when S5 =>
                next_state <= S6;
            when S6 => 
                next_state <= S7;
            when S7 =>
                next_state <= S8;
            when S8 => 
                if o_end = '1' then
                    next_state <= S9;
                elsif o_end = '0' then
                    next_state <= S1;
                end if;
            when S9 =>
                if i_start = '0' then
                    next_state <= S0;
                end if;
        end case;
        
    end process;
    
    --OUTPUT FUNCTION--
    lambda: process(cur_state)
    begin
        in_load <= '0';
        d1_load <= '0';
        d2_load <= '0';
        out_load <= '0';
        wm_sel <= '0';
        cnt_sel <= '0';
        cnt_load <= '0';
        raddr_load <= '0';
        waddr_load <= '0';
        rw_sel <= '0';
        o_en <= '0';
        o_we <= '0';
        i_psel <= '0';
        psel_load <= '0';
        i_rsel <= '0';
        rsel_load <= '0';
        i_wsel <= '0';
        wsel_load <= '0';
        o_done <= '0';
        
        case cur_state is
        
            --S0 reset state--
            --initialize psel_reg, rsel_reg, wsel_reg--
            when S0 =>
                i_psel <= '0';
                psel_load <= '1';
                i_rsel <= '0';
                rsel_load <= '1';
                i_wsel <= '0';
                wsel_load <= '1';
                
            --S1 calculate the memory cell address to read from--
            when S1 =>
                raddr_load <= '1';
                
            --S2 read from memory--
            --if o_address = 0 (first time) => i_data is number of words to elaborate--
            --other wise i_data is the word to elaborate
            when S2 => 
                o_en <= '1';
                o_we <= '0';
                rw_sel <= '0';
            
            --S3 save number of words to elaborate in reg_cnt--
            when S3 =>
                cnt_sel <= '0';
                cnt_load <= '1';
                
            --S4 initialize rsel_reg with 1--
            --compare value in reg_cnt with 0 to produce o_end signal--
            when S4 => 
                i_rsel <= '1';
                rsel_load <= '1';
                
            --S5 save the word to elaborate in reg_in--
            when S5 =>
                in_load <= '1';
                
            --S6 calculate the result of convolution and save it in reg_out--
            --save the last bit of input word in d1--
            --propagate a memory address in reg_waddr--
            --load 1 to wsel_reg--
            when S6 => 
                out_load <= '1';
                d1_load <= '1';
                waddr_load <= '1';
                i_wsel <= '1';
                wsel_load <= '1';
                
            --S7 write in memory 1 byte of result--
            --save the second last bit of input word in d1 and last bit in d2--
            --save in reg_cnt the number of words yet to elaborate--
            --calculate the address where to write the next byte of result--
            when S7 =>
                d1_load <= '1';
                d2_load <= '1';
                wm_sel <= '0';
                o_en <= '1';
                o_we <= '1';
                rw_sel <= '1';
                cnt_sel <= '1';
                cnt_load <= '1';
                waddr_load <= '1';
                
            --S8 write in memory 2 byte of result--
            --calculate the address to read next word from--
            --load 1 in psel_reg in order to choose right prefix for the next word--
            when S8 => 
                wm_sel <= '1';
                o_en <= '1';
                o_we <= '1';
                rw_sel <= '1';
                i_psel <= '1';
                psel_load <= '1';
                
            --S9 elaboration was successfully terminated--
            --put o_done to 0 and wait till i_start becomes equal to 0--
            when S9 =>
                o_done <= '1';
        end case;
        
    end process;
    
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath_module is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           in_load: in STD_LOGIC;
           d1_load: in STD_LOGIC;
           d2_load: in STD_LOGIC;
           i_psel: in STD_LOGIC;
           psel_load: in STD_LOGIC;
           out_load: in STD_LOGIC;
           wm_sel: in STD_LOGIC;
           cnt_sel: in STD_LOGIC;
           cnt_load: in STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_end : out STD_LOGIC
           );
           
end datapath_module;

architecture Behavioral of datapath_module is
signal input: STD_LOGIC_VECTOR(9 downto 0) := "0000000000";
signal conv_in: STD_LOGIC_VECTOR(9 downto 0);
signal conv_out: STD_LOGIC_VECTOR(15 downto 0);
signal prefix_sel: STD_LOGIC;
signal d1_in: STD_LOGIC;
signal d1_out: STD_LOGIC;
signal d2_out: STD_LOGIC;
signal result: STD_LOGIC_VECTOR(15 downto 0);
signal count_in: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal count_out: STD_LOGIC_VECTOR(7 downto 0);

begin
    --Assignment of an input signal of reg_in--
    --MUX P--
    with prefix_sel select
        input <= "00" & i_data when '0',
                  d1_out & d2_out & i_data when '1',
                  "XXXXXXXXXX" when others;
                  
    --Description of psel_reg register--
    psel_reg: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                prefix_sel <= '0';
            elsif psel_load = '1' then
                prefix_sel <= i_psel;
            end if;
        end if;
    end process;

    --Description of reg_in register
    reg_in: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                conv_in <= "0000000000";
            elsif in_load = '1' then
                conv_in <= input;
            end if;
        end if;
    end process;
    
    --Assignment of conv_out according to convolutional code
    conv_out <= (
                15 => conv_in(7) xor conv_in(9),
                14 => conv_in(7) xor conv_in(8) xor conv_in(9),
                13 => conv_in(6) xor conv_in(8),
                12 => conv_in(6) xor conv_in(7) xor conv_in(8),
                11 => conv_in(5) xor conv_in(7),
                10 => conv_in(5) xor conv_in(6) xor conv_in(7),
                9  => conv_in(4) xor conv_in(6),
                8  => conv_in(4) xor conv_in(5) xor conv_in(6),
                7  => conv_in(3) xor conv_in(5),
                6  => conv_in(3) xor conv_in(4) xor conv_in(5),
                5  => conv_in(2) xor conv_in(4),
                4  => conv_in(2) xor conv_in(3) xor conv_in(4),
                3  => conv_in(1) xor conv_in(3),
                2  => conv_in(1) xor conv_in(2) xor conv_in(3),
                1  => conv_in(0) xor conv_in(2),
                0  => conv_in(0) xor conv_in(1) xor conv_in(2)
                );
    
    --Assignment of d1_in according to states of d2 register
    --d2_load serves as mux selector signal
    with d2_load select
            d1_in <= conv_in(0) when '0',
                      conv_in(1) when '1',
                      'X' when others;
    
    --Description of d1 and d2
    d1: process(i_clk)
        begin
            if i_clk'event and i_clk = '1' then
                if i_rst = '1' then
                    d1_out <= '0';
                elsif d1_load = '1' then
                    d1_out <= d1_in;
                end if;
            end if;
    end process;
        
    d2: process(i_clk)
        begin
            if i_clk'event and i_clk = '1' then
                if i_rst = '1' then
                    d2_out <= '0';
                elsif d2_load = '1' then
                    d2_out <= d1_out;
                end if;
            end if;
    end process;
    
    --Description of reg_out register
    reg_out: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                result <= "0000000000000000";
            elsif out_load = '1' then
                result <= conv_out;
            end if;
        end if;
    end process;
    
    --Assignment of an o_data signal based on wm_sel--
    --MUX O--
    with wm_sel select
        o_data <= result(15 downto 8) when '0',
                  result(7 downto 0) when '1',
                  "XXXXXXXX" when others;
    
    --Assignment of a count_in signal based on cnt_sel--
    --MUX C--
    with cnt_sel select
        count_in <= i_data when '0',
                    count_out - "00000001" when '1',
                    "XXXXXXXX" when others;
                    
    --Description of reg_cnt register
    reg_cnt: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                count_out <= "00000000";
            elsif cnt_load = '1' then
                count_out <= count_in;
            end if;
        end if;
    end process;
    
    --Description of o_end comparator--
    o_end <= '1' when (count_out = "00000000") else '0';
    
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath_address_logic is
    Port ( 
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_rsel: in STD_LOGIC;
           rsel_load: in STD_LOGIC;
           raddr_load:in STD_LOGIC;
           rw_sel: in STD_LOGIC;
           i_wsel: in STD_LOGIC;
           wsel_load: in STD_LOGIC;
           waddr_load: in STD_LOGIC;
           o_address: out STD_LOGIC_VECTOR(15 downto 0);
           o_is_first_read: out STD_LOGIC
           );
end datapath_address_logic;

architecture Behavioral of datapath_address_logic is
signal raddr_sel : STD_LOGIC;
signal waddr_sel : STD_LOGIC;
signal raddr_in: STD_LOGIC_VECTOR(15 downto 0);
signal raddr_out: STD_LOGIC_VECTOR(15 downto 0);
signal waddr_in: STD_LOGIC_VECTOR(15 downto 0);
signal waddr_out: STD_LOGIC_VECTOR(15 downto 0);

begin
    --Assignment of an raddr_in signal of reg_raddr--
    --MUX R--
    with raddr_sel select
        raddr_in <= (others => '0') when '0',
                    raddr_out + "0000000000000001" when '1',
                    (others => 'X') when others;
    
    --Description of rsel_reg register--
    rsel_reg: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                raddr_sel <= '0';
            elsif rsel_load = '1' then
                raddr_sel <= i_rsel;
            end if;
        end if;
    end process;
    
    --Description of o_is_first_read comparator--
    o_is_first_read <= '1' when (raddr_sel = '0') else '0';
    
    --Description of reg_raddr register--
    reg_raddr: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                raddr_out <= (others => '0');
            elsif raddr_load = '1' then
                raddr_out <= raddr_in;
            end if;
        end if;
    end process;
    
    
    --Assignment of a waddr_in signal of reg_waddr--
    --MUX W--
    with waddr_sel select
        waddr_in <= "0000001111101000" when '0',
                    waddr_out + "0000000000000001" when '1',
                    (others => 'X') when others;
    
    --Description of wsel_reg register--
    wsel_reg: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                waddr_sel <= '0';
            elsif wsel_load = '1' then
                waddr_sel <= i_wsel;
            end if;
        end if;
    end process;
    
    --Description of reg_waddr register--
    reg_waddr: process(i_clk)
    begin
        if i_clk'event and i_clk = '1' then
            if i_rst = '1' then
                waddr_out <= (others => '0');
            elsif waddr_load = '1' then
                waddr_out <= waddr_in;
            end if;
        end if;
    end process;
    
    --Assignment of o_address signal--
    --MUX A--
    with rw_sel select
        o_address <= raddr_out when '0',
                    waddr_out when '1',
                    (others => 'X') when others;

end Behavioral;