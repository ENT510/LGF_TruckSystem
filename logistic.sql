

-- Dump della struttura di tabella apocalypse.lgf_logistic
CREATE TABLE IF NOT EXISTS `lgf_logistic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Player` varchar(255) NOT NULL,
  `CurrentLevel` int(11) NOT NULL,
  `reward_redeemed` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;