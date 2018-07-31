# SwiftyFetch

[![CI Status](https://img.shields.io/travis/charlesfries/SwiftyFetch.svg?style=flat)](https://travis-ci.org/charlesfries/SwiftyFetch)
[![Version](https://img.shields.io/cocoapods/v/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)
[![License](https://img.shields.io/cocoapods/l/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
Fetch.shared.setBaseUrl("https://jsonplaceholder.typicode.com/")
Fetch.shared.setAPIKey("xxxxxxxxxxxxxxxxxxxx")

Fetch.shared.request(url: "posts", method: "POST", body: ["limit": 25]) {
	response in

	if response["ok"] {
		let data = response["json"]
		for (_, j): (String, JSON) in data {
			print(j)
		}
    } else {
		print(response["status"])
		print(response["statusText"])
	}
}
```

## Requirements

## Installation

SwiftyFetch is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftyFetch'
```

## Author

charlesfries, charliefries@icloud.com

## License

SwiftyFetch is available under the MIT license. See the LICENSE file for more info.
