<p align="center">
<img alt="logo image" width="250" src="https://trapp-documentation.s3.eu-central-1.amazonaws.com/LogoMakr-7gMmq0.png"  />
</p>

# TrAPP iOS Library
Version 1.1.0

## ⚠️ Breaking Changes
With the introduction of offline mode in version 1.1.0, the order of the parameters to be passed to the `init()` of `TranslatorConfigurationModel` has changed. The new signature is the following:
```swift
TranslatorConfigurationModel(
    primaryLanguage: String,
    options: [TranslatorSyncOptions] = [],
    apiKey: String? = nil,
    localFilePath: URL? = nil
)
```

Moreover, the method `setDefaultsStrings(fileURL: URL)` of the `Translator` class does not exist anymore. 
To set an offline file as fallback in case of remote errors, now you need to: 

1. Download the JSON file with the [correct schema](#external-file) from the TrAPP web-app.
2. Put the JSON file in Xcode.
3. In the `TranslatorConfigurationModel` initializer, set `localFilePath` to the JSON file path, without setting the `.localOnly` option.

***

TrAPP is a platform that allow to manage the localization of mobile and web apps. This repository contains the library to integrate TrAPP with iOS mobile apps.
The library handles the following features:

- Authentication
- Synchronization
- Translation


# Overview

Every development platform comes with the support of localization, to be able to translate text based on the preferences of the user's device.
The main issue is that every platform uses different formats and the localization files must be added inside the application bundles, requiring an update every time a string is changed.
Moreover, keeping the files of every platform up to date is a recurring task that can be time consuming and prone to errors.
TrAPP helps keeping all the translations in a single point, always up to date and available to every component of the team.

This Swift library allows iOS developers to retrieve and use the translations of the platform with a simple integration, without worrying about the technical implementation behind.

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

To use TrAPP library you need an instance of the Translator object; to obtain it the configuration must be completed first.

### Configuration

To configure the library to get the translation remotely, call the function `configure` specifying the API Key, and the primary language.

``` swift
do {
    try Translator.configure(
        TranslatorConfigurationModel(
            primaryLanguage: "en-US",
            apiKey: "your API key",
        )
    )
} catch {
    // handle error
}
```

To configure the library to get the translation from a local file, call the function `configure` setting the `localOnly` option, the path of the local file and the primary language.

``` swift
do {
    try Translator.configure(
        TranslatorConfigurationModel(
            primaryLanguage: "en-US",
            options: [.localOnly]
            localFilePath: Bundle.main.url(forResource: "your local file name", withExtension: ".json"),
        )
    )
} catch {
    // handle error
}
```
It is also possible to pass a path of a local file (without the `.localOnly` option) to be used as a backup in case the remote sync fails and the desired language hasn't been saved in the database.

To automatically use device language for translation, during the configuration the option `automaticallyUpdateLocale` must be set, as shown in the following code:

``` swift
do {
    try Translator.configure(
        TranslatorConfigurationModel(
            primaryLanguage: "en-US", 
            options: [.automaticallyUpdateLocale],
            apiKey: "your API Key"
        )
    )
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

To synchronize the local database with the remote one or with the local translations file, the `sync` function must be used. Since the function is marked with `async`, it must be used in an asynchronous scope.

``` swift
try await translator.sync()
```

The synchronization operation should be done at least once every time the app is started, possibly as first operation, to ensure that the strings are available before using them. Depending on the behavior of the app, the sync operation can also be done multiple times during the lifecycle of the app, without issues.

### Observing the state

`Translator` emits two states that are `translatorSyncState` and `translatorLanguageState`.

`translatorSyncState` describes the state of the synchronization of the local database with the remote one and can assume seven values:

- `desynchronized`: when the `Translator` has not been synchronized or the previous synchronization failed;
- `synchronized`: when the synchronization has been done successfully;
- `synchronizing`: when the synchronization is in progress;
- `remoteError`: there has been a remote error during the synchronization of the `Translator`;
- `databaseError`: when there has been a database error during the synchronization of the `Translator`;
- `localFileError`: when there has been an error with the local translations file used with the `localOnly` option;
- `genericError`: when there has been a generic error during the synchronization of the `Translator`.

`translatorLanguageState` describes the synchronization state of the new language when this changes and can assume one of the following values:

- `changingLanguage`: when the synchronization of the new language is in progress;
- `defaultLanguage`: when the language has not been changed or the previous synchronization of the new language failed;
- `languageChanged`: when the synchronization of the new language has been done successfully;
- `remoteError`: there has been a remote error during the synchronization of the `Translator`;
- `databaseError`: when there has been a database error during the synchronization of the `Translator`;
- `localFileError`: when there has been an error with the local translations file used with the `localOnly` option;
- `genericError`: when there has been a generic error during the synchronization of the `Translator`.

These states could be used to ensure that the translation operation is done only when the value of one of the states is `synchronized` or `languageChanged`. To see the values of the states two approaches could be followed:

- the states could be observed by making a `sink` on them;
- the current value of the state could be retrieved by checking his `value` 

### Localization

After the synchronization, localization keys can be translated. To do it there are two functions, `translate` and `getTranslationFor`; the difference between them is how the not-found error is handled.

``` swift
let string1 = translator.translate("test.plain")
let string2 = try translator.getTranslationFor("test.plain")
```

In the first case, `translate` will return the same key if it is not available in the local database, and `getTranslationFor` will throw a `DatabaseError`. The usage depends on the desired result; for example, if the developer wants to translate a string inside a SwiftUI `Text` object they may prefer to use the function without any throw, to make the code more readable.

#### Template Strings

A translation can contain some placeholders that need to be substitute with some values. To achieve this, the translation method accepts an array of `String` that contains the substitutions that will replace the placeholders. The order of the array will be the same in which the substitutions will appear in the localized string.
For example, the translation for the following strings will be:
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

If the option `automaticallyUpdateLocale` was passed during the configuration, the library will change language based on the device's preferences. If, instead, the developer wants to handle this manually, the function `setLanguage` will allow to set and synchronize a new language.

``` swift
try await translator.setLanguage(languageCode: "en-US")
```

> **_NOTE:_** Calling the `setLanguage` function also disables the `automaticallyUpdateLocale` option.
> **_NOTE:_** Calling the `setLanguage` function automatically synchronize the new language. 

This function needs a string indicating the `languageCode` that needs to be set. This string should follow the language ISO standard, with two characters for the language, four optional characters for the script, and two characters for the country, like `en-US` or `zh-HANS-CN`. 
The same language must be set also in the TrAPP online platform.

### External file

Since an Internet connection is not always guaranteed at the first launch of the app, it is possible to give to the library an external `JSON` file containing the translations that needs to be always available. If the library is configured with the `.localOnly` option, this will also be the file used to retrieve the translations without doing any remote call.
The format of the `JSON` file needs to be the following:
```json
{
    "baseLanguage": "<base language code>",
    "languageFallback": {
      "<language not translated code>": "<fallback language code>",
      "<language not translated code>": "<fallback language code>"
    },
    "translations": {
      "<language code>": {
        "<key>": "<translation>",
        "<key>": "<translation>",
        "<key>": "<translation>"
      },
      "<language code>": {
        "<key>": "<translation>",
        "<key>": "<translation>",
        "<key>": "<translation>"
      }
    }
  }

```

To add this file to the library, its path must be passed in the `Translator.configure()` function.
```swift
try Translator.configure(
    TranslatorConfigurationModel(
        primaryLanguage: "en-US",
        apiKey: "your API key",
        localFilePath: Bundle.main.url(forResource: "name of the local file", withExtension: ".json")
    )
)
```

### TranslatableText

The translation of a string could also be done using `TranslatableText`, a wrapper of `SwiftUI.Text`. 

This *View* waits, with a shimmered text, until one of the `Translator` states becomes `synchronized` or `languageChanged`; only when one of this states is reached it performs the translation.

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
