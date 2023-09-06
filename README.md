# TrAPP iOS Library

TrAPP is a platform that allow to manage all the translations of mobile apps and web apps. This repository
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
that the strings are available before using them. Depending on the behaviour of the app, the sync operation can 
also be done multiple time during the lifecycle of the app, without issues.

Since the library download only the active language (to be fast and save bandwidth), the synchronization should
be done also if the language is changed, to allow the library to download the new required language.

### Localization

After the synchronization the localization keys can be translated. To do it there are two functions,
`translate` and `getTranslationFor` the difference between the two is how the not-found error is handled.

``` swift
let string1 = translator.translate("test.plain")
let string2 = try translator.getTranslationFor("test.plain")
```

In the first case `translate` will return the same key if it is not available in the local database,
instead `getTranslationFor` will throw a `DatabaseError`. The usage depends on the desired result, for
example if the developer wants to translate a string inside a SwiftUI `Text` object they may prefer
to use the function without any throw, to make the code more readable.

### Change language

If the option `automaticallyUpdateLocale` was passed during the configuration the library will change
language based on the device's preference. If instead the developer wants to handle this manally, the
function `setLanguage` will allow to set a new language. The string should follow the language ISO
standard, with two characters for the language and two for the country, like `en-US`. The same language
must be set also in the TrAPP platform backoffice.



## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

## About

Made with ❤️ by zero12. 
The names and logo are trademarks of zero12 srl.
