.data
ReadString:	.space 	16	#Nome do Posto
StructInfo:	.space	32	#Número dado em bytes: | Data-2 | QtdCombust�vel-2 | Pre�o-4 | Distancia-4 | NomePosto-16 | PonteiroProx-4

#Declaração de strings
Cadastrar:      .asciiz "\n1.Cadastrar abastecimento;\n" 
Excluir:        .asciiz "2.Excluir abastecimento;\n"
EAbastecimento: .asciiz "3.Exibir abastecimento;\n"
EConsumoMedio:  .asciiz "4.Consumo médio;\n"
EPrecoMedio:    .asciiz "5.Preço médio;\n\n"
DigiteOpcao:    .asciiz "Digite a opção desejada: "

Ins_Dia:	.asciiz "Insira o dia do abastecimento: "
Ins_Mes:	.asciiz "Insira o mes do abastecimento: "
Ins_Ano:	.asciiz "Insira o ano do abastecimento: "
Ins_Nome:	.asciiz "Insira o nome do posto: "
Ins_Qlmt:	.asciiz "Insira a quilometragem do carro: "
Ins_Qntd:	.asciiz "Insira a quantidade de combustivel: "
Ins_Prec:	.asciiz "Insira o preco por litro: "

SemReg:		.asciiz "Não há registro de abastecimento, retornando ao menu...\n"

Ex_Qlmt:	.asciiz "Quilometragem: "
.text
#----------- Inicializando -----------#
	#subi $sp, $sp, -28 
	divu $sp, $sp, 32
	mulu $sp, $sp, 32
	and $s7,$s7,$zero	#"Seta" $s7 para 0 pois este contar� quantos cadastros foram feitos	
	add $fp,$sp,$zero	#Escreve o valor maximo da pilha em FP
	add $s6,$zero,$zero	#O ponteiro inicial será guardado em $s6
#------------ Exibir Menu ------------#
Menu:
	li  $v0, 4
	la $a0, Cadastrar
	syscall
	
	la $a0, Excluir
	syscall
	
	la $a0, EAbastecimento
	syscall
	
	la $a0, EConsumoMedio
	syscall
	
	la $a0, EPrecoMedio
	syscall
	
	la $a0, DigiteOpcao
	syscall

#------------ Exibir Menu ------------#	

#--------- Op��o Selecionada ---------#		
	li $v0, 5
	syscall
	
	beq $v0,1,Cadastro
	beq $v0,2,Exclui
	beq $v0,3,EAbastece
	beq $v0,4,EConsumo
	beq $v0,5,EMedio
		
	j  Menu
	
#--------- Op��o Selecionada ---------#	
	
#------ Cadastro Abastecimento -------#	
Cadastro:
	jal RData	
	add $t1,$zero,$v0 # $t1 det�m do valor da EPOCH
	
	li $v0,4	#Recebe Nome do Posto no Addr. ReadString
	la $a0,Ins_Nome
	syscall
	li $v0,8
	la $a0,ReadString
	li $a1,16
	syscall
	
	li $v0,4	#Recebe Quilometragem em $s1
	la $a0,Ins_Qlmt
	syscall
	li $v0,5
	syscall
	add $s1,$zero,$v0
	
	li $v0,4	#Recebe Quantidade de combust�vel em upper($s0)
	la $a0,Ins_Qntd
	syscall
	li $v0,5
	syscall
	sll $v0,$v0,16
	or $t1,$t1,$v0
	
	li $v0,4	#Recebe Pre�o do litro em $f0
	la $a0,Ins_Prec
	syscall
	li $v0,6
	syscall
	
	la $s4,ReadString
	
	#addi $sp,$sp,-28
	jal malloc
	add $t7,$v0,$zero #current pointer in t7
	
	sw $t1,0($v0)	#Data e Qtd Comb. OK
	s.s $f0,4($v0)	#Pre�o do litro	OK
	sw $s1,8($v0)	#Km Atual	O
	addi $v0,$v0,0xc
	addi $t0,$zero,4
StoreWord:		#Nome do Posto
	lw $t1,0($s4)
	sw $t1,0($v0)
	addi $s4,$s4,4
	addi $v0,$v0,4
	addi $t0,$t0,-1
	bnez $t0,StoreWord
	
	add  $v0, $t7, $zero
	beq  $s7, $zero, emptyList #if list is empty
	
	
	
	lw   $t4, 0($v0) #store current item epoch
	andi $t4, $t4, 65535 #crop epoch data ???
	lw   $t1, 0($s6) 
	andi $t1, $t1, 65535 #crop epoch data ???
	
	slt  $t3, $t4, $t1 #t3 = 1 if first data < new data
	bne  $t3, $zero, emptyList
	
	add  $t0, $s6, $zero	#Pega inicio da lista ligada
findNext:
	lw   $t2, 28($t0) #t2 is current->next
	beq  $t2, $zero, exitFindNext
	
	lw   $t1, 0($t2) #t1 is current->next->data
	andi $t1, $t1, 65535 #crop epoch data ???
	
	slt  $t3, $t1, $t4 #t3 is 1 if current->next->data < new data
	beq  $t3, $zero, exitFindNext
	
	add  $t0, $t2, $zero #keep walking along list
	j findNext
