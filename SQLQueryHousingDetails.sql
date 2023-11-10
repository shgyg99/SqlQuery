
-- Standardize Date Format

select SaleDate, convert(date, SaleDate) 
from portfolioProject.dbo.NashvilleHousing

alter table portfolioProject.dbo.NashvilleHousing 
add SaleDateConverted date

update portfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


-- Populate Property Address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
join portfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioProject.dbo.NashvilleHousing a
join portfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress 
from portfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from portfolioProject.dbo.NashvilleHousing



alter table portfolioProject.dbo.NashvilleHousing
add PropertySplitAddress varchar(255)

alter table portfolioProject.dbo.NashvilleHousing
add PropertySplitCity varchar(255)


update portfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update portfolioProject.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select * 
from portfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from portfolioProject.dbo.NashvilleHousing



alter table portfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress varchar(255)

update portfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table portfolioProject.dbo.NashvilleHousing
add OwnerSplitCity varchar(255)


update portfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)


alter table portfolioProject.dbo.NashvilleHousing
add OwnerSplitState varchar(255)

update portfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant)
from portfolioProject.dbo.NashvilleHousing

update portfolioProject.dbo.NashvilleHousing
set SoldAsVacant = 'Yes'
from portfolioProject.dbo.NashvilleHousing
where SoldAsVacant='Y'

update portfolioProject.dbo.NashvilleHousing
set SoldAsVacant = 'No'
from portfolioProject.dbo.NashvilleHousing
where SoldAsVacant='N'

--update portfolioProject.dbo.NashvilleHousing
--set SoldAsVacant=case whan 'Y' then 'Yes'
--when 'N' then 'No'
--else SoldAsVacant
--End

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

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

