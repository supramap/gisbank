ALTER TABLE `gisbank`.`isolates` ADD CONSTRAINT `lococation_con` FOREIGN KEY `lococation_key` (`location_id`)
    REFERENCES `locations` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
 ADD CONSTRAINT `pathogen` FOREIGN KEY `pathogen` (`pathogen_id`)
    REFERENCES `pathogens` (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
 ADD CONSTRAINT `host` FOREIGN KEY `host` (`host_id`)
    REFERENCES `hosts` (id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;


ALTER TABLE gisbank.sequences ADD CONSTRAINT `isolate_key` FOREIGN KEY `isolate_key` (`isolate_id`)
    REFERENCES `isolates` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
ADD CONSTRAINT `protein_key` FOREIGN KEY `protein_key` (`protein_id`)
    REFERENCES `proteins` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;
 
