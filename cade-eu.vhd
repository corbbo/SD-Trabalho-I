library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.std_logic_arith.all;

entity cade_eu is
  port (
    clock     :    in  std_logic;
    reset     :    in  std_logic;
    x, y      :    in  std_logic_vector(5 downto 0);
    find      :    in  std_logic;
    prog      :    in  std_logic;
    point     :    in  std_logic;
    address   :    out std_logic_vector(11 downto 0);
    fin       :    out std_logic;
    room      :    out std_logic_vector(3 downto 0);
    -- saidas para uso explicito do testbench
    walls     :    out std_logic_vector(3 downto 0); -- has_wall
    estado    :    out std_logic_vector(4 downto 0); -- EA
    isroom    :    out std_logic;                     -- is_room
    deltax    :    out std_logic_vector(5 downto 0); -- coord_sala.x
    deltay    :    out std_logic_vector(5 downto 0)  -- coord_sala.y
  );
end cade_eu;

architecture arq of cade_eu is
  type coord is record
    x:  std_logic_vector(5 downto 0);
    y:  std_logic_vector(5 downto 0);
  end record;
  constant N_ROOM: integer := 8;
  signal ponto_de_teste, coord_XYMin, coord_XYMax, coord_sala: coord;
  type state is (
                init, idle, 
                search_down, search_up, search_left, search_right, 
                src_XMin, set_wall_srcXMin, src_YMin, set_wall_srcYMin, src_XMax, set_wall_srcXMax, src_YMax, set_wall_srcYMax, 
                retorno, set_room, final_test, room_n_check
                );
  signal EA, PE: state;
  signal is_room, is_end: std_logic;
  signal has_wall: std_logic_vector(3 downto 0);
  type ROOMS is array(0 to N_ROOM) of coord;
  signal salas : ROOMS;
  signal cont_sala, cont_sala2, final_answer : STD_LOGIC_VECTOR(3 downto 0);
