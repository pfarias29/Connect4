.data

.include "../images_jogo/amarelo.data"		#36x26
.include "../images_jogo/vermelho.data"	#36x26
.include "../images_jogo/seta.data"		#16x16
.include "../images_jogo/tabuleiro.data"	#320x240

checa_peca:	.word 0
peca:		.word 0			#0 = amarelo, 1 = vermelho
posicao_inicial:.word 2, 2
coluna_peca:	.word 0
linha_peca:	.word 0
vetor_peca:	.word 0, 0
vetor_tab:	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
endereco_seta:	.word 12, 0		#coluna, linha


.text
	li s0, 0xff0			#s0 = frame usado(0)
	slli s0, s0, 20
	la a0, tabuleiro
	
	lw s1, 0(a0)			#320
	lw s2, 4(a0)			#240
	addi a0, a0, 8
	
	li t0, 0			#colunas
	li t1, 0			#linhas
PRINT_TAB: 				#printa o tabuleiro na tela
	lw t2, 0(a0)
	sw t2, 0(s0)
	
	addi t1, t1, 4
	addi a0, a0, 4	
	addi s0, s0, 4
	
	bne t1, s1, PRINT_TAB
	
	li t1, 0
	addi t0, t0, 1
	
	bne t0, s2, PRINT_TAB
		
JOGO: 					#prepara para começar o jogo
	
	li s0, 0xff0
	slli s0, s0, 20
	la a0, seta
	
	call PRINT_SETA
	
LOOP_JOGO:				#loop que o jogo vai estar
	li t1,0xFF200000		# carrega o endereço de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,FIM   	   	# Se não há tecla pressionada então vai para FIM
  	lw t2,4(t1)  			# le o valor da tecla tecla
	j MOVE_SETA
	  			
FIM:	ret				# retorna


PRINT_SETA:				#prepara informações para printar a seta
	la a1, endereco_seta
	
	lw t0, 0(a1)
	add s0, s0, t0

	lw s1, 0(a0)
	lw s2, 4(a0)
	addi a0, a0, 8
	
	li t0, 0
	li t1, 0
	
LOOP_SETA:				#printa a seta		
	lw t2, 0(a0)
	sw t2, 0(s0)
	
	addi t1, t1, 4
	addi a0, a0, 4
	addi s0, s0, 4
	
	beq t1, s1, RESET_SETA
	j LOOP_SETA
	
RESET_SETA:				#muda a linha do display
	li t1, 0
	addi t0, t0, 1
	
	addi s0, s0, 320
	sub s0, s0, s1
	
	blt t0, s2, LOOP_SETA
	ret

MOVE_SETA:				#move seta para esquerda ou direita
	li t0, 'a'
	beq t0, t2, ESQ
	
	li t0, 'd'
	beq t0, t2, DIR
	
	li t0, 'p'
	beq t0, t2, COLOCA_PECA_COLUNA
	j LOOP_JOGO
	
DIR:					#move para a direita
	li t0, 292			#limite na direita
	la a0, endereco_seta
	lw s1, 0(a0) 		
	beq s1, t0, LOOP_JOGO
	
	la a0, posicao_inicial
	lw t0, 0(a0)
	addi t0, t0, 36			#move a peça para a esquerda
	sw t0, 0(a0)
	
	la a0, coluna_peca		#é somado no vetor_tab
	lw t0, 0(a0)
	addi t0, t0, 32
	sw t0, 0(a0)
	
	la a0, vetor_peca		#8x8
	lw t0, 0(a0)
	addi t0, t0, 1
	sw t0, 0(a0)
	
	addi s2, s1, 40 		#nova posição seta
	li s0, 0xff0
	slli s0, s0, 20
	
	la a0, tabuleiro
	addi a0, a0, 8
	
	add a0, a0, s1
	add s0, s0, s1
	
	li s1, 16 			#s1 = colunas da seta (quadrado => linhas = coluna)
	li t0, 0
	li t1, 0
	

PRINT_PARTE_TAB:			#apaga a seta anterior
	lw t2, 0(a0)
	sw t2, 0(s0)
	
	addi t1, t1, 4
	addi s0, s0, 4
	addi a0, a0, 4
	
	bne s1, t1, PRINT_PARTE_TAB


	li t1, 0
	addi t0, t0, 1
	
	addi s0, s0, 320
	addi a0, a0, 320
	sub s0, s0, s1
	sub a0, a0, s1
	
	bne t0, s1, PRINT_PARTE_TAB
	
	la s1, endereco_seta
	sw s2, 0(s1)
	j JOGO
	
ESQ:					#move para a esquerda
	li t0, 12			#limite na esquerda
	la a0, endereco_seta
	lw s1, 0(a0) 			#s1 = colunas da seta (quadrado => linhas = colunas)
	beq s1, t0, LOOP_JOGO
	
	la a0, posicao_inicial
	lw t0, 0(a0)
	addi t0, t0, -36		#move a peça para a esquerda
	sw t0, 0(a0)
	
	la a0, coluna_peca
	lw t0, 0(a0)
	addi t0, t0, -32
	sw t0, 0(a0)
	
	la a0, vetor_peca
	lw t0, 0(a0)
	addi t0, t0, -1
	sw t0, 0(a0)
	
	addi s2, s1, -40 		#nova posição seta
	li s0, 0xff0
	slli s0, s0, 20
	
	la a0, tabuleiro
	addi a0, a0, 8
	

	add s0, s0, s1
	add a0, a0, s1
	
	
	li s1, 16
	li t0, 0
	li t1, 0
	
	j PRINT_PARTE_TAB	
	
COLOCA_PECA_COLUNA:
	la a0, vetor_tab
	la a1, coluna_peca
	lw t0, 0(a1)
	
	add a0, a0, t0
  
  	li t0, 7
  	la a1, vetor_peca
  	la a2, linha_peca
  	li t2, 28
  	add a0, a0, t2
  	
COLOCA_PECA_LINHA:
	sw t0, 4(a1)
	sw t2, 0(a2)
	
	lw t1, 0(a0)
	beqz t1, ESCOLHE_COR
	
	addi t0, t0, -1
	addi t2, t2, -4
	addi a0, a0, -4
	bgez t2, COLOCA_PECA_LINHA	
	j JOGO

COLOCA_AMARELA:
	li t0, 1
	sw t0, 0(a0)
	j COLOCA_PECA
	
COLOCA_VERMELHA:
	li t0, 2
	sw t0, 0(a0)
	j COLOCA_PECA		
				
ESCOLHE_COR:	
	la a1, peca
	lw t0, 0(a1)
	beqz t0, COLOCA_AMARELA
	j COLOCA_VERMELHA
	
COLOCA_PECA:	
	li s0, 0xff0			
	slli s0, s0, 20
	addi s0, s0, 642		#320 + 320 + 2
	la a0, vetor_peca
	lw t0, 0(a0)
	li t1, 36
	mul t0, t0, t1
	li t1, 4
	lw t2, 0(a0)
	mul t1, t2, t1
	add t0, t1, t0
	add s0, s0, t0
	
	la a0, posicao_inicial
	sw t0, 0(a0)
	
	la a0, peca
	lw t0, 0(a0)
	beqz t0, AMARELO
	j VERMELHO
	
AMARELO:
	la a0, amarelo
	lw s1, 0(a0)
	lw s2, 4(a0)
	li t0, 0
	li t1, 0
	addi a0, a0, 8
	
	j PRINT_PECA
	
VERMELHO:

	la a0, vermelho
	lw s1, 0(a0)
	lw s2, 4(a0)
	li t0, 0
	li t1, 0
	addi a0, a0 8
	
PRINT_PECA:
	lh t2, 0(a0)
	sh t2, 0(s0)
	
	addi t1, t1, 2
	addi s0, s0, 2
	addi a0, a0, 2
	
	bne s1, t1, PRINT_PECA


	li t1, 0
	addi t0, t0, 1
	
	addi s0, s0, 320
	sub s0, s0, s1
	
	bne t0, s2, PRINT_PECA
	
CHECA_PECA:				#checa se a peça chegou no final
	la a1, vetor_peca
	lw t0, 4(a1)
	la a2, checa_peca
	lw t1, 0(a2)	
	beq t0, t1, TROCA_PECA
	
ANDA_PECA:
	call APAGA_PECA
	
	li a7, 32
	li a0, 25
	ecall
	
	la a2, checa_peca
	lw t1, 0(a2)
	addi t1, t1, 1
	sw t1, 0(a2)
	
	la a0, peca
	lw t0, 0(a0)
	beqz t0, AMARELO
	j VERMELHO
	
