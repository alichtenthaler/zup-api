# Change log

## 1.1.1 - 11/27/2015
### Corrections
- [Reports] Task scheduling fix for extracting data from EXIFF


## 1.1.0 - 11/20/2015
### Adittions
- [Reports] Added perimeters filter for searching reports
- [Perimeters] Added search by title and ordering to the perimeters endpoint
- [Perimeters] Added standard solver group for perimeters

### Changes
- [Reports/Logs] Added new kind of history to identify when a report is forwarded to a perimeter

### Corrections
- [Tests] Fixing tests that were randomly failing
- [Notifications] Corrected notifications for the standard deadline to accept null values
- [Notifications] Added report category in the return of notifications search

### Corrections
- [Reports] Fixed search by days overdue for overdue notifications

### Corrections
- Fixed translations into Portuguese

### Corrections
- [Steps] Changed steps to list triggers in the correct order

### Corrections
- [Triggers] Corrects triggers' and conditions' update

## 1.0.6
### Changes
- Update of the dependence of asynchronous jobs

## 1.0.5
## Changes
- [Reports/Perimeters] Changed paging of perimeters to optional

### Corrections
- [Users] Changed birth date to optional in user registration

## 1.0.4
## Improvements
- [Reports] Added Perimeters functionality 
- [Users] Added extra fields
- [Flows] Fixes issue that prevented the display of permissionaire fields in the listing of all fields of a Flow

## Changes
- [Notifications] Changed notifications for the default deadline to be optional
- [Reports] Changed address placeholder to use full address instead of just the street
- [Reports] Changed address search to filter by street, district and zip code fields

### Corrections
- [Users] Added password confirmation validation

## 1.0.3
## Improvements
- Added subtitle and date to the report images

### Corrections
- [Reports] Standardized response time in the notification search

## 1.0.2
## Improvements
- Added new notifications feature to the report categories

### Improvements
- [Specs] Split apis/cases spec into multiple files to run faster on CI;
- [Flows] The management of permissions of steps is now done entirely by the endpoint `PUT /flows/:id/steps/:id/permissions`;
- [Specs] Increased coverage of Field and Step models;
- [Specs] Updated knapsack report;
- [Cases] Search and filtering parameters in cases listing;

## Changes
- [Flows/Cases] Return current version if the flow is not in draft mode and a draft was ordered
- [Reports] Create history when the reference of a report is changed

### Corrections
- [Flows/Cases] Bug in Field#add_field_on_step
- [Flows/Cases] Bug in Step#set_draft
- [Specs] Factories: Field and Step
- [Gitlab CI] Fixed build on Gitlab CI and increasing the number of nodes to 5
- [Descriptions/Reports] Fixed the difference in the amount of descriptions found between
Reports and Descriptions search
- [Reports/Categories] Fixed the listing of private categories, that was being displayed to users not logged in

## 1.0.0
Initial stable release
