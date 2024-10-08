CREATE TABLE IF NOT EXISTS `UntamedGarage` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `charidentifier` VARCHAR(50) NOT NULL,
    `job` VARCHAR(50) NOT NULL,
    `wagon` VARCHAR(50) NOT NULL,
    `is_taken` BOOLEAN DEFAULT FALSE,
    `last_used` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
