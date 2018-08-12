# SwiftyFetch

[![CI Status](https://img.shields.io/travis/charlesfries/SwiftyFetch.svg?style=flat)](https://travis-ci.org/charlesfries/SwiftyFetch)
[![Version](https://img.shields.io/cocoapods/v/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)
[![License](https://img.shields.io/cocoapods/l/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyFetch.svg?style=flat)](https://cocoapods.org/pods/SwiftyFetch)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
// AppDelegate.swift

Fetch.shared.setBaseUrl("https://jsonplaceholder.typicode.com/")
Fetch.shared.setAPIKey("xxxxxxxxxxxxxxxxxxxx")

UserDefaults.standard.set("accessToken", forKey: "xxxxxxxxxxxxxxxxxxxx") // <- for testing; should be set by your auth controller
if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
    Fetch.shared.setToken(accessToken)
}
```

```swift
// ViewController.swift

Fetch.shared.request(url: "posts", method: "POST", body: ["limit": 25]) {
	response in

	if response["ok"] {
		let json = response["json"]
		
		print(json) // JSON payload
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
