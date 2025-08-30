# Toki 

# WIP: This file is work in progress

#### Install CLI

You can install Toki via [Homebrew](https://brew.sh):

```bash
brew install manuelvrhovac/toki/toki
```

To install a specific version, use the tagged formula:

```bash
brew install brew install manuelvrhovac/toki/toki@0.9.0
```

#### Authentication

Before you can run Toki, you must [Configure the Personal Access Token](Readme_setup_authentication) - `COLGEN_TOKEN`.

## Usage

To pull the latest colors into your Xcode project, navigate to your project root and run:

```bash
toki generate
```

Toki will fetch the colors and generate an Xcode Asset Catalog (.xcassets) automatically.

Tip: Optionally, add the `-l` flag to print the complete list of primitive/semantic colors.
Warning: **Do not manually edit the `.xcassets` folder**—it will be **overwritten** each time you run Toki.

## Contributing

We believe that the community can help us improve and build better a product.
Please refer to our [contributing guide](CONTRIBUTING.md) to learn about the types of contributions we accept and the process for submitting them.

To ensure that our community remains respectful and professional, we defined a [code of conduct](CODE_OF_CONDUCT.md) that we expect all contributors to follow.

We appreciate your interest and look forward to your contributions.
#### Deployment

To learn how to deploy a new version of Toki, follow the instructions inside [Deployment](https://github.com/infinum/ios-figma-token-generator/wiki/Deployment).

## License

```text
Copyright 2024 Infinum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Credits

Maintained and sponsored by [Infinum](https://infinum.com).

<div align="center">
    <a href='https://infinum.com'>
    <picture>
        <source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
        <img src="https://assets.infinum.com/brand/logo/static/default.svg">
    </picture>
    </a>
</div>
