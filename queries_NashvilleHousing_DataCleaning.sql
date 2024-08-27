/* 
DATA CLEANING Tutorial
This Tutorial covers the following tasks:
- standardizing date format
- populate NULL data
- breaking out substrings
- standardizing column entries
- removing duplicates
- dropping unused columns
*/


-- --------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

UPDATE nashville_housing
SET SaleDateConverted = DATE(SaleDate);

-- --------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- using IFNULL()
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- --------------------------------------------------------------------------------------------------------------------

-- breaking out address into individual columns (Address, City, State)

-- using SUBSTRING
SELECT 
PropertyAddress,
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1) AS Address,
SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress nvarchar(250), 
ADD PropertySplitCity nvarchar(250);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') -1),
PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress));

-- using SUBSTRING_INDEX
SELECT OwnerAddress, 
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS OwnerSplitCity,
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerSplitAddress nvarchar(250), 
ADD OwnerSplitCity nvarchar(250),
ADD OwnerSplitState nvarchar(250);

UPDATE nashville_housing
SET 
	OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
	OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1),
	OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- -------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'SoldAsVacant' Field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS count
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY count DESC;

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    ELSE SoldAsVacant
END AS SoldAsVacantUpdate
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END;

-- ---------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- using CTE
DELETE nh
FROM nashville_housing nh
JOIN (SELECT UniqueID
FROM (
	SELECT UniqueID,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
						) AS row_num
	FROM nashville_housing
    ) AS RowNumCTE
    WHERE row_num > 1
) AS duplicates
	ON nh.UniqueID = duplicates.UniqueID;

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, 
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
        ) AS row_num
    FROM nashville_housing
) AS RowNumCTE
WHERE row_num > 1;

-- ------------------------------------------------------------------------------------------------------------

-- Delete unused columns
ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate;