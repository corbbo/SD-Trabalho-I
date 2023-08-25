---------------------------------------------------------------------------------------------------------
-- TRABALHO 1 - CIRCUITOS DIGITAIS
-- AUTHORS: 
-- DATE: 2/2023
---------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ondeestou is
   port (
      clock: in STD_LOGIC;
      reset: in STD_LOGIC;
      ---- interface para pedir localização
      x, y:   in STD_LOGIC_VECTOR (5 downto 0);
      achar:  in STD_LOGIC;
      prog:   in STD_LOGIC;
      ---- interface com a memória
      address:  out STD_LOGIC_VECTOR (11 downto 0);
      ponto:     in STD_LOGIC;
      ---- interface com o resultado da localização
      fim:     out STD_LOGIC;
      sala:    out STD_LOGIC_VECTOR (3 downto 0)
      ); 
end ondeestou;
 

architecture ondeestou of ondeestou is

  type coord is record
    x:    STD_LOGIC_VECTOR (5 downto 0);      
    y:    STD_LOGIC_VECTOR (5 downto 0);
  end record;
  --- definição do array para armazenar as coordenadas das salas 
  constant N_SALAS: integer := 8;
  type room is array(0 to N_SALAS) of coord ;
  signal salas : room ; 
  -- máquina de estados
  type states is ( IDLE, SALVA_POS, VERIF_PONTO, VERIF_N, FINAL);
  signal EA, PE: states;
  signal cont_sala : STD_LOGIC_VECTOR (3 downto 0);
  signal Xpos, Ypos : STD_LOGIC_VECTOR (5 downto 0);
begin
   ----  coordendas das salas ----------------------------------------------------------------
   process (reset, clock)
   begin
      if reset='1' then 
            cont_sala <= (others=>'0');
      elsif clock'event and clock='1' then
            if  prog='1' then
               salas(conv_integer(cont_sala)).x <= x;
               salas(conv_integer(cont_sala)).y <= y;
               if cont_sala<N_SALAS then
                     cont_sala <= cont_sala + 1;
               end if;
            end if;
      end if;
   end process;

   ---- acesso à memória externa ----------------------------------------------------------------------
   address <= Ypos & Xpos when EA = VERIF_PONTO else (others=>'0'); 

   ----  máquina de estados de controle ---------------------------------------------------------------
   process (reset, clock)
   begin
      if reset='1' then 
         EA <= IDLE;
      elsif clock'event and clock='1' then
         EA <= PE;
      end if;
   end process;

   ---- processo para definir o proximo estado --------------------------------------------------------
   process ( EA, achar )
   begin
      case EA is
         when IDLE =>
            IF achar = '1' THEN 
               PE <= SALVA_POS;
            ELSE 
               PE <= IDLE;
            END IF;

         when SALVA_POS =>
            PE <= VERIF_PONTO;
         
         when VERIF_PONTO =>
            IF ponto = '1' THEN
               PE <= FINAL;
            ELSE 
               PE <= VERIF_N;
            END IF;
         
         when VERIF_N =>
            PE <= VERIF_N;
         
         when FINAL =>
            PE <= IDLE;

         when others => 
            PE <= IDLE;
      end case;
   end process;
   
   ----  processo para controlar os registradores -----------------------------------------------------
   process (reset, clock)
   begin
      if reset='1' then
         Xpos <= (others=>'0');
         Ypos <= (others=>'0');
      elsif clock'event and clock='1' then
         if EA = SALVA_POS then
            Xpos <= x;
            Ypos <= y;
         end if;
         
      end if;
   end process;
   
   fim  <= '1' when EA = FINAL else '0';
   sala <= "0000" when EA = FINAL else (others=>'0');

 end ondeestou;
