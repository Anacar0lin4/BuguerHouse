--Todos os pedidos no 1sem de 2025
WITH TABELA_INICIAL AS (
SELECT 
    vf.*,
    p.descricao,
    p.categoria,
    p.tipo,
    c.Descricao AS CANAL,
    c.Tipo_Canal,
    ROW_NUMBER() OVER (PARTITION BY vf.id_venda, ID_Cliente, p.ID_Produto ORDER BY vf.data_compra DESC) AS rn
    --eu tenho algumas duplicidades entre vendas e alguns id_vendas tiveram erro no caracter entao foi necessario usar o id_cliente para diferenciar
FROM workspace.default.burger_house_vendas_2025_final AS vf
LEFT JOIN workspace.default.tabela_produtos as p ON  vf.ID_produto = p.ID_Produto
LEFT JOIN workspace.default.canais_burguer_house c ON vf.ID_Canal = c.ID_Canal
)

SELECT 
    id_venda,
    Id_cliente,
    --transformação de de time stamp para data
    DATE_FORMAT(data_compra,'yyyy-MM') AS safra, 
    DATE_FORMAT(data_compra,'yyyy-MM-dd') AS data_compra,
    ID_Produto,
    descricao AS PRODUTO,
    categoria,
    quantidade,
    tipo,
    valor_produto,
    valor_produto * quantidade AS total_compra,
    meio_pagamento,
    ID_Canal,
    Canal,
    Tipo_Canal,
    cidade,
    Estado,
    regiao

FROM TABELA_INICIAL 
WHERE rn = 1
