# Changelog

## 1.0.2

## Bug Fixes

* Fixed a bug somtimes causing the profile picture to appear on top of the cover photo when changing segments.
* Added assertions for when nil is returned from required data source methods
* Changed from using `UIImageEffects` to `FXBlurView` to blur the cover photo.

### Public API Changes

* Renamed `selectContentViewControllerAtIndex:` to `selectContentControllerAtIndex:`
* Changed `profileViewController:subtitleForContentControllerAtIndex:` to now be optional
* Renamed `DBProfilePictureView` class to `DBProfileAvatarImageView`
* Renamed `profilePictureView` property to `avatarImageView`

### Added

* Added `profileViewController:willSelectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:willDeselectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectProfilePicture:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectCoverPhoto:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didHighlightProfilePicture:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didUnhighlightProfilePicture:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didHighlightCoverPhoto:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didUnhighlightCoverPhoto:` to `DBProfileViewControllerDelegate`
* Added `selectCoverPhotoAnimated:`
* Added `deselectCoverPhotoAnimated:`
* Added `selectProfilePictureAnimated:`
* Added `deselectCoverPhotoAnimated:`
* Added `coverPhotoScrollAnimationStyle` property

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
