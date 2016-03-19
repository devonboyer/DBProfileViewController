# Changelog

## 1.0.2

## Bug Fixes

* Fixed a bug somtimes causing the profile picture to appear on top of the cover photo when changing segments.
* Added assertions for when nil is returned from required data source methods
* Changed from using `UIImageEffects` to `FXBlurView` to blur the cover photo.

### Public API Changes

* Renamed `selectContentViewControllerAtIndex:` to `selectContentControllerAtIndex:`
* Changed `profileViewController:subtitleForContentControllerAtIndex:` to now be optional
* Renamed `DBProfilePictureView` class to `DBProfileAvatarView`
* Renamed `profilePictureView` property to `avatarView`
* Renamed `profileViewController:didSelectProfilePicture:` to `profileViewController:didSelectAvatarView:` in `DBProfileViewControllerDelegate`
* Renamed `profileViewController:didSelectCoverPhoto:` to `profileViewController:didSelectCoverPhotoView:` in `DBProfileViewControllerDelegate`
* Renamed `setProfilePicture:animated:` to `setAvatarImage:animated:`
* Renamed `setCoverPhoto:animated:` to `setCoverPhotoImage:animated:`

### Added

* Added `profileViewController:willSelectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:willDeselectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectContentControllerAtIndex:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectCoverPhotoView:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didHighlightCoverPhotoView:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didUnhighlightCoverPhotoView:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didHighlightAvatarView:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didDeselectAvatarView:` to `DBProfileViewControllerDelegate`
* Added `profileViewController:didUnhighlightAvatarView:` to `DBProfileViewControllerDelegate`
* Added `selectCoverPhotoViewAnimated:`
* Added `deselectCoverPhotoViewAnimated:`
* Added `selectAvatarViewAnimated:`
* Added `deselectAvatarViewAnimated:`
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