APAGA_PECA:
	li s0, 0xff0			
	slli s0, s0, 20
	addi s0, s0, 642
	
	la a1, vetor_peca
	lw t0, 0(a1)
	li t1, 36
	mul t0, t0, t1
	li t1, 4
	lw t2, 0(a1)
	mul t1, t2, t1
	add t0, t1, t0
	add s0, s0, t0
	
	la a1, posicao_inicial
	lw, t0, 4(a1)
	li t1, 320
	mul t0, t1, t0
	add t0, t1, t0
	add s0, t0, s0 
	
	la a0, tabuleiro
	addi a0, a0, 8
	addi a0, a0, 642
		
	la a1, vetor_peca
	lw t0, 0(a1)
	li t1, 36
	mul t0, t0, t1
	li t1, 4
	lw t2, 0(a1)
	mul t1, t2, t1
	add t0, t1, t0
	add a0, a0, t0
	
	la a1, posicao_inicial
	lw, t0, 4(a1)
	li t1, 320
	mul t0, t1, t0
	add t0, t1, t0
	add a0, t0, a0
	
	li t0, 0
	li t1, 0
	
APAGA_PECA2:			#apaga a peca anterior
	lh t2, 0(a0)
	sh t2, 0(s0)
	
	addi t1, t1, 2
	addi s0, s0, 2
	addi a0, a0, 2
	
	bne s1, t1, APAGA_PECA2


	li t1, 0
	addi t0, t0, 1
	
	addi s0, s0, 320
	addi a0, a0, 320
	sub s0, s0, s1
	sub a0, a0, s1
	
	bne t0, s1, APAGA_PECA2
	
	la a0, posicao_inicial
	lw t0, 4(a0)
	addi t0, t0, 26
	
	la a1, checa_peca
	lw t1, 0(a1)
	li t2, 1
	mul t1, t2, t1
	add t0, t0, t1
	
	sw t0, 4(a0)
	ret

TROCA_PECA:
	j CHECA_VITORIA_LINHA
RET_PECA:
	la a0, peca
	lw t0, 0(a0)
	bnez t0, TROCA_AMARELO
	li t0, 1
	sw t0, 0(a0)
	
	la a0, checa_peca
	sw zero, 0(a0)
	
	la a0, posicao_inicial
	li t0, 2
	sw t0, 0(a0)
	sw t0, 4(a0)
	
	#se não é igual a amarelo, então é a vez do computador
	
	rdtime t0
	li t1, 7
	rem t0, t0, t1
	
	la a0, posicao_inicial
	li t2, 36
	lw t1, 0(a0)
	mul t2, t2, t0
	add t1, t1, t2
	sw t1, 0(a0)
	
	la a0, coluna_peca
	li t2, 32
	mul t1, t2, t0
	sw t1, 0(a0)
	
	la a0, vetor_peca
	sw t0, 0(a0)
	
	j COLOCA_PECA_COLUNA
	

	la a1, endereco_seta
	lw t0, 0(a1)
	
	li s0, 0xff0
	slli s0, s0, 20
	
	la a0, tabuleiro
	addi a0, a0, 8
	
	add a0, a0, t0
	add s0, s0, t0
	
	li s1, 16
	li t0, 0
	li t1, 0
REINICIA_SETA:	
	lw t2, 0(a0)
	sw t2, 0(s0)
	
	addi t1, t1, 4
	addi s0, s0, 4
	addi a0, a0, 4
	
	bne s1, t1, REINICIA_SETA


	li t1, 0
	addi t0, t0, 1
	
	addi s0, s0, 320
	addi a0, a0, 320
	sub s0, s0, s1
	sub a0, a0, s1
	
	bne t0, s1, REINICIA_SETA
	
	la s1, endereco_seta
	li t0, 12
	sw t0, 0(s1)
	
	la s1, posicao_inicial
	li t0, 2
	sw t0, 0(s1)
	sw t0, 4(s1)
	
	la s1, coluna_peca
	sw zero, 0(s1)
	
	la s1, linha_peca
	sw zero, 0(s1)
	
	la s1, vetor_peca
	sw zero, 0(s1)
	sw zero, 4(s1)
	
	la a0, posicao_inicial
	li t0, 2
	sw t0, 0(a0)
	sw t0, 4(a0)
	
	
	j JOGO
