# Changelog

## 1.0.1

## Bug Fixes

* Improved transition animations when changing size classes (e.g. from portrait to landscape)
* Fixed memory warnings that sometimes occurred related to blurring the cover photo
* Performance improvements when loading a profile view controller's view

### Public API Changes

* Renamed `setVisibleContentViewControllerAtIndex:` to `selectContentViewControllerAtIndex:`
* Renamed `visibleContentViewControllerIndex` property to `indexForSelectedContentController`
* Renamed `profileViewControllerDidPullToRefresh:` to `profileViewController:didPullToRefreshContentControllerAtIndex:` of `DBProfileViewControllerDelegate`

* Removed `addContentViewController:`
* Removed `addContentViewControllers:`
* Removed `insertContentViewController:atIndex:`
* Removed `removeContentViewControllerAtIndex:`
* Removed `addContentViewControllers:`

* Removed `contentViewControllers` property
* Removed `segmentedControlView` property
* Removed `navigationView` property

### Added

* Added `initWithSegmentedControlClass:`
* Added `segmentedControl` property
* Added `beginUpdates`, `endUpdates` and `reloadData`
* Added `hidesSegmentedControlForSingleContentController` property
* Added `coverPhotoMimicsNavigationBarNavigationItem` property
* Added `DBProfileViewControllerDataSource`
* Added `profileViewController:didSelectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
