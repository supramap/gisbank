-- phpMyAdmin SQL Dump
-- version 3.2.5
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 04, 2010 at 11:59 AM
-- Server version: 5.4.3
-- PHP Version: 5.3.0

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `gisbank`
--

-- --------------------------------------------------------

--
-- Table structure for table `isolates`
--

CREATE TABLE IF NOT EXISTS `isolates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tax_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `isolate_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sequence_ids` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `virus_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `passage` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `collect_date` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `host` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `notes` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `update_date` datetime DEFAULT NULL,
  `is_public` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `isolate_submitter` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `sample_lab` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sequence_lab` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `iv_animal_vaccin_product` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `resist_to_adamantanes` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `resist_to_oseltamivir` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `resist_to_zanamivir` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `resist_to_peramivir` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `resist_to_other` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `h1n1_swine_set` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `lab_culture` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `is_complete` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `iv_sample_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `date_selected_for_vaccine` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `provider_sample_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `antigen_character` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `pathogen_test_info` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `antiviral_resistance` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `authors` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `is_vaccinated` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `human_specimen_source` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `animal_specimen_source` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `animal_health_status` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `animal_domestic_status` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `source_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `geoplace_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `host_age` int(11) DEFAULT NULL,
  `host_gender` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `zip_code` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `patient_status` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `antiviral_treatment` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `outbreak` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `vaccination_last_year` datetime DEFAULT NULL,
  `pathogenicity` text CHARACTER SET utf8,
  `computed_antiviral` text CHARACTER SET utf8,
  `latitude` decimal(10,0) DEFAULT NULL,
  `longitude` decimal(10,0) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_isolates_u1` (`tax_id`,`isolate_id`),
  KEY `tax_id` (`tax_id`),
  KEY `isolate_id` (`isolate_id`),
  KEY `id` (`id`),
  KEY `host` (`host`),
  KEY `location` (`location`),
  KEY `name` (`name`),
  KEY `tax_id_iso_id_name` (`tax_id`,`isolate_id`,`name`),
  KEY `name_host_location` (`name`,`host`,`location`),
  KEY `tax_iso` (`tax_id`,`isolate_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7999 ;

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE IF NOT EXISTS `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

-- --------------------------------------------------------

--
-- Table structure for table `queries`
--

CREATE TABLE IF NOT EXISTS `queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `isolate_name` varchar(255) DEFAULT NULL,
  `virus_type` varchar(255) DEFAULT NULL,
  `h1n1_swine_set` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `max_collect_date` datetime DEFAULT NULL,
  `min_collect_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ha` tinyint(1) DEFAULT NULL,
  `na` tinyint(1) DEFAULT NULL,
  `pb1` tinyint(1) DEFAULT NULL,
  `pb2` tinyint(1) DEFAULT NULL,
  `pa` tinyint(1) DEFAULT NULL,
  `np` tinyint(1) DEFAULT NULL,
  `mp` tinyint(1) DEFAULT NULL,
  `ns` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=202 ;

-- --------------------------------------------------------

--
-- Table structure for table `schema_migrations`
--

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sequences`
--

CREATE TABLE IF NOT EXISTS `sequences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `genbank_acc_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sequence_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `isolate_id` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `data` text CHARACTER SET utf8,
  `created_at` datetime DEFAULT NULL,
  `sequence_type` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_sequences_u2` (`isolate_id`,`sequence_type`),
  UNIQUE KEY `unique_sequences_genbank_acc_id` (`genbank_acc_id`),
  UNIQUE KEY `unique_sequences_sequence_id` (`sequence_id`),
  KEY `genbank_acc_id` (`genbank_acc_id`),
  KEY `sequence_id` (`sequence_id`),
  KEY `isolate_id` (`isolate_id`,`sequence_type`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=26963 ;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=204 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `crypted_password` varchar(255) NOT NULL,
  `password_salt` varchar(255) NOT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `single_access_token` varchar(255) NOT NULL,
  `perishable_token` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `last_request_at` datetime DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;
