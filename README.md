Uber Coding Challenge
============

This is my result of the coding challenge I am participating in. I made this pretty quickly, but then made a pretty big overhaul of the whole thing to make things look prettier.

- [The task](#the-task)
- [Features](#features)
- [Frameworks used](#frameworks-used)
- [Configuration](#configuration)
- [Architecture](#architecture)

The task
--------

Write a mobile app that uses the Flickr image search API and shows the results in a 3-column scrollable view.

**Requirements:**

- The app must support endless scrolling, automatically requesting and displaying more images when the user scrolls to the bottom of the view.
- The app must allow you to see a history of past searches
- Feel free to use whatever technologies you're the most comfortable with. This includes any sort of open-source third-party frameworks, auto-layout, etc

**Your priorities should be:**

A working app. Shortcuts are fine given the time constraints, but be prepared to justify them and explain better solutions you would have implemented with more time.
Clean code and architecture. We’d like you to write production ready code that you would be proud to submit as an open source project.
We expect this to take a maximum of 4 hours so no need to implement features that would obviously require more time than that. A concise and readable codebase that accomplishes all of the above requirements is the goal, so don’t try to do any more than is required to solve the problem cleanly.

Please include complete source code in your submission.

Good luck!


----------


**Flickr API**
You can make this call to the Flickr API to return a JSON object with a list of photos.

[https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens](https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens)

The text parameter should be replaced with the query that the user enters into the app.

The JSON response you'll receive will have items described like this example.

{
"id": "23451156376",
"owner": "28017113@N08",
"secret": "8983a8ebc7",
"server": "578",
"farm": 1,
"title": "Merry Christmas!",
"ispublic": 1,
"isfriend": 0,
"isfamily": 0
},

You can use these parameters to get the full URL of the photo:

http://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg

So, using our example from before, the URL would be

http://farm1.static.flickr.com/578/23451156376_8983a8ebc7.jpg

If interested, more documentation about the search endpoint can be found at https://www.flickr.com/services/api/explore/flickr.photos.search. If you have any problems with the Uber-specified API key, then you can generate your own at https://www.flickr.com/services/api/misc.api_keys.html.

Features:
---------

- Searching the Flickr Database for images
- Looking up the history of your past searches
- Infinite scroll

Frameworks used
--------------------

For this task I have used the following third party frameworks:

- Alamofire ([https://github.com/Alamofire/Alamofire](https://github.com/Alamofire/Alamofire))
- AlamofireImage ([https://github.com/Alamofire/AlamofireImage](https://github.com/Alamofire/AlamofireImage)) 
- AlamofireObjectMapper ([https://github.com/tristanhimmelman/AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper))
Uses [Objectmapper](https://github.com/Hearst-DD/ObjectMapper) under the hood. This library maps JSON responses to objects.
- DZNEmptyDataSet ([https://github.com/dzenbot/DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet))
gives some good options to avoid showing empty TableViews or CollectionViews
- OHHTTPStubs ([https://github.com/AliSoftware/OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs))
Allows stubbing network requests and responses for Unit Tests


Configuration
-------------

All values used by the app are stored in *Config.swift*.
You can change the following values:

- Flickr API Key
- Flickr API Url
- Backgroundcolor of views
- Number of items per page
- Number of columns

```swift
static let APIKey = "1234567890abcdefghijklmnopqrstuvwxyz"
static let MainColor = UIColor.blackColor()
static let ItemsPerPage = 20
```

Architecture
--------
To make sure all the images are laid out nicely, I have subclassed `UICollectionViewLayout`, where I am calculating the position for every image in the `UICollectionView`. The standard `UICollectionViewFlowLayout` had the big disadvantage, that all items were lined up evenly, which resulted in having vertical spaces between images, since these images don't share the same aspect ratio and the `UICollectionViewFlowLayout` does not take care of that. 

All network requests are made using Alamofire.
