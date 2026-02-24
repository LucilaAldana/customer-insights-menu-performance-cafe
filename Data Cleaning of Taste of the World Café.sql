-- CUSTOMER INSIGHTS AND MENU PERFORMANCE ANALYSIS FOR TASTE OF THE WORLD CAFÉ - by Lucila Aldana Quiñonez | Marketing Data Analyst
-- Data Cleaning:

	-- Creating the database:
DROP DATABASE IF EXISTS `Taste_of_the_World_Cafe`;
CREATE DATABASE `Taste_of_the_World_Cafe`;
USE `Taste_of_the_World_Cafe`;

	-- Importing data tables from .csv files and becoming familiar with them:
SELECT *
FROM menu_items;

SELECT *
FROM order_details;

SELECT *
FROM restaurant_db_data_dictionary;

	-- Renaming the tables that are useful for analysis as raw data to keep them as the original data:
RENAME TABLE menu_items TO menu_items_rawdata;

RENAME TABLE order_details TO order_details_rawdata;

	-- Creating copies of the raw data tables to clean them while keeping the originals:
CREATE TABLE menu_items_staging LIKE menu_items_rawdata;

INSERT menu_items_staging
SELECT *
FROM menu_items_rawdata;

SELECT *
FROM menu_items_staging;


CREATE TABLE order_details_staging LIKE order_details_rawdata;

INSERT order_details_staging
SELECT *
FROM order_details_rawdata;

SELECT *
FROM order_details_staging;

	-- Cleaning data from the menu_items_staging table:
        -- Correcting menu_item_id column title:
SHOW COLUMNS FROM menu_items_staging;

ALTER TABLE menu_items_staging
RENAME COLUMN ï»¿menu_item_id TO menu_item_id;

		-- Triming all possible blank spaces to the left and right from row values:
UPDATE menu_items_staging
SET menu_item_id = TRIM(menu_item_id);

UPDATE menu_items_staging
SET item_name = TRIM(item_name);

UPDATE menu_items_staging
SET category = TRIM(category);

UPDATE menu_items_staging
SET price = TRIM(price);

		-- Identifying if there are any null or blank values:
SELECT *
FROM menu_items_staging
WHERE menu_item_id IS NULL
OR menu_item_id = '';

SELECT *
FROM menu_items_staging
WHERE item_name IS NULL
OR item_name = '';

SELECT *
FROM menu_items_staging
WHERE category IS NULL
OR category = '';

SELECT *
FROM menu_items_staging
WHERE price IS NULL
OR price = '';

        -- Checking how many menu items are there and if there are any missing or duplicate menu item IDs:
SELECT COUNT(*)
FROM menu_items_staging;

SELECT COUNT(DISTINCT menu_item_id) AS unique_menu_item_id
FROM menu_items_staging;

		-- Checking if there are no duplicate values in the item_name column
SELECT COUNT(DISTINCT item_name) AS unique_item_name
FROM menu_items_staging;

		-- Checking if the category column has consistent/correct values:
SELECT DISTINCT category
FROM menu_items_staging
ORDER BY category;

SELECT COUNT(DISTINCT category) AS unique_categories
FROM menu_items_staging;

        -- Correcting the data type of the price column from double to decimal:
ALTER TABLE menu_items_staging
MODIFY price DECIMAL(10,2);

	-- Cleaning data from the order_details_staging table:
        -- Correcting order_details_id column title:
SHOW COLUMNS FROM order_details_staging;

ALTER TABLE order_details_staging
RENAME COLUMN ï»¿order_details_id TO order_details_id;

		-- Triming all possible blank spaces to the left and right from row values:
UPDATE order_details_staging
SET order_details_id = TRIM(order_details_id);

UPDATE order_details_staging
SET order_id = TRIM(order_id);

UPDATE order_details_staging
SET order_date = TRIM(order_date);

UPDATE order_details_staging
SET order_time = TRIM(order_time);

UPDATE order_details_staging
SET item_id = TRIM(item_id);

		-- Identifying if there are any null or blank values:
SELECT *
FROM order_details_staging
WHERE order_details_id IS NULL
OR order_details_id = '';

SELECT *
FROM order_details_staging
WHERE order_id IS NULL
OR order_id = '';

SELECT *
FROM order_details_staging
WHERE order_date IS NULL
OR order_date = '';

SELECT *
FROM order_details_staging
WHERE order_time IS NULL
OR order_time = '';

SELECT *
FROM order_details_staging
WHERE item_id IS NULL
OR item_id = '';

		-- The column item_id is the only one that has NULL values:
SELECT COUNT(*)
FROM order_details_staging
WHERE item_id IS NULL;

        -- Checking how many order details are there and if there are any duplicate order details:
SELECT COUNT(*)
FROM order_details_staging;

SELECT COUNT(DISTINCT order_details_id) AS unique_order_details_id
FROM order_details_staging;

        -- Checking how many orders are registered in the table:
SELECT COUNT(DISTINCT order_id) AS unique_order_id
FROM order_details_staging;

        -- Correcting the data type of the order_date column from text to date:
UPDATE order_details_staging 
SET `order_date` = STR_TO_DATE(`order_date`, '%m/%d/%Y');

ALTER TABLE order_details_staging
MODIFY COLUMN `order_date` DATE;

        -- Correcting the data type of the order_time column from text to time:
UPDATE order_details_staging
SET order_time = DATE_FORMAT(STR_TO_DATE(order_time, '%r'), '%H:%i:%s');

ALTER TABLE order_details_staging
MODIFY order_time TIME;

	-- Renaming clean tables:
CREATE TABLE menu_items_cleaned LIKE menu_items_staging;

INSERT menu_items_cleaned
SELECT *
FROM menu_items_staging;


CREATE TABLE order_details_cleaned LIKE order_details_staging;

INSERT order_details_cleaned
SELECT *
FROM order_details_staging;


SELECT *
FROM menu_items_cleaned;
SELECT *
FROM order_details_cleaned;