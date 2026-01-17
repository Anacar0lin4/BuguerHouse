import pandas as pd
import numpy as np
import random
from faker import Faker
from datetime import datetime, timedelta
import unidecode
fake = Faker('pt_BR')
# -------------------------
# Parâmetros
# -------------------------
n_total = 80000
n_blocos = 3
bloco = n_total // n_blocos
start_date = datetime(2025, 1, 1)
end_date = datetime(2025, 6, 30)
# -------------------------
# Tabelas de referência
# -------------------------
produtos = pd.DataFrame({
    'ID_Produto':[10001,10002,10003,10004,10005,20001,20002,20003,20004,20005,
                  30001,30002,30003,30004,40001,40002,40003,40004,50001,50002,50003,50004,50005,50006,50007],
    'Descricao':['Classic Burger','Bacon Deluxe','Chicken Crispy','Veggie Delight','Cheese Lover',
                 'Combo Classic','Combo Bacon Deluxe','Combo Chicken','Combo Veggie','Combo Cheese Lover',
                 'Family Classic','Family Bacon Deluxe','Party Mix','Veggie Family',
                 'Refrigerante 300ml','Agua 500ml','Shake pequeno','Suco natural 300ml',
                 'Batata frita pequena','Batata media','Batata grande','Molhos artesanais','Queijo extra','Bacon extra','Sobremedeira'],
    'Valor':[25,30,28,27,32,38,45,40,39,47,70,85,160,75,6,4,12,8,8,12,16,3,4,4,10],
    # Peso de venda ajustado para combos saírem mais
    'Peso':[0.05,0.05,0.05,0.05,0.05,0.12,0.12,0.12,0.12,0.12,
            0.06,0.06,0.03,0.03,0.02,0.02,0.01,0.01,0.04,0.04,0.03,0.03,0.01,0.01,0.01]
})
produtos['Peso'] /= produtos['Peso'].sum()  # normalizar
canais = pd.DataFrame({
    'ID_Canal':[4558,2893,3176,4921,1745,3862],
    'Descricao':['Plataforma propria / Site','iFood','Uber Eats','Rappi','Telefone','WhatsApp'],
    'Tipo':['Interno','Externo','Externo','Externo','Interno','Interno']
})
localidades = [
    ('Sao Paulo','SP','Sudeste', {'Sao Paulo':0.6,'Campinas':0.15,'Santos':0.15,'Ribeirao Preto':0.05,'Sao Jose dos Campos':0.05}),
    ('Rio de Janeiro','RJ','Sudeste',{'Rio de Janeiro':0.6,'Niteroi':0.2,'Nova Iguacu':0.15,'Petropolis':0.05}),
    ('Minas Gerais','MG','Sudeste',{'Belo Horizonte':0.6,'Uberlandia':0.2,'Contagem':0.15,'Juiz de Fora':0.05}),
    ('Espirito Santo','ES','Sudeste',{'Vitoria':1.0}),
    ('Parana','PR','Sul',{'Curitiba':0.6,'Londrina':0.2,'Maringa':0.2}),
    ('Santa Catarina','SC','Sul',{'Florianopolis':0.6,'Joinville':0.25,'Blumenau':0.15}),
    ('Rio Grande do Sul','RS','Sul',{'Porto Alegre':0.6,'Caxias do Sul':0.25,'Pelotas':0.15})
]
peso_estado = {'SP':0.45,'RJ':0.15,'MG':0.08,'ES':0.02,'PR':0.12,'SC':0.10,'RS':0.08}
peso_canal = [0.3,0.5,0.12,0.05,0.02,0.01]
meios_pagamento = ['Cartao de credito','Pix','Debito','Dinheiro']
peso_pagamento = [0.5,0.25,0.2,0.05]
def random_datetime(start, end):
    delta = end - start
    int_delta = delta.days*24*60*60 + delta.seconds
    return start + timedelta(seconds=random.randrange(int_delta))
# -------------------------
# Gerar clientes
# -------------------------
n_clientes = 30000
id_clientes = [fake.uuid4().replace('-','')[:12] for _ in range(n_clientes)]
nomes_clientes = [unidecode.unidecode(fake.name()) for _ in range(n_clientes)]
# -------------------------
# Função para gerar quantidade realista
# -------------------------
def gerar_quantidade(produto_id):
    if produto_id >= 20001 and produto_id <= 30004:  # combos/family
        return np.random.choice([1,2,3,4,5], p=[0.4,0.3,0.2,0.07,0.03])
    elif produto_id >= 50001 and produto_id <= 50007:  # extras
        return np.random.choice([1,2], p=[0.9,0.1])
    else:  # burgers individuais
        return np.random.choice([1,2,3], p=[0.6,0.3,0.1])
# -------------------------
# Gerar blocos
# -------------------------
for bloco_idx in range(n_blocos):
    registros = []
    for _ in range(bloco):
        idx_cliente = random.randint(0,n_clientes-1)
        cliente_id = id_clientes[idx_cliente]
        nome_cliente = nomes_clientes[idx_cliente]
        produto = np.random.choice(produtos['ID_Produto'], p=produtos['Peso'])
        valor = produtos.loc[produtos['ID_Produto']==produto,'Valor'].values[0]
        canal = np.random.choice(canais['ID_Canal'], p=peso_canal)
        pagamento = np.random.choice(meios_pagamento, p=peso_pagamento)
        estado_info = random.choices(localidades, weights=[peso_estado[loc[1]] for loc in localidades])[0]
        estado = estado_info[1]
        regiao = estado_info[2]
        cidade = random.choices(list(estado_info[3].keys()), weights=list(estado_info[3].values()))[0]
        quantidade = gerar_quantidade(produto)
        data_compra = random_datetime(start_date,end_date)
        data_str = data_compra.strftime("%d-%m-%Y %H:%M:%S")
        registros.append([cliente_id,nome_cliente,produto,valor,canal,pagamento,quantidade,data_str,cidade,estado,regiao])
    df = pd.DataFrame(registros, columns=['ID_Cliente','Nome_Cliente','ID_Produto','Valor_Produto',
                                          'ID_Canal','Meio_Pagamento','Quantidade','Data_Compra',
                                          'Cidade','Estado','Regiao'])
    df.insert(0,'ID_Venda',range(bloco_idx*bloco+1, bloco_idx*bloco+1 + len(df)))
    # Duplicidade/triplicidade
    df_final = pd.DataFrame()
    for idx in range(len(df)):
        linha = df.iloc[idx]
        rand_dup = random.choices([1,2,3], weights=[0.55,0.35,0.1])[0]
        for _ in range(rand_dup):
            nova_linha = linha.copy()
            dt = datetime.strptime(linha['Data_Compra'], "%d-%m-%Y %H:%M:%S")
            dt += timedelta(minutes=random.randint(0,59), seconds=random.randint(0,59))
            nova_linha['Data_Compra'] = dt.strftime("%d-%m-%Y %H:%M:%S")
            df_final = pd.concat([df_final, pd.DataFrame([nova_linha])], ignore_index=True)
    # Salvar CSV do bloco
    df_final.to_csv(f'/content/BurgerHouse_Vendas_2025_parte{bloco_idx+1}.csv', index=False)
    print(f"Bloco {bloco_idx+1} gerado: {len(df_final)} registros")
