## The Sitch ##
* Currently, the app is being migrated from the MBaaS backendless to Google's Firebase.

## Pretty crucial features ##
* Push notification when a new request is added on the circle
* Push notification when someone accepts your request
* Push notification when someone requests karma points
* Push notification when someone completes your request (pay button is pressed)
* Push notification when someone pays you karma points (pay button in direct transfer button is pressed)

## Necessary Kha Zix fixes ##
* Become able to leave circles
* Become able to log out
* Become able to upload your own image
* Add deinits to every listening handler

## Some Cool Bean Changes ##
### Easy ###
* User images
* Clock for time on order

### Everything in between ###
* Push notification when user joins your circle
* Caching images and requests

### Hard ###
* Geolocation

## Design fixes ##
* Move current user variables to become load variables at the beginning instead of inside functions because they don't change
* Make a customized user object that has the three attributes to be carried around as well as current user data such as images and seen requests

## Priority List for Dev ##
* User images
* Push notifications
* Transaction history on Karma button
* Press for more information on billboard
* Newest to oldest (maybe)
* Cancel accept
* Better icons for tab bar controller
* Email invite users on top right of members list
* Calculator go back one instead of clear
* Removing members from circle

## Need views for: ##
* What more information looks like
* Transaction history example

Notes:
locations for where userprofiles appear:
notifications page,
user profile page,
members page,
requests page

