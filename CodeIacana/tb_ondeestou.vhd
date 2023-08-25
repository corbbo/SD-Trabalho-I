---------------------------------------------------------------------------------------------------------
-- TESTBENCH FOR THE ondeestou CIRCUIT
-- AUTHORS: 
-- DATE: 02/2023
---------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.std_logic_arith.all;

entity tb_ondeestou is                               
end tb_ondeestou;

architecture teste of tb_ondeestou is
  
   signal prog, reset, clock, achar, ponto, fim : std_logic := '0';
   signal x, y:  STD_LOGIC_VECTOR(5 downto 0) := (others=>'0');
   signal address:  STD_LOGIC_VECTOR(11 downto 0) := (others=>'0');
   signal sala : STD_LOGIC_VECTOR(3 downto 0) := (others=>'0');

   type mapa_type is array(0 to 63) of STD_LOGIC_VECTOR(0 to 63) ;
   constant mapa : mapa_type :=  
      --          1         2         3         4         5         6      
      --0123456789012345678901234567890123456789012345678901234567890123
      ("0000000000000000000000000000000000000000000000000000000000000000",   --  0
       "0000000000000000000111111111111111111111111110000000000000000000",   --  1
       "0000000000000000000100000000000000000000000010000000000000000000",   --  2
       "0000111111111100000100000000000000000000000010000000000000000000",   --  3
       "0000100000000000000100000000000000000000000010000000000000000000",   --  4
       "0000100000000000000100000000000000000000000010000000000000000000",   --  5
       "0000100000000000000100000000000000000000000010000000000000000000",   --  6
       "0000100000000000000100000000000000000000000010000000000000000000",   --  7
       "0000100000000000000111111111111111111111111110000000000000000000",   --  8   - 26 x 8 (sala 1)
       "0000100000000000000000000000000000000000000000000000000000000000",   --  9
       "0000000000000000011111111110000000000000000000000000000000000000",   -- 10 
       "0000000000000000010000000010000000000000000000000000000000000000",   --  1 
       "0000000000000000011111111110000000000000000000000000000000000000",   --  2  - 10 x 3  (sala 2)
       "0000000000000000000000000000000000000000000000000000000000000000",   --  3
       "0000000000000000000000000111111111100100000000000000000000000000",   --  4 
       "0000000011111111111000000000000000000100000000000000000000000000",   --  5 
       "0000000010000000001000000000000000000100000000000111111000000000",   --  6 
       "0000000010000000001000000000000000000100000000000100001000000000",   --  7 
       "0000000010000000001000000000000000000100000000000100001000000000",   --  8 
       "0000000010000000001000000000000000000100000000000100001000000000",   --  9 
       "0000000010000000001000000000000000000100000000000100001000000000",   -- 20 
       "0000000010000000001000000000000000000100000000000111111000000000",   --  1  - 6 x 6 (sala 3)
       "0000000010000000001000000000000000000100000000000000000000000000",   --  2    
       "0000000010000000001000000000000000000100000000000000000000000000",   --  3   
       "0000000010000000001000000000000000000100000000000000000000000000",   --  4 
       "0000000010000000001000000000000111111000000000000000000000000000",   --  5 
       "0000000010000000001000000000000000000000000000000000000000000000",   --  6 
       "0000000010000000001000000000000000000000000000000000000000000000",   --  7 
       "0000000010000000001000000000000000000000000000000000000000000000",   --  8 
       "0000000010000000001000000000000000001111111111111111111100000000",   --  9 
       "0000000010000000001000000000000000001000000000000000000100000000",   -- 30 
       "0000000010000000001000000000000000001000000000000000000100000000",   --  1 
       "0000000010000000001000000000000000001000000000000000000100000000",   --  2 
       "0000000010000000001000000000000000001000000000000000000100000000",   --  3
       "0000000011111111111000000000000000001000000000000000000100000000",   --  4   - 11 x 20 (sala 4)
       "0000000000000000000000000000000000001000000000000000000100000000",   --  5 
       "0000000000000000000000000000000000001000000000000000000100000000",   --  6 
       "0001111110000000000000000000000000001000000000000000000100000000",   --  7 
       "0000000010000000000000000000000000001000000000000000000100000000",   --  8 
       "0010000010000000000000000000000000001000000000000000000100000000",   --  9 
       "0010000010000000000000000000000000001111111111111111111100000000",   -- 40   - 20 x 12 (sala 5)
       "0010000010000000000000000000000000000000000000000000000000000000",   --  1
       "0001111110000000000000000000000000000000000000000000000000000000",   --  2
       "0000000000000011111000000000000000000000000000000000000000000000",   --  3
       "0000000000000010001000000000000000000000000000000000000000000000",   --  4
       "0000000000000010001000000000000000000000000000000000000000000000",   --  5
       "0000000000000010001000000001111111111111111111111111111110000000",   --  6
       "0000000000000011111000000001000000000000000000000000000010000000",   --  7    - 5 x 5 (sala 6)
       "0000000000000000000000000001000000000000000000000000000010000000",   --  8
       "0000000000000000000000000001000000000000000000000000000010000000",   --  9
       "0000000000000000000000000001000000000000000000000000000010000000",   -- 50
       "0000000000000000000000000001000000000000000000000000000010000000",   --  1
       "0000000000000000000000000001000000000000000000000000000010000000",   --  2   
       "0000000000000000000000000001000000000000000000000000000010000000",   --  3   
       "0000011111111111111100000001000000000000000000000000000010000000",   --  4
       "0000010000000000000100000001111111111111111111111111111110000000",   --  5   - 30 x 10 (sala 7)
       "0000010000000000000100000000000000000000000000000000000000000000",   --  6
       "0000010000000000000100000000000000000000000000000000000000000000",   --  7
       "0000010000000000000100000000000000000000000000000000000010000000",   --  8
       "0000010000000000000100000000000000000000000000000000000000000000",   --  9
       "0000010000000000000100000000000000000000000000000000000000000000",   -- 60 
       "0000011111111111111100000000000000011111111111111100000000000000",   --  1   - 15 x 8 (sala 8)
       "0000000000000000000000000000000000000000000000000000000000000000",   --  2
       "0000000000000000000000000000000000000000000000000000000000000000"    --  3
     );
     --          1         2         3         4         5         6      
          --0123456789012345678901234567890123456789012345678901234567890123

   type coord is record  
      x, y, resp: integer;
   end record;
   
   constant N_SALAS: integer := 8;      -- there is 8 valid rooms
   constant MAX_TEST : integer :=18;    -- 18 tests will be applied 

   --- ROOMS'S SIZE - the third filed (expected answer) is not used
   type def_salas is array(0 to N_SALAS) of coord ;
   signal salas : def_salas := (  (0,0,0), (26,8,0), (10,3,0), (6,6,0), (11,20,0), (20,12,0), (5,5,0), (30,10,0),  (15,8,0) );
   -- CONV_STD_LOGIC_VECTOR( salas(cont_s).x ,6); ----> Exemplo de como conveter o valor para STD_LOGIC_VECTOR                                 
                                 
    -- coordinates for the tests -----------------------------------------------
   type room is array(0 to MAX_TEST-1) of coord ;                                 
   constant cc: room := (( 7, 8,1), (11, 8, 0), (21,11,2), (34,24,0), (53,20,3), (29,25,0),
                         ( 9,16,4), (15,39, 0), (38,39,5), (42,43,0), (16,45,6), (55,47,7), 
                         (42,58,0), (10,57, 8), (6,40, 0), (54,30,5), (22,45,0), (16,51,0) );

 begin

   dut:  entity work.ondeestou port map(clock=>clock, reset=>reset, 
                                       x=>x,  y=>y, achar=>achar, prog=>prog,
                                       address=>address, ponto=>ponto, 
                                       fim=>fim, sala=>sala);
                                       
   ponto <= mapa(conv_integer(address(11 downto 6)))(conv_integer(address(5 downto 0)));
   
   reset <= '1', '0' after 15 ns ;         

   clock <=  not clock after 5 ns;

   process
     variable cont, cont_s : integer := 0;
   begin
   
      -- espera 100 ns para começar a simulação
      if cont_s = 0 then
           wait for 100 ns;
      end if;
      
      if cont_s < N_SALAS+1 then
         -- envia o tamanho das salas para o circuito
         wait until clock'event and clock='0';
         prog <= '1';
         x <= CONV_STD_LOGIC_VECTOR( salas(cont_s).x ,6);          
         y <= CONV_STD_LOGIC_VECTOR( salas(cont_s).y ,6);          
         cont_s := cont_s + 1;
      else
         -- processo de teste! envio dos pares (x,y) e comapração com a resposta esperada!!
         wait for 100 ns;
         x <= CONV_STD_LOGIC_VECTOR( cc(cont).x ,6);          
         y <= CONV_STD_LOGIC_VECTOR( cc(cont).y ,6);
         wait for 20 ns;
         achar <= '1';
         wait for 20 ns;
         achar <= '0';
         wait;       
              
     end if;   
  end process;    
   
end teste;


