SELECT *
FROM ProjectsSQL..NashvilleHousing


-- Standardize Date Format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

-- Make a structure (address, city, state)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From ProjectsSQL..NashvilleHousing a
JOIN ProjectsSQL..NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectsSQL..NashvilleHousing a
JOIN ProjectsSQL..NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

-- Convert Y, N to Yes or No
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectsSQL..NashvilleHousing
Group by SoldAsVacant


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Delete duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, 
SaleDate, SalePrice, LegalReference 
ORDER BY UniqueID) row_num
FROM ProjectsSQL..NashvilleHousing
)
DELETE
From RowNumCTE
where row_num > 1

-- Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress