.data
ReadString:	.space 	16	#Nome do Posto
StructInfo:	.space	32	#Número dado em bytes: | Data-2 | QtdCombust?vel-2 | Pre?o-4 | Distancia-4 | NomePosto-16 | PonteiroProx-4

#Declaração de strings
Cadastrar:      .asciiz "\n1.Cadastrar abastecimento;\n" 
Excluir:        .asciiz "2.Excluir abastecimento;\n"
EAbastecimento: .asciiz "3.Exibir abastecimento;\n"
EConsumoMedio:  .asciiz "4.Consumo médio;\n"
EPrecoMedio:    .asciiz "5.Preço médio;\n"
SairProg:	.asciiz "6.Sair\n\n"

DigiteOpcao:    .asciiz "Digite a opção desejada: "

Ins_Dia:	.asciiz "Insira o dia do abastecimento: "
Ins_Mes:	.asciiz "Insira o mes do abastecimento: "
Ins_Ano:	.asciiz "Insira o ano do abastecimento: "
Ins_Nome:	.asciiz "Insira o nome do posto: "
Ins_Qlmt:	.asciiz "Insira a quilometragem do carro: "
Ins_Qntd:	.asciiz "Insira a quantidade de combustivel: "
Ins_Prec:	.asciiz "Insira o preco por litro: "


EncontradoReg:  .asciiz "O registro foi excluido com sucesso! \n"
SemReg:		.asciiz "Nenhum registro foi encontrado! \n"

ExibePorData:	.asciiz "Lista de abastecimentos:\n"

Kms:		.asciiz " Km"
Litros:		.asciiz " Litros"


Consumo:	.asciiz "Consumo médio:    "
SemRegConsumo:	.asciiz "Não há registros que indiquem algum consumo, retornando ao menu...\n"
KmL:		.asciiz " Km/L"

ReaisPorLitro:  .asciiz " R$/L"

Reais:		.asciiz "R$ "

Separacao:      .asciiz " | "
Barra:		.asciiz "/"
Espaco:		.asciiz " "
Ponto:		.asciiz "."
FimDeLinha:	.asciiz "\n"
Zero:		.asciiz "0"

Ex_Qlmt:	.asciiz "Quilometragem: "
MenuNomePreco:	.asciiz "  | Nome do Posto    | Preço Médio\n"
.text
main:

#----------- Inicializando -----------#
	#subi $sp, $sp, -28 
	divu $sp, $sp, 32
	mulu $sp, $sp, 32

	and $s7,$s7,$zero	#"Seta" $s7 para 0 pois este contar? quantos cadastros foram feitos	
	add $fp,$sp,$zero	#Escreve o valor maximo da pilha em FP
	#lui $s6,0x1004

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
	
	la $a0, SairProg
	syscall
	
	la $a0, DigiteOpcao
	syscall

#------------ Exibir Menu ------------#	

#--------- Op??o Selecionada ---------#		
	li $v0, 5
	syscall
	
	beq $v0,1,Cadastro
	beq $v0,6,Exit
	bne $s6,$zero,StartOpcao
	li $v0,4
	la $a0,SemReg
	syscall
	j  Menu
StartOpcao:

	beq $v0,2,Exclui
	beq $v0,3,EAbastece
	beq $v0,4,EConsumo
	beq $v0,5,EMedio
		
	j  Menu
	
#--------- Opção Selecionada ---------#	

#------ Cadastro Abastecimento -------#	
Cadastro:
	jal RData	
	add $t1,$zero,$v0 # $t1 det?m do valor da EPOCH

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
	
	li $v0,4	#Recebe Quantidade de combust?vel em upper($s0)

	la $a0,Ins_Qntd
	syscall
	li $v0,5
	syscall
	sll $v0,$v0,16
	or $t1,$t1,$v0
	
	li $v0,4	#Recebe Pre?o do litro em $f0

	la $a0,Ins_Prec
	syscall
	li $v0,6
	syscall
	
	la $s4,ReadString
	
	#addi $sp,$sp,-28

	#jal malloc
	addi $a0, $zero, 8
	jal nalloc
	
	add $t7,$v0,$zero #current pointer in t7
	
	sw $t1,0($v0)	#Data e Qtd Comb. OK
	s.s $f0,4($v0)	#Pre?o do litro	OK
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

	#Start of linked list insertion
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

	#ponteiro inicial $s6 
	#$s7 qtd registros
	
	#$t1 valor da data digitado em EPOCH
	#$t2 valor da data na lista ligada
	#$t3 Ponteiro anterior
	#$t4 ->prox do item excluido
	#t5 ponteiro da lista
	#$t6 decrementador
	
Exclui:
	jal RData	
	add $t1,$zero,$v0 # valor da EPOCH em $t1
	
	add $t5, $s6, $zero # Ponteiro da lista em $t5
	add $t6, $s7, $zero # Quantidade de registros em $t6
	beq $t6, $zero, MsgSemReg
	
	
	lh $t2, 0($t5)	# Carrega a data da lista
	la $t3, ($t5)
	beq $t1, $t2, ExcluiPrimeiroElemento
	addi $t6, $t6, -1
	
LoopProcuraData:
	beq $t6, $zero, MsgSemReg
	
	addi $t5, $t5, 28 # Avança pra prosição do ponteiro
	addi $t6, $t6, -1
	lw $t5, 0($t5) # Proximo elento da lista
	
	lh $t2, 0($t5)	# Carrega a data da lista
	beq $t1, $t2, ExcluiRealmente
	la $t3, ($t5)
	
	bne $t1, $t2, LoopProcuraData

MsgSemReg:	
	li $v0, 4
	la $a0, SemReg
	syscall
	j FimExclui

MsgEncontradoReg:	
	li $v0, 4
	la $a0, EncontradoReg
	syscall
	j FimExclui

ExcluiPrimeiroElemento:
	sw $zero, 0($t5)
	lw $t3, 28($t5)
	add $s6, $t3, $zero
	addi $s7, $s7, -1
	j MsgEncontradoReg
			
ExcluiRealmente:	
	
	sw $zero, 0($t5)
	lw $t4, 28($t5)
	sw $t4, 28($t3)
	
	addi $s7, $s7, -1
	j MsgEncontradoReg	
	
FimExclui:
	j Menu
#-------- Excluir Abstecimento -------#	

#--------- Exibe Abastecimento -------#	
EAbastece: # FORMAT <DD>/<MM>/<AAAA> | <INT>Km | <INT> litros (<FLOAT> R$/l) | Posto <posto>
	#Número dado em bytes: | Data-2 | QtdCombust?vel-2 | Pre?o-4 | Distancia-4 | NomePosto-16 | PonteiroProx-4
	#ponteiro inicial $s6 
	#$s7 qtd registros
	#t5 ponteiro da lista
	#$t6 decrementador
	#$t7 contador de registro
	
	li $v0,4	#Recebe Nome do Posto no Addr. ReadString
	la $a0, ExibePorData
	syscall
	
	add $t5, $s6, $zero
	
	
	addi $t7, $zero, 1	
	add $t6, $s7, $zero
	
LoopExibe:
	beq $t6, $zero, FimExibe 
	
	
	li $v0, 1
	add $a0, $t7, $zero

	syscall		    #exibe o indice
	jal PrintaPonto
	jal PrintaEspaco
	
	lh $v0, 0($t5)
	#and $v0, $v0, 65535
	jal EpochToDate     #pega a data e desconverte do epoc
	

	add $t0, $a0, $zero
	jal IdentaData
	add $a0, $t0, $zero

	li $v0, 1
	syscall             #printa dia
	jal PrintaBarra
	
	add $a0, $a1, $zero
	add $t0, $a1, $zero
	jal IdentaData
	add $a0, $t0, $zero
	li $v0, 1

	syscall             #printa mes
	jal PrintaBarra
	
	li $v0, 1
	add $a0, $a2, $zero
	syscall             #printa ano
	
	jal PrintaSeparacao
	
	addi $t5, $t5, 2
	
	lh $a0, 0($t5)

	add $t3, $a0, $zero
	add $t4, $a0, $zero
	jal identacaoCombustivel
	add $a0, $t4, $zero

	li $v0, 1
	syscall		    #printa qtd combustivel
	
	jal PrintaLitros
	jal PrintaSeparacao
	
	addi $t5, $t5, 2
	
	lwc1 $f12, 0($t5)
	li $v0, 2
	syscall		    #printa preco
	
	jal PrintaReaisPorLitro
	jal PrintaSeparacao
	
	addi $t5, $t5, 4
	
	lw $a0, 0($t5)

	add $t0, $a0, $zero
	add $t1, $a0, $zero
	jal IdentaDistancia
	add $a0, $t1, $zero

	li $v0, 1
	syscall		   #printa distancia
	
	jal PrintaKm
	jal PrintaSeparacao
	
	addi $t5, $t5, 4
	
	la $a0, ($t5)
	li $v0, 4
	syscall
	
	#jal PrintaFimDeLinha
	
	addi $t5, $t5, 16
	lw $t5, 0($t5)
	addi $t6, $t6, -1
	addi $t7, $t7,  1
	
	j LoopExibe

FimExibe:
	j Menu 
	
PrintaEspaco:
	li $v0, 4
	la $a0, Espaco
	syscall
	jr $ra
	
PrintaBarra:
	li $v0, 4
	la $a0, Barra
	syscall
	jr $ra
	
PrintaPonto:
	li $v0, 4
	la $a0, Ponto
	syscall
	jr $ra
	
PrintaSeparacao:
	li $v0, 4
	la $a0, Separacao
	syscall
	jr $ra
	
PrintaLitros:
	li $v0, 4
	la $a0, Litros
	syscall
	jr $ra
	
PrintaReaisPorLitro:
	li $v0, 4
	la $a0, ReaisPorLitro
	syscall
	jr $ra
	
PrintaKm:
	li $v0, 4
	la $a0, Kms
	syscall
	jr $ra
	
PrintaFimDeLinha:
	li $v0, 4
	la $a0, FimDeLinha
	syscall	
	jr $ra

identacaoCombustivel:
	div $t0, $t3, 100
	bne $t0, $zero, Identado
	li $v0, 4
	la $a0, Zero
	syscall
	mul $t3, $t3, 10	
	
	j identacaoCombustivel	
 
Identado:
 	jr $ra
 	
IdentaData:
	div $t1, $t0, 10
	bne $t1, $zero, Identadoo
	li $v0, 4
	la $a0, Zero
	syscall
Identadoo:
	jr $ra
	
IdentaDistancia:
	div $t2, $t0, 10000
	bne $t2, $zero, Identadooo
	li $v0, 4
	la $a0, Zero
	syscall
	mul $t0, $t0, 10
	j IdentaDistancia
	
Identadooo:
	jr $ra
#--------- Exibe Abastecimento -------#	

#---------- Exibe Consumo ------------#	
EConsumo:
	add $t0, $s6, $zero
	add $t4, $zero, $zero
	add $t2, $zero, $zero
	
	bne $t0, $zero, LConsumo
	
	mtc1 $t0, $f0
  	cvt.s.w $f0, $f0
	add.s $f12, $f0, $f0
	li $v0, 2
	syscall	
	
	j    Menu
	
	LConsumo:
		
	lh  $t1, 2($t0)
	add $t2, $t2, $t1		#salva a quantidade de combustivel
	
	lw  $t3, 8($t0)
	add $t4, $zero, $t3		#salva Km
	
	add $t1, $zero, $t0
	lw  $t0, 28($t0)
	bne $t0, $zero, LConsumo
	
	lh  $t0, 2($t1)
	sub $t2, $t2, $t0
	add $t0, $zero, $s6
	lw  $t3, 8($t0)
	sub $t4, $t4, $t3
	
	beq $t4, $zero, SemConsumo
	
	mtc1 $t4, $f0
  	cvt.s.w $f0, $f0
  	mtc1 $t2, $f1
  	cvt.s.w $f1, $f1
	div.s $f12, $f0, $f1
	
	li $v0, 4
	la $a0, Consumo
	syscall
	
	li $v0, 2
	syscall
	
	li $v0, 4
	la $a0, KmL
	syscall
	
	jal PrintaFimDeLinha
	j Menu
	
SemConsumo:
	li $v0, 4
	la $a0, SemRegConsumo
	syscall
	
	j Menu	
#---------- Exibe Consumo ------------#
	
#-------- Exibe Preco Medio ----------#	
EMedio:	#$t0 - reg. temp. para percorrer lista; $t1 - reg. para guardar string temp.; $t3 - inicio pilha; $t4 - quantidade em pilha; $t5 - temp. para receber word; $f31 - preço temp.
	#Data Format, bytes - | val medio - 4 | freq - 4 | nome - 16 | sigma preços - 4|
	add $t0,$s6,$zero
	add $fp,$sp,$zero
	add $t4,$zero,$zero
	add $t3,$sp,$zero
	la $t1,ReadString
	
ReadNewEntry:	#Lê nova entrada
	l.s $f31,4($t0)
	addi $t0,$t0,12
	addi $t2,$zero,4	#$t2 - neste caso, para contar 1 word
	
CarregaStringEMedio:
	lw $t5,0($t0)
	sw $t5,0($t1)
	addi $t0,$t0,4
	addi $t1,$t1,4
	addi $t2,$t2,-1
	bne $t2,$zero,CarregaStringEMedio
	addi $t1,$t1,-16
	
	beq $t3,$sp,AnotherEntry
	add $fp,$zero,$t3	#$fp recebe o endereço do inicio da pilha
	la $a0,($t1)
CheckNameEMedio:	#Procura se há ocorrencia da palavra então carregada
	la $a1,-24($fp)
	jal cmpstr
	addi $fp,$fp,-28
	bne $v0,$zero,IncrementEntry
	beq $fp,$sp,AnotherEntry
	j CheckNameEMedio
	
IncrementEntry:		#Contabiliza novos resultados daquela palavra
	l.s $f30,0($fp)
	add.s  $f31,$f31,$f30
	s.s $f31,0($fp)
	lw $t2,20($fp)
	addi $t2,$t2,1
	sw $t2,20($fp)
	mtc1 $t2,$f30	#Move $t2 para COPROCESSOR 1 (FLU-floating point unit)
	cvt.s.w $f30,$f30 #Move os 32-bit inteiros da direita para um ponto flutuante (reg. esquerda)
	div.s $f31,$f31,$f30
	s.s $f31,24($fp)
	j PrepareToReadNewEntry
	
AnotherEntry:		#Nova palavra, novo espaço na pilha...
	addi $sp,$sp,-28	#libera 28 bytes
	s.s $f31,0($sp)
	addi $fp,$fp,-24	#pos 24
	addi $t2,$zero,4	#$t2 - para contar 4 words
StoreFirstEMedio:
	lw $t5,0($t1)
	sw $t5,0($fp)
	addi $fp,$fp,4
	addi $t1,$t1,4
	addi $t2,$t2,-1
	bne $t2,$zero,StoreFirstEMedio
	addi $t1,$t1,-16
	
	addi $t2,$zero,1	#pos 8 e $t2 - "seta" frequencia
	sw $t2,0($fp)
	addi $fp,$fp,4		#pos 4 - guarda valor medio atual
	s.s $f31,0($fp)		
	add $t4,$t4,1
	#$lw $t2,-4($fp)
	#l.s $f31,-24($fp)
	#div.s 
	#sw $f31,0($fp)	
	
PrepareToReadNewEntry:		#Vamos para o próximo cadastro...
	lw $t2,0($t0)		#$t2 = end. do prox
	beq $t2,$zero,ExitEMedio
	add $t0,$t2,$zero
	j ReadNewEntry
	
ExitEMedio:
	#Todo processo de imprimir em decrescente e entao voltar para o menu
	add $a0,$zero,$t3	#inicio da pilha em $a0
	add $a1,$zero,$t4	#quantidade de infos da pilha em $a1
	
	jal BSort
	#$v0 - inicio da pilha; $v1 - quantidade de infos
	#$t0 - comparador de \n; $t1 - reg. para guardar string temp.; $s5 - inicio da pilha; $t5 - temp. contador de null; $t6 - recebe bytes; $t7 - contador de índice.
	#Data Format, bytes - | val medio - 4 | freq - 4 | nome - 16 | sigma preços - 4|
	add $s5,$zero,$v0
	
	li  $v0, 4
	la $a0, MenuNomePreco
	syscall
	
	addi $t7,$zero,1
	la $t1,ReadString
LoopPrintEMEdio:
	li $v0, 1
	add $a0, $t7, $zero
	syscall		    #exibe o indice
	jal PrintaSeparacao

	addi $t2,$zero,16	#numero de repetiçoes do loop abaixo
	add $t5,$zero,$zero	#contador de null
	addi $t0,$zero,10	#comparador de \n
	addi $sp,$sp,4	
LoopPrintNomePostoEMEdio:
	lb $t6,0($sp)
	bne $t6,$t0,ContinueStoringEMedio
	add $t6,$zero,$zero
ContinueStoringEMedio:
	sb $t6,0($t1)
	addi $t1,$t1,1
	addi $sp,$sp,1
	addi $t2,$t2,-1
	bne $t6,$zero,DontCountNullEMedio
	addi $t5,$t5,1
DontCountNullEMedio:
	bne $t2,$zero,LoopPrintNomePostoEMEdio
	
	addi $t1,$t1,-16
	addi $sp,$sp,4
	
	li $v0,4
	add $a0,$t1,$zero
	syscall
	
AligningTextEMedio:
	jal PrintaEspaco
	addi $t5,$t5,-1
	bne $t5,$zero,AligningTextEMedio
	
	jal PrintaSeparacao
	
	li $v0,4
	la $a0,Reais
	syscall
	
	l.s $f12,0($sp)
	li $v0,2
	syscall
	addi $sp,$sp,4
	
	jal PrintaFimDeLinha
	
	addi $t7,$t7,1
	bne $sp,$s5,LoopPrintEMEdio
	j Menu 
#-------- Exibe Preco Medio ----------#	

#------ Converte Data para EPOCH -----#
DateToEpoch: #DD em $a0 - MM em $a1 - AAAA em $a2
	addi $t1, $a1, -1 # Janeiro ? mes 1
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
	addi $a1, $a1, 1 # Janeiro ? mes 1
	
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
	
	li $v0,4	#Recebe M?s em $a1

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

#------------- new malloc ------------#
nalloc:
	lui  $t0, 0x1004	#Start search at the beginning of heap
_next:	lw   $t2, 0($t0)
	beq  $t2, $zero, _found	#If found zeroed-out position, check for contiguous
	addi $t0, $t0, 32
	j _next
_found:
	add $v0, $t0, $zero
	#addi $t0, $t0, 4	#Check next for continuity
	jr $ra
#------------- new malloc ------------#

#--------------- cmpstr --------------#
cmpstr:	#$a0 - End. String 1, $a1 - End. String 2
	lb $t6,0($a0)
	lb $t7,0($a1)
	
	bne $t6,$t7,cmpstrExitFalse
	beq $t6,$zero,cmpstrExitTrue
	
	addi $a0,$a0,1
	addi $a1,$a1,1
	
	j cmpstr
cmpstrExitTrue:
	addi $v0,$zero,1	#Retorna 1 caso a string seja igual
	jr $ra
cmpstrExitFalse:
	add $v0,$zero,$zero	#Retorna 0 caso a string seja diferente
	jr $ra	
#--------------- cmpstr --------------#

#--------------- BBSort --------------#
#$a0 - inicio pilha; $a1 - n infos;
#compare floating point number:
#c.eq.s fs,ft (compare if fs is equal to ft)
#bc1t LABEL (if true branch to the LABEL)
BSort:
	add $t6, $a0, $zero # save $a0 into $t6
	add $t5, $a1, $zero # save $a1 into $t5
	addi $t7, $zero,1 # i = 1
for1tst: 
	slt $t0, $t7, $t5 # $t0 = 0 if $t7 ? $t5 (i ? n)
	beq $t0, $zero, exit1 # go to exit1 if $t7 ? $t5 (i ? n)
	addi $s1,$t7,-1  # j = i – 1
for2tst: 
	slti $t0, $s1, 0 # $t0 = 1 if $s1 < 0 (j < 0)
	bne $t0, $zero, exit2 # go to exit2 if $s1 < 0 (j < 0)
	mulu $t1, $s1, 28 # $t1 = j * 28
	sub $t2, $t6, $t1 # $t2 = v - (j * 28)
	l.s $f4, -4($t2) # $f4 = v[j]
	l.s $f5, -32($t2) # $f5 = v[j + 1]
	c.lt.s $f5,$f4 # flag 0 = false if $f5 ? $f4
	bc1f exit2 # go to exit2 if $f5 ? $f4
	
	add $a0,$zero,$t6 # 1st param of swap is v (old $a0)
	add $a1,$zero,$s1 # 2nd param of swap is j
	j BSortSwap # call swap procedure
ReturnBSortSwap:
	addi $s1,$s1,-1 # j –= 1
	j for2tst # jump to test of inner loop
exit2: 
	addi $t7, $t7, 1 # i += 1
	j for1tst # jump to test of outer loop
exit1:
	add $v0,$zero,$t6
	add $v1,$zero,$t5
	jr $ra

BSortSwap: 	#trocar posições!
	addi $a1,$a1,1
	mulu $t1, $a1, 28	# $t1 = k * 4
	sub $t1, $a0, $t1	# $t1 = v-(k*4)(address of v[k])
	addi $t4, $zero, 7
	
BSortLoopSwap:
	lw $t0, 0($t1) 		# $t0 (temp) = v[k]
	lw $t2, -28($t1) 		# $t2 = v[k+1]
	sw $t2, 0($t1) 		# v[k] = $t2 (v[k+1])
	sw $t0, -28($t1) 		# v[k+1] = $t0 (temp)
	addi $t1,$t1,4
	addi $t4,$t4,-1
	bne $t4,$zero,BSortLoopSwap
	j ReturnBSortSwap
#--------------- BBsort --------------#

Exit:
	li $v0,17
	li $a0,0
	syscall
