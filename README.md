# DBProfileViewController

[![CI Status](http://img.shields.io/travis/Devon Boyer/DBProfileViewController.svg?style=flat)](https://travis-ci.org/Devon Boyer/DBProfileViewController)
[![Version](https://img.shields.io/cocoapods/v/DBProfileViewController.svg?style=flat)](http://cocoapods.org/pods/DBProfileViewController)
[![License](https://img.shields.io/cocoapods/l/DBProfileViewController.svg?style=flat)](http://cocoapods.org/pods/DBProfileViewController)
[![Platform](https://img.shields.io/cocoapods/p/DBProfileViewController.svg?style=flat)](http://cocoapods.org/pods/DBProfileViewController)

## Overview

A customizable library for displaying a user profile interface consisting of a cover photo, profile picture, segmented control, and an array of content view controllers. It was designed to address two use cases simultaneously:

1. Provide good looking, high quality implementations of familiar profile experiences out of the box. By default a `DBProfileViewController` is styled to look much like a Twitter profile.
2. Enable quick and easy customization of the user experience via properties which change the appearance and behaviour of the cover photo and profile picture.

## Quick Start

The table below details the most important classes and is hyperlinked directly to the current header file. All classes are fully documented.

<table>
    <tr><th colspan="2" style="text-align:center;">Controllers</th></tr>
    <tr>
        <td><a href="Source/Controllers/DBProfileViewController.h">DBProfileViewController</a></td>
        <td>A view controller that is specialized to display a profile interface.</td>
    </tr>
    <tr><th colspan="2" style="text-align:center;">Protocols</th></tr>
    <tr>
        <td><a href="Source/Protocols/DBProfileContentPresenting.h">DBProfileContentPresenting</a></td>
        <td>A protocol that is adopted by classes that are to be displayed as content view controllers of a <a       href="Source/Controllers/DBProfileViewController.h">DBProfileViewController</a>.</td>
    </tr>
    <tr><th colspan="2" style="text-align:center;">Views</th></tr>
    <tr>
        <td><a href="Source/Views/DBProfileCoverPhotoView.h">DBProfileCoverPhotoView</a></td>
        <td>A configurable view that displays a cover photo.</td>
    </tr>
    <tr>
        <td><a href="Source/Views/DBProfilePictureView.h">DBProfileProfilePicture</a></td>
        <td>A configurable view that displays a profile picture.</td>
    </tr>
    <tr>
        <td><a href="Source/Views/DBProfileSegmentedControlView.h">DBProfileSegmentedControlView</a></td>
        <td>A configurable view that displays a segmented control.</td>
    </tr>
</table>

## Installation

#### CocoaPods Installation

The recommended path for installation is [CocoaPods](http://cocoapods.org/). CocoaPods provides a simple, versioned dependency management system that automates the tedious and error prone aspects of manually configuring libraries and frameworks. You can add DBProfileViewController to your project via CocoaPods by doing the following:

```sh
$ sudo gem install cocoapods
$ pod setup
```

Now create a `Podfile` in the root of your project directory and add the following:

```ruby
pod 'DBProfileViewController'
```

Complete the installation by executing:

```sh
$ pod install
```

These instructions will setup your local CocoaPods environment and import DBProfileViewController into your project.

## Author

* [Devon Boyer](https://github.com/devonboyer)

## License

DBProfileViewController is available under the MIT license. See the LICENSE file for more info.
