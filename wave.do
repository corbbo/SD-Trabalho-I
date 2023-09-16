onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clock
add wave -noupdate /tb_ondeestou/clock
add wave -noupdate -divider Entradas
add wave -noupdate /tb_ondeestou/reset
add wave -noupdate /tb_ondeestou/achar
add wave -noupdate /tb_ondeestou/prog
add wave -noupdate /tb_ondeestou/x
add wave -noupdate /tb_ondeestou/y
add wave -noupdate /tb_ondeestou/salas
add wave -noupdate /tb_ondeestou/cc
add wave -noupdate /tb_ondeestou/mapa
add wave -noupdate -divider Saidas
add wave -noupdate /tb_ondeestou/fim
add wave -noupdate /tb_ondeestou/ponto
add wave -noupdate /tb_ondeestou/address
add wave -noupdate -divider Sala
add wave -noupdate -color Orange -radix decimal -radixshowbase 0 /tb_ondeestou/sala
add wave -noupdate -divider Signals
add wave -noupdate -color {Medium Blue} /tb_ondeestou/walls
add wave -noupdate -color {Medium Blue} /tb_ondeestou/estado
add wave -noupdate -color {Medium Blue} /tb_ondeestou/isroom
add wave -noupdate -color {Cornflower Blue} -radix decimal -radixshowbase 0 /tb_ondeestou/deltax
add wave -noupdate -color {Cornflower Blue} -radix decimal -radixshowbase 0 /tb_ondeestou/deltay
add wave -noupdate -divider Constantes
add wave -noupdate -color {Medium Slate Blue} /tb_ondeestou/N_SALAS
add wave -noupdate -color {Medium Slate Blue} /tb_ondeestou/MAX_TEST
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13856 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
configure wave -valuecolwidth 355
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1346 ns}
