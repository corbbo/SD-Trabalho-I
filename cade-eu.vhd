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
    room      :    out std_logic_vector(3 downto 0);
  );
end cade_eu;

architecture arq of cade_eu is
  type coord is record
  x:  std_logic_vector(5 downto 0);
  y:  std_logic_vector(5 downto 0);
  end record;
  constant N_ROOM: integer := 8;
  type ROOM is array(0 to N_ROOM) of coord;
  signal salas : ROOM;
begin
  
    
