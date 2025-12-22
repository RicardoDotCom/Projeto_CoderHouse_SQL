-- ======================================================
-- SCRIPT: INSERÇÃO DE DADOS E RELATÓRIOS
-- PROJETO: SISTEMA DE PEDIDOS DE CLIENTES
-- ======================================================

USE sistema_vendas;

-- 1. População de Tabelas bases
INSERT INTO endereco (logradouro, numero, cidade, estado, cep) VALUES
('Av. Paulista', 1500, 'São Paulo', 'SP', 01310100),
('Rua das Flores', 123, 'Curitiba', 'PR', 80010000),
('Av. Atlântica', 500, 'Rio de Janeiro', 'RJ', 22010000);

INSERT INTO cliente (nome_cliente, sobrenome_cliente, id_endereco_cliente) VALUES
('Ricardo', 'Andrade', 1),
('Ana', 'Silva', 2),
('Carla', 'Souza', 3);

INSERT INTO categoria (nome_categoria) VALUES
('Eletrônicos'),
('Informática'),
('Acessórios');

INSERT INTO fornecedor (nome_fornecedor, cnpj) VALUES
('Tech Distribuidora', '12.345.678/0001-90'),
('Global Logística', '98.765.432/0001-00');

INSERT INTO vendedor (nome_vendedor, comissao_percentual) VALUES
('Carlos Alberto', 5.00),
('Mariana Lima', 7.50);

INSERT INTO status_pedido (descricao) VALUES
('Pendente'),
('Pago'),
('Enviado'),
('Entregue');

INSERT INTO condicao_pagamento (descricao) VALUES
('Cartão de Crédito'),
('Boleto Bancário'),
('Dinheiro'),
('PIX');

INSERT INTO transportadora (nome_transportadora, frete_medio) VALUES
('TransExpress', 25.00),
('LogBr', 15.50);

INSERT INTO desconto (nome_campanha, percentual) VALUES
('Black Friday', 15.00),
('Primeira Compra', 10.00);

-- 2. População de Produtos e Estoque
INSERT INTO produto (nome_produto, preco, id_categoria_produto, id_fornecedor_produto) VALUES
('Smartphone S23', 4500.00, 1, 1),
('Notebook Pro', 7200.00, 2, 1),
('Mouse Gamer', 150.00, 3, 2);

INSERT INTO estoque (id_produto_estoque, quantidade) VALUES
(1, 50),
(2, 20),
(3, 100);

-- 3. Transações: Pedidos e Itens
-- Pedido 1
INSERT INTO pedido (id_cliente_pedido, id_vendedor_pedido, id_condicao_pagamento_pedido, id_status_pedido, id_transportadora_pedido, id_desconto_pedido) 
VALUES (1, 1, 3, 2, 1, 1);
INSERT INTO item_pedido (id_pedido_item, id_produto_item, quantidade, preco_unitario) VALUES (1, 1, 1, 4500.00);

-- Pedido 2
INSERT INTO pedido (id_cliente_pedido, id_vendedor_pedido, id_condicao_pagamento_pedido, id_status_pedido, id_transportadora_pedido, id_desconto_pedido) 
VALUES (2, 2, 1, 2, 2, 2);
INSERT INTO item_pedido (id_pedido_item, id_produto_item, quantidade, preco_unitario) VALUES (2, 2, 1, 7200.00);
INSERT INTO item_pedido (id_pedido_item, id_produto_item, quantidade, preco_unitario) VALUES (2, 3, 2, 150.00);

-- 4. Acionando Stored Procedures para Finalizar Vendas e Baixar Estoque
-- Finaliza na Tabela Fato
CALL sp_finalizar_pedido(1);
CALL sp_finalizar_pedido(2);

-- Atualiza valor total na Fato (Simulação de cálculo pós-item)
UPDATE fato_vendas SET valor_total = 4500.00 WHERE id_pedido = 1;
UPDATE fato_vendas SET valor_total = 7500.00 WHERE id_pedido = 2;

-- Baixa de estoque manual via procedure
CALL sp_baixa_estoque(1, 1);
CALL sp_baixa_estoque(2, 1);
CALL sp_baixa_estoque(3, 2);

-- 5. Teste da Trigger de Auditoria (Alterando preço de um produto)
UPDATE produto SET preco = 4200.00 WHERE id_produto = 1;

-- ======================================================
-- GERAÇÃO DE RELATÓRIOS (RELATÓRIO ANALÍTICO)
-- ======================================================

-- Relatório 1: Desempenho da Equipe Comercial (Via View)
SELECT * FROM vw_desempenho_vendedores;

-- Relatório 2: Faturamento Consolidado por Cliente (Via View)
SELECT * FROM vw_faturamento_por_cliente;

-- Relatório 3: Visão 360 do Status Logístico (Via View)
SELECT * FROM vw_pedidos_detalhados;

-- Relatório 4: Produtos que mais giram no estoque (Via View)
SELECT * FROM vw_produtos_mais_vendidos;

-- Relatório 5: Auditoria Fiscal - Cálculo de Imposto Estimado (Uso de Function)
SELECT 
    id_pedido, 
    valor_total AS valor_bruto, 
    fn_total_com_imposto(valor_total) AS valor_com_imposto_18pct,
    (fn_total_com_imposto(valor_total) - valor_total) AS total_imposto_retido
FROM fato_vendas;

-- Relatório 6: Auditoria de Alterações de Preços (Uso de Trigger + View)
SELECT * FROM vw_auditoria_precos_recentes;

-- Relatório 7: Verificação de Integridade de Nomes (Efeito da Trigger de UPCASE)
-- Observe que o nome inserido como 'Ricardo Andrade' agora aparece como 'RICARDO ANDRADE'
SELECT nome_cliente, sobrenome_cliente FROM cliente;