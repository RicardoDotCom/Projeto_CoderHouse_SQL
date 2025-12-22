-- =========================================
-- SISTEMA DE VENDAS - Ricardo Andrade
-- Script de criação do banco de dados
-- =========================================

-- Criação do banco
CREATE DATABASE sistema_vendas;
USE sistema_vendas;

-- =========================================
-- Tabela: ENDERECO
-- =========================================
CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    logradouro VARCHAR(100),
    numero INT,
    cidade VARCHAR(30),
    estado VARCHAR(20),
    cep INT
);

-- =========================================
-- Tabela: CLIENTE
-- =========================================
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente VARCHAR(50),
    sobrenome_cliente VARCHAR(50),
    id_endereco_cliente INT,
    FOREIGN KEY (id_endereco_cliente) REFERENCES endereco(id_endereco)
);

-- =========================================
-- Tabela: CATEGORIA
-- =========================================
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(15)
);

-- =========================================
-- Tabela: FORNECEDOR
-- =========================================
CREATE TABLE fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome_fornecedor VARCHAR(100), 
	cnpj VARCHAR(20)
);

-- =========================================
-- Tabela: PRODUTO
-- =========================================
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(50),
    preco DECIMAL(10,2),
    id_categoria_produto INT, 
	id_fornecedor_produto INT,
    FOREIGN KEY (id_categoria_produto) REFERENCES categoria(id_categoria),
    FOREIGN KEY (id_fornecedor_produto) REFERENCES fornecedor(id_fornecedor)
);

-- =========================================
-- Tabela: VENDEDOR
-- =========================================
CREATE TABLE vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nome_vendedor VARCHAR(100), 
	comissao_percentual DECIMAL(5,2)
);

-- =========================================
-- Tabela: ESTOQUE
-- =========================================
CREATE TABLE estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto_estoque INT, 
	quantidade INT,
    FOREIGN KEY (id_produto_estoque) REFERENCES produto(id_produto)
);

-- =========================================
-- Tabela: STATUS_PEDIDO
-- =========================================
CREATE TABLE status_pedido (
    id_status INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50)
);

-- =========================================
-- Tabela: CONDICAO_PAGAMENTO
-- =========================================
CREATE TABLE condicao_pagamento (
    id_condicao_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(50)
);

-- =========================================
-- Tabela: TRANSPORTADORA
-- =========================================
CREATE TABLE transportadora (
    id_transportadora INT AUTO_INCREMENT PRIMARY KEY,
    nome_transportadora VARCHAR(100), 
	frete_medio DECIMAL(10,2)
);

-- =========================================
-- Tabela: DESCONTO
-- =========================================
CREATE TABLE desconto (
    id_desconto INT AUTO_INCREMENT PRIMARY KEY,
    nome_campanha VARCHAR(50), 
	percentual DECIMAL(5,2)
);

-- =========================================
-- Tabela: PEDIDO
-- =========================================
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_pedido INT, 
	id_vendedor_pedido INT,
    id_condicao_pagamento_pedido INT, 
	id_status_pedido INT,
    id_transportadora_pedido INT,
	id_desconto_pedido INT,
	data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente_pedido) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor_pedido) REFERENCES vendedor(id_vendedor),
    FOREIGN KEY (id_condicao_pagamento_pedido) REFERENCES condicao_pagamento(id_condicao_pagamento),
    FOREIGN KEY (id_status_pedido) REFERENCES status_pedido(id_status),
    FOREIGN KEY (id_transportadora_pedido) REFERENCES transportadora(id_transportadora),
    FOREIGN KEY (id_desconto_pedido) REFERENCES desconto (id_desconto)
);

-- =========================================
-- Tabela: ITEM_PEDIDO
-- =========================================
CREATE TABLE item_pedido ( -- TRANSACIONAL 1
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido_item INT, 
	id_produto_item INT, 
	quantidade INT, 
	preco_unitario DECIMAL(10,2),
    FOREIGN KEY (id_pedido_item) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_produto_item) REFERENCES produto(id_produto)
);

-- =========================================
-- Tabela: LOG_PRECOS
-- =========================================
CREATE TABLE log_precos ( -- TRANSACIONAL 2
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_produto_log INT, 
	preco_antigo DECIMAL(10,2), 
	preco_novo DECIMAL(10,2), 
	data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto_log) REFERENCES produto(id_produto)
);

-- =========================================
-- Tabela: FATO_VENDAS
-- =========================================
CREATE TABLE fato_vendas (
    id_fato INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_cliente INT,
    id_vendedor INT,
    valor_total DECIMAL(10,2),
    data_venda DATE,
    CONSTRAINT fk_fato_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    CONSTRAINT fk_fato_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_fato_vendedor FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

-- =========================================
-- CRIAÇÃO DE VIEWS
-- =========================================
-- Faturamento por Cliente
CREATE OR REPLACE VIEW vw_faturamento_por_cliente AS
SELECT c.nome_cliente, c.sobrenome_cliente, SUM(f.valor_total) AS total_gasto
FROM fato_vendas f
JOIN cliente c ON f.id_cliente = c.id_cliente
GROUP BY c.id_cliente;

-- Desempenho de Vendedores
CREATE OR REPLACE VIEW vw_desempenho_vendedores AS
SELECT v.nome_vendedor, SUM(f.valor_total) AS faturamento_gerado,
       SUM(f.valor_total * (v.comissao_percentual/100)) AS comissao_total
FROM fato_vendas f
JOIN vendedor v ON f.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor;

-- Produtos Mais Vendidos
CREATE OR REPLACE VIEW vw_produtos_mais_vendidos AS
SELECT p.nome_produto, SUM(ip.quantidade) AS total_unidades
FROM item_pedido ip
JOIN produto p ON ip.id_produto_item = p.id_produto
GROUP BY p.id_produto
ORDER BY total_unidades DESC;

-- Pedidos Detalhados (Visão 360)
CREATE OR REPLACE VIEW vw_pedidos_detalhados AS
SELECT p.id_pedido, c.nome_cliente, v.nome_vendedor, t.nome_transportadora, s.descricao AS status
FROM pedido p
JOIN cliente c ON p.id_cliente_pedido = c.id_cliente
JOIN vendedor v ON p.id_vendedor_pedido = v.id_vendedor
JOIN transportadora t ON p.id_transportadora_pedido = t.id_transportadora
JOIN status_pedido s ON p.id_status_pedido = s.id_status;

-- Auditoria de Preços
CREATE OR REPLACE VIEW vw_auditoria_precos_recentes AS
SELECT p.nome_produto, l.preco_antigo, l.preco_novo, l.data_alteracao
FROM log_precos l
JOIN produto p ON l.id_produto_log = p.id_produto
ORDER BY l.data_alteracao DESC;

-- =========================================
-- CRIAÇÃO DE STORED PROCEDURES
-- =========================================
-- Stored Procedure: sp_finalizar_pedido
-- Objetivo: Realiza o INSERT dos dados do pedido para a tabela FATO_VENDAS 
-- DROP PROCEDURE IF EXISTS sp_finalizar_pedido;

DELIMITER //

CREATE PROCEDURE sp_finalizar_pedido(IN p_id_pedido INT)
BEGIN
	INSERT INTO fato_vendas (id_pedido, data_venda, valor_total, id_cliente, id_vendedor)
	SELECT 
		p.id_pedido, 
		CURDATE(), 
		(SELECT SUM(quantidade * preco_unitario) FROM item_pedido WHERE id_pedido_item = p.id_pedido), -- Cálculo real
		p.id_cliente_pedido, 
		p.id_vendedor_pedido 
	FROM pedido p
	WHERE p.id_pedido = p_id_pedido;
END //

DELIMITER ;

-- Stored Procedure: sp_baixa_estoque
-- Objetivo: Realiza a baixa do estoque do produto após a venda
DELIMITER //

CREATE PROCEDURE sp_baixa_estoque(IN p_id_prod INT, IN p_qtd INT)
BEGIN
    UPDATE estoque SET quantidade = quantidade - p_qtd WHERE id_produto_estoque = p_id_prod;
END 

//
DELIMITER ;

-- =========================================
-- CRIAÇÃO DE FUNÇÕES
-- =========================================
-- Função: fn_total_com_imposto (Calcula 18% de imposto)
-- Objetivo: Permite calcular o imposto de forma rápida, sem precisar repetir a fórmula toda vez
DELIMITER //

CREATE FUNCTION fn_total_com_imposto(valor DECIMAL(10,2)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC 
BEGIN 
	RETURN valor * 1.18; 
END 

//
DELIMITER ;

-- Função: fn_validar_estoque 
-- Objetivo: Realiza a validação se tem o produto disponível antes de realizar a venda 
DELIMITER //

CREATE FUNCTION fn_validar_estoque(p_id_prod INT, p_qtd_desejada INT) 
RETURNS BOOLEAN
DETERMINISTIC BEGIN
    DECLARE v_qtd INT;
    SELECT quantidade INTO v_qtd FROM estoque WHERE id_produto_estoque = p_id_prod;
    RETURN IF(v_qtd >= p_qtd_desejada, TRUE, FALSE);
END 

//
DELIMITER ;

-- =========================================
-- 5. CRIAÇÃO DE TRIGGERS
-- =========================================

-- Importante: Remove a trigger antiga se ela existir
-- DROP TRIGGER IF EXISTS tr_audit_preco;

-- Objetivo: Registra o preço antigo e o novo para futuras auditorias 
DELIMITER //

CREATE TRIGGER tr_audit_preco 
AFTER UPDATE ON produto
FOR EACH ROW 
BEGIN
   
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO log_precos (id_produto_log, preco_antigo, preco_novo)
        VALUES (OLD.id_produto, OLD.preco, NEW.preco);
    END IF;
END //

DELIMITER ;

-- Trigger: tr_padroniza_nome_cliente
-- Importante! Exclui a trigger antiga, se existir, pois não consegui que atualizasse
-- DROP TRIGGER IF EXISTS tr_padroniza_nome_cliente;

-- Objetivo: Garante que o nome e sobrenome do cliente sejam sempre salvos em CAIXA ALTA (MAIÚSCULAS) para padronização.
DELIMITER //

CREATE TRIGGER tr_padroniza_nome_cliente BEFORE INSERT ON cliente
FOR EACH ROW BEGIN
    SET NEW.nome_cliente = UPPER(NEW.nome_cliente), NEW.sobrenome_cliente = UPPER(NEW.sobrenome_cliente);
END 

//
DELIMITER ;