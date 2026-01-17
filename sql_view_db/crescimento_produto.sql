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
    LEFT JOIN workspace.default.tabela_produtos AS p ON vf.ID_produto = p.ID_Produto
    LEFT JOIN workspace.default.canais_burguer_house c ON vf.ID_Canal = c.ID_Canal
),

VENDAS_AGREGADAS AS (
    SELECT 
        --truncar a data para semana e agregar a quantidade e valor
        DATE_TRUNC('WEEK', data_compra) AS semana,
        categoria,
        SUM(quantidade) AS total_qtd,
        SUM(valor_produto * quantidade) AS total_vendas
    FROM TABELA_INICIAL
    WHERE rn = 1
    GROUP BY ALL
),

VENDAS_LIMPAS AS (
    SELECT *,
    --pego o ultimo mes (tudo isso p ver o ultimo mes e dps tirar a ultima dt)
           MAX(DATE_TRUNC('MONTH', semana)) OVER () AS ultimo_mes
    FROM VENDAS_AGREGADAS
),

VARIACAO AS (
    SELECT
        semana,
        categoria,
        total_qtd,
        total_vendas,
        LAG(total_qtd) OVER (PARTITION BY categoria ORDER BY semana) AS qtd_semana_anterior,
        LAG(total_vendas) OVER (PARTITION BY categoria ORDER BY semana) AS vendas_semana_anterior,
        ultimo_mes
    FROM VENDAS_LIMPAS
)

SELECT
    semana,
    categoria,
    total_qtd,
    qtd_semana_anterior,
    total_qtd - qtd_semana_anterior AS dif_qtd,
    ROUND(((total_qtd - qtd_semana_anterior) / NULLIF(qtd_semana_anterior,0)) * 100,2) AS perc_var_qtd,
    total_vendas,
    vendas_semana_anterior,
    total_vendas - vendas_semana_anterior AS dif_vendas,
    ROUND(((total_vendas - vendas_semana_anterior) / NULLIF(vendas_semana_anterior,0)) * 100,2) AS perc_var_vendas
FROM VARIACAO
WHERE DATE_TRUNC('MONTH', semana) = ultimo_mes
 AND semana < (SELECT MAX(semana) FROM VENDAS_LIMPAS)  -- exclui a última semana parcial
ORDER BY categoria, semana;
