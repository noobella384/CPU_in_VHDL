library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUD is
    port(
        A, B    : in std_logic_vector(15 downto 0);
        Oper    : in std_logic_vector(3 downto 0);
        C       : out std_logic_vector(15 downto 0);
        Z       : out std_logic;
        Carry   : out std_logic);
end entity;

architecture behav of ALUD is
    signal cprime : std_logic_vector(15 downto 0) := (others => '0');
    signal zprime : std_logic := '0';
    signal carryprime : std_logic := '0';
begin
    Output : process(A, B, Oper)
        variable temp_carry : std_logic := '0';
        variable temp_borrow : std_logic := '0';
        variable temp_cprime : std_logic_vector(15 downto 0);
    begin
        -- Reset intermediate signals
        temp_cprime := (others => '0');
        
        case Oper is
            when "0000" => -- Add
                temp_carry := '0';
                for i in 0 to 15 loop
                    temp_cprime(i) := (A(i) xor B(i)) xor temp_carry;
                    temp_carry := (A(i) and B(i)) or ((A(i) xor B(i)) and temp_carry);
                end loop;
                carryprime <= temp_carry;

            when "0010" => -- Subtract
                temp_borrow := '0';
                for i in 0 to 15 loop
                    temp_cprime(i) := (A(i) xor B(i)) xor temp_borrow;
                    temp_borrow := (not A(i) and B(i)) or ((not A(i) or B(i)) and temp_borrow);
                end loop;


            when "0011" => -- Multiply (lower 4 bits only)
                temp_cprime := std_logic_vector(to_unsigned(
                    to_integer(unsigned(A(3 downto 0))) * 
                    to_integer(unsigned(B(3 downto 0))), 16));

            when "0100" => -- Bitwise AND
                for i in 0 to 15 loop
                    temp_cprime(i) := A(i) and B(i);
                end loop;

            when "0101" => -- Bitwise OR
                for i in 0 to 15 loop
                    temp_cprime(i) := A(i) or B(i);
                end loop;

            when "0110" => -- Bitwise IMPLIES
                for i in 0 to 15 loop
                    temp_cprime(i) := (not A(i)) or B(i);
                end loop;

            when others => -- Default
                temp_cprime := (others => '0');
                carryprime <= '0';
        end case;

        -- Update cprime with temporary result
        cprime <= temp_cprime;
    end process;
zprime <= not( cprime(15) or cprime(14) or cprime(13) or cprime(12) or cprime(11) or cprime(10) or cprime(9) or cprime(8) or cprime(7) 
					or cprime(6) or cprime(5) or cprime(4) or cprime(3) or cprime(2) or cprime(1) or cprime(0));

    -- Assign outputs
    C <= cprime;
    Z <= zprime;
    Carry <= carryprime;
end architecture;
