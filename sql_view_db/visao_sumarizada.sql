WITH TABELA_INICIAL AS (
    SELECT 
        vf.*,
        p.descricao,
        p.categoria,
        p.tipo,
        c.Descricao AS CANAL,
        c.Tipo_Canal,
        ROW_NUMBER() OVER (PARTITION BY vf.id_venda, ID_Cliente, p.ID_Produto ORDER BY vf.data_compra DESC) AS rn
    FROM workspace.default.burger_house_vendas_2025_final AS vf
    LEFT JOIN workspace.default.tabela_produtos p ON vf.ID_produto = p.ID_Produto
    LEFT JOIN workspace.default.canais_burguer_house c ON vf.ID_Canal = c.ID_Canal
)


 , RESUMO_MENSAL AS (
SELECT 
        Estado,
        Regiao,
        DATE_FORMAT(data_compra,'yyyy-MM') AS safra_compra,
        --o valor real é a quantidade de produto com valor
        ROUND(SUM(valor_produto * quantidade)/COUNT(DISTINCT Id_cliente),2) AS ticket_medio,
        ROUND(SUM(valor_produto * quantidade),0) AS total_compra,
        COUNT(id_venda) AS total_vendas
    FROM TABELA_INICIAL
    WHERE rn = 1
    GROUP BY ALL
),

 RESUMO_COM_LAG AS (
    SELECT
        Estado,
        Regiao,
        safra_compra,
        ticket_medio,
        total_compra,
        total_vendas,
        LAG(total_compra) OVER (PARTITION BY Estado ORDER BY safra_compra) AS total_mes_anterior
    FROM RESUMO_MENSAL
)

SELECT
    Estado,
    Regiao,
    safra_compra,
    ticket_medio,
    total_compra,
    total_vendas,
    total_mes_anterior,
    ROUND(((total_compra - total_mes_anterior)/total_mes_anterior)*100, 2) AS variacao_percentual
FROM RESUMO_COM_LAG
ORDER BY Estado, safra_compra;
