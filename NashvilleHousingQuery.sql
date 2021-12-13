/*

Cleaning Nashville Housing data

*/

Select * 
From PortfolioHousing.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioHousing.dbo.NashvilleHousing

Update PortfolioHousing.dbo.NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table PortfolioHousing.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioHousing.dbo.NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


-- Populating our property address data

Select *
From PortfolioHousing.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- Joining table to itself and matching by ParcelID. Properties with same ParcelID also have same address so we can use this to populate some of the Null addresses 
-- Then using ISNULL to populate null addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioHousing.dbo.NashvilleHousing a
Join PortfolioHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Updating our table
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioHousing.dbo.NashvilleHousing a
Join PortfolioHousing.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Confirming that it updated correctly
Select PropertyAddress
From PortfolioHousing.dbo.NashvilleHousing


-- Moving property addresses into individual columns (Address, City, State)
Select *
From PortfolioHousing.dbo.NashvilleHousing

-- Using charindex to split on comma. subtracting one from position # to remove our comma
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, Len(PropertyAddress)) as Address
From PortfolioHousing.dbo.NashvilleHousing


--Updating our table
Alter Table PortfolioHousing.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioHousing.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter Table PortfolioHousing.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioHousing.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, Len(PropertyAddress))


Select *
from PortfolioHousing.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioHousing.dbo.NashvilleHousing

-- Parsing with parsename
Select
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
,PARSENAME(Replace(OwnerAddress, ',', '.'),2)
,PARSENAME(Replace(OwnerAddress, ',', '.'),3)
From PortfolioHousing.dbo.NashvilleHousing


-- Updating Table
Alter Table PortfolioHousing.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioHousing.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)



Alter Table PortfolioHousing.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioHousing.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)



Alter Table PortfolioHousing.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioHousing.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)



Select *
from PortfolioHousing.dbo.NashvilleHousing


-- Chaning Y and N to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioHousing.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From PortfolioHousing.dbo.NashvilleHousing



Update PortfolioHousing.dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END


-- Removing Duplicates
With RowNumberCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
	) row_num

From PortfolioHousing.dbo.NashvilleHousing
)
-- Delete
Select *
From RowNumberCTE
Where row_num > 1


-- Deleting Unused Cols

Select *
from PortfolioHousing.dbo.NashvilleHousing

Alter Table PortfolioHousing.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioHousing.dbo.NashvilleHousing
Drop Column SaleDate