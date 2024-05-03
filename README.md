<p align="center">
<img alt="logo image" width="250" src="https://trapp-documentation.s3.eu-central-1.amazonaws.com/LogoMakr-7gMmq0.png"  />
</p>

# TrAPP iOS Library

TrAPP is a platform that allow to manage all the translations of mobile and web apps. This repository
contains the library to integrate TrAPP with iOS mobile apps.
The library handles the following features:
- Authentication
- Synchronization
- Translation

# Overview

Every development platforms comes with the support of localization, to be able to translate text based on
the preferences of the user's device.
The main issue is that every platform uses different formats and the localization files must be added inside
the application bundles, requiring an update every time a string is changed.
Moreover, keeping the files of every platform up to date is a constant task that can be time consuming and prone
to errors.
TrAPP helps keeping all the translations in a single point, always up to date and available to every component
of the team.
This Swift library allows iOS developers to retrieve and use the translations of the platform with a simple integration,
without worrying about the technical implementation behind.

## Installation

You can add TrAPP library to an Xcode project by adding it to your project as a package.

> https://github.com/zero12srl/TrAPP-lib-iOS.git

You can add TrAPP in a [SwiftPM](https://swift.org/package-manager/) project by adding
it to the `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/zero12srl/TrAPP-lib-iOS.git", .upToNextMajor(from: "1.0.0"))
]
```

And to the target:
``` swift
.product(name: "TrAPP-lib", package: "TrAPP-lib-iOS"),
```

Then just import it through:
```
import TrAPPSync
```

## Quick start

To use TrAPP library you need an instance of the Translator object, to obtain it the configuration must be completed first.

### Configuration

To configure the library call the function `configure` specifying the API Key, and the primary language.

``` swift
do {
    try Translator.configure(TranslatorConfigurationModel(apiKey: "your API Key", primaryLanguage: "en-US"))
} catch {
    // handle error
}
```

To automatically use device language for translation, during the configuration must be set as option `automaticallyUpdateLocale`, as shown in the following code:

``` swift
do {
    try Translator.configure(TranslatorConfigurationModel(apiKey: "your API Key", primaryLanguage: "en-US", options: [.automaticallyUpdateLocale]))
} catch {
    // handle error
}
```

### Retrieve the Translator object

Once the library is configured, an instance of the Translator object can be retrieved through the `getTranslator` function.

``` swift
do {
    let translator = try Translator.getTranslator()
} catch {
    // handle error
}
```

> **_NOTE:_** The Translator object is a singleton, the returned instance is always the same.

This object can now be injected or retrieved anywhere in the application.

### Sync

To synchronize the local database with the remote one, the `sync` function must be used. Since the function is marked with `async`, it must be used in an asynchronous scope.

``` swift
try await translator.sync()
```

The synchronization operation should be done at least once every time the app is started, possibly as first operation, to ensure that the strings are available before using them. Depending on the behavior of the app, the sync operation can also be done multiple time during the lifecycle of the app, without issues.

### Observing the state

`Translator` emits two states, `translatorSyncState` and `translatorLanguageState`.

The former describes the state of the synchronization of the local database with remote one and can assume three values:
- `desynchronized`: when the `Translator` has not been synchronized or the previous synchronization failed;
- `synchronized`: when the synchronization has been done successfully;
- `synchronizing`: when the synchronization is in progress.

The latter describes the synchronization state of the new language when this changes can assume three values:
- `changingLanguage`: when the synchronization of the new language is in progress;
- `defaultLanguage`: when the language has not been changed or the previous synchronization of the new language failed;
- `languageChanged`: when the synchronization of the new language has been done successfully.

This states could be used to ensure that the translation operation is done only when the value of one of the states is `synchronized` or `languageChanged`. To see the values of the states two approaches could be followed:
- the states could be observed by making a `sink` on them;
- the current value of the state could be retrieved by checking his `value` 

### Localization

After the synchronization, the localization keys can be translated. To do it there are two functions, `translate` and `getTranslationFor` the difference between them is how the not-found error is handled.

``` swift
let string1 = translator.translate("test.plain")
let string2 = try translator.getTranslationFor("test.plain")
```

In the first case, `translate` will return the same key if it is not available in the local database, instead `getTranslationFor` will throw a `DatabaseError`. The usage depends on the desired result, for example if the developer wants to translate a string inside a SwiftUI `Text` object they may prefer to use the function without any throw, to make the code more readable.

#### Template Strings

A translation can contain some placeholders that need to be substitute with some values. To achieve this, the translation method accepts an array of `String` that contains the substitutions to the placeholders. The order of the array will be used to order the substitutions.
For example the translation for the following strings will be:
``` json
"test.substring1": "Lorem {{1}} dolor sit amet, {{2}} adipiscing elit."
"test.substring2": "Lorem {{2}} dolor sit amet, {{1}} adipiscing elit."
```
``` swift
let string1 = translator.translate("test.substring1", ["ipsum", "consectetur"])
// string1 -> "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
let string2 = translator.translate("test.substring2", ["ipsum", "consectetur"])
// string2 -> "Lorem consectetur dolor sit amet, ipsum adipiscing elit."
```

> **_NOTE:_**  When using the method `getTranslationFor`, the `DatabaseError` will describe the reason of the failure.

### Change language

If the option `automaticallyUpdateLocale` was passed during the configuration, the library will change language based on the device's preference. If, instead, the developer wants to handle this manually, the function `setLanguage` will allow to set and synchronize a new language.

``` swift
try await translator.setLanguage(languageCode: "en-US")
```

> **_NOTE:_** Calling the `setLanguage` function also disables the `automaticallyUpdateLocale` option.
> **_NOTE:_** Calling the `setLanguage` function automatically synchronize the new language. 

This function needs a string indicating the `languageCode` that needs to be set. This string should follow the language ISO standard, with two characters for the language, four optional characters for the script, and two characters for the country, like `en-US` or `zh-HANS-CN`. 
The same language must be set also in the TrAPP online platform.

### External file

Since the Internet connection is not always guaranteed at the first launch of the app, it is possible to give to the library an external `JSON` file containing the translations that needs to be always available. 
The format of the `JSON` file needs to be the following:
``` json
{
    "keys": {
        "test.plain": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "test.substring": "Lorem {{1}} dolor sit amet, consectetur adipiscing elit.",
    }
}
```
To add this file to the library must be used the `setDefaultsStrings` function. This function saves the provided strings in the local database.

``` swift
try await translator.setDefaultsStrings(fileURL: localPath)
```

In the example, the `localPath` is the `URL` to file. The format of the `URL` should be `file:///<path-to-file>/file.json`. 

> **_NOTE:_** This method should be called only at the first launch of the app.

### TranslatableText

The translation of a string could also be done using `TranslatableText`, a wrapper of `SwiftUI.Text`. 

This *View* waits, with a shimmered text, until one of the `Translator` states becomes `synchronized` or `languageChanged` and only when one of this states are reached performs the translation.

The view supports:
- the translation of templated strings;
- custom placeholder;
- custom timeout:
- view modifiers applied to the text with the `content` closure.

TranslatableText without modifiers
```swift
TranslatableText(key: "test.plain")
```

TranslatableText with modifiers
```swift
TranslatableText(key: "test.plain", content: { text in
    text
        .font(.caption)
        .fontWeight(.semibold)
        .underline()
        .foregroundColor(.green)
})
```

## About

Made with ❤️ by zero12. 
The names and logo are trademarks of zero12 srl.
