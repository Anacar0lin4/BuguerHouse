import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import calendar
# -------------------------
# Usar o CSV de vendas que você já gerou
# -------------------------
df_vendas = pd.read_csv('/content/BurgerHouse_Vendas_2025_parte1.csv')  # você pode concatenar todos os blocos se quiser
# Exemplo: df_vendas = pd.concat([pd.read_csv(f'/content/BurgerHouse_Vendas_2025_parte{i+1}.csv') for i in range(3)], ignore_index=True)
# -------------------------
# Parâmetros da avaliação
# -------------------------
percentual_avaliam = 0.68  # 68% dos clientes
notas = [1,2,3,4,5]
peso_notas = [0.1,0.15,0.35,0.3,0.1]  # média aproximada de 3-4
# -------------------------
# Selecionar vendas para avaliação
# -------------------------
n_avaliacoes = int(len(df_vendas) * percentual_avaliam)
df_avaliacoes = df_vendas.sample(n=n_avaliacoes, random_state=42).reset_index(drop=True)
# -------------------------
# Gerar notas e datas de avaliação
# -------------------------
avaliacoes = []
for idx, row in df_avaliacoes.iterrows():
    # Nota
    nota = random.choices(notas, weights=peso_notas)[0]
    # Data da avaliação no mesmo mês da compra
    dt_compra = datetime.strptime(row['Data_Compra'], "%d-%m-%Y %H:%M:%S")
    ultimo_dia = calendar.monthrange(dt_compra.year, dt_compra.month)[1]  # último dia do mês
    ultimo_dia_mes = datetime(dt_compra.year, dt_compra.month, ultimo_dia, 23, 59, 59)
    delta_segundos = int((ultimo_dia_mes - dt_compra).total_seconds())
    if delta_segundos < 0:
        delta_segundos = 0
    random_segundos = random.randint(0, delta_segundos)
    dt_avaliacao = dt_compra + timedelta(seconds=random_segundos)
    data_str = dt_avaliacao.strftime("%d-%m-%Y %H:%M:%S")
    avaliacoes.append([row['ID_Venda'], row['ID_Cliente'], nota, data_str])
# -------------------------
# Transformar em DataFrame e salvar CSV
# -------------------------
df_satisfacao = pd.DataFrame(avaliacoes, columns=['ID_Venda','ID_Cliente','Nota_Satisfacao','Data_Avaliacao'])
df_satisfacao.to_csv('/content/satisfacao_clientes.csv', index=False)
print(f"CSV gerado com sucesso: satisfacao_clientes.csv ({len(df_satisfacao)} registros)")

