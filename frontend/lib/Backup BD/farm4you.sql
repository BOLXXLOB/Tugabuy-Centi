-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 21-Fev-2025 às 10:48
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `farm4you`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `avaliacoes`
--

CREATE TABLE `avaliacoes` (
  `id` int(11) NOT NULL,
  `agricultor_id` int(11) NOT NULL,
  `consumidor_id` int(11) NOT NULL,
  `produto_id` int(11) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  `classificacao` int(11) DEFAULT NULL CHECK (`classificacao` between 1 and 5),
  `data_avaliacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `estado`
--

CREATE TABLE `estado` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `estado`
--

INSERT INTO `estado` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'A levar para a transportadora', 'A levar para a transportadora', '2025-02-18 11:45:39'),
(2, 'Recebido Pela Transportadora', 'Recebido Pela Transportadora', '2025-02-18 11:45:39'),
(3, 'A Caminho De Sua Casa', 'A Caminho De Sua Casa', '2025-02-18 11:46:34'),
(4, 'Pronto A Levantar', 'Pronto A Levantar', '2025-02-18 11:46:34'),
(5, 'Em preparação', 'Em preparação o pedido', '2025-02-18 11:46:54'),
(6, 'Recusada', 'O pedido foi recusado', '2025-02-18 11:51:56'),
(7, 'Aceite', 'Pedido foi aceite ', '2025-02-21 09:39:43');

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos`
--

CREATE TABLE `produtos` (
  `id` int(11) NOT NULL,
  `nome` varchar(150) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` double NOT NULL,
  `quantidade` int(11) NOT NULL,
  `categoria` varchar(255) DEFAULT NULL,
  `estado` enum('Disponível','Esgotado') DEFAULT 'Disponível',
  `data_adicionado` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizado` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `agricultor_id` int(11) NOT NULL,
  `imagem` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `produtos`
--

INSERT INTO `produtos` (`id`, `nome`, `descricao`, `preco`, `quantidade`, `categoria`, `estado`, `data_adicionado`, `data_atualizado`, `agricultor_id`, `imagem`) VALUES
(78, 'Espinafres', 'Biológicos ', 2, 0, '', 'Disponível', '2025-02-11 11:51:42', '2025-02-18 10:46:20', 6, 'farm4you-api/uploads/img_67ab39ceb604d7.13463347.jpg'),
(79, 'Tomates', 'Frescos', 1, 6774, '', 'Disponível', '2025-02-11 11:52:21', '2025-02-18 12:58:52', 6, 'farm4you-api/uploads/img_67ab39f5db44f6.49746400.jpg'),
(80, 'Pepinos', 'Grandes', 2, 0, '', 'Disponível', '2025-02-11 11:54:19', '2025-02-21 09:06:00', 10, 'farm4you-api/uploads/img_67ab3a6b897eb0.00960034.png');

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos_estado`
--

CREATE TABLE `produtos_estado` (
  `produto_id` int(11) NOT NULL,
  `estado_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipo`
--

CREATE TABLE `tipo` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `tipo`
--

INSERT INTO `tipo` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Agricultor', 'Vendedor', '2025-01-07 11:35:31'),
(2, 'Admin', 'Admin', '2025-01-07 11:37:23'),
(3, 'Consumidor', 'Consumidor', '2025-01-07 11:37:23');

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes`
--

CREATE TABLE `transacoes` (
  `id` int(11) NOT NULL,
  `tipo` enum('Compra','Venda') NOT NULL,
  `descricao` text DEFAULT NULL,
  `quantidade` int(11) NOT NULL,
  `data` timestamp NOT NULL DEFAULT current_timestamp(),
  `produto_id` int(11) DEFAULT NULL,
  `utilizador_id` int(11) DEFAULT NULL,
  `estado_id` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes`
--

INSERT INTO `transacoes` (`id`, `tipo`, `descricao`, `quantidade`, `data`, `produto_id`, `utilizador_id`, `estado_id`) VALUES
(4, 'Compra', NULL, 1, '2025-02-11 11:55:13', 78, 6, 8),
(5, 'Compra', NULL, 1, '2025-02-11 11:55:40', 80, 6, 3),
(6, 'Compra', NULL, 1, '2025-02-11 11:57:36', 79, 6, 3),
(7, 'Compra', NULL, 1, '2025-02-11 11:57:40', 79, 6, 1),
(8, 'Compra', NULL, 1, '2025-02-11 11:57:44', 80, 6, 1),
(9, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 8),
(10, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 3),
(11, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 8),
(12, 'Compra', NULL, 1, '2025-02-11 11:58:00', 78, 6, 6),
(13, 'Compra', NULL, 1, '2025-02-11 11:58:27', 78, 6, 6),
(14, 'Compra', NULL, 1, '2025-02-11 11:58:27', 78, 6, 1),
(37, 'Compra', NULL, 1, '2025-02-14 15:42:48', 80, 6, 1),
(38, 'Compra', NULL, 1, '2025-02-14 15:42:55', 80, 6, 1),
(39, 'Compra', NULL, 1, '2025-02-14 15:42:56', 80, 6, 1),
(40, 'Compra', NULL, 1, '2025-02-14 15:42:57', 80, 6, 1),
(41, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(42, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(43, 'Compra', NULL, 1, '2025-02-14 15:49:25', 80, 6, 1),
(44, 'Compra', NULL, 1, '2025-02-14 15:59:29', 79, 6, 1),
(45, 'Compra', NULL, 1, '2025-02-14 16:01:51', 79, 6, 1),
(46, 'Compra', NULL, 1, '2025-02-14 16:02:09', 79, 6, 1),
(47, 'Compra', NULL, 1, '2025-02-14 16:02:15', 79, 6, 1),
(48, 'Compra', NULL, 2, '2025-02-14 16:07:59', 79, 6, 1),
(49, 'Compra', NULL, 17, '2025-02-14 16:37:23', 78, 6, 1),
(50, 'Compra', NULL, 5, '2025-02-14 16:39:06', 78, 6, 6),
(51, 'Compra', NULL, 1, '2025-02-14 16:51:10', 78, 4, 1),
(52, 'Compra', NULL, 1, '2025-02-14 16:51:14', 78, 4, 1),
(53, 'Compra', NULL, 18, '2025-02-16 14:23:16', 78, 6, 6),
(54, 'Compra', 'Aguardando confirmação', 1, '2025-02-16 14:44:46', 78, 6, 3),
(55, 'Compra', 'Pagamento antecipado', 18, '2025-02-16 14:44:51', 78, 6, 3),
(56, 'Compra', 'Pagamento antecipado', 15, '2025-02-16 14:58:22', 78, 6, 3),
(57, 'Compra', 'Aguardando confirmação', 9, '2025-02-16 14:58:38', 78, 6, 3),
(58, 'Compra', 'Pagamento antecipado', 16, '2025-02-16 15:01:19', 78, 6, 3),
(59, 'Compra', 'Pagamento antecipado', 20, '2025-02-16 15:01:38', 78, 6, 3),
(60, 'Compra', 'Aguardando confirmação', 302, '2025-02-16 15:01:56', 79, 6, 3),
(61, 'Compra', 'Aguardando confirmação', 2, '2025-02-16 15:02:49', 78, 6, 3),
(62, 'Compra', 'Pagamento antecipado', 1, '2025-02-17 15:07:59', 79, 6, 3),
(63, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:08:03', 79, 6, 3),
(64, 'Compra', 'Pagamento antecipado', 2, '2025-02-17 15:09:55', 78, 9, 3),
(65, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:10:15', 78, 9, 3),
(66, 'Compra', 'Aguardando confirmação', 306, '2025-02-17 15:52:28', 79, 6, 3),
(67, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 10:46:20', 78, 6, 3),
(68, 'Compra', 'Pagamento antecipado', 3, '2025-02-18 10:46:36', 80, 6, 3),
(69, 'Compra', 'Aguardando confirmação', 2, '2025-02-18 10:47:15', 80, 6, 2),
(70, 'Compra', 'Aguardando confirmação', 4535, '2025-02-18 10:47:28', 79, 6, 3),
(71, 'Compra', 'Pagamento antecipado', 2329, '2025-02-18 11:16:39', 79, 6, 3),
(72, 'Compra', 'Pagamento antecipado', 1931, '2025-02-18 11:16:50', 79, 6, 3),
(73, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 11:35:09', 80, 6, 3),
(74, 'Compra', 'Pagamento antecipado', 965, '2025-02-18 12:58:52', 79, 6, 3),
(75, 'Compra', 'Aguardando confirmação', 1041, '2025-02-21 08:51:50', 79, 6, 1),
(76, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 09:06:00', 80, 6, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes_estado`
--

CREATE TABLE `transacoes_estado` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes_estado`
--

INSERT INTO `transacoes_estado` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Pendente', 'Transação está aguardando confirmação', '2025-02-11 13:15:00'),
(2, 'Completa', 'Transação foi concluída com sucesso', '2025-02-11 13:15:00'),
(3, 'Cancelada', 'Transação foi cancelada', '2025-02-11 13:15:00'),
(6, 'Recusada', 'O agricultor recusou a reserva', '2025-02-14 14:36:24'),
(8, 'Aceite', 'O agricultor aceitou a reserva', '2025-02-14 14:37:09');

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizadores`
--

CREATE TABLE `utilizadores` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(64) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `tipo_id` int(11) NOT NULL,
  `verificado` tinyint(1) DEFAULT 0,
  `data_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('ativo','inativo') DEFAULT 'ativo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `utilizadores`
--

INSERT INTO `utilizadores` (`id`, `nome`, `email`, `password`, `telefone`, `tipo_id`, `verificado`, `data_registro`, `status`) VALUES
(1, 'admin', 'admin@gmail.com', 'admin123', NULL, 2, 0, '2025-01-07 11:38:19', 'ativo'),
(2, 'agricultor', 'agricultor@gmail.com', 'agricultor123', NULL, 1, 0, '2025-01-07 11:39:35', 'ativo'),
(3, 'consumidor', 'consumidor@gmail.com', 'consumidor123', NULL, 3, 0, '2025-01-07 11:39:35', 'ativo'),
(4, 'atum', 'atum@gmail.com', '$2y$10$3AaO5fz3VV5oI0KlWJSzFeKPoNciT00Nc5Z7yBTv9YoQHXHt22D4S', NULL, 3, 0, '2025-01-07 12:56:13', 'ativo'),
(5, 'zeasdrubal', 'asdrubal@gmail.com', '$2y$10$SLkuyxvDwxiX1eJrEWcFPOKZUf7g.med5lawyL8sK9Othx2lkJHcC', NULL, 3, 0, '2025-01-07 12:57:14', 'ativo'),
(6, 'arroz', 'arroz@gmail.com', '$2y$10$O.1rVXyz4ArhOlGb0R7KuuPYkdgkMd3Hbjo3TnJe3Ep7PwqL0jIxi', NULL, 1, 0, '2025-01-07 12:59:32', 'ativo'),
(7, 'arro', 'ajdjjd@gmail.com', '$2y$10$dN5BzemUXWfZdI.2CICaWOCAhJd/yoo8AlClaYZEEACkxrCaf1lGa', NULL, 3, 0, '2025-01-10 14:00:27', 'ativo'),
(9, 'vinagre', 'vinagre@gmail.com', '$2y$10$50GI.W5BJeKQZXmnGs/KfedaIi0OMf5.u2vm.jSAgSXpoBkrNCyYq', NULL, 1, 0, '2025-02-04 10:59:59', 'ativo'),
(10, 'jose', 'jose@gmail.com', '$2y$10$/mviF6MW/in2FAJSmZluIeRRRmTSDDoJ5zpSPj.kZSRcPNKMv4IZC', NULL, 1, 0, '2025-02-07 14:53:59', 'ativo');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`),
  ADD KEY `consumidor_id` (`consumidor_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices para tabela `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`);

--
-- Índices para tabela `produtos_estado`
--
ALTER TABLE `produtos_estado`
  ADD PRIMARY KEY (`produto_id`,`estado_id`),
  ADD KEY `estado_id` (`estado_id`);

--
-- Índices para tabela `tipo`
--
ALTER TABLE `tipo`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produto_id` (`produto_id`),
  ADD KEY `utilizador_id` (`utilizador_id`),
  ADD KEY `transacoes_estado_fk` (`estado_id`);

--
-- Índices para tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `tipo_id` (`tipo_id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `estado`
--
ALTER TABLE `estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT de tabela `tipo`
--
ALTER TABLE `tipo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `transacoes`
--
ALTER TABLE `transacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT de tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD CONSTRAINT `avaliacoes_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_2` FOREIGN KEY (`consumidor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_3` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `produtos`
--
ALTER TABLE `produtos`
  ADD CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `produtos_estado`
--
ALTER TABLE `produtos_estado`
  ADD CONSTRAINT `produtos_estado_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `produtos_estado_ibfk_2` FOREIGN KEY (`estado_id`) REFERENCES `estado` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD CONSTRAINT `transacoes_estado_fk` FOREIGN KEY (`estado_id`) REFERENCES `transacoes_estado` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_2` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD CONSTRAINT `utilizadores_ibfk_1` FOREIGN KEY (`tipo_id`) REFERENCES `tipo` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*//////////////////////////////////////////////////////////////////////////////
-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 24-Fev-2025 às 15:38
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `farm4you`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `avaliacoes`
--

CREATE TABLE `avaliacoes` (
  `id` int(11) NOT NULL,
  `agricultor_id` int(11) NOT NULL,
  `consumidor_id` int(11) NOT NULL,
  `produto_id` int(11) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  `classificacao` int(11) DEFAULT NULL CHECK (`classificacao` between 1 and 5),
  `data_avaliacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `estados`
--

CREATE TABLE `estados` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `estados`
--

INSERT INTO `estados` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'A levar para a transportadora', 'A levar para a transportadora', '2025-02-18 11:45:39'),
(2, 'Recebido Pela Transportadora', 'Recebido Pela Transportadora', '2025-02-18 11:45:39'),
(3, 'A Caminho De Sua Casa', 'A Caminho De Sua Casa', '2025-02-18 11:46:34'),
(4, 'Pronto A Levantar', 'Pronto A Levantar', '2025-02-18 11:46:34'),
(5, 'Em preparação', 'Em preparação o pedido', '2025-02-18 11:46:54'),
(6, 'Recusada', 'O pedido foi recusado', '2025-02-18 11:51:56'),
(7, 'Aceite', 'Pedido foi aceite ', '2025-02-21 09:39:43'),
(8, 'Pago e aguardando pela confirmação', 'Pago e aguardando pela confirmação', '2025-02-24 14:13:27'),
(9, 'Aguardando confirmação', 'Aguardando confirmação', '2025-02-24 14:13:27');

-- --------------------------------------------------------

--
-- Estrutura da tabela `pedidos`
--

CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL,
  `utilizador_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL,
  `estado_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos`
--

CREATE TABLE `produtos` (
  `id` int(11) NOT NULL,
  `nome` varchar(150) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` double NOT NULL,
  `quantidade` int(11) NOT NULL,
  `categoria` varchar(255) DEFAULT NULL,
  `estado` enum('Disponível','Esgotado') DEFAULT 'Disponível',
  `data_adicionado` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizado` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `agricultor_id` int(11) NOT NULL,
  `imagem` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `produtos`
--

INSERT INTO `produtos` (`id`, `nome`, `descricao`, `preco`, `quantidade`, `categoria`, `estado`, `data_adicionado`, `data_atualizado`, `agricultor_id`, `imagem`) VALUES
(78, 'Espinafres', 'Biológicos ', 2, 0, '', 'Disponível', '2025-02-11 11:51:42', '2025-02-18 10:46:20', 6, 'farm4you-api/uploads/img_67ab39ceb604d7.13463347.jpg'),
(79, 'Tomates', 'Frescos', 1, 3491, '', 'Disponível', '2025-02-11 11:52:21', '2025-02-24 14:19:43', 6, 'farm4you-api/uploads/img_67ab39f5db44f6.49746400.jpg'),
(80, 'Pepinos', 'Grandes', 2, 59999, '', 'Disponível', '2025-02-11 11:54:19', '2025-02-21 14:55:13', 10, 'farm4you-api/uploads/img_67ab3a6b897eb0.00960034.png');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipo`
--

CREATE TABLE `tipo` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `tipo`
--

INSERT INTO `tipo` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Agricultor', 'Vendedor', '2025-01-07 11:35:31'),
(2, 'Admin', 'Admin', '2025-01-07 11:37:23'),
(3, 'Consumidor', 'Consumidor', '2025-01-07 11:37:23');

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes`
--

CREATE TABLE `transacoes` (
  `id` int(11) NOT NULL,
  `tipo` enum('Compra','Venda') NOT NULL,
  `descricao` text DEFAULT NULL,
  `quantidade` int(11) NOT NULL,
  `data` timestamp NOT NULL DEFAULT current_timestamp(),
  `produto_id` int(11) DEFAULT NULL,
  `utilizador_id` int(11) DEFAULT NULL,
  `estado_id` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes`
--

INSERT INTO `transacoes` (`id`, `tipo`, `descricao`, `quantidade`, `data`, `produto_id`, `utilizador_id`, `estado_id`) VALUES
(4, 'Compra', NULL, 1, '2025-02-11 11:55:13', 78, 6, 7),
(5, 'Compra', NULL, 1, '2025-02-11 11:55:40', 80, 6, 3),
(6, 'Compra', NULL, 1, '2025-02-11 11:57:36', 79, 6, 3),
(7, 'Compra', NULL, 1, '2025-02-11 11:57:40', 79, 6, 3),
(8, 'Compra', NULL, 1, '2025-02-11 11:57:44', 80, 6, 1),
(10, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 3),
(11, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 2),
(12, 'Compra', NULL, 1, '2025-02-11 11:58:00', 78, 6, 6),
(13, 'Compra', NULL, 1, '2025-02-11 11:58:27', 78, 6, 6),
(37, 'Compra', NULL, 1, '2025-02-14 15:42:48', 80, 6, 1),
(38, 'Compra', NULL, 1, '2025-02-14 15:42:55', 80, 6, 1),
(39, 'Compra', NULL, 1, '2025-02-14 15:42:56', 80, 6, 1),
(40, 'Compra', NULL, 1, '2025-02-14 15:42:57', 80, 6, 1),
(41, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(42, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(43, 'Compra', NULL, 1, '2025-02-14 15:49:25', 80, 6, 1),
(44, 'Compra', NULL, 1, '2025-02-14 15:59:29', 79, 6, 6),
(45, 'Compra', NULL, 1, '2025-02-14 16:01:51', 79, 6, 6),
(46, 'Compra', NULL, 1, '2025-02-14 16:02:09', 79, 6, 3),
(47, 'Compra', NULL, 1, '2025-02-14 16:02:15', 79, 6, 3),
(50, 'Compra', NULL, 5, '2025-02-14 16:39:06', 78, 6, 6),
(53, 'Compra', NULL, 18, '2025-02-16 14:23:16', 78, 6, 6),
(54, 'Compra', 'Aguardando confirmação', 1, '2025-02-16 14:44:46', 78, 6, 3),
(55, 'Compra', 'Pagamento antecipado', 18, '2025-02-16 14:44:51', 78, 6, 3),
(56, 'Compra', 'Pagamento antecipado', 15, '2025-02-16 14:58:22', 78, 6, 3),
(57, 'Compra', 'Aguardando confirmação', 9, '2025-02-16 14:58:38', 78, 6, 3),
(58, 'Compra', 'Pagamento antecipado', 16, '2025-02-16 15:01:19', 78, 6, 3),
(59, 'Compra', 'Pagamento antecipado', 20, '2025-02-16 15:01:38', 78, 6, 3),
(60, 'Compra', 'Aguardando confirmação', 302, '2025-02-16 15:01:56', 79, 6, 3),
(61, 'Compra', 'Aguardando confirmação', 2, '2025-02-16 15:02:49', 78, 6, 3),
(62, 'Compra', 'Pagamento antecipado', 1, '2025-02-17 15:07:59', 79, 6, 6),
(63, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:08:03', 79, 6, 3),
(64, 'Compra', 'Pagamento antecipado', 2, '2025-02-17 15:09:55', 78, 9, 3),
(65, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:10:15', 78, 9, 3),
(66, 'Compra', 'Aguardando confirmação', 306, '2025-02-17 15:52:28', 79, 6, 3),
(67, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 10:46:20', 78, 6, 3),
(68, 'Compra', 'Pagamento antecipado', 3, '2025-02-18 10:46:36', 80, 6, 3),
(69, 'Compra', 'Aguardando confirmação', 2, '2025-02-18 10:47:15', 80, 6, 2),
(70, 'Compra', 'Aguardando confirmação', 4535, '2025-02-18 10:47:28', 79, 6, 3),
(71, 'Compra', 'Pagamento antecipado', 2329, '2025-02-18 11:16:39', 79, 6, 3),
(72, 'Compra', 'Pagamento antecipado', 1931, '2025-02-18 11:16:50', 79, 6, 3),
(73, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 11:35:09', 80, 6, 3),
(74, 'Compra', 'Pagamento antecipado', 965, '2025-02-18 12:58:52', 79, 6, 6),
(75, 'Compra', 'Aguardando confirmação', 1041, '2025-02-21 08:51:50', 79, 6, 3),
(76, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 09:06:00', 80, 6, 3),
(77, 'Compra', 'Aguardando confirmação', 1512, '2025-02-21 10:04:35', 80, 9, 1),
(78, 'Compra', 'Pagamento antecipado', 92, '2025-02-21 10:41:43', 79, 6, 6),
(79, 'Compra', 'Pagamento antecipado', 20, '2025-02-21 10:54:39', 79, 6, 7),
(80, 'Compra', 'Pagamento antecipado', 742, '2025-02-21 10:55:11', 79, 6, 3),
(81, 'Compra', 'Pagamento antecipado', 82, '2025-02-21 10:55:50', 79, 6, 3),
(82, 'Compra', 'Pagamento antecipado', 657, '2025-02-21 10:57:16', 79, 6, 3),
(83, 'Compra', 'Pagamento antecipado', 739, '2025-02-21 11:00:31', 79, 6, 3),
(84, 'Compra', 'Pagamento antecipado', 426, '2025-02-21 11:04:39', 79, 6, 2),
(85, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 14:55:13', 80, 6, 2),
(86, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 14:55:20', 79, 6, 2),
(87, 'Compra', 'Aguardando confirmação', 5436, '2025-02-24 13:53:13', 80, 6, 5),
(88, 'Compra', 'Pagamento antecipado', 96, '2025-02-24 13:53:44', 79, 10, 2),
(89, 'Compra', 'Aguardando confirmação', 2285, '2025-02-24 13:53:59', 80, 10, 5),
(90, 'Compra', 'Aguardando confirmação', 5770, '2025-02-24 14:08:47', 80, 6, 5),
(91, 'Compra', 'Pagamento antecipado', 331, '2025-02-24 14:08:58', 79, 6, 7),
(93, 'Compra', 'Aguardando confirmação', 5588, '2025-02-24 14:15:56', 80, 6, 1),
(94, 'Compra', 'Aguardando confirmação', 44, '2025-02-24 14:16:23', 79, 6, 1),
(95, 'Compra', 'Pagamento antecipado', 97, '2025-02-24 14:19:43', 79, 6, 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes_estado`
--

CREATE TABLE `transacoes_estado` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes_estado`
--

INSERT INTO `transacoes_estado` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Pendente', 'Transação está aguardando confirmação', '2025-02-11 13:15:00'),
(2, 'Completa', 'Transação foi concluída com sucesso', '2025-02-11 13:15:00'),
(3, 'Cancelada', 'Transação foi cancelada', '2025-02-11 13:15:00'),
(5, 'Em preparação', 'Pedido em preparação', '2025-02-21 10:52:21'),
(6, 'Recusada', 'O agricultor recusou a reserva', '2025-02-14 14:36:24'),
(7, 'Aceite', 'Pedido aceite', '2025-02-21 10:54:07');

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizadores`
--

CREATE TABLE `utilizadores` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(64) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `tipo_id` int(11) NOT NULL,
  `verificado` tinyint(1) DEFAULT 0,
  `data_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('ativo','inativo') DEFAULT 'ativo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `utilizadores`
--

INSERT INTO `utilizadores` (`id`, `nome`, `email`, `password`, `telefone`, `tipo_id`, `verificado`, `data_registro`, `status`) VALUES
(1, 'admin', 'admin@gmail.com', 'admin123', NULL, 2, 0, '2025-01-07 11:38:19', 'ativo'),
(2, 'agricultor', 'agricultor@gmail.com', 'agricultor123', NULL, 1, 0, '2025-01-07 11:39:35', 'ativo'),
(3, 'consumidor', 'consumidor@gmail.com', 'consumidor123', NULL, 3, 0, '2025-01-07 11:39:35', 'ativo'),
(4, 'atum', 'atum@gmail.com', '$2y$10$3AaO5fz3VV5oI0KlWJSzFeKPoNciT00Nc5Z7yBTv9YoQHXHt22D4S', NULL, 3, 0, '2025-01-07 12:56:13', 'ativo'),
(5, 'zeasdrubal', 'asdrubal@gmail.com', '$2y$10$SLkuyxvDwxiX1eJrEWcFPOKZUf7g.med5lawyL8sK9Othx2lkJHcC', NULL, 3, 0, '2025-01-07 12:57:14', 'ativo'),
(6, 'arroz', 'arroz@gmail.com', '$2y$10$O.1rVXyz4ArhOlGb0R7KuuPYkdgkMd3Hbjo3TnJe3Ep7PwqL0jIxi', NULL, 1, 0, '2025-01-07 12:59:32', 'ativo'),
(7, 'arro', 'ajdjjd@gmail.com', '$2y$10$dN5BzemUXWfZdI.2CICaWOCAhJd/yoo8AlClaYZEEACkxrCaf1lGa', NULL, 3, 0, '2025-01-10 14:00:27', 'ativo'),
(9, 'vinagre', 'vinagre@gmail.com', '$2y$10$50GI.W5BJeKQZXmnGs/KfedaIi0OMf5.u2vm.jSAgSXpoBkrNCyYq', NULL, 1, 0, '2025-02-04 10:59:59', 'ativo'),
(10, 'jose', 'jose@gmail.com', '$2y$10$/mviF6MW/in2FAJSmZluIeRRRmTSDDoJ5zpSPj.kZSRcPNKMv4IZC', NULL, 1, 0, '2025-02-07 14:53:59', 'ativo');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`),
  ADD KEY `consumidor_id` (`consumidor_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices para tabela `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_estado` (`estado_id`),
  ADD KEY `fk_produtos` (`produto_id`),
  ADD KEY `fk_utilizador` (`utilizador_id`);

--
-- Índices para tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`);

--
-- Índices para tabela `tipo`
--
ALTER TABLE `tipo`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produto_id` (`produto_id`),
  ADD KEY `utilizador_id` (`utilizador_id`),
  ADD KEY `transacoes_estado_fk` (`estado_id`);

--
-- Índices para tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `tipo_id` (`tipo_id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `estados`
--
ALTER TABLE `estados`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de tabela `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT de tabela `tipo`
--
ALTER TABLE `tipo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `transacoes`
--
ALTER TABLE `transacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT de tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD CONSTRAINT `avaliacoes_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_2` FOREIGN KEY (`consumidor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_3` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_estado` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`id`),
  ADD CONSTRAINT `fk_produtos` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`),
  ADD CONSTRAINT `fk_utilizador` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`);

--
-- Limitadores para a tabela `produtos`
--
ALTER TABLE `produtos`
  ADD CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD CONSTRAINT `transacoes_estado_fk` FOREIGN KEY (`estado_id`) REFERENCES `transacoes_estado` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_2` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD CONSTRAINT `utilizadores_ibfk_1` FOREIGN KEY (`tipo_id`) REFERENCES `tipo` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


--------------------------Esta é a Atual:


-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 07-Mar-2025 às 15:33
-- Versão do servidor: 10.4.32-MariaDB
-- versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `farm4you`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `avaliacoes`
--

CREATE TABLE `avaliacoes` (
  `id` int(11) NOT NULL,
  `agricultor_id` int(11) NOT NULL,
  `consumidor_id` int(11) NOT NULL,
  `produto_id` int(11) DEFAULT NULL,
  `comentario` text DEFAULT NULL,
  `classificacao` int(11) DEFAULT NULL CHECK (`classificacao` between 1 and 5),
  `data_avaliacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `estados`
--

CREATE TABLE `estados` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `estados`
--

INSERT INTO `estados` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'A levar para a transportadora', 'A levar para a transportadora', '2025-02-18 11:45:39'),
(2, 'Recebido Pela Transportadora', 'Recebido Pela Transportadora', '2025-02-18 11:45:39'),
(3, 'A Caminho De Sua Casa', 'A Caminho De Sua Casa', '2025-02-18 11:46:34'),
(4, 'Pronto A Levantar', 'Pronto A Levantar', '2025-02-18 11:46:34'),
(5, 'Em preparação', 'Em preparação o pedido', '2025-02-18 11:46:54'),
(6, 'Recusada', 'O pedido foi recusado', '2025-02-18 11:51:56'),
(7, 'Aceite', 'Pedido foi aceite ', '2025-02-21 09:39:43'),
(8, 'Pago e aguardando pela confirmação', 'Pago e aguardando pela confirmação', '2025-02-24 14:13:27'),
(9, 'Aguardando confirmação', 'Aguardando confirmação', '2025-02-24 14:13:27'),
(10, 'Pedido realizado', 'Pedido realizado', '2025-02-24 14:49:08'),
(11, 'Entregue', 'A encomenda foi entregue', '2025-03-05 15:10:46');

-- --------------------------------------------------------

--
-- Estrutura da tabela `pedidos`
--

CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL,
  `comprador_id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `estado_id` int(11) NOT NULL,
  `data_pedido` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `pedidos`
--

INSERT INTO `pedidos` (`id`, `comprador_id`, `produto_id`, `quantidade`, `estado_id`, `data_pedido`) VALUES
(1, 6, 80, 73, 6, '2025-02-25 12:08:51'),
(2, 6, 80, 73, 11, '2025-02-25 12:08:51'),
(3, 6, 79, 1, 10, '2025-02-25 12:08:51'),
(4, 6, 79, 639, 1, '2025-02-25 12:08:51'),
(5, 6, 80, 10590, 11, '2025-02-25 12:08:51'),
(6, 6, 79, 248, 1, '2025-02-25 12:08:51'),
(7, 9, 79, 423, 1, '2025-02-25 12:08:51'),
(8, 6, 79, 365, 11, '2025-02-25 12:08:51'),
(9, 6, 79, 340, 11, '2025-02-25 12:08:51'),
(10, 6, 79, 1, 11, '2025-02-25 12:08:51'),
(11, 6, 79, 1, 11, '2025-02-25 12:08:51'),
(12, 6, 80, 3357, 11, '2025-02-25 12:08:51'),
(13, 6, 80, 1617, 6, '2025-02-25 12:08:51'),
(14, 6, 79, 1, 11, '2025-02-25 12:08:51'),
(15, 6, 79, 309, 7, '2025-02-25 12:08:51'),
(16, 6, 79, 134, 11, '2025-03-01 17:45:34'),
(17, 6, 79, 134, 11, '2025-03-01 17:45:36'),
(18, 6, 79, 340, 6, '2025-03-02 20:32:51'),
(19, 6, 80, 10090, 11, '2025-03-02 20:33:56'),
(20, 6, 79, 415, 11, '2025-03-02 20:34:33'),
(21, 6, 80, 709, 11, '2025-03-02 20:35:22'),
(22, 6, 79, 372, 6, '2025-03-02 20:38:59'),
(23, 6, 79, 142, 11, '2025-03-05 15:01:58'),
(24, 6, 79, 155, 11, '2025-03-05 15:02:09'),
(25, 6, 79, 251, 11, '2025-03-05 15:02:41'),
(26, 6, 79, 147, 3, '2025-03-05 15:05:50'),
(27, 6, 79, 167, 3, '2025-03-05 15:40:01'),
(28, 6, 80, 9031, 11, '2025-03-05 15:40:50'),
(29, 6, 80, 4719, 8, '2025-03-05 15:45:13');

-- --------------------------------------------------------

--
-- Estrutura da tabela `produtos`
--

CREATE TABLE `produtos` (
  `id` int(11) NOT NULL,
  `nome` varchar(150) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` double NOT NULL,
  `quantidade` int(11) NOT NULL,
  `categoria` varchar(255) DEFAULT NULL,
  `estado` enum('Disponível','Esgotado') DEFAULT 'Disponível',
  `data_adicionado` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizado` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `agricultor_id` int(11) NOT NULL,
  `imagem` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `produtos`
--

INSERT INTO `produtos` (`id`, `nome`, `descricao`, `preco`, `quantidade`, `categoria`, `estado`, `data_adicionado`, `data_atualizado`, `agricultor_id`, `imagem`) VALUES
(78, 'Espinafres', 'Biológicos ', 2, 0, '', 'Disponível', '2025-02-11 11:51:42', '2025-02-18 10:46:20', 6, 'farm4you-api/uploads/img_67ab39ceb604d7.13463347.jpg'),
(79, 'Tomates', 'Frescos', 1, 2644, '', 'Disponível', '2025-02-11 11:52:21', '2025-03-05 15:02:09', 6, 'farm4you-api/uploads/img_67ab39f5db44f6.49746400.jpg'),
(80, 'Pepinos', 'Grandes', 2, 59926, '', 'Disponível', '2025-02-11 11:54:19', '2025-02-24 16:34:38', 10, 'farm4you-api/uploads/img_67ab3a6b897eb0.00960034.png');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipo`
--

CREATE TABLE `tipo` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `tipo`
--

INSERT INTO `tipo` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Agricultor', 'Vendedor', '2025-01-07 11:35:31'),
(2, 'Admin', 'Admin', '2025-01-07 11:37:23'),
(3, 'Consumidor', 'Consumidor', '2025-01-07 11:37:23');

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes`
--

CREATE TABLE `transacoes` (
  `id` int(11) NOT NULL,
  `tipo` enum('Compra','Venda') NOT NULL,
  `descricao` text DEFAULT NULL,
  `quantidade` int(11) NOT NULL,
  `data` timestamp NOT NULL DEFAULT current_timestamp(),
  `produto_id` int(11) DEFAULT NULL,
  `utilizador_id` int(11) DEFAULT NULL,
  `estado_id` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes`
--

INSERT INTO `transacoes` (`id`, `tipo`, `descricao`, `quantidade`, `data`, `produto_id`, `utilizador_id`, `estado_id`) VALUES
(4, 'Compra', NULL, 1, '2025-02-11 11:55:13', 78, 6, 7),
(5, 'Compra', NULL, 1, '2025-02-11 11:55:40', 80, 6, 3),
(6, 'Compra', NULL, 1, '2025-02-11 11:57:36', 79, 6, 3),
(7, 'Compra', NULL, 1, '2025-02-11 11:57:40', 79, 6, 3),
(8, 'Compra', NULL, 1, '2025-02-11 11:57:44', 80, 6, 1),
(10, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 3),
(11, 'Compra', NULL, 1, '2025-02-11 11:57:44', 78, 6, 2),
(12, 'Compra', NULL, 1, '2025-02-11 11:58:00', 78, 6, 6),
(13, 'Compra', NULL, 1, '2025-02-11 11:58:27', 78, 6, 6),
(37, 'Compra', NULL, 1, '2025-02-14 15:42:48', 80, 6, 1),
(38, 'Compra', NULL, 1, '2025-02-14 15:42:55', 80, 6, 1),
(39, 'Compra', NULL, 1, '2025-02-14 15:42:56', 80, 6, 1),
(40, 'Compra', NULL, 1, '2025-02-14 15:42:57', 80, 6, 1),
(41, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(42, 'Compra', NULL, 1, '2025-02-14 15:42:58', 80, 6, 1),
(43, 'Compra', NULL, 1, '2025-02-14 15:49:25', 80, 6, 1),
(44, 'Compra', NULL, 1, '2025-02-14 15:59:29', 79, 6, 6),
(45, 'Compra', NULL, 1, '2025-02-14 16:01:51', 79, 6, 6),
(46, 'Compra', NULL, 1, '2025-02-14 16:02:09', 79, 6, 3),
(47, 'Compra', NULL, 1, '2025-02-14 16:02:15', 79, 6, 3),
(50, 'Compra', NULL, 5, '2025-02-14 16:39:06', 78, 6, 6),
(53, 'Compra', NULL, 18, '2025-02-16 14:23:16', 78, 6, 6),
(54, 'Compra', 'Aguardando confirmação', 1, '2025-02-16 14:44:46', 78, 6, 3),
(55, 'Compra', 'Pagamento antecipado', 18, '2025-02-16 14:44:51', 78, 6, 3),
(56, 'Compra', 'Pagamento antecipado', 15, '2025-02-16 14:58:22', 78, 6, 3),
(57, 'Compra', 'Aguardando confirmação', 9, '2025-02-16 14:58:38', 78, 6, 3),
(58, 'Compra', 'Pagamento antecipado', 16, '2025-02-16 15:01:19', 78, 6, 3),
(59, 'Compra', 'Pagamento antecipado', 20, '2025-02-16 15:01:38', 78, 6, 3),
(60, 'Compra', 'Aguardando confirmação', 302, '2025-02-16 15:01:56', 79, 6, 3),
(61, 'Compra', 'Aguardando confirmação', 2, '2025-02-16 15:02:49', 78, 6, 3),
(62, 'Compra', 'Pagamento antecipado', 1, '2025-02-17 15:07:59', 79, 6, 6),
(63, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:08:03', 79, 6, 3),
(64, 'Compra', 'Pagamento antecipado', 2, '2025-02-17 15:09:55', 78, 9, 3),
(65, 'Compra', 'Aguardando confirmação', 1, '2025-02-17 15:10:15', 78, 9, 3),
(66, 'Compra', 'Aguardando confirmação', 306, '2025-02-17 15:52:28', 79, 6, 3),
(67, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 10:46:20', 78, 6, 3),
(68, 'Compra', 'Pagamento antecipado', 3, '2025-02-18 10:46:36', 80, 6, 3),
(69, 'Compra', 'Aguardando confirmação', 2, '2025-02-18 10:47:15', 80, 6, 2),
(70, 'Compra', 'Aguardando confirmação', 4535, '2025-02-18 10:47:28', 79, 6, 3),
(71, 'Compra', 'Pagamento antecipado', 2329, '2025-02-18 11:16:39', 79, 6, 3),
(72, 'Compra', 'Pagamento antecipado', 1931, '2025-02-18 11:16:50', 79, 6, 3),
(73, 'Compra', 'Pagamento antecipado', 1, '2025-02-18 11:35:09', 80, 6, 3),
(74, 'Compra', 'Pagamento antecipado', 965, '2025-02-18 12:58:52', 79, 6, 6),
(75, 'Compra', 'Aguardando confirmação', 1041, '2025-02-21 08:51:50', 79, 6, 3),
(76, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 09:06:00', 80, 6, 3),
(77, 'Compra', 'Aguardando confirmação', 1512, '2025-02-21 10:04:35', 80, 9, 1),
(78, 'Compra', 'Pagamento antecipado', 92, '2025-02-21 10:41:43', 79, 6, 6),
(79, 'Compra', 'Pagamento antecipado', 20, '2025-02-21 10:54:39', 79, 6, 7),
(80, 'Compra', 'Pagamento antecipado', 742, '2025-02-21 10:55:11', 79, 6, 3),
(81, 'Compra', 'Pagamento antecipado', 82, '2025-02-21 10:55:50', 79, 6, 3),
(82, 'Compra', 'Pagamento antecipado', 657, '2025-02-21 10:57:16', 79, 6, 3),
(83, 'Compra', 'Pagamento antecipado', 739, '2025-02-21 11:00:31', 79, 6, 3),
(84, 'Compra', 'Pagamento antecipado', 426, '2025-02-21 11:04:39', 79, 6, 2),
(85, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 14:55:13', 80, 6, 2),
(86, 'Compra', 'Pagamento antecipado', 1, '2025-02-21 14:55:20', 79, 6, 2),
(87, 'Compra', 'Aguardando confirmação', 5436, '2025-02-24 13:53:13', 80, 6, 5),
(88, 'Compra', 'Pagamento antecipado', 96, '2025-02-24 13:53:44', 79, 10, 2),
(89, 'Compra', 'Aguardando confirmação', 2285, '2025-02-24 13:53:59', 80, 10, 5),
(90, 'Compra', 'Aguardando confirmação', 5770, '2025-02-24 14:08:47', 80, 6, 5),
(91, 'Compra', 'Pagamento antecipado', 331, '2025-02-24 14:08:58', 79, 6, 7),
(93, 'Compra', 'Aguardando confirmação', 5588, '2025-02-24 14:15:56', 80, 6, 1),
(94, 'Compra', 'Aguardando confirmação', 44, '2025-02-24 14:16:23', 79, 6, 1),
(95, 'Compra', 'Pagamento antecipado', 97, '2025-02-24 14:19:43', 79, 6, 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `transacoes_estado`
--

CREATE TABLE `transacoes_estado` (
  `id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `transacoes_estado`
--

INSERT INTO `transacoes_estado` (`id`, `nome`, `descricao`, `data_criacao`) VALUES
(1, 'Pendente', 'Transação está aguardando confirmação', '2025-02-11 13:15:00'),
(2, 'Completa', 'Transação foi concluída com sucesso', '2025-02-11 13:15:00'),
(3, 'Cancelada', 'Transação foi cancelada', '2025-02-11 13:15:00'),
(5, 'Em preparação', 'Pedido em preparação', '2025-02-21 10:52:21'),
(6, 'Recusada', 'O agricultor recusou a reserva', '2025-02-14 14:36:24'),
(7, 'Aceite', 'Pedido aceite', '2025-02-21 10:54:07');

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizadores`
--

CREATE TABLE `utilizadores` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(64) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `tipo_id` int(11) NOT NULL,
  `verificado` tinyint(1) DEFAULT 0,
  `data_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('ativo','inativo') DEFAULT 'ativo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_swedish_ci;

--
-- Extraindo dados da tabela `utilizadores`
--

INSERT INTO `utilizadores` (`id`, `nome`, `email`, `password`, `telefone`, `tipo_id`, `verificado`, `data_registro`, `status`) VALUES
(4, 'atum', 'atum@gmail.com', '$2y$10$3AaO5fz3VV5oI0KlWJSzFeKPoNciT00Nc5Z7yBTv9YoQHXHt22D4S', NULL, 3, 0, '2025-01-07 12:56:13', 'ativo'),
(6, 'arroz', 'arroz@gmail.com', '$2y$10$O.1rVXyz4ArhOlGb0R7KuuPYkdgkMd3Hbjo3TnJe3Ep7PwqL0jIxi', NULL, 1, 0, '2025-01-07 12:59:32', 'ativo'),
(9, 'vinagre', 'vinagre@gmail.com', '$2y$10$50GI.W5BJeKQZXmnGs/KfedaIi0OMf5.u2vm.jSAgSXpoBkrNCyYq', NULL, 1, 0, '2025-02-04 10:59:59', 'ativo'),
(10, 'jose', 'jose@gmail.com', '$2y$10$/mviF6MW/in2FAJSmZluIeRRRmTSDDoJ5zpSPj.kZSRcPNKMv4IZC', NULL, 1, 0, '2025-02-07 14:53:59', 'ativo');

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`),
  ADD KEY `consumidor_id` (`consumidor_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices para tabela `estados`
--
ALTER TABLE `estados`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_estado` (`estado_id`),
  ADD KEY `fk_produtos` (`produto_id`),
  ADD KEY `fk_utilizador` (`comprador_id`);

--
-- Índices para tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agricultor_id` (`agricultor_id`);

--
-- Índices para tabela `tipo`
--
ALTER TABLE `tipo`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produto_id` (`produto_id`),
  ADD KEY `utilizador_id` (`utilizador_id`),
  ADD KEY `transacoes_estado_fk` (`estado_id`);

--
-- Índices para tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `tipo_id` (`tipo_id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `estados`
--
ALTER TABLE `estados`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de tabela `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT de tabela `tipo`
--
ALTER TABLE `tipo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `transacoes`
--
ALTER TABLE `transacoes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT de tabela `transacoes_estado`
--
ALTER TABLE `transacoes_estado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `avaliacoes`
--
ALTER TABLE `avaliacoes`
  ADD CONSTRAINT `avaliacoes_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_2` FOREIGN KEY (`consumidor_id`) REFERENCES `utilizadores` (`id`),
  ADD CONSTRAINT `avaliacoes_ibfk_3` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_estado` FOREIGN KEY (`estado_id`) REFERENCES `estados` (`id`),
  ADD CONSTRAINT `fk_produtos` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`),
  ADD CONSTRAINT `fk_utilizador` FOREIGN KEY (`comprador_id`) REFERENCES `utilizadores` (`id`);

--
-- Limitadores para a tabela `produtos`
--
ALTER TABLE `produtos`
  ADD CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`agricultor_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `transacoes`
--
ALTER TABLE `transacoes`
  ADD CONSTRAINT `transacoes_estado_fk` FOREIGN KEY (`estado_id`) REFERENCES `transacoes_estado` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transacoes_ibfk_2` FOREIGN KEY (`utilizador_id`) REFERENCES `utilizadores` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `utilizadores`
--
ALTER TABLE `utilizadores`
  ADD CONSTRAINT `utilizadores_ibfk_1` FOREIGN KEY (`tipo_id`) REFERENCES `tipo` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
