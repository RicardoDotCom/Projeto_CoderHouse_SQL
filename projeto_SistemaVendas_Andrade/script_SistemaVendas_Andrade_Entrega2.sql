-- =========================================
-- SISTEMA DE VENDAS - Ricardo Andrade
-- Script de criação e objetos do banco de dados (Entrega 2)
-- =========================================

-- =========================================
-- 1. INSERÇÃO DE DADOS INICIAIS
-- =========================================

-- 1.1 Tabela: ENDERECO
INSERT INTO endereco (logradouro, numero, cidade, estado, cep) VALUES
('Rua das Flores', 123, 'São Paulo', 'SP', 12345678),
('Avenida Principal', 456, 'Rio de Janeiro', 'RJ', 87654321),
('Travessa da Esperança', 789, 'Belo Horizonte', 'MG', 54321098),
('Estrada do Sol', 101, 'Curitiba', 'PR', 98765432);

-- 1.2 Tabela: CLIENTE
INSERT INTO cliente (nome_cliente, sobrenome_cliente, id_endereco_cliente) VALUES
('Ana', 'Silva', 1),
('Ricardo', 'Andrade', 2),
('Carla', 'Santos', 3),
('Daniel', 'Oliveira', 4);

-- 1.3 Tabela: CATEGORIA
INSERT INTO categoria (nome_categoria) VALUES
('Eletrônicos'),
('Livros'),
('Móveis'),
('Acessórios');

-- 1.4 Tabela: PRODUTO
INSERT INTO produto (nome_produto, preco, id_categoria_produto) VALUES
('Smartphone Android', 2500.00, 1),
('Aventuras de Tim Tim', 50.50, 2),
('Cadeira Gamer', 899.99, 3),
('Fone Bluetooth', 120.00, 1),
('Mesa de Escritório', 450.00, 3);

-- 1.5 Tabela: CONDICAO_PAGAMENTO
INSERT INTO condicao_pagamento (descricao) VALUES
('À Vista'),
('Cartão de Crédito'),
('Pix'),
('Boleto');

-- 1.6 Tabela: PEDIDO
INSERT INTO pedido (id_cliente_pedido, id_produto_pedido, id_condicao_pagamento_pedido, data_pedido) VALUES
(1, 1, 3, NOW()), -- Ana comprou Smartphone Android com Pix
(2, 3, 2, '2025-11-20 10:30:00'), -- Ricardo comprou Cadeira Gamer com Cartão
(1, 4, 3, '2025-11-20 11:00:00'), -- Ana comprou Fone Bluetooth com Pix
(3, 2, 1, '2025-11-21 14:00:00'), -- Carla comprou Aventuras de Tim Tim à Vista
(4, 5, 4, '2025-11-22 09:00:00'); -- Daniel comprou Mesa de Escritório com Boleto

-- =========================================
-- 2. CRIAÇÃO DE VIEWS
-- =========================================

-- 2.1 View: vw_clientes_endereco
-- Objetivo: Permite buscar o nome e onde o cliente mora com uma só consulta.
CREATE OR REPLACE VIEW vw_clientes_endereco AS
SELECT
    c.id_cliente,
    c.nome_cliente,
    c.sobrenome_cliente,
    e.logradouro,
    e.numero,
    e.cidade,
    e.estado,
    e.cep
FROM
    cliente c
JOIN
    endereco e ON c.id_endereco_cliente = e.id_endereco;

-- 2.2 View: vw_produtos_categoria
-- Objetivo: Auxilia na visualição dos itens do estoque, sabendo qual produto está em qual categoria. 
CREATE OR REPLACE VIEW vw_produtos_categoria AS
SELECT
    p.id_produto,
    p.nome_produto,
    p.preco,
    c.nome_categoria
FROM
    produto p
JOIN
    categoria c ON p.id_categoria_produto = c.id_categoria;

-- =========================================
-- 3. CRIAÇÃO DE FUNÇÕES
-- =========================================

-- 3.1 Função: fn_calcular_imposto (Calcula 18% de imposto)
-- Objetivo: Permite calcular o imposto de forma rápida, sem precisar repetir a fórmula toda vez.
DELIMITER //

CREATE FUNCTION fn_calcular_imposto(preco_produto DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE imposto DECIMAL(10, 2);
    SET imposto = preco_produto * 0.18;
    RETURN imposto;
END 

//

-- 3.2 Função: fn_contar_pedidos_cliente
-- Objetivo: Auxilia a identificar rapidamente quais clientes são os que realizam mais pedidos.

DELIMITER //

CREATE FUNCTION fn_contar_pedidos_cliente(cliente_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total_pedidos INT;
    SELECT COUNT(*) INTO total_pedidos
    FROM pedido
    WHERE id_cliente_pedido = cliente_id;
    RETURN total_pedidos;
END 

//

-- =========================================
-- 4. CRIAÇÃO DE STORED PROCEDURES
-- =========================================

-- 4.1 Stored Procedure: sp_inserir_novo_produto
-- Objetivo: Simplifica a inclusão de novos produtos, garantindo que todos os campos sejam preenchidos corretamente de uma vez só. 
DELIMITER //

CREATE PROCEDURE sp_inserir_novo_produto(
    IN p_nome_produto VARCHAR(50),
    IN p_preco DECIMAL(10, 2),
    IN p_id_categoria_produto INT
)
BEGIN
    INSERT INTO produto (nome_produto, preco, id_categoria_produto)
    VALUES (p_nome_produto, p_preco, p_id_categoria_produto);
END 

//

-- 4.2 Stored Procedure: sp_pedidos_por_condicao_pagamento
-- Objetivo: Gera relatórios específicos sobre quais são as formas de pagamento mais usadas pelos clientes.
DELIMITER //

CREATE PROCEDURE sp_pedidos_por_condicao_pagamento(
    IN p_id_condicao_pagamento INT
)
BEGIN
    SELECT
        pd.id_pedido,
        cl.nome_cliente,
        pr.nome_produto,
        cp.descricao AS condicao_pagamento
    FROM
        pedido pd
    JOIN
        cliente cl ON pd.id_cliente_pedido = cl.id_cliente
    JOIN
        produto pr ON pd.id_produto_pedido = pr.id_produto
    JOIN
        condicao_pagamento cp ON pd.id_condicao_pagamento_pedido = cp.id_condicao_pagamento
    WHERE
        pd.id_condicao_pagamento_pedido = p_id_condicao_pagamento
    ORDER BY
        pd.id_pedido;
END 

//

-- =========================================
-- 5. CRIAÇÃO DE TRIGGERS
-- =========================================

-- 5.1 Trigger: tr_before_padronizar_endereco (BEFORE UPDATE)
-- Importante! Exclui a trigger antiga, se existir, pois não consegui que atualizasse
DROP TRIGGER IF EXISTS tr_before_padronizar_endereco;

-- OBJETIVO: Garante que os campos 'cidade' e 'estado' sejam sempre salvos em CAIXA ALTA (MAIÚSCULAS) para padronização.
DELIMITER //

CREATE TRIGGER tr_before_padronizar_endereco
BEFORE UPDATE ON endereco
FOR EACH ROW
BEGIN
    -- Converte o novo valor da cidade para maiúsculas antes de salvar
    SET NEW.cidade = UPPER(NEW.cidade);

    -- Converte o novo valor do estado para maiúsculas antes de salvar
    SET NEW.estado = UPPER(NEW.estado);
END //

DELIMITER ;

-- 5.2 Trigger: tr_after_aplicar_desconto_produto (AFTER INSERT na tabela PEDIDO)
-- Importante! Exclui a trigger antiga, se existir, pois não consegui que atualizasse 
DROP TRIGGER IF EXISTS tr_after_aplicar_desconto_produto;

-- OBJETIVO: Reduz o preço do produto em 5% (simulando desconto/promoção) DEPOIS que ele é vendido em um pedido.
DELIMITER //

CREATE TRIGGER tr_after_aplicar_desconto_produto
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    -- Atualiza o preço na tabela PRODUTO, aplicando um desconto de 5% (multiplica por 0.95)
    UPDATE produto
    SET preco = preco * 0.95
    WHERE id_produto = NEW.id_produto_pedido;
END //

DELIMITER ;