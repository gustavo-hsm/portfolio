library(tidyverse)

#Configurando diret�rios
cur_dir = rstudioapi::getActiveProject()
input_dir = paste(cur_dir, 'input', sep = '/')

#Selecionando arquivos
files <- list.files(input_dir, '.csv')

#files[1] cliente_tabla.csv: Tabela com ID e nome de clientes
#files[2] producto_tabla.csv: Tabela com ID e nome de produtos
#files[3] sample_submission: Template de output para testar modelo preditivo no Kaggle
#files[4] test.csv: Dados para teste
#files[5] town_state.csv: Tabela com ID e nome de cidades e estados
#files[6] train.csv: Dados para treino
datasets = lapply(files, function(x){
  read_csv(paste(input_dir, x, sep = '/'), n_max = 100)
})

## Tabelas de jun��o
#Clientes
head(datasets[[1]], 20)
#Observando os primeiros registros, � poss�vel detectar algumas inconsist�ncias:
# * O cliente 4 est� duplicado.
# * Os clientes 0 e 2 possuem o mesmo nome. Isso significa que n�o podemos agrupar clientes pelo nome,
#dada a possibilidade de existir clientes hom�nimos
#� poss�vel que exista mais de um registro para o mesmo cliente

#Produtos
head(datasets[[2]], 20)
# * Os produtos parecem estar corretamente cadastrados. O ID 0 aparenta ser um registro gen�rico para produtos n�o identificados.
#Novos produtos n�o cadastrados nessa lista ser�o associado ao ID 0.
# * Cada produto possui informa��es extras em seu nome, como a quantidade de gramas e/ou a quantidade de pe�as.
#Extrair essa informa��o pode ser �til para medir o volume de itens solicitados

#Cidades
head(datasets[[5]], 20)
#Registro de cada distribuidora. Existe um ID prim�rio para cada ag�ncia de distribui��o e um ID secund�rio
#para cada cidade, representado pelo n�mero no texto.
#Cada cidade e ag�ncia est� associada a um estado.

## Dados dispon�veis para previs�o
#sample_submission
head(datasets[[3]], 20)
# Para cada ID no dataset de teste, � esperado um valor num�rico de Demanda

#Teste
head(datasets[[4]], 20)
#Descri��o das vari�veis dispon�veis para teste:
# * Semana: N�mero da semana no ano
# * Agencia_ID: ID da distribuidora, podendo ser associado ao dataset town_state.csv
# * Canal_ID: Meio de comunica��o utilizado entre cliente e distribuidora
# * Ruta_SAK: ID do percurso realizado entre a distribuidora e o cliente
# * Cleinte_ID: ID do cliente, podendo ser associado ao dataset cliente_tabla.csv
# * Producto_ID: ID do produto, podendo ser associado ao dataset producto_tabla.csv

#Treino
head(datasets[[6]], 20)
#Al�m dos dados de teste, temos dispon�vel os valores necess�rios para calcular as features do modelo preditivo:
# * Venta_uni_hoy: N�mero de vendas nesta semana
# * Venta_hoy: Valor financeiro obtido pelas vendas
# * Dev_uni_proxima: N�mero de devolu��es na pr�xima semana
# * Dev_proxima: Valor financeiro das devolu��es
# * Demanda_uni_equil: Vari�vel target, representando a Demanda ajustada (Venta_uni_hoy - Dev_uni_proxima)
#     * A Demanda prevista sempre ser� maior que zero.