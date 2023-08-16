library IEEE;
use IEEE.std_logic.all;
use IEEE.std_logic_vector.all;

entity cade_eu is
  port (
    clock     :    in  std_logic;
    reset     :    in  std_logic;
    x, y      :    in  std_logic_vector(5 downto 0);
    find      :    in  std_logic;
    prog      :    in  std_logic;
    point     :    in  std_logic;
    address   :    out std_logic_vector(11 downto 0);
    finish    :    out std_logic;
    room      :    out std_logic_vector(3 downto 0)
  );
end cade_eu;

architecture arq of cade_eu is
  type coord is record
    x:  std_logic_vector(5 downto 0);
    y:  std_logic_vector(5 downto 0);
  end record;
  constant N_ROOM: integer := 8;
  signal ponto_de_teste: coord;
  type state is (init, idle, search_down, search_up, search_left, search_right, src_X0, src_Y0, src_X1, src_Y1, retorno);
  signal EA, PE: state;
  signal is_room: std_logic;
  signal has_wall: std_logic_vector(3 downto 0);
  type ROOM is array(0 to N_ROOM) of coord;
  signal salas : ROOM;
begin
  -- FSM
  process(reset, clock)
  begin
    if reset = '1' then
      EA <= idle;
      is_room <= '0';
      has_wall <= "0000";
      room <= "0000";
      address <= x"00";
      finish <= '0';
    else if clock'event and clock = '1' then
      EA <= PE;
    end if;
  end process;
  -- logica de estados
  process(EA, find, prog)
  begin
    case EA is
      when idle =>  if prog = '1' then
                      PE <= init;
                    else PE <= idle;

      when init =>  
      when 
    
