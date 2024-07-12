CREATE TABLE IF NOT EXISTS `UntamedGarage` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `charidentifier` VARCHAR(50) NOT NULL,
    `wagon` VARCHAR(50) NOT NULL,
    `job` VARCHAR(50) NOT NULL,
    `is_taken` BOOLEAN NOT NULL DEFAULT FALSE,
    `last_used` BIGINT NOT NULL,
    PRIMARY KEY (`id`)
);