begin
    address <= ponto_de_teste.y & ponto_de_teste.x when EA = search_up or EA = search_down or EA = search_left or EA = search_right
                                                        or EA = src_XMin or EA = src_XMax or EA = src_YMin or EA = src_YMax 
                                                   else y & x when EA = idle                                                
                                                   else x"000";

    room <= final_answer when final_answer /= "0000" else "0000";
    deltax <= coord_sala.x;
    deltay <= coord_sala.y;
    fin <= '1' when is_end = '1' else '0';

    -- saidas para uso explicito do testbench
    deltax <= coord_sala.x;
    deltay <= coord_sala.y;
    walls <= has_wall;
    isroom <= is_room;
    estado <= "00000" when EA = idle
                      else "00001" when EA = init
                      else "00010" when EA = search_up
                      else "00011" when EA = search_down
                      else "00100" when EA = search_left
                      else "00101" when EA = search_right
                      else "00110" when EA = src_XMin
                      else "00111" when EA = set_wall_srcXMin
                      else "01000" when EA = src_YMin
                      else "01001" when EA = set_wall_srcYMin
                      else "01010" when EA = src_XMax
                      else "01011" when EA = set_wall_srcXMax
                      else "01100" when EA = src_YMax
                      else "01101" when EA = set_wall_srcYMax
                      else "01110" when EA = retorno
                      else "01111" when EA = set_room
                      else "10000" when EA = final_test
                      else "10001" when EA = room_n_check
                      else "10010";

   -- registro de salas
   process (reset, clock)
   begin
      if reset='1' then 
            cont_sala <= (others=>'0');
            salas <= (others => (x => "000000", y => "000000"));
      elsif clock'event and clock='1' and cont_sala<N_ROOM then
            if  prog='1' then
               salas(conv_integer(cont_sala)).x <= x;
               salas(conv_integer(cont_sala)).y <= y;
               if cont_sala<N_ROOM then
                     cont_sala <= cont_sala + 1;
               end if;
            end if;
      end if;
   end process;

  -- FSM
  process(reset, clock)
  begin
    if reset = '1' then
        EA <= idle;
        is_room <= '0';
        has_wall <= "0000"; --UP , DOWN , LEFT , RIGHT
        ponto_de_teste.x <= "000000";
        ponto_de_teste.y <= "000000";
        coord_XYMin.x <= "000000";
        coord_XYMin.y <= "000000";
        coord_XYMax.x <= "000000";
        coord_XYMax.y <= "000000";
        coord_sala.x <= "000000";
        coord_sala.y <= "000000";
        cont_sala2 <= "0000";
        is_end <= '0';
        final_answer <= "0000";
    else if clock'event and clock = '1' then
        case EA is
            -- estado de inicializacao          
            when init                                 => ponto_de_teste.x <= x; -- pega o ponto que vai testar e coloca ele em coord.x
                                                         ponto_de_teste.y <= y; -- pega o ponto que vai testar e coloca ele em coord.y
                                                         cont_sala2 <= "0000";
                                                         final_answer <= "0000";
                                                         is_end <= '0';
                                                         is_room <= '0';
                                                         has_wall <= "0000";

            -- estado de busca para cima
            when search_up                            => ponto_de_teste.y <= ponto_de_teste.y + '1';
                                                         if point = '1' then
                                                            coord_XYMax.y <= ponto_de_teste.y; -- recebe coords maximas para teste em src_XMax
                                                            ponto_de_teste.y <= y; -- volta para o ponto inicial
                                                            has_wall(3) <= '1';
                                                         end if;

            -- estado de busca para baixo
            when search_down                          => ponto_de_teste.y <= ponto_de_teste.y - '1';
                                                         if point = '1' then
                                                            coord_XYMin.y <= ponto_de_teste.y; -- recebe coords minimas para teste em src_XMin
                                                            ponto_de_teste.y <= y; -- volta para o ponto inicial
                                                            has_wall(2) <= '1';
                                                         end if;

            -- estado de busca para direita
            when search_right                         => ponto_de_teste.x <= ponto_de_teste.x + '1';
                                                          if point = '1' then
                                                              coord_XYMax.x <= ponto_de_teste.x; -- recebe coords maximas para teste em src_YMax
                                                              ponto_de_teste.x <= x; -- volta para o ponto inicial
                                                              has_wall(1) <= '1';
                                                          end if;

            -- estado de busca para esquerda                                              
            when search_left                          => ponto_de_teste.x <= ponto_de_teste.x - '1';
                                                          if point = '1' then
                                                              coord_XYMin.x <= ponto_de_teste.x; -- recebe coords minimas para teste em src_YMin
                                                              ponto_de_teste.x <= x; -- volta para o ponto inicial
                                                              has_wall(0) <= '1';
                                                          end if;
            
            -- estado de verificação da parede inferior
            when src_XMin                             => ponto_de_teste.x <= ponto_de_teste.x + '1';

            -- estado de verificação da parede superior
            when src_XMax                             => ponto_de_teste.x <= ponto_de_teste.x - '1';

            -- estado de verificação da parede esquerda
            when src_YMin                             => ponto_de_teste.y <= ponto_de_teste.y + '1';

            -- estado de verificação da parede direita
            when src_YMax                             => ponto_de_teste.y <= ponto_de_teste.y - '1';

            -- estado de confirmação preliminar de sala
            when set_room                             =>  if has_wall = "1111" then -- se encontrou 4 possiveis paredes em todos os lados, talvez seja uma sala
                                                           is_room <= '1';
                                                           has_wall <= "0000";
                                                           ponto_de_teste.x <= coord_XYMin.x; -- recebe coords minimas para teste em src_XMin
                                                           ponto_de_teste.y <= coord_XYMin.y;
                                                          else
                                                           is_room <= '0';
                                                          end if;

            -- estado de setar a parede inferior                                                                                                             
            when set_wall_srcXMin                       => if is_room = '1' then -- se possivelmente for uma sala...                                                                        
                                                            has_wall(2) <= '1'; -- down
                                                            ponto_de_teste.x <= coord_XYMin.x; -- recebe coords minimas para teste em src_YMin
                                                            -- nao recebe coord_XYMin.y pois ja recebeu no set_room
                                                            is_room <= '0'; -- reset pois foi setado para '1' no fim dos searches para validar os proximos estados, voltara a ser '1' se no fim dos srcs has_wall for "1111"
                                                          end if;

            -- estado de setar a parede esquerda
            when set_wall_srcYMin                       => has_wall(1) <= '1'; -- left
                                                           ponto_de_teste.y <= coord_XYMax.y; -- recebe coords maximas para teste em src_XMax
                                                           ponto_de_teste.x <= coord_XYMax.x; 

            -- estado de setar a parede superior                                               
            when set_wall_srcXMax                       => has_wall(3) <= '1'; -- up
                                                           ponto_de_teste.x <= coord_XYMax.x; -- recebe coords maximas para teste em src_YMax
                                                           -- nao recebe coord_XYMax.y pois ja recebeu no set_wall_srcYMin

            -- estado de setar a parede direita
            when set_wall_srcYMax                       => has_wall(0) <= '1'; -- right

            -- estado de confirmação final da sala
            when final_test                             => if has_wall = "1111" then -- se todas as paredes foram continuas, é uma sala
                                                            is_room <= '1';
                                                            coord_sala.x <= coord_XYMax.x - coord_XYMin.x + '1'; -- determina largura da sala
                                                            coord_sala.y <= coord_XYMax.y - coord_XYMin.y + '1'; -- determina altura da sala
                                                           else
                                                            is_room <= '0'; -- caso contrario, não é uma sala
                                                           end if;

            -- estado de verificação do número da sala
            when room_n_check                           => if is_room = '1' and is_end = '0' then -- se depois de todos os checks ainda for uma sala, e não for o fim do programa...
                                                            if salas(conv_integer(cont_sala2)) = coord_sala then -- se a sala encontrada for igual a uma das salas registradas...
                                                                final_answer <= cont_sala2; -- retorna o numero da sala
                                                                is_end <= '1';
                                                            elsif cont_sala2 < N_ROOM then -- caso contrario, incrementa o index (cont_sala2)
                                                                cont_sala2 <= cont_sala2 + '1';
                                                            else -- se o index >= 8, encerra o programa
                                                                is_end <= '1';
                                                            end if;
                                                          end if;
                                                          
            -- estado de deu muito ruim em alguma coisa
            when others                               => null;
        end case;
      EA <= PE;
    end if;                                                             
  end if;
  end process;

  -- logica de estados
  process(EA, find, point, is_room, is_end)
  begin
    case EA is
      -- estado de inicializacao
      when init                           => PE <= search_up;
      
      -- estado ocioso
      when idle                           => if find = '1' 
                                              then PE <= init;
                                             else 
                                              PE <= idle;
                                             end if;

      -- estado de busca para baixo
      when search_down                    => if point = '1' then -- achou parede
                                              PE <= search_left;
                                              elsif point = '0' and ponto_de_teste.y = "000000" then -- se não achou uma parede e chegou no limite
                                                PE <= final_test;
                                              else -- se não achou uma parede e nem chegou no limite
                                                PE <= search_down;
                                             end if;

      -- estado de busca para cima
      when search_up                      => if point = '1' then -- achou parede
                                              PE <= search_down;
                                              elsif point = '0' and ponto_de_teste.y = "111111" then -- se não achou uma parede e chegou no limite
                                                PE <= final_test;
                                              else -- se não achou uma parede e nem chegou no limite
                                                PE <= search_up;
                                              end if;

      -- estado de busca para esquerda
      when search_left                    => if point = '1' then -- achou parede
                                              PE <= search_right;
                                              elsif point = '0' and ponto_de_teste.x = "000000" then -- se não achou uma parede e chegou no limite
                                                PE <= final_test;
                                              else -- se não achou uma parede e nem chegou no limite
                                                PE <= search_left;
                                             end if;

      -- estado de busca para direita
      when search_right                   => if point = '1' then
                                              PE <= set_room;
                                              elsif point = '0' and ponto_de_teste.x = "111111" then
                                                PE <= final_test;
                                              else
                                                PE <= search_right;
                                             end if;

      -- estado de verificação da parede inferior
      when src_XMin                       => if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x then
                                              PE <= src_XMin; -- enquanto for uma parede, continua no estado
                                              else
                                                PE <= set_wall_srcXMin; -- caso contrario vai para o estado de setar a parede
                                             end if;  

      -- estado de setar a parede inferior
      when set_wall_srcXMin               => PE <= src_YMin;

      -- estado de verificação da parede esquerda
      when src_YMin                       => if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMax.y then
                                              PE <= src_YMin;
                                              else
                                                PE <= set_wall_srcYMin;
                                             end if;

      -- estado de setar a parede esquerda
      when set_wall_srcYMin               => PE <= src_XMax;

      -- estado de verificação da parede superior
      when src_XMax                       => if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x then
                                              PE <= src_XMax;
                                              else
                                                PE <= set_wall_srcXMax;
                                             end if;

      -- estado de setar a parede superior  
      when set_wall_srcXMax               => PE <= src_YMax;

      -- estado de verificação da parede direita
      when src_YMax                       => if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMin.y then
                                              PE <= src_YMax;
                                              else
                                                PE <= set_wall_srcYMax;
                                             end if;

      -- estado de setar a parede direita
      when set_wall_srcYMax               => PE <= final_test;

      -- estado de confirmação preliminar de sala
      when set_room                       => PE <= src_XMin;

      -- estado de verificação do número da sala
      when room_n_check                   => if is_end = '0' and cont_sala2 < N_ROOM then
                                              PE <= room_n_check;
                                             else 
                                              PE <= idle;
                                             end if;

      -- estado de confirmação final da sala
      when final_test                     => PE <= room_n_check;

      -- estado de deu muito ruim em alguma coisa
      when others                         => PE <= idle;
    end case;
  end process;
end architecture arq;
