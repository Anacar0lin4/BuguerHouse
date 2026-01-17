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
    LEFT JOIN workspace.default.tabela_produtos p 
        ON vf.ID_produto = p.ID_Produto
    LEFT JOIN workspace.default.canais_burguer_house c 
        ON vf.ID_Canal = c.ID_Canal
),
RESUMO_MENSAL AS (
    SELECT 
        ti.Estado,
        ti.Regiao,
        ti.categoria,
        DATE_FORMAT(ti.data_compra,'yyyy-MM') AS safra_compra,
        ROUND(SUM(ti.valor_produto * ti.quantidade)/COUNT(DISTINCT ti.Id_cliente),2) AS ticket_medio,
        ROUND(SUM(ti.valor_produto * ti.quantidade),0) AS total_compra,
        COUNT(ti.id_venda) AS total_vendas,
        ROUND(AVG(sc.Nota_satisfacao),2) AS media_satisfacao
    FROM TABELA_INICIAL ti
    LEFT JOIN workspace.default.satisfacao_clientes sc ON ti.ID_Cliente = sc.ID_CLIENTE
    AND DATE_FORMAT(ti.data_compra,'yyyy-MM') = DATE_FORMAT(sc.DATA_AVALIACAO,'yyyy-MM')
    WHERE rn = 1
    GROUP BY ALL
),
RESUMO_COM_LAG AS (
    SELECT 
        Estado,
        Regiao,
        categoria,
        safra_compra,
        ticket_medio,
        total_compra,
        total_vendas,
        media_satisfacao,
        LAG(total_compra) OVER (PARTITION BY Estado ORDER BY safra_compra) AS total_mes_anterior
    FROM RESUMO_MENSAL
)
SELECT 
    Estado,
    Regiao,
    categoria,
    safra_compra,
    ticket_medio,
    total_compra,
    total_vendas,
    media_satisfacao,
    total_mes_anterior,
    ROUND(((total_compra - total_mes_anterior)/total_mes_anterior)*100, 2) AS variacao_percentual
FROM RESUMO_COM_LAG
ORDER BY Estado, safra_compra;
