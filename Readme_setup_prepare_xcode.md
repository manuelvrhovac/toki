# Prepare your Xcode project before running Colgen

> **Note:** Before you start, check if you have a `Colgen.yml` file at your project root. If yes, skip this article altogether.
 
Colgen requires a configuration file to function properly:

1. Create a `.colgen.yml` file in the root of your project
2. Copy and paste the contents into it:

```yml
storageRepo: {company/storage-for-exported-colors}
branch: {project_folder_name}
primitiveKey: {FigmaPrimitiveColumn/Name}
semanticLightKey: {FigmaSemanticColumn/Name}
semanticDarkKey: {FigmaSemanticColumn/Name}
xcassetsOutputPath: {Path/To/Generated/Colors.xcassets}
useNamespacing: {true/false}
shouldGenerateResolvedFiles: {true/false}
```

3. Populate the YML file with necessary parameters:
    - **storageRepo** - as defined in "Storage GitHub Repository". At Infinum we use `infinum/figma-token-storage` .
    - **branch** - the branch name, corresponds to project, e.g. `some-nice-app`.
    - **primitiveKey / semanticLightKey / semanticDarkKey** - These are the columns names in Figma Variables table. Ask the designer for this, or inspect the JSON on storage repo.
    - **xcassetsOutputPath**  - The path at which XCAssets will get created.
    - **useNamespacing** - (Optional) Translates color path on Figma to subfolders in XCAssets. Default=false. Read more below.
    - **shouldGenerateResolvedFiles**  - (Optional) "resolved" files are actually a list of all the generated colors in your project. Default=false. The list makes it easier to inspect and verify all the added/removed/modified semantic colors after running Colgen generate. Tip: you can disable this if you use Redbreast.

#### Creating code references

Although it's in the pipeline, Colgen currently doesn't generate code references to the colors in the generated XCAssets file. We recommend using [Redbreast](https://github.com/infinum/redbreast) to do so.
#### Namespacing

If colors on Figma are organised in this hierarchy:
`Button/Branded/Primary/button-branded-primary`

This may result in unnecessary duplication on our side:
`= .Button.Branded.Primary.buttonBrandedPrimary`

 To fix this issue make sure to set `useNamespacing` to `false` so that only the last path component of the color is used actually used (must be unique for each color):
`= .buttonBrandedPrimary

### Example: YML file

```yml
projectName: someclient-coolproject
primitiveKey: Primitive/Mode 1
semanticLightKey: Semantic/Light Tokens
semanticDarkKey: Semantic/Dark Tokens
xcassetsOutputPath: Resources/Assets/Colors.xcasset
useNamespacing: false
shouldGenerateResolvedFiles: true
```

![image](ReadmeImages/figma-columns.png)
### Usage

You should be now ready to use - see [Usage in Readme](README.md#Usage)