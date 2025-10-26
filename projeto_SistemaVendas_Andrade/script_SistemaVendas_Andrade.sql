-- =========================================
-- SISTEMA DE VENDAS - Ricardo Andrade
-- Script de criação do banco de dados
-- =========================================

-- Criação do banco
CREATE DATABASE sistema_vendas;
USE sistema_vendas;

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
-- Tabela: PRODUTO
-- =========================================
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(50),
    preco DECIMAL(10,2),
    id_categoria_produto INT,
    FOREIGN KEY (id_categoria_produto) REFERENCES categoria(id_categoria)
);

-- =========================================
-- Tabela: CATEGORIA
-- =========================================
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(15)
);

-- =========================================
-- Tabela: CONDICAO_PAGAMENTO
-- =========================================
CREATE TABLE condicao_pagamento (
    id_condicao_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(20)
);

-- =========================================
-- Tabela: PEDIDO
-- =========================================
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_pedido INT,
    id_produto_pedido INT,
    id_condicao_pagamento_pedido INT,
	data_pedido TIMESTAMP,
    FOREIGN KEY (id_cliente_pedido) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_produto_pedido) REFERENCES produto(id_produto),
    FOREIGN KEY (id_condicao_pagamento_pedido) REFERENCES condicao_pagamento(id_condicao_pagamento)
);
