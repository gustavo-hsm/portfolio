library(tidyverse)

#Configurando diret�rios
cur_dir = rstudioapi::getActiveProject()
input_dir = paste(cur_dir, 'input/', sep = '/')

#Selecionando arquivos
files <- list.files(input_dir, '[^zip_files]')
# cliente_tabla - Tabela de Clientes
# producto_tabla - Tabela de produtos
# sample_submission - Template a ser enviado ao Kaggle
# test - Dataset de teste
# town_state - Tabela de fornecedores e suas respectivas cidades e estados de atua��o no M�xico
# train - Dataset de treino

#Carregando dataset
datasets <- lapply(paste(input_dir, files, sep = ''), read_csv, n_max = 100000)
View(datasets)

#Procurando valores NA
lapply(datasets, function(x){sum(is.na(x))})
#Todos os inputs est�o devidamente preenchidos

#Observando os datasets carregados
mapply(glimpse, datasets)
# * Clientes - Todos os clientes cadastrados est�o nessa tabela
# * Produtos - Todos os produtos fornecidos tamb�m est�o nessa tabela. Entretanto, percebi que o
#primeiro registro (Producto_ID 0, "NO IDENTIFICADO") parece ser um item gen�rico. Isso pode sugerir
#que o ID zero na verdade representa poss�veis valores NA
# * Cidades - Todos os fornecedores e suas respectivas cidades e estados est�o cadastrados aqui
# * Test/Train - Os dados a serem processados. 
#Dados que existem � disposi��o para o modelo preditivo:
# Semana: n�mero da semana do ano, sugerindo que as entregas de produtos s�o semanais e n�o di�rias
# Agencia_ID: ID do fornecedor que atende aquele cliente
# Canal_ID: ?
# Ruta_SAK: ?
# Cliente_ID: ID do cliente solicitante
# Producto_ID: ID do produto solicitado
#
#Dados adicionais dispon�veis no dataset de treino para o algoritmo aprender as correla��es entre os campos acima
# Venta_uni_hoy: Quantidade de itens vendidos
# Venta_hoy: Valor monet�rio obtido pelas vendas
# Dev_uni_proxima: Quantidade de itens a serem devolvidos na semana seguinte (n�o vendidos)
# Dev_proxima: Valor monet�rio das devolu��es
# **Demanda_uni_equil: Demanda ajustada pelo produto: vari�vel target a ser prevista**
#
#Meu objetivo neste projeto � prever as demandas por produtos de cada cliente,
#buscando maximizar as vendas (Venta_uni) e minimizar as devolu��es (Dev_uni).

#### Observando as ocorr�ncias em que os IDs de clientes e produtos s�o zero ####
##Premissa: Novos clientes e novos produtos ainda n�o existentes nos datasets ser�o
#Visualizar poss�veis ocorr�ncias de ID zero nas colunas de cliente e produto nos datasets de treino e teste
library(data.table)
lapply(list(files[[4]], files[[6]]), function(x){
  zeroId <- fread(input = paste(input_dir, x, sep = ''), select = c('Semana','Cliente_ID','Producto_ID'))
  print(zeroId[Cliente_ID == 0])
  print(zeroId[Producto_ID == 0])
})

#N�o foram encontradas ocorr�ncias dos IDs zero nos datasets de treino e teste, sugerindo que:
# * Todos os produtos solicitados e fornecidos podem ser localizados
# * Todos os clientes atendidos est�o registrados
rm(zeroId)

#### Compreendendo os campos Canal_ID e Ruta_SAK ####
canal_rutaSak <- lapply(list(files[[4]], files[[6]]), function(x){
  fread(input = paste(input_dir, x, sep = ''), select = c('Semana','Canal_ID', 'Ruta_SAK'))
})
mapply(summary, canal_rutaSak)
#Os campos Canal_ID e Ruta_SAK representam identificadores que eu n�o pude associar intuitivamente
#A descri��o destes campos na competi��o do Kaggle diz o seguinte:
# * Canal_ID: Sales Channel ID
# * Ruta_SAK: Route ID (Several routes = Sales Depot)
# A maioria das ocorr�ncias de Canal_ID s�o '1', sugerindo um meio de comunica��o abrangente entre os clientes e a empresa
# As ocorr�ncias de Ruta_SAK s�o bastante variadas
rm(canal_rutaSak)

#### Conclus�es e pr�ximas etapas ####
#Esse projeto possui um grande volume de dados que est�o muito bem normalizados, sendo poss�vel realizar
#diversos cruzamentos e extrair insights interessantes.
#
#A pr�xima etapa ser� realizar uma an�lise mais profunda nestes dados e suas correla��es. Algumas id�ias que quero tentar implementar
# * Demanda por produtos em "m�ltiplos n�veis": estadual (estado), regional (cidade), local (cliente)
#Insights que quero extrair
# * Demanda por produtos por "tipo" de semana: pares/�mpares e m�ltiplas de 4 (assumindo quatro semanas por m�s).
# * Demanda por produtos por rota percorrida