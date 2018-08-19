.data

Cadastrar:      .asciiz "1. para cadastrar abastecimento;\n"
Excluir:        .asciiz "2. para excluir abastecimento;\n"
EAbastecimento: .asciiz "3. para exibir abastecimento;\n"
EConsumoMedio:  .asciiz "4. para consumo médio;\n"
EPrecoMedio:    .asciiz "5. para preço médio;\n\n"
DigiteOpcao:    .asciiz "Digite a opção desejada: "

Ins_Dia:	.asciiz "Insira o dia do abastecimento: "
Ins_Mes:	.asciiz "Insira o mes do abastecimento: "
Ins_Ano:	.asciiz "Insira o ano do abastecimento: "
Ins_Nome:	.asciiz "Insira o nome do posto: "
Ins_Qlmt:	.asciiz "Insira a quilometragem do carro: "
Ins_Qntd:	.asciiz "Insira a quantidade de combustivel: "
Ins_Prec:	.asciiz "Insira o preco por litro: "

.text
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

#--------- Opção Selecionada ---------#		
	li $v0, 5
	syscall
	
	addi $t1, $zero, 1
	beq $t1, $v0, Cadastro
	
	addi $t1, $zero, 2
	beq $t1, $v0, Exclui
	
	addi $t1, $zero, 3
	beq $t1, $v0, EAbastece
	
	addi $t1, $zero, 4
	beq $t1, $v0, EConsumo
	
	addi $t1, $zero, 5
	beq $t1, $v0, EMedio
	
	j Menu
	
#--------- Opção Selecionada ---------#	
	
#------ Cadastro Abastecimento -------#	
Cadastro:
#------ Cadastro Abastecimento -------#		
	
#-------- Excluir Abstecimento -------#	
Exclui:
#-------- Excluir Abstecimento -------#	

#--------- Exibe Abastecimento -------#	
EAbastece:
#--------- Exibe Abastecimento -------#	

#---------- Exibe Consumo ------------#	
EConsumo:
#---------- Exibe Consumo ------------#	

#-------- Exibe Preco Medio ----------#	
EMedio:
#-------- Exibe Preco Medio ----------#	

#------ Converte Data para EPOCH -----#
DateToEpoch: #DD em $a0 - MM em $a1 - AAAA em $a2
	addi $t1, $a1, -1 # Janeiro é mes 1
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
	addi $a1, $a1, 1 # Janeiro é mes 1
	
	jr $ra
#------ Converte EPOCH para Data -----#
	
Exit:
	
