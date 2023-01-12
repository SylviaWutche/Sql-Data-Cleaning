
SELECT 
    *
FROM
    nashville_housing_data.nashville_housing;

-- 	STANDARDIZED DATE
SELECT 
    SaleDate, CONVERT( SaleDate , DATE) Date
FROM
    nashville_housing;

UPDATE nashville_housing 
SET 
    SaleDate = CONVERT( SaleDate , DATE);

-- 	POPULATE PROPERTY ADDRESS 
UPDATE nashville_housing 
SET 
    PropertyAddress = NULLIF(propertyAddress, '''');

SELECT 
    *
FROM
    nashville_housing
ORDER BY ParcelID;

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    a.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;

UPDATE nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

-- 	BREAKING OUT ADDRESSES INTO INDIVIDUAL COLUMNS (ADDRESS, CITY,STATE)

SELECT 
    PropertyAddress
FROM
    nashville_housing
ORDER BY ParcelID;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1) State
FROM
    nashville_housing;

ALTER TABLE nashville_housing
ADD Address VARCHAR(255);

UPDATE nashville_housing 
SET 
    Address = SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1);

ALTER TABLE nashville_housing
ADD City VARCHAR(255);

UPDATE nashville_housing 
SET 
    City = SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1);


UPDATE nashville_housing 
SET 
    OwnerAddress = NULLIF(OwnerAddress, '''');
 
SELECT 
    OwnerAddress
FROM
    nashville_housing;

SELECT 
    OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAA,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1),
    SUBSTRING_INDEX(OwnerAddress, ',', - 1)
FROM
    nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerADress VARCHAR(255);

UPDATE nashville_housing 
SET 
    OwnerADress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing
ADD OwnerCity VARCHAR(255);
 
UPDATE nashville_housing 
SET 
    OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);

ALTER TABLE nashville_housing
ADD OwnerState VARCHAR(255);

UPDATE nashville_housing 
SET 
    OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', - 1);


-- 	CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT FIELD"

SELECT DISTINCT
    SoldAsVacant, COUNT(SoldAsVacant)
FROM
    nashville_housing
GROUP BY SoldAsVacant;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'No' THEN 'No'
        WHEN SoldAsVacant = 'Yes' THEN 'Yes'
        ELSE 'SoldAsVacant'
    END
FROM
    nashville_housing;

UPDATE nashville_housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        WHEN SoldAsVacant = 'No' THEN 'No'
        WHEN SoldAsVacant = 'Yes' THEN 'Yes'
        ELSE 'SoldAsVacant'
    END;

-- 	REMOVE DUPLICATES

CREATE TEMPORARY TABLE Duplicate_values AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY 
	ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID) RN
FROM nashville_housing
ORDER BY ParcelID);

DELETE FROM Duplicate_values 
WHERE
    RN > 1;

SELECT 
    *
FROM
    Duplicate_values
WHERE
    RN > 1;


-- DELETE UNUSED COLUMNS

SELECT 
    *
FROM
    nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress, DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict

