# Beauchamp
A behavior prediction engine

Pre-release

## What is Beauchamp?

TLDR; - You tell Beauchamp how a user is using your app. Beauchamp tells you how that user is likely to use it next time.

Having an app with good UX is table stakes for todays app market. Understanding how easy it is for your users to navigate around and find the information they need is essential in building an app where users are likely to return. Methods like A/B testing are commonplace now in order to refine UX and eliminate pain points for users. But the next step in making an app easy to use is recognizing that people are different.

Rarely to users engage with all of the features in your app. Most will only use a subset but that subset might be different on a user-by-user basis. Instead of simply appealing to the majority, great apps will observe what features an individual is using most often and anticipate those needs by surfacing them more prominently, or making them easier to get to.

Take the example of a group messaging app. Most users will probably want to land in the general chat room when they open the app. For first-time users this is a great place to put them so they have a general sense of the conversation that's going on. But as a user gets more advanced, a user might find more value in spending most of their time in a room that is more specific to their interests. It would be a constant source of frustration if every time a user opened the app, they landed in the general discussion room and then had to navigate to their favorite room, especially if there are many rooms available and navigating to the room that they want involves server click or a search.

Beauchamp's goal is to solve this problem. In this example, you could record which room the user navigates to. Every time they visit the app and navigate to a particular room, Beauchamp is able to use the choices the user has made in the past to predict the choices they are likely to make in the future. So the next time they open the app, you can immediately drop them into their favorite room.

## Project Goals

Beauchamp aims to provide a general framework for predicting user behavior based on past behavior. All behavior recording and prediction is done locally so the users privacy is intact. Beauchamp can be used on a session-by-session basis or behavior data can be persisted across sessions.

## Using Beauchamp

Each set of choices the user can make is organized into a `Study` which contains a collection of `Option`'s. A typical `Study` would represent something like a tab navigation and each `Option` in the `Study` would represent a tab.

### Setting up a Options

Set up a new `Option` by instantiating an object like so:

```swift
let option1 = Option(description: "Photos Tab")
```

The `desciption` is a required property and uniquely identifies the `Option`. Any two `Option`'s with the same description are considered the same object when placed in a `Study` so make sure your description is specific enough to uniquely describe the `Option`

### Setting up a Study

Set up a new `Study` by instantiating an object like so:

```swift
let option1 = Option(description: "Photos Tab")
let option2 = Option(description: "Messages Tab")
let option3 = Option(description: "Settings Tab")
let tabStudy = Study(description: "Home page tab navigation study", options: [option1, option2, option3])
```

### Recording user behavior

There are two pieces of information you must record. You must record 'encounters' whenever a user is presented with the options. If you are recording a tab navigation, for example, you may want to record an encounter every time the view appears:

```swift
override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    tabStudy.recordEncounter()
}
```

The next piece of information you must record is whenever the user 'takes' or chooses one of the options you have presented. For example in a tab navigation, you would want to do this when the user selects a tab:

```swift
func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    let option = getOptionForViewController(viewController)
    tabStudy.recordOptionTaken(option)
}
```

In this example `getOptionForViewController` is a function that maps the UIViewController of a tab with one of the `Option`'s in the `Study`

### Predicting behavior

A `Prediction` object is returned by a `Study` when you request the most likely option the user will choose. The `Prediciton` objects just contains the option it predicts along with a `confidence` score. `confidence` is a number from 0 to 1 where 0 represents a blind guess and 1 represents absolute certainty. You can use this `confidence` score to determine if the prediction is useful enough to act on. Here's an example:

```swift
override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
	if let prediction = tabStudy.getMostLikelyPrediciton() where prediction.confidence > 0.5 {
		let index = getTabIndexOfOption(prediction.option)
		selectedIndex = index
	}
}
```

In this example, the proper default tab is selected only if the `confifence` is above 0.5. `getTabIndexOfOption` is a function that returns the index of the tab that an `Option` in the `Study` represents.

## Roadmap
1. Add a user defaults persistence class to the BeauchampPersistence framework
2. Add a time wighted prediction where most recent options are weighted more heavily
3. Add an Obj-C wrapper
