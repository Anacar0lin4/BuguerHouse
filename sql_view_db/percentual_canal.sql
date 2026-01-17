--Resumo de receita por canal no 1º semestre de 2025
WITH TABELA_INICIAL AS (
    SELECT 
        vf.*,
        c.Descricao AS Canal,
        ROW_NUMBER() OVER (PARTITION BY vf.id_venda, vf.ID_Cliente, vf.ID_Produto ORDER BY vf.data_compra DESC) AS rn
    FROM workspace.default.burger_house_vendas_2025_final AS vf
    LEFT JOIN workspace.default.canais_burguer_house c ON vf.ID_Canal = c.ID_Canal
)

SELECT 
    Canal,
    SUM(valor_produto * quantidade) AS receita_canal,
    ROUND(SUM(valor_produto * quantidade) / SUM(SUM(valor_produto * quantidade)) OVER () * 100, 2) AS participacao_percentual
FROM TABELA_INICIAL
WHERE rn = 1
GROUP BY ALL
ORDER BY receita_canal DESC;