exitFindNext:
	sw   $t2, 28($v0) #new node -> next = current -> next
	sw   $v0, 28($t0) #current -> next = current addr
	j doneAdding
	
emptyList:
	sw  $s6,28($v0) #new node -> next = old pointer
	add $s6, $v0, $zero #old pointer = new node addr
	#j doneAdding
	
	#sw $zero,0($v0) #Ponteiro "seta prox"
	#addi $sp,$sp,-32
doneAdding:
	addi $s7,$s7,1
		
	j Menu	
#------ Cadastro Abastecimento -------#		
	
#-------- Excluir Abstecimento -------#	
Exclui:
	add $t0,$fp,-64
	sw $zero,0($t0)
	j Menu
	#jal RData
	#bne $s7,$zero,ExcluiRealmente
	#li $v0,4
	#la $a0,SemReg
	#syscall
	#j Menu
#ExcluiRealmente:
	
	
#-------- Excluir Abstecimento -------#	

#--------- Exibe Abastecimento -------#	
EAbastece: # FORMAT <DD>/<MM>/<AAAA> | <INT>Km | <INT> litros (<FLOAT> R$/l) | Posto <posto>
	jal RData
	addi $t0, $sp, -28
TryNxt:	addi $t0, $t0, 28
	lw  $t1, 0($t0)
	sll $t1, $t1, 16
	srl $t1, $t1, 16 # Crop EPOCH data
	bne $v0, $t0, TryNxt 
	
	li  $v0, 4
	la  $a0, Ex_Qlmt
	syscall
	li  $v0, 1
	lw  $a0, 8($s0)
	syscall
	
	j Menu
No_Val:	
	
	j Menu
#--------- Exibe Abastecimento -------#	

#---------- Exibe Consumo ------------#	
EConsumo:
#---------- Exibe Consumo ------------#	

#-------- Exibe Preco Medio ----------#	
EMedio:
#-------- Exibe Preco Medio ----------#	

#------ Converte Data para EPOCH -----#
DateToEpoch: #DD em $a0 - MM em $a1 - AAAA em $a2
	addi $t1, $a1, -1 # Janeiro � mes 1
	mul  $t1, $t1, 30
	
	addi $t2, $a2, -2000 # EPOCH em 2000
	mul  $t2, $t2, 360
	
	add  $v0, $t2, $t1
	add  $v0, $v0, $a0 # Result em $v0
	
	jr $ra
#------ Converte Data para EPOCH -----#
	
#------ Converte EPOCH para Data -----#
EpochToDate: #EPOCH em $v0
	div  $a2, $v0, 360 # Parte inteira em $a2 (ano)
	mul  $t0, $a2, 360
	sub  $t0, $v0, $t0 # Resto em $t0 (mes e dia)

	div  $a1, $t0, 30 # parte inteira em $a1 (mes)
	mul  $t1, $a1, 30
	sub  $a0, $t0, $t1 # Resto em $a0 (dia)

	addi $a2, $a2, 2000 # EPOCH em 2000
	addi $a1, $a1, 1 # Janeiro � mes 1
	
	jr $ra
#------ Converte EPOCH para Data -----#
#------------ Recebe data ------------#
RData:	
	li $v0,4	#Recebe Dia em $a0
	la $a0,Ins_Dia
	syscall
	li $v0,5
	syscall
	add $t7,$zero,$v0
	
	li $v0,4	#Recebe M�s em $a1
	la $a0,Ins_Mes
	syscall
	li $v0,5
	syscall
	add $t6,$zero,$v0
	
	li $v0,4	#Recebe Ano em $a2
	la $a0,Ins_Ano
	syscall
	li $v0,5
	syscall
	add $t5,$zero,$v0
	
	add $a0,$zero,$t7
	add $a1,$zero,$t6
	add $a2,$zero,$t5
	
	add $t4,$zero,$ra
	jal DateToEpoch
	
	jr $t4
#------------ Recebe data ------------#

#--------------- malloc --------------#
malloc:
	add  $t3, $fp, $zero
	add  $t0, $sp, $zero
	#add  $t0, $sp, 32	#$t0 will move through stack

	#slt  $t2, $t0, $t3	#	check if we dont try to find an invalid position
	#beq  $t2, $zero, blowup	#	then try next block
	
next:	lw   $t2, 0($t0)
	beq  $t2, $zero, found	#if current block is empty
	addi $t0, $t0, 32	#	else will check next block
	
	slt  $t2, $t0, $t3	#	check if we dont try to find an invalid position
	bne  $t2, $zero, next	#	then try next block
	
blowup:	addi $v0, $sp, -32	#		else just add a new position at the top of stack
	addi $sp, $sp, -32
	jr   $ra

found:	add  $v0, $t0, $zero	#return current pointer
	jr   $ra
#--------------- malloc --------------#

Exit:
	li $v0,17
	li $a0,0
	syscall
