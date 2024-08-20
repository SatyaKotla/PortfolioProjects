/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is Null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--- Breaking out address into Individual Columns (Address,City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

--Using substring
Select
SUBSTRING(PropertyAddress,1,CharIndex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set  PropertySplitAddress = SUBSTRING(PropertyAddress,1,CharIndex(',',PropertyAddress)-1) 

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set  PropertySplitCity = SUBSTRING(PropertyAddress,CharIndex(',',PropertyAddress)+1,Len(PropertyAddress)) 

Select*
From PortfolioProject.dbo.NashvilleHousing






Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3) --Parse name only works with periods(.) hence replacing (,) with (.) also it gives output in reverse
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing
 

 Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2) 

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select*
From PortfolioProject.dbo.NashvilleHousing

----Change Y and N to Yes and No in 'Sold as Vacant' Field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Using case statement

Select SoldAsVacant
,Case when SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-- Remove Duplicates

With RowNumCTE As(
Select *,
ROW_NUMBER() Over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			    UniqueID
				)row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

With RowNumCTE As(
Select *,
ROW_NUMBER() Over(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			    UniqueID
				)row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select*
From RowNumCTE
Where row_num >1
Order by PropertyAddress

---Delete Unused Columns

Select*
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate