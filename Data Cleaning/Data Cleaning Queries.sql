/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing$


-- Standardize Data Format


Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing$


ALTER TABLE NashvilleHousing$
Add SaleDateConverted Date

Update NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)




--Populate Property Address Data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
--SET PropertyAddress = ISNULL(a.PropertyAddress, 'No Address')
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City) In PropertyAddress

Select SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CityAddress
From PortfolioProject.dbo.NashvilleHousing$



ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )



ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing$



-- Breaking out Address into Individual Columns (Address, City, State) In OwnerAddress

Select PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From PortfolioProject.dbo.NashvilleHousing$



ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)



ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)



ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing$




-- Change Y and N to Yes and No in "SoldAsVacant" field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing$
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
    ELSE SoldAsVacant
  End
From PortfolioProject.dbo.NashvilleHousing$


Update NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
    ELSE SoldAsVacant
  End




-- Find Duplicates

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing$
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress






-- Remove Duplicates (Normally, we should not delete any data from the database, just for portfolio)

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing$
)
DELETE
From RowNumCTE
Where row_num > 1




-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing$

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN TaxDistrict
