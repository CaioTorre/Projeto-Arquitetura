.data

Cadastrar:      .asciiz "1. para cadastrar abastecimento;\n"
Excluir:        .asciiz "2. para excluir abastecimento;\n"
EAbastecimento: .asciiz "3. para exibir abastecimento;\n"
EConsumoMedio:  .asciiz "4. para consumo médio;\n"
EPrecoMedio:    .asciiz "5. para preço médio;\n\n"
DigiteOpcao:    .asciiz "Digite a opção desejada: "

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

	
	
	
	
	