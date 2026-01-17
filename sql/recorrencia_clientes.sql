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


 ,CLIENTE_MENSAL AS (
    SELECT 
        Id_cliente,
        Estado,
        Regiao,
        --usando esse agrupamento p complentar calculo abaixo
        DATE_FORMAT(data_compra,'yyyy-MM') AS safra_compra,
        --saber quantas vezeso cliente distintamente comprou no mes
        COUNT(DISTINCT id_venda) AS compras_mes
    FROM TABELA_INICIAL
    WHERE rn = 1
    GROUP BY ALL
)

-- Classificação de clientes por faixa de compras
, CLIENTE_FAIXA AS (
    SELECT 
        Id_cliente,
        Estado,
        Regiao,
        safra_compra,
        compras_mes,
        CASE 
            WHEN compras_mes BETWEEN 1 AND 2 THEN '1-2 vezes'
            WHEN compras_mes BETWEEN 3 AND 5 THEN '3-5 vezes'
            ELSE '+6 vezes'
        END AS faixa_frequencia
    FROM CLIENTE_MENSAL
)

-- Quantos clientes estão em cada faixa
SELECT 
    Estado,
    Regiao,
    safra_compra,
    faixa_frequencia,
    COUNT(DISTINCT Id_cliente) AS clientes
FROM CLIENTE_FAIXA
GROUP BY ALL
ORDER BY safra_compra, Estado, faixa_frequencia;
