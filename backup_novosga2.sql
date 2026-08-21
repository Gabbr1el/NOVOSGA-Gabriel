-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: novosga2
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `agendamentos`
--

DROP TABLE IF EXISTS `agendamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agendamentos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int DEFAULT NULL,
  `unidade_id` int DEFAULT NULL,
  `servico_id` int DEFAULT NULL,
  `data` date NOT NULL,
  `hora` time NOT NULL,
  `data_confirmacao` datetime DEFAULT NULL,
  `oid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `situacao` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_2D12EA4ADE734E51` (`cliente_id`),
  KEY `IDX_2D12EA4AEDF4B99B` (`unidade_id`),
  KEY `IDX_2D12EA4A82E14982` (`servico_id`),
  KEY `agendamento_oid_index` (`oid`),
  CONSTRAINT `FK_2D12EA4A82E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_2D12EA4ADE734E51` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `FK_2D12EA4AEDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agendamentos`
--

LOCK TABLES `agendamentos` WRITE;
/*!40000 ALTER TABLE `agendamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `atendimentos`
--

DROP TABLE IF EXISTS `atendimentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atendimentos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int DEFAULT NULL,
  `unidade_id` int DEFAULT NULL,
  `servico_id` int DEFAULT NULL,
  `prioridade_id` int DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  `usuario_tri_id` int DEFAULT NULL,
  `atendimento_id` int DEFAULT NULL,
  `num_local` smallint DEFAULT NULL,
  `dt_age` datetime DEFAULT NULL,
  `dt_cheg` datetime NOT NULL,
  `dt_cha` datetime DEFAULT NULL,
  `dt_ini` datetime DEFAULT NULL,
  `dt_fim` datetime DEFAULT NULL,
  `tempo_espera` int DEFAULT NULL,
  `tempo_permanencia` int DEFAULT NULL,
  `tempo_atendimento` int DEFAULT NULL,
  `tempo_deslocamento` int DEFAULT NULL,
  `status` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolucao` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `senha_sigla` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_numero` int NOT NULL,
  `local_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_29E906E7DE734E51` (`cliente_id`),
  KEY `IDX_29E906E7EDF4B99B` (`unidade_id`),
  KEY `IDX_29E906E782E14982` (`servico_id`),
  KEY `IDX_29E906E7226EFC79` (`prioridade_id`),
  KEY `IDX_29E906E7DB38439E` (`usuario_id`),
  KEY `IDX_29E906E7875F1A79` (`usuario_tri_id`),
  KEY `IDX_29E906E776323123` (`atendimento_id`),
  CONSTRAINT `FK_29E906E7226EFC79` FOREIGN KEY (`prioridade_id`) REFERENCES `prioridades` (`id`),
  CONSTRAINT `FK_29E906E776323123` FOREIGN KEY (`atendimento_id`) REFERENCES `atendimentos` (`id`),
  CONSTRAINT `FK_29E906E782E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_29E906E7875F1A79` FOREIGN KEY (`usuario_tri_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_29E906E7DB38439E` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_29E906E7DE734E51` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `FK_29E906E7EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atendimentos`
--

LOCK TABLES `atendimentos` WRITE;
/*!40000 ALTER TABLE `atendimentos` DISABLE KEYS */;
INSERT INTO `atendimentos` VALUES (7,4,2,6,3,5,2,NULL,1,NULL,'2026-08-20 06:38:39','2026-08-20 08:10:28',NULL,'2026-08-20 22:36:45',5509,57486,0,0,'nao_compareceu',NULL,NULL,'A',1,3),(8,4,2,6,3,5,3,NULL,2,NULL,'2026-08-20 08:59:30','2026-08-20 22:36:46',NULL,'2026-08-20 22:39:56',49036,49226,0,0,'nao_compareceu',NULL,NULL,'A',2,3),(9,4,2,6,3,5,2,NULL,1,NULL,'2026-08-20 22:40:21','2026-08-20 22:40:34',NULL,NULL,13,NULL,NULL,NULL,'chamado',NULL,NULL,'A',3,3);
/*!40000 ALTER TABLE `atendimentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `atendimentos_codificados`
--

DROP TABLE IF EXISTS `atendimentos_codificados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atendimentos_codificados` (
  `servico_id` int NOT NULL,
  `atendimento_id` int NOT NULL,
  `valor_peso` smallint NOT NULL,
  PRIMARY KEY (`servico_id`,`atendimento_id`),
  KEY `IDX_DDF47B2D82E14982` (`servico_id`),
  KEY `IDX_DDF47B2D76323123` (`atendimento_id`),
  CONSTRAINT `FK_DDF47B2D76323123` FOREIGN KEY (`atendimento_id`) REFERENCES `atendimentos` (`id`),
  CONSTRAINT `FK_DDF47B2D82E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atendimentos_codificados`
--

LOCK TABLES `atendimentos_codificados` WRITE;
/*!40000 ALTER TABLE `atendimentos_codificados` DISABLE KEYS */;
/*!40000 ALTER TABLE `atendimentos_codificados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `atendimentos_metadata`
--

DROP TABLE IF EXISTS `atendimentos_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atendimentos_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `atendimento_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`atendimento_id`),
  KEY `IDX_4F7723EB76323123` (`atendimento_id`),
  CONSTRAINT `FK_4F7723EB76323123` FOREIGN KEY (`atendimento_id`) REFERENCES `atendimentos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `atendimentos_metadata`
--

LOCK TABLES `atendimentos_metadata` WRITE;
/*!40000 ALTER TABLE `atendimentos_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `atendimentos_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dt_nascimento` date DEFAULT NULL,
  `genero` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `end_pais` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_cep` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_estado` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_cidade` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_logradouro` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_numero` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_complemento` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (4,'Felipe gabriel silva rocha','11',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes_metadata`
--

DROP TABLE IF EXISTS `clientes_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cliente_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`cliente_id`),
  KEY `IDX_23B81DEEDE734E51` (`cliente_id`),
  CONSTRAINT `FK_23B81DEEDE734E51` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes_metadata`
--

LOCK TABLES `clientes_metadata` WRITE;
/*!40000 ALTER TABLE `clientes_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `clientes_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contador`
--

DROP TABLE IF EXISTS `contador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contador` (
  `unidade_id` int NOT NULL,
  `servico_id` int NOT NULL,
  `numero` int DEFAULT NULL,
  PRIMARY KEY (`unidade_id`,`servico_id`),
  KEY `IDX_E83EF8FAEDF4B99B` (`unidade_id`),
  KEY `IDX_E83EF8FA82E14982` (`servico_id`),
  CONSTRAINT `FK_E83EF8FA82E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_E83EF8FAEDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contador`
--

LOCK TABLES `contador` WRITE;
/*!40000 ALTER TABLE `contador` DISABLE KEYS */;
INSERT INTO `contador` VALUES (2,5,1),(2,6,4),(2,7,1);
/*!40000 ALTER TABLE `contador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departamentos`
--

DROP TABLE IF EXISTS `departamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departamentos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departamentos`
--

LOCK TABLES `departamentos` WRITE;
/*!40000 ALTER TABLE `departamentos` DISABLE KEYS */;
INSERT INTO `departamentos` VALUES (2,'Recepção','Recepção',1,'2026-08-11 12:25:07','2026-08-19 17:28:26'),(3,'TFD','tfd',1,'2026-08-19 17:37:44',NULL),(4,'Regulação','Regulação',1,'2026-08-19 17:37:57','2026-08-20 08:53:08');
/*!40000 ALTER TABLE `departamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctrine_migration_versions`
--

DROP TABLE IF EXISTS `doctrine_migration_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctrine_migration_versions` (
  `version` varchar(191) COLLATE utf8mb3_unicode_ci NOT NULL,
  `executed_at` datetime DEFAULT NULL,
  `execution_time` int DEFAULT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctrine_migration_versions`
--

LOCK TABLES `doctrine_migration_versions` WRITE;
/*!40000 ALTER TABLE `doctrine_migration_versions` DISABLE KEYS */;
INSERT INTO `doctrine_migration_versions` VALUES ('DoctrineMigrations\\Version1','2026-08-11 12:14:54',3747),('DoctrineMigrations\\Version2','2026-08-11 12:14:58',346),('DoctrineMigrations\\Version20210326134543','2026-08-11 12:14:58',787),('DoctrineMigrations\\Version20240723214655','2026-08-11 12:14:59',330),('DoctrineMigrations\\Version20241223212116','2026-08-11 12:14:59',21);
/*!40000 ALTER TABLE `doctrine_migration_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historico_atendimentos`
--

DROP TABLE IF EXISTS `historico_atendimentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_atendimentos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cliente_id` int DEFAULT NULL,
  `unidade_id` int DEFAULT NULL,
  `servico_id` int DEFAULT NULL,
  `prioridade_id` int DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  `usuario_tri_id` int DEFAULT NULL,
  `atendimento_id` int DEFAULT NULL,
  `num_local` smallint DEFAULT NULL,
  `dt_age` datetime DEFAULT NULL,
  `dt_cheg` datetime NOT NULL,
  `dt_cha` datetime DEFAULT NULL,
  `dt_ini` datetime DEFAULT NULL,
  `dt_fim` datetime DEFAULT NULL,
  `tempo_espera` int DEFAULT NULL,
  `tempo_permanencia` int DEFAULT NULL,
  `tempo_atendimento` int DEFAULT NULL,
  `tempo_deslocamento` int DEFAULT NULL,
  `status` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `resolucao` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacao` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `senha_sigla` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_numero` int NOT NULL,
  `local_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_CBBDF95FDE734E51` (`cliente_id`),
  KEY `IDX_CBBDF95FEDF4B99B` (`unidade_id`),
  KEY `IDX_CBBDF95F82E14982` (`servico_id`),
  KEY `IDX_CBBDF95F226EFC79` (`prioridade_id`),
  KEY `IDX_CBBDF95FDB38439E` (`usuario_id`),
  KEY `IDX_CBBDF95F875F1A79` (`usuario_tri_id`),
  KEY `IDX_CBBDF95F76323123` (`atendimento_id`),
  CONSTRAINT `FK_CBBDF95F226EFC79` FOREIGN KEY (`prioridade_id`) REFERENCES `prioridades` (`id`),
  CONSTRAINT `FK_CBBDF95F76323123` FOREIGN KEY (`atendimento_id`) REFERENCES `historico_atendimentos` (`id`),
  CONSTRAINT `FK_CBBDF95F82E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_CBBDF95F875F1A79` FOREIGN KEY (`usuario_tri_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_CBBDF95FDB38439E` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_CBBDF95FDE734E51` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  CONSTRAINT `FK_CBBDF95FEDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historico_atendimentos`
--

LOCK TABLES `historico_atendimentos` WRITE;
/*!40000 ALTER TABLE `historico_atendimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `historico_atendimentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historico_atendimentos_codificados`
--

DROP TABLE IF EXISTS `historico_atendimentos_codificados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_atendimentos_codificados` (
  `servico_id` int NOT NULL,
  `atendimento_id` int NOT NULL,
  `valor_peso` smallint NOT NULL,
  PRIMARY KEY (`servico_id`,`atendimento_id`),
  KEY `IDX_111248C282E14982` (`servico_id`),
  KEY `IDX_111248C276323123` (`atendimento_id`),
  CONSTRAINT `FK_111248C276323123` FOREIGN KEY (`atendimento_id`) REFERENCES `historico_atendimentos` (`id`),
  CONSTRAINT `FK_111248C282E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historico_atendimentos_codificados`
--

LOCK TABLES `historico_atendimentos_codificados` WRITE;
/*!40000 ALTER TABLE `historico_atendimentos_codificados` DISABLE KEYS */;
/*!40000 ALTER TABLE `historico_atendimentos_codificados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historico_atendimentos_metadata`
--

DROP TABLE IF EXISTS `historico_atendimentos_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_atendimentos_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `atendimento_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`atendimento_id`),
  KEY `IDX_169630A576323123` (`atendimento_id`),
  CONSTRAINT `FK_169630A576323123` FOREIGN KEY (`atendimento_id`) REFERENCES `historico_atendimentos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historico_atendimentos_metadata`
--

LOCK TABLES `historico_atendimentos_metadata` WRITE;
/*!40000 ALTER TABLE `historico_atendimentos_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `historico_atendimentos_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locais`
--

DROP TABLE IF EXISTS `locais`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locais` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_C823878C54BD530C` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locais`
--

LOCK TABLES `locais` WRITE;
/*!40000 ALTER TABLE `locais` DISABLE KEYS */;
INSERT INTO `locais` VALUES (2,'Recepção','2026-08-11 12:15:20','2026-08-11 12:25:38'),(3,'Sala do TFD','2026-08-19 17:31:03','2026-08-20 08:54:54'),(4,'Sala','2026-08-19 17:31:10','2026-08-20 08:54:31');
/*!40000 ALTER TABLE `locais` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lotacoes`
--

DROP TABLE IF EXISTS `lotacoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lotacoes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int DEFAULT NULL,
  `unidade_id` int DEFAULT NULL,
  `perfil_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lotacao_usuario_unidade_idx` (`usuario_id`,`unidade_id`),
  KEY `IDX_10E72C2FDB38439E` (`usuario_id`),
  KEY `IDX_10E72C2FEDF4B99B` (`unidade_id`),
  KEY `IDX_10E72C2F57291544` (`perfil_id`),
  CONSTRAINT `FK_10E72C2F57291544` FOREIGN KEY (`perfil_id`) REFERENCES `perfis` (`id`),
  CONSTRAINT `FK_10E72C2FDB38439E` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_10E72C2FEDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lotacoes`
--

LOCK TABLES `lotacoes` WRITE;
/*!40000 ALTER TABLE `lotacoes` DISABLE KEYS */;
INSERT INTO `lotacoes` VALUES (4,3,2,2),(5,4,2,4),(6,5,2,3);
/*!40000 ALTER TABLE `lotacoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata`
--

LOCK TABLES `metadata` WRITE;
/*!40000 ALTER TABLE `metadata` DISABLE KEYS */;
INSERT INTO `metadata` VALUES ('novosga.settings','appearance','{\"theme\": \"slate\", \"customJS\": \"\", \"customCSS\": \"\", \"logoLogin\": \"\", \"logoNavbar\": \"\", \"navbarColor\": \"bg-primary\"}'),('novosga.settings','behavior','{\"prioritySwap\": false, \"prioritySwapCount\": 1, \"prioritySwapMethod\": \"unity\", \"callTicketByService\": false, \"callTicketOutOfOrder\": true}');
/*!40000 ALTER TABLE `metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oauth2_access_token`
--

DROP TABLE IF EXISTS `oauth2_access_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oauth2_access_token` (
  `identifier` char(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `client` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `expiry` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `user_identifier` varchar(128) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `scopes` text COLLATE utf8mb3_unicode_ci COMMENT '(DC2Type:oauth2_scope)',
  `revoked` tinyint(1) NOT NULL,
  PRIMARY KEY (`identifier`),
  KEY `IDX_454D9673C7440455` (`client`),
  CONSTRAINT `FK_454D9673C7440455` FOREIGN KEY (`client`) REFERENCES `oauth2_client` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oauth2_access_token`
--

LOCK TABLES `oauth2_access_token` WRITE;
/*!40000 ALTER TABLE `oauth2_access_token` DISABLE KEYS */;
INSERT INTO `oauth2_access_token` VALUES ('08ab539d37c9ca3e57343953c2ff7e4f6882278c8b63261c998c720833a2c32e1115be9321f47848','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 18:49:54','admin','email',1),('41bd7008dab53a7fb1b382c58f5c4bb6774ca3a9720e5506967bb40ebbab41bf48fda717a7657b1a','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 18:49:53','admin','email',0),('543306102e06e78d61acf41ee0e33db54ec65bdba50f46464c1ecf3af35f706729bcd39f38bb91fa','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 10:02:16','admin','email',1),('5dee4204b4f60eb8302a57235c0ac89024a5e8c8c70e25f2fc10032c488fe5e9d4b89ca86ea19f1f','157b6a65d779f8303d2dda0e1ca1e955','2026-08-21 00:22:13','admin','email',0),('8a4752586cac23d5b4503484209517d6bd2202b145e97a109dd04424619904dae221d19cdd5d3760','c084f82154484efd44dc3a78d3dbabcf','2026-08-21 00:22:19','admin','email',0),('a3718938e6ae5cbe0a36833199377a4bca12f67881cdc3bcfd6d35ba0bf0a98ddf116f64864159c3','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 15:17:36','admin','email',1),('a90ab0dc7a52979dd22453ae3bd9562927c74fd33da9e56feebab32c30d2e80f3c805f6d7c30b172','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 23:10:34','admin','email',1),('bb9ab14039f9b210e40bd116d5fb8ae39b37657e70f01b0d65f6552447bce84289c86c0c09f2032a','c084f82154484efd44dc3a78d3dbabcf','2026-08-21 00:27:54','admin','email',0),('d4d7ea026761abdfaf72a2b5ccd35a7379e3b8c2884f5cdadd6118e0ebf6194c723829d4bed35b46','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 09:03:14','admin','email',1),('d70f66ed8dbd66eab113aa0608611079b5cbdc14c5fd0a7993c99c1683a0276a17d8dac9f3c8edc5','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 15:17:36','admin','email',0),('ea74048bbc9164feb42d87a76b6f419a4944516344e1fbbc7c33884c0f4ef74137f84afbadcdd7b5','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 22:11:32','admin','email',1),('ef7a27dd0520bfd50859bb82c9435f6194a388abc35e4a51169b3d90604a1f8acc7fb9c8a39fa26d','157b6a65d779f8303d2dda0e1ca1e955','2026-08-20 09:04:39','admin','email',1),('f51595f8fd0b7faa6e72e42ca4bf7a40aed68261c494ffd078ed933fefa7aa64663f1dca3dc98a8a','157b6a65d779f8303d2dda0e1ca1e955','2026-08-21 10:57:37','admin','email',0),('fffb3f5569099e47cf9e5d203377fdf8188f8174b262094dfb6ce4d33f9c3e883c2a9bcf6ba58d6b','c084f82154484efd44dc3a78d3dbabcf','2026-08-20 09:03:14','admin','email',0);
/*!40000 ALTER TABLE `oauth2_access_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oauth2_authorization_code`
--

DROP TABLE IF EXISTS `oauth2_authorization_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oauth2_authorization_code` (
  `identifier` char(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `client` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `expiry` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `user_identifier` varchar(128) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `scopes` text COLLATE utf8mb3_unicode_ci COMMENT '(DC2Type:oauth2_scope)',
  `revoked` tinyint(1) NOT NULL,
  PRIMARY KEY (`identifier`),
  KEY `IDX_509FEF5FC7440455` (`client`),
  CONSTRAINT `FK_509FEF5FC7440455` FOREIGN KEY (`client`) REFERENCES `oauth2_client` (`identifier`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oauth2_authorization_code`
--

LOCK TABLES `oauth2_authorization_code` WRITE;
/*!40000 ALTER TABLE `oauth2_authorization_code` DISABLE KEYS */;
/*!40000 ALTER TABLE `oauth2_authorization_code` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oauth2_client`
--

DROP TABLE IF EXISTS `oauth2_client`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oauth2_client` (
  `identifier` varchar(32) COLLATE utf8mb3_unicode_ci NOT NULL,
  `name` varchar(128) COLLATE utf8mb3_unicode_ci NOT NULL,
  `secret` varchar(128) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `redirect_uris` text COLLATE utf8mb3_unicode_ci COMMENT '(DC2Type:oauth2_redirect_uri)',
  `grants` text COLLATE utf8mb3_unicode_ci COMMENT '(DC2Type:oauth2_grant)',
  `scopes` text COLLATE utf8mb3_unicode_ci COMMENT '(DC2Type:oauth2_scope)',
  `active` tinyint(1) NOT NULL,
  `allow_plain_text_pkce` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oauth2_client`
--

LOCK TABLES `oauth2_client` WRITE;
/*!40000 ALTER TABLE `oauth2_client` DISABLE KEYS */;
INSERT INTO `oauth2_client` VALUES ('157b6a65d779f8303d2dda0e1ca1e955','panel Agendamento','acb00b7bf615b6b10ae4071a827d2de541e0e3b802bcad40de0a6cd0a4589f9e27931abbbd214127a92ee0d5b9bbe5efa58028100ceccd2d7323eb203e7540bd',NULL,'token password refresh_token','email',1,0),('c084f82154484efd44dc3a78d3dbabcf','panel TFD','0cd92e0021fde22370886f11c1165393324b5dbd3bf7ea721e15fd2628f40cad3bc2324e10892f21a3739f2861da96a87a211f875b6452a52e4dd873c31c39ca',NULL,'token password refresh_token','email',1,0);
/*!40000 ALTER TABLE `oauth2_client` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oauth2_refresh_token`
--

DROP TABLE IF EXISTS `oauth2_refresh_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `oauth2_refresh_token` (
  `identifier` char(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `access_token` char(80) COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `expiry` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `revoked` tinyint(1) NOT NULL,
  PRIMARY KEY (`identifier`),
  KEY `IDX_4DD90732B6A2DD68` (`access_token`),
  CONSTRAINT `FK_4DD90732B6A2DD68` FOREIGN KEY (`access_token`) REFERENCES `oauth2_access_token` (`identifier`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oauth2_refresh_token`
--

LOCK TABLES `oauth2_refresh_token` WRITE;
/*!40000 ALTER TABLE `oauth2_refresh_token` DISABLE KEYS */;
INSERT INTO `oauth2_refresh_token` VALUES ('0aba7baf7f6cf9f05db4b48d692f76bfe9f4f94829781df7427ca62abc8c4b4125b04ad19ea836d1','ea74048bbc9164feb42d87a76b6f419a4944516344e1fbbc7c33884c0f4ef74137f84afbadcdd7b5','2026-09-20 21:11:32',1),('0e18a1e006844e951640f78da88ddb775ec380b9c6065ba09b4e8b43b49fbab17977ec7930022cc9',NULL,'2026-09-11 23:50:17',1),('1425b536400f39917327c8e62787f4f65749d8dae22060bd7542e65d0e5e368bf22730e94ecf9589','a90ab0dc7a52979dd22453ae3bd9562927c74fd33da9e56feebab32c30d2e80f3c805f6d7c30b172','2026-09-20 22:10:34',1),('3699dcd315034dcaa71b2900bbf45fa1160ac2e2bd45509669d3e68be0aa57fff188f095a8a82c2d',NULL,'2026-09-11 18:17:35',1),('47b1d56336a4fb2f1eae8a6ce462a907c5e50001d2b0a22130b79760617081363f4078266e8b3e4f','f51595f8fd0b7faa6e72e42ca4bf7a40aed68261c494ffd078ed933fefa7aa64663f1dca3dc98a8a','2026-09-21 09:57:37',0),('4898b8f8ab805b65c207e6ac83a6546c4f81bd4b3f06d38da4f3f85c9fc78cb7402b3f5ad19e3c29',NULL,'2026-09-12 11:30:53',1),('48cd4a13d8ebb201531987146a54b1eb0b6c108b2b43deba44fe13ec34d82a1d3fbea7ddc7152c5e','d4d7ea026761abdfaf72a2b5ccd35a7379e3b8c2884f5cdadd6118e0ebf6194c723829d4bed35b46','2026-09-20 08:03:14',1),('4a4d8592570e6bf961c738405f54134162ee55b28145498397e4cebc64843353eda63c33bb1a5d61',NULL,'2026-09-12 00:49:19',1),('4a9965123cc8adbdcdf52ccf295512dc7ece75282776fa1222ad9f1ef345e3a23601930e99c92941',NULL,'2026-09-11 15:20:31',1),('4cb5b732729e08bcc7491f7a4e6a5a11525b4a0dafdc59efa03f6584a9ca06e21f9719a479859fbd',NULL,'2026-09-11 19:16:35',1),('51c2e6029e6b3d4847c239c68a14d7ba0d26a34f4d2542a2cd36294203a6902db04b780ddaa75a9a','5dee4204b4f60eb8302a57235c0ac89024a5e8c8c70e25f2fc10032c488fe5e9d4b89ca86ea19f1f','2026-09-20 23:22:13',0),('62a0c64c8193368b57cc306f2ef50cb4418d25064ac6cf618c54390d9e777fb760f056972ff5bfd8','bb9ab14039f9b210e40bd116d5fb8ae39b37657e70f01b0d65f6552447bce84289c86c0c09f2032a','2026-09-20 23:27:54',0),('6e31ce8d307356bcae272fd93e16927a33833b78d6e166b80fb9d562597111f0346dc9085ae505a5','8a4752586cac23d5b4503484209517d6bd2202b145e97a109dd04424619904dae221d19cdd5d3760','2026-09-20 23:22:19',0),('7365bac1eeaee3f335aea263723d677e7aed23289e5a91301894a6143f76936168c686619d8da492','a3718938e6ae5cbe0a36833199377a4bca12f67881cdc3bcfd6d35ba0bf0a98ddf116f64864159c3','2026-09-20 14:17:36',1),('76c8fa5d1bcfe97e75dd1c1f680363a594b21fbf39efbaae3213032a5bfd6f13f9809a0a25c9d62f',NULL,'2026-09-11 20:15:37',1),('843826bd57d39570730364d01282b1a5a45a970822840f5d417bd0f00e48cd18e229fe197ae91912','ef7a27dd0520bfd50859bb82c9435f6194a388abc35e4a51169b3d90604a1f8acc7fb9c8a39fa26d','2026-09-20 08:04:39',1),('984629b6d74fa9bfc2250a87f79e6afb71855398cb21007e18b0799ac2202ddb184ebe51dc429e78',NULL,'2026-09-11 14:21:28',1),('a509d4b23f1abf40ee27d6ce9b44ad8e9a01d6ef0861021cbd7f559724a5388efaa3575d4a775d01',NULL,'2026-09-11 17:18:34',1),('a7c40affb13514e15386862508fbe8eebad927f510fab82355a62768faea1a2dc695e5db701a34ed','08ab539d37c9ca3e57343953c2ff7e4f6882278c8b63261c998c720833a2c32e1115be9321f47848','2026-09-20 17:49:54',1),('c27435f6f62b5ce7c9dfd01249fb5f571fb6ee1680fad22439aef4d401e8a6fe7a207902877d818a',NULL,'2026-09-11 13:22:28',1),('e335a38adb411362a1f8eae8cf91f7b4de94abeea5c343d149b317fb2aa9846e33970ad96c82c002','543306102e06e78d61acf41ee0e33db54ec65bdba50f46464c1ecf3af35f706729bcd39f38bb91fa','2026-09-20 09:02:16',1),('eaa2f71ac462aa2cbc0fa3b6be24fc49143c434bd6790a081b8cd0cf02f1092dc571c4d451562f90',NULL,'2026-09-12 01:48:20',1),('eab4339bf7fedc117b797072d1c8968788e7ad2aef9c2b8a7483b219db003559da0322127cb0a68c','fffb3f5569099e47cf9e5d203377fdf8188f8174b262094dfb6ce4d33f9c3e883c2a9bcf6ba58d6b','2026-09-20 08:03:14',0),('eadc106282be081b1f75969b2102e1018e04f2298d5c8c60aaf6d7daf2f0c219a5b1a57b8006a0d1','d70f66ed8dbd66eab113aa0608611079b5cbdc14c5fd0a7993c99c1683a0276a17d8dac9f3c8edc5','2026-09-20 14:17:36',0),('f2065100100c06cc731697285d5bacfff00b9d2083ff2119123aad99513e86e95e2640adfc56b560','41bd7008dab53a7fb1b382c58f5c4bb6774ca3a9720e5506967bb40ebbab41bf48fda717a7657b1a','2026-09-20 17:49:53',0),('fa2ad9ecd43cff65a730132dc6ac12b49a467f6676254b7f18c5bdb1cc3949093a052b1f71f487da',NULL,'2026-09-11 12:23:26',1),('faa6fa1dd093583147cf64f72aa7317d685b3baa3665d048801f666f6e8e272d2e1abeeeaf707771',NULL,'2026-09-19 03:35:24',0),('feefc156ae4c9e2a802e957e356c0280826745ab56e8fb0749c2b92fa06763da8a90f06bb70d6b3b',NULL,'2026-09-11 16:19:32',1);
/*!40000 ALTER TABLE `oauth2_refresh_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paineis`
--

DROP TABLE IF EXISTS `paineis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paineis` (
  `host` int NOT NULL,
  `unidade_id` int DEFAULT NULL,
  `senha` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`host`),
  KEY `IDX_CE58BF05EDF4B99B` (`unidade_id`),
  CONSTRAINT `FK_CE58BF05EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paineis`
--

LOCK TABLES `paineis` WRITE;
/*!40000 ALTER TABLE `paineis` DISABLE KEYS */;
/*!40000 ALTER TABLE `paineis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paineis_servicos`
--

DROP TABLE IF EXISTS `paineis_servicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paineis_servicos` (
  `host` int NOT NULL,
  `servico_id` int NOT NULL,
  `unidade_id` int DEFAULT NULL,
  PRIMARY KEY (`host`,`servico_id`),
  KEY `IDX_D98415D3CF2713FD` (`host`),
  KEY `IDX_D98415D382E14982` (`servico_id`),
  KEY `IDX_D98415D3EDF4B99B` (`unidade_id`),
  CONSTRAINT `FK_D98415D382E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_D98415D3CF2713FD` FOREIGN KEY (`host`) REFERENCES `paineis` (`host`),
  CONSTRAINT `FK_D98415D3EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paineis_servicos`
--

LOCK TABLES `paineis_servicos` WRITE;
/*!40000 ALTER TABLE `paineis_servicos` DISABLE KEYS */;
/*!40000 ALTER TABLE `paineis_servicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `painel_senha`
--

DROP TABLE IF EXISTS `painel_senha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `painel_senha` (
  `id` int NOT NULL AUTO_INCREMENT,
  `servico_id` int DEFAULT NULL,
  `unidade_id` int DEFAULT NULL,
  `num_senha` int NOT NULL,
  `sig_senha` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `msg_senha` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `local` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_local` smallint NOT NULL,
  `peso` smallint NOT NULL,
  `prioridade` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nome_cliente` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `documento_cliente` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_390182E682E14982` (`servico_id`),
  KEY `IDX_390182E6EDF4B99B` (`unidade_id`),
  CONSTRAINT `FK_390182E682E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_390182E6EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `painel_senha`
--

LOCK TABLES `painel_senha` WRITE;
/*!40000 ALTER TABLE `painel_senha` DISABLE KEYS */;
INSERT INTO `painel_senha` VALUES (3,6,2,1,'A','','Sala - TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(4,6,2,1,'A','','Sala - TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(5,6,2,1,'A','','Sala - TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(6,6,2,1,'A','','Sala - TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(7,6,2,1,'A','','Sala - TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(8,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(9,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(10,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(11,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(12,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(13,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(14,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(15,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(16,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(17,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(18,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(19,6,2,1,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(20,6,2,2,'A','','Sala do TFD',2,0,'Normal','Felipe gabriel silva rocha','11'),(21,6,2,2,'A','','Sala do TFD',2,0,'Normal','Felipe gabriel silva rocha','11'),(22,6,2,3,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11'),(23,6,2,3,'A','','Sala do TFD',1,0,'Normal','Felipe gabriel silva rocha','11');
/*!40000 ALTER TABLE `painel_senha` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfis`
--

DROP TABLE IF EXISTS `perfis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfis` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `modulos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '(DC2Type:simple_array)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfis`
--

LOCK TABLES `perfis` WRITE;
/*!40000 ALTER TABLE `perfis` DISABLE KEYS */;
INSERT INTO `perfis` VALUES (2,'Recepcionista','recepcionista','novosga.triage,novosga.monitor,novosga.customers,novosga.reports','2026-08-19 17:30:48','2026-08-19 18:25:49'),(3,'Usuário TFD','tfd user','novosga.attendance,novosga.monitor,novosga.customers,novosga.reports','2026-08-19 17:40:27',NULL),(4,'Usuário Regulação','user Regulação','novosga.attendance,novosga.monitor,novosga.customers,novosga.reports','2026-08-19 17:40:57','2026-08-20 08:54:18');
/*!40000 ALTER TABLE `perfis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prioridades`
--

DROP TABLE IF EXISTS `prioridades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prioridades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `peso` smallint NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `cor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prioridades`
--

LOCK TABLES `prioridades` WRITE;
/*!40000 ALTER TABLE `prioridades` DISABLE KEYS */;
INSERT INTO `prioridades` VALUES (3,'Normal','Atendimento normal',0,1,'2026-08-11 12:15:20',NULL,NULL,'#0000FF'),(4,'Prioridade','Atendimento prioritário',1,1,'2026-08-11 12:15:20',NULL,NULL,'#FF0000');
/*!40000 ALTER TABLE `prioridades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicos`
--

DROP TABLE IF EXISTS `servicos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `macro_id` int DEFAULT NULL,
  `nome` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `peso` smallint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_89DD09E3F43A187E` (`macro_id`),
  CONSTRAINT `FK_89DD09E3F43A187E` FOREIGN KEY (`macro_id`) REFERENCES `servicos` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicos`
--

LOCK TABLES `servicos` WRITE;
/*!40000 ALTER TABLE `servicos` DISABLE KEYS */;
INSERT INTO `servicos` VALUES (5,NULL,'Coleta de dados - Recepção','coleta',1,1,'2026-08-11 12:25:23',NULL,NULL),(6,NULL,'Agendamento de Passagem - TFD','Agendamento para passagem',1,1,'2026-08-19 17:29:23',NULL,NULL),(7,NULL,'Serviço - Regulação','sr',1,1,'2026-08-19 18:06:20','2026-08-20 08:53:38',NULL);
/*!40000 ALTER TABLE `servicos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicos_metadata`
--

DROP TABLE IF EXISTS `servicos_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicos_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `servico_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`servico_id`),
  KEY `IDX_8E8BF0E482E14982` (`servico_id`),
  CONSTRAINT `FK_8E8BF0E482E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicos_metadata`
--

LOCK TABLES `servicos_metadata` WRITE;
/*!40000 ALTER TABLE `servicos_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `servicos_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicos_unidades`
--

DROP TABLE IF EXISTS `servicos_unidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicos_unidades` (
  `servico_id` int NOT NULL,
  `unidade_id` int NOT NULL,
  `local_id` int DEFAULT NULL,
  `departamento_id` int DEFAULT NULL,
  `sigla` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `peso` smallint NOT NULL,
  `numero_inicial` int NOT NULL,
  `numero_final` int DEFAULT NULL,
  `incremento` int NOT NULL,
  `mensagem` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo` smallint DEFAULT NULL,
  `maximo` int DEFAULT NULL,
  PRIMARY KEY (`servico_id`,`unidade_id`),
  KEY `IDX_C50F703482E14982` (`servico_id`),
  KEY `IDX_C50F7034EDF4B99B` (`unidade_id`),
  KEY `IDX_C50F70345D5A2101` (`local_id`),
  KEY `IDX_C50F70345A91C08D` (`departamento_id`),
  CONSTRAINT `FK_C50F70345A91C08D` FOREIGN KEY (`departamento_id`) REFERENCES `departamentos` (`id`),
  CONSTRAINT `FK_C50F70345D5A2101` FOREIGN KEY (`local_id`) REFERENCES `locais` (`id`),
  CONSTRAINT `FK_C50F703482E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_C50F7034EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicos_unidades`
--

LOCK TABLES `servicos_unidades` WRITE;
/*!40000 ALTER TABLE `servicos_unidades` DISABLE KEYS */;
INSERT INTO `servicos_unidades` VALUES (5,2,NULL,2,'B',1,1,1,NULL,1,NULL,1,NULL),(6,2,NULL,3,'A',1,1,1,NULL,1,NULL,1,NULL),(7,2,NULL,4,'C',1,1,1,NULL,1,NULL,1,NULL);
/*!40000 ALTER TABLE `servicos_unidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `servicos_usuarios`
--

DROP TABLE IF EXISTS `servicos_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servicos_usuarios` (
  `servico_id` int NOT NULL,
  `unidade_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `peso` smallint NOT NULL,
  PRIMARY KEY (`servico_id`,`unidade_id`,`usuario_id`),
  KEY `IDX_CF69430282E14982` (`servico_id`),
  KEY `IDX_CF694302EDF4B99B` (`unidade_id`),
  KEY `IDX_CF694302DB38439E` (`usuario_id`),
  CONSTRAINT `FK_CF69430282E14982` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`),
  CONSTRAINT `FK_CF694302DB38439E` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`),
  CONSTRAINT `FK_CF694302EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `servicos_usuarios`
--

LOCK TABLES `servicos_usuarios` WRITE;
/*!40000 ALTER TABLE `servicos_usuarios` DISABLE KEYS */;
INSERT INTO `servicos_usuarios` VALUES (5,2,3,1),(6,2,5,1),(7,2,4,1);
/*!40000 ALTER TABLE `servicos_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unidades`
--

DROP TABLE IF EXISTS `unidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unidades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `impressao_cabecalho` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `impressao_rodape` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `impressao_exibir_data` tinyint(1) NOT NULL,
  `impressao_exibir_prioridade` tinyint(1) NOT NULL,
  `impressao_exibir_nome_unidade` tinyint(1) NOT NULL,
  `impressao_exibir_nome_servico` tinyint(1) NOT NULL,
  `impressao_exibir_mensagem_servico` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unidades`
--

LOCK TABLES `unidades` WRITE;
/*!40000 ALTER TABLE `unidades` DISABLE KEYS */;
INSERT INTO `unidades` VALUES (2,'Secretaria de Saúde','sec saude',1,'2026-08-11 12:15:19','2026-08-19 19:47:43',NULL,'NovoSGA','NovoSGA',1,1,1,1,1);
/*!40000 ALTER TABLE `unidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unidades_metadata`
--

DROP TABLE IF EXISTS `unidades_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `unidades_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `unidade_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`unidade_id`),
  KEY `IDX_A21ACF47EDF4B99B` (`unidade_id`),
  CONSTRAINT `FK_A21ACF47EDF4B99B` FOREIGN KEY (`unidade_id`) REFERENCES `unidades` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unidades_metadata`
--

LOCK TABLES `unidades_metadata` WRITE;
/*!40000 ALTER TABLE `unidades_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `unidades_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `login` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sobrenome` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senha` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL,
  `ultimo_acesso` datetime DEFAULT NULL,
  `ip` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `algorithm` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `admin` tinyint(1) NOT NULL,
  `salt` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_EF687F2AA08CB10` (`login`),
  UNIQUE KEY `UNIQ_EF687F2E7927C74` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (2,'admin','Administrador','Global',NULL,'$2y$12$CygrsEV2Ji7AybQz9NGfWecH4JTuEC.BrcKoByUMchYO0SFCDjv96',1,NULL,NULL,'tpjfuie79nfptd0n4e48t0ur6f','bcrypt',1,NULL,'2026-08-11 12:14:59','2026-08-20 22:40:10',NULL),(3,'recepcionista','recepcionista','recep','recepcionista@gmail.com','$2y$12$Om7wiB/XeRQ2fpa6myIhjuzgihy6DTJA.JNWj0E7MP.D0UyWAd6ue',1,NULL,NULL,'kvt302utcqektdbh2rgjqup8l5','bcrypt',0,NULL,'2026-08-19 17:32:11','2026-08-20 08:58:47',NULL),(4,'regulacao','agendamentouser','agendauser','useragendamento@gmail.com','$2y$12$3wV6wy0z0djbYfvyJlsCDOBqrzdhshIjkw9B6xLiJ7JlrWQjo9BP2',1,NULL,NULL,'sthn5b2v9rrtedn0569eo15aun','bcrypt',0,NULL,'2026-08-19 17:44:52','2026-08-20 09:00:19',NULL),(5,'tfd','usertfd','tfd','usertfd@gmail.com','$2y$12$wd9Nmw/f33NUetd5dmAxGe9DCG61yRr..FbxRGf.9iRknkx7k1zK6',1,NULL,NULL,'ihub7hor2g6vi0vsbfqhn9bs2k','bcrypt',0,NULL,'2026-08-19 18:11:35','2026-08-20 22:40:31',NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios_metadata`
--

DROP TABLE IF EXISTS `usuarios_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios_metadata` (
  `namespace` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` int NOT NULL,
  `value` json NOT NULL COMMENT '(DC2Type:json)',
  PRIMARY KEY (`namespace`,`name`,`usuario_id`),
  KEY `IDX_BD8E7838DB38439E` (`usuario_id`),
  CONSTRAINT `FK_BD8E7838DB38439E` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios_metadata`
--

LOCK TABLES `usuarios_metadata` WRITE;
/*!40000 ALTER TABLE `usuarios_metadata` DISABLE KEYS */;
INSERT INTO `usuarios_metadata` VALUES ('global','atendimento.local',2,'3'),('global','atendimento.local',3,'2'),('global','atendimento.local',4,'2'),('global','atendimento.local',5,'3'),('global','atendimento.num_local',2,'1'),('global','atendimento.num_local',3,'1'),('global','atendimento.num_local',4,'1'),('global','atendimento.num_local',5,'1'),('global','atendimento.tipo',2,'\"todos\"'),('global','atendimento.tipo',3,'\"todos\"'),('global','atendimento.tipo',4,'\"todos\"'),('global','atendimento.tipo',5,'\"todos\"'),('global','session.unidade',2,'4'),('global','session.unidade',3,'2'),('global','session.unidade',4,'2'),('global','session.unidade',5,'2');
/*!40000 ALTER TABLE `usuarios_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `view_atendimentos`
--

DROP TABLE IF EXISTS `view_atendimentos`;
/*!50001 DROP VIEW IF EXISTS `view_atendimentos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_atendimentos` AS SELECT 
 1 AS `id`,
 1 AS `num_local`,
 1 AS `dt_age`,
 1 AS `dt_cheg`,
 1 AS `dt_cha`,
 1 AS `dt_ini`,
 1 AS `dt_fim`,
 1 AS `tempo_espera`,
 1 AS `tempo_permanencia`,
 1 AS `tempo_atendimento`,
 1 AS `tempo_deslocamento`,
 1 AS `status`,
 1 AS `resolucao`,
 1 AS `observacao`,
 1 AS `senha_sigla`,
 1 AS `senha_numero`,
 1 AS `cliente_id`,
 1 AS `unidade_id`,
 1 AS `servico_id`,
 1 AS `prioridade_id`,
 1 AS `usuario_id`,
 1 AS `usuario_tri_id`,
 1 AS `atendimento_id`,
 1 AS `local_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_atendimentos_codificados`
--

DROP TABLE IF EXISTS `view_atendimentos_codificados`;
/*!50001 DROP VIEW IF EXISTS `view_atendimentos_codificados`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_atendimentos_codificados` AS SELECT 
 1 AS `valor_peso`,
 1 AS `servico_id`,
 1 AS `atendimento_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `webhooks`
--

DROP TABLE IF EXISTS `webhooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhooks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) COLLATE utf8mb3_unicode_ci NOT NULL,
  `url` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  `headers` json NOT NULL,
  `events` json NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL COMMENT '(DC2Type:datetime_immutable)',
  `updated_at` datetime DEFAULT NULL COMMENT '(DC2Type:datetime_immutable)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhooks`
--

LOCK TABLES `webhooks` WRITE;
/*!40000 ALTER TABLE `webhooks` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'novosga2'
--

--
-- Final view structure for view `view_atendimentos`
--

/*!50001 DROP VIEW IF EXISTS `view_atendimentos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`novosga`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_atendimentos` AS select `atendimentos`.`id` AS `id`,`atendimentos`.`num_local` AS `num_local`,`atendimentos`.`dt_age` AS `dt_age`,`atendimentos`.`dt_cheg` AS `dt_cheg`,`atendimentos`.`dt_cha` AS `dt_cha`,`atendimentos`.`dt_ini` AS `dt_ini`,`atendimentos`.`dt_fim` AS `dt_fim`,`atendimentos`.`tempo_espera` AS `tempo_espera`,`atendimentos`.`tempo_permanencia` AS `tempo_permanencia`,`atendimentos`.`tempo_atendimento` AS `tempo_atendimento`,`atendimentos`.`tempo_deslocamento` AS `tempo_deslocamento`,`atendimentos`.`status` AS `status`,`atendimentos`.`resolucao` AS `resolucao`,`atendimentos`.`observacao` AS `observacao`,`atendimentos`.`senha_sigla` AS `senha_sigla`,`atendimentos`.`senha_numero` AS `senha_numero`,`atendimentos`.`cliente_id` AS `cliente_id`,`atendimentos`.`unidade_id` AS `unidade_id`,`atendimentos`.`servico_id` AS `servico_id`,`atendimentos`.`prioridade_id` AS `prioridade_id`,`atendimentos`.`usuario_id` AS `usuario_id`,`atendimentos`.`usuario_tri_id` AS `usuario_tri_id`,`atendimentos`.`atendimento_id` AS `atendimento_id`,`atendimentos`.`local_id` AS `local_id` from `atendimentos` union all select `historico_atendimentos`.`id` AS `id`,`historico_atendimentos`.`num_local` AS `num_local`,`historico_atendimentos`.`dt_age` AS `dt_age`,`historico_atendimentos`.`dt_cheg` AS `dt_cheg`,`historico_atendimentos`.`dt_cha` AS `dt_cha`,`historico_atendimentos`.`dt_ini` AS `dt_ini`,`historico_atendimentos`.`dt_fim` AS `dt_fim`,`historico_atendimentos`.`tempo_espera` AS `tempo_espera`,`historico_atendimentos`.`tempo_permanencia` AS `tempo_permanencia`,`historico_atendimentos`.`tempo_atendimento` AS `tempo_atendimento`,`historico_atendimentos`.`tempo_deslocamento` AS `tempo_deslocamento`,`historico_atendimentos`.`status` AS `status`,`historico_atendimentos`.`resolucao` AS `resolucao`,`historico_atendimentos`.`observacao` AS `observacao`,`historico_atendimentos`.`senha_sigla` AS `senha_sigla`,`historico_atendimentos`.`senha_numero` AS `senha_numero`,`historico_atendimentos`.`cliente_id` AS `cliente_id`,`historico_atendimentos`.`unidade_id` AS `unidade_id`,`historico_atendimentos`.`servico_id` AS `servico_id`,`historico_atendimentos`.`prioridade_id` AS `prioridade_id`,`historico_atendimentos`.`usuario_id` AS `usuario_id`,`historico_atendimentos`.`usuario_tri_id` AS `usuario_tri_id`,`historico_atendimentos`.`atendimento_id` AS `atendimento_id`,`historico_atendimentos`.`local_id` AS `local_id` from `historico_atendimentos` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_atendimentos_codificados`
--

/*!50001 DROP VIEW IF EXISTS `view_atendimentos_codificados`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`novosga`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_atendimentos_codificados` AS select `atendimentos_codificados`.`valor_peso` AS `valor_peso`,`atendimentos_codificados`.`servico_id` AS `servico_id`,`atendimentos_codificados`.`atendimento_id` AS `atendimento_id` from `atendimentos_codificados` union all select `historico_atendimentos_codificados`.`valor_peso` AS `valor_peso`,`historico_atendimentos_codificados`.`servico_id` AS `servico_id`,`historico_atendimentos_codificados`.`atendimento_id` AS `atendimento_id` from `historico_atendimentos_codificados` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-21 10:00:43
