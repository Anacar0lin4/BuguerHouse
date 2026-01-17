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

, TABELA_LIMPA AS (
    SELECT 
        DATE_FORMAT(data_compra,'yyyy-MM-dd') AS data_compra,
        DATE_FORMAT(data_compra,'yyyy-MM') AS safra,
        cidade,
        estado
    FROM TABELA_INICIAL 
    WHERE rn = 1
),

PEDIDOS_DIA AS (
SELECT 
        estado,
        cidade,
        safra,
        data_compra,
        COUNT(*) AS pedidos_dia
FROM TABELA_LIMPA
GROUP BY ALL
)


SELECT 
    safra,
    estado,
    cidade,
    ROUND(AVG(pedidos_dia),2) AS media_pedidos_diaria
FROM PEDIDOS_DIA
GROUP BY ALL
ORDER BY media_pedidos_diaria DESC;
