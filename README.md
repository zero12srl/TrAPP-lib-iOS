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
.product(name: "TrAPP-lib-iOS", package: "TrAPP-lib"),
```

Then just import it through:
```
import TrAPPSync
```

## Quick start

To use TrAPP library you need an instance of the Translator object, but to obtain it you need to configure
the library first.

### Configuration

To configure the library call the function `configure` specifying the API Key, and the primary language.

``` swift
do {
    try Translator.configure(TranslatorConfigurationModel(apiKey: "your API Key", primaryLanguage: "en-US"))
} catch {
    // handle error
}
```

If you want to let the library to automatically use the device language for the translation you can also
set the option `automaticallyUpdateLocale` during the configuration.

``` swift
do {
    try Translator.configure(TranslatorConfigurationModel(apiKey: "your API Key", primaryLanguage: "en-US", options: [.automaticallyUpdateLocale]))
} catch {
    // handle error
}
```

### Retrieve the Translator object

Now that the library is configured, an instance of the Translator object can be retrieved through the
`getTranslator` function.

``` swift
do {
    let translator = try Translator.getTranslator()
} catch {
    // handle error
}
```

> **_NOTE:_** The translator object is a singleton, the returned instance is always the same.

This object can now be injected or retrieved anywhere in the application.

### Sync

To synchronize the local database with the remote one, the `sync` function must be used. Since the function is marked
with `async` remember to use it in an asynchronous scope.

``` swift
try await translator.sync()
```

The synchronization operation should be done at least at every startup of the app, as first operation, to ensure
that the strings are available before using them. Depending on the behavior of the app, the sync operation can 
also be done multiple time during the lifecycle of the app, without issues.

### Localization

After the synchronization the localization keys can be translated. To do it there are two functions,
`translate` and `getTranslationFor` the difference between them is how the not-found error is handled.

``` swift
let string1 = translator.translate("test.plain")
let string2 = try translator.getTranslationFor("test.plain")
```

In the first case `translate` will return the same key if it is not available in the local database,
instead `getTranslationFor` will throw a `DatabaseError`. The usage depends on the desired result, for
example if the developer wants to translate a string inside a SwiftUI `Text` object they may prefer
to use the function without any throw, to make the code more readable.

#### Templated Strings

A translation can contain some placeholders that needs to be substitute with some values. To achieve this the translation method accepts an array of `String` that contains the substitutions to the placeholders. The order of the array will be the same of the number of the placeholders. 
For example the translation for the following strings will be:
``` swift
"test.substring2": "Lorem {{1}} dolor sit amet, {{2}} adipiscing elit."
"test.substring3": "Lorem {{2}} dolor sit amet, {{1}} adipiscing elit."
let string1 = translator.translate("test.substring2", ["ipsum", "consectetur"])
// string1 == "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
let string2 = translator.translate("test.substring3", ["ipsum", "consectetur"])
// string2 == "Lorem consectetur dolor sit amet, ipsum adipiscing elit."
```

> **_NOTE:_**  When using the method `getTranslationFor` the thrown `DatabaseError` will describe the reason of the failure.


### Change language

If the option `automaticallyUpdateLocale` was passed during the configuration the library will change
language based on the device's preference. If instead the developer wants to handle this manually, the
function `setLanguage` will allow to set and synchronies a new language.

``` swift
try await translator.setLanguage(languageCode: "en-US")
```

> **_NOTE:_** The call to the `setLanguage` method disables the `automaticallyUpdateLocale` option.

This method needs a string indicating the `languageCode` that needs to be set. This string should follow the language ISO
standard, with two characters for the language, eventually four characters for the script, and two for the country, like `en-US` or `zh-HANS-CN`. The same language
must be set also in the TrAPP platform.

### External file

Since there could be connection problem that will compromise the correct function of the library, there is also the possibility to give to the app an external `JSON` containing the translations that needs to be always available. The format of the `JSON` needs to be the following:
```` json
{
    "keySet": [
        "test.plain": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. DEFAULT"
    ]
}
``````
To add this file to the library there is the `setDefaultsStrings` method that save the provided strings in the local database.

``` swift
try await translator.setDefaultsStrings(fileURL: localPath)
```

This method needs the local path to the file that contains the default strings. 


## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

## About

Made with ❤️ by zero12. 
The names and logo are trademarks of zero12 srl.