TROCA_AMARELO:
	sw zero, 0(a0)
	
	la a0, checa_peca
	sw zero, 0(a0)
	
	la a1, endereco_seta
	lw t0, 0(a1)
	
	li s0, 0xff0
	slli s0, s0, 20
	
	la a0, tabuleiro
	addi a0, a0, 8
	
	add a0, a0, t0
	add s0, s0, t0
	
	li s1, 16
	li t0, 0
	li t1, 0
	
	j REINICIA_SETA

CHECA_VITORIA_LINHA: 
	la a0, vetor_tab
	li s4, 0			#contador de linhas
	li s5, 0			#contador de colunas
	
TESTA_LINHA1:
	li t0, 5
	bge s4, t0, RESETA_LINHA

	lw t0, 0(a0)
	bnez t0, TESTA_LINHA2
	
	addi s4, s4, 1
	addi a0, a0, 4
	beqz zero, TESTA_LINHA1
	
TESTA_LINHA2:
	lw s6, 0(a0)			#cor que estava no primeiro
	lw t0, 4(a0)
	
	beq s6, t0, TESTA_LINHA3
	
	addi s4, s4, 2
	addi a0, a0, 8
	beqz zero, TESTA_LINHA1

TESTA_LINHA3:
	lw t0, 8(a0)
	
	beq s6, t0, TESTA_LINHA4
	
	addi s4, s4, 3
	addi a0, a0, 12
	beqz zero, TESTA_LINHA1

TESTA_LINHA4:
	lw t0, 12(a0)
	
	beq s6, t0, FIM_JOGO
	
	addi s4, s4, 4
	addi a0, a0, 16
	beqz zero, TESTA_LINHA1
	
RESETA_LINHA:
	li t0, 7
	bge s5, t0, CHECA_VITORIA_COLUNA
	
	mv s4, zero
	addi s5, s5, 1
	
	#li t1, 32
	#la a0, vetor_tab
	#mul t1, t1, s5
	#add a0, a0, s5
	addi a0, a0, 12
	
	beqz zero, TESTA_LINHA1
	
CHECA_VITORIA_COLUNA:
	la a0, vetor_tab
	li s4, 0			#contador de linhas
	li s5, 0			#contador de colunas
	
TESTA_COLUNA1:
	li t0, 5
	bge s5, t0, RESETA_COLUNA

	lw t0, 0(a0)
	bnez t0, TESTA_COLUNA2
	
	addi s5, s5, 1
	addi a0, a0, 32
	beqz zero, TESTA_COLUNA1

TESTA_COLUNA2:
	lw s6, 0(a0)			#cor que estava no primeiro	
	lw t0, 32(a0)
	
	beq s6, t0, TESTA_COLUNA3
	
	addi s5, s5, 2
	addi a0, a0, 64
	beqz zero, TESTA_COLUNA1

TESTA_COLUNA3:
	lw t0, 64(a0)
	
	beq s6, t0, TESTA_COLUNA4
	
	addi s5, s5, 3
	addi a0, a0, 96
	beqz zero, TESTA_COLUNA1
	
TESTA_COLUNA4:
	lw t0, 96(a0)
	
	beq s6, t0, FIM_JOGO
	
	addi s5, s5, 4
	addi a0, a0, 128
	beqz zero, TESTA_COLUNA1

RESETA_COLUNA:
	li t0, 7
	bge s4, t0, RET_PECA
	
	mv s5, zero
	addi s4, s4 1
	
	li t0, 4
	mul t0, t0, s4
	la a0, vetor_tab
	add a0, a0, t0
	
	beqz zero, TESTA_COLUNA1

FIM_JOGO:
	li t0, 1
	beq t0, s6 AMARELA_GANHOU
	j VERMELHA_GANHOU
	
AMARELA_GANHOU:
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0x7F7F7F7F	# cor vermelho|vermelho|vermelhor|vermelho
	
	j LOOP_VITORIA
	
VERMELHA_GANHOU:
	
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho

LOOP_VITORIA:
 	beq t1,t2,FORA		# Se for o último endereço então sai do loop
	sw t3,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	j LOOP_VITORIA	

FORA:
	li a7, 10
	ecall