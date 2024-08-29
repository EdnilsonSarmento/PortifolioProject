/*

Cleaning Data in SQL Queries

By Ednilson Sarmento

*/

Select *
From PortifolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate) as NewDate
From PortifolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortifolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortifolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address1,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address2
From PortifolioProject.dbo.NashvilleHousing

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortifolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortifolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Addess, City and State
Select OwnerAddress
From PortifolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortifolioProject.dbo.NashvilleHousing

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
Add OnwerSplitAddress nvarchar(255);

Update PortifolioProject.dbo.NashvilleHousing
SET OnwerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
Add OnwerSplitCity nvarchar(255);

Update PortifolioProject.dbo.NashvilleHousing
SET OnwerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
Add OnwerSplitState nvarchar(255);

Update PortifolioProject.dbo.NashvilleHousing
SET OnwerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),  Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 02


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
  When SoldAsVacant = 'N' then 'No'
  Else SoldAsVacant
  End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
  When SoldAsVacant = 'N' then 'No'
  Else SoldAsVacant
  End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
   PropertyAddress,
   SalePrice,
   SaleDate,
   LegalReference
   ORDER BY
   UniqueID
   ) row_num
From NashvilleHousing
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict