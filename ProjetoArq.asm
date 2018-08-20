.data
ReadString:	.space 	16	#Nome do Posto
StructInfo:	.space	28	#Número dado em bytes: | Data-2 | QtdCombust�vel-2 | Pre�o-4 | Distancia-4 | NomePosto-16


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
	and $s7,$s7,$zero	#"Seta" $s7 para 0 pois este contar� quantos cadastros foram feitos	
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
	add $t3,$zero,$t1
	or $t1,$t1,$v0
	
	li $v0,4	#Recebe Pre�o do litro em $f0
	la $a0,Ins_Prec
	syscall
	li $v0,6
	syscall
	
	la $s4,ReadString
	
	beq $s7,$zero,InserePilha
	add $fp,$zero,$sp
	lh $t2,0($fp)
	ble $t3,$t2,InserePilha
	addi $fp,$fp,28
ProximaCelula:
	lh $t2,0($fp)
	addi $t4,$zero,7
	ble $t3,$t2,DeslocaCelula
	j InserePilha
	
DeslocaCelula:
	lw $t5,0($fp)
	sw $t5,-28($fp)
	addi $fp,$fp,4
	addi $t4,$t4,-1
	bne $t4,$zero,DeslocaCelula
	j ProximaCelula
	
InserePilha:	
	addi $sp,$sp,-28
	
	sw $t1,0($sp)	#Data e Qtd Comb. OK
	s.s $f0,4($sp)	#Pre�o do litro	OK
	sw $s1,8($sp)	#Km Atual	O
	addi $sp,$sp,0xc
	addi $t0,$zero,4
StoreWord:		#Nome do Posto
	lw $t1,0($s4)
	sw $t1,0($sp)
	addi $s4,$s4,4
	addi $sp,$sp,4
	addi $t0,$t0,-1
	bnez $t0,StoreWord
	
	addi $sp,$sp,-28
	addi $s7,$s7,1
		
	j Menu	
#------ Cadastro Abastecimento -------#		
	
#-------- Excluir Abstecimento -------#	
Exclui:
	jal RData
	bne $s7,$zero,ExcluiRealmente
	li $v0,4
	la $a0,SemReg
	syscall
	j Menu
ExcluiRealmente:
	
	
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
Exit:
	li $v0,17
	li $a0,0
	syscall
