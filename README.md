# code-playground.nvim


https://github.com/user-attachments/assets/ef4002a9-c676-4de4-810c-6e144c5ba77c


## Description

**code-playground.nvim** is a simple yet powerful Neovim plugin that allows you to run code in the language of your choosing directly within Neovim. When invoked, it opens a buffer in the selected language where you can type your code. Upon saving the buffer, the plugin automatically runs your code and displays the output. 

Currently, the plugin supports the following languages:

- .NET (C#)
- TypeScript
- Rust
- Zig
- Python
- Java
- F#
- Go
- Odin
- Haskell

More languages will be supported in future updates!

## Features

- **Language Selection**: Easily choose between supported languages to run your code.
- **Automatic Execution**: Code is automatically executed upon saving the buffer.
- **Real-time Feedback**: The output of your code is displayed immediately after execution.
- **Extensible**: More languages will be supported in the future.

## Setup

### Without options
```lua
-- lazy.nvim
{
  "GustavEikaas/code-playground.nvim",
  config = function()
    require("code-playground").setup()
  end
}
```

### With options
```lua
-- lazy.nvim
{
  "GustavEikaas/code-playground.nvim",
  config = function()
    require("code-playground").setup({
      split_direction = "vsplit", -- split | vsplit
      auto_change_cwd = false
    })
  end
}
```


## Usage

### Running code 

To run code in a specific language:

1. Open the command prompt in Neovim by pressing `:`.

   ```vim
   :Code <language>
   ```

   For example, to run C# code, use:

   ```vim
   :Code dotnet
   ```

2. A new buffer will open. Type your code in this buffer.

3. Save the buffer using `:w` or `Ctrl+s`. The plugin will automatically execute your code, and the output will be displayed.


### Resetting a workspace

Run the command `Code <language> reset`.

This will destroy the workspace and reinitialize it.

### Commands

- To run C# (.NET) code:

  ```vim
  Code
  Code dotnet
  Code typescript
  Code rust
  Code zig
  Code python
  Code java
  Code go
  Code fsharp
  Code odin
  Code haskell
  ```

## Configuration

The plugin is designed to work out of the box without requiring additional configuration. However you will still need to have the languages installed 

## Contributing

Contributions are welcome! If you want to add a new feature or language support, please fork the repository and create a pull request.

### Steps to Contribute

1. Fork the repository.
2. Create a new branch for your feature: `git checkout -b feature-name`.
3. Commit your changes: `git commit -am 'Add new feature'`.
4. Push to the branch: `git push origin feature-name`.
5. Open a pull request.

## License

This plugin is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

