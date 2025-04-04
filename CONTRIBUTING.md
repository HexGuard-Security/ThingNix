# Contributing to ThingNix

Thank you for your interest in contributing to ThingNix! This document provides guidelines and instructions for contributing to the project.

## Ways to Contribute

There are many ways you can contribute to ThingNix:

- **Testing and Bug Reports**: Test ThingNix on your hardware and report any issues
- **Documentation**: Improve or extend existing documentation
- **Code**: Implement new features, fix bugs, or optimize existing code
- **Design**: Contribute wallpapers, icons, themes, or other visual assets
- **Ideas**: Suggest new features or improvements

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Create a branch** for your contribution
4. **Make your changes** and commit them with clear, descriptive commit messages
5. **Push your changes** to your fork
6. **Create a pull request** to the main ThingNix repository

## Development Workflow

### Local Development

To test your changes locally:

```bash
# Clone the repository
git clone https://github.com/HexGuard-Security/ThingNix.git
cd ThingNix

# Build the ISO
./build.sh
```

### Continuous Integration

ThingNix uses GitHub Actions for continuous integration. On every push and pull request:

1. The workflow automatically builds ISOs for both x86_64 and aarch64 architectures
2. Artifacts are uploaded and available for download for 7 days
3. For tagged releases, the workflow creates a GitHub Release with the ISOs and checksums

You can view the build status in the "Actions" tab of the GitHub repository.

## Design Contributions

We welcome design contributions to enhance the visual identity of ThingNix:

### Icons

- Icons should be provided in SVG format
- Follow the ThingNix color palette and design language
- Place icons in the appropriate directory:
  - `assets/icons/desktop/` for desktop application icons
  - `assets/icons/tools/` for tool category icons

### Wallpapers

- Wallpapers should be at least 1920x1080 resolution
- Follow the ThingNix aesthetic (cyber-security/IoT themed)
- Place wallpapers in `assets/wallpapers/` directory

### Themes

- Theme files should be compatible with XFCE
- Place theme files in `assets/themes/` directory

## Code Style

- Follow the existing code style in the project
- Use descriptive variable names and add comments for clarity
- Keep functions small and focused on a single task
- Write tests for new functionality when possible

## Pull Request Process

1. Update the README or documentation with details of your changes if needed
2. Make sure your code builds and works correctly
3. Get your pull request reviewed by maintainers
4. Once approved, your pull request will be merged

## Communication

- Use GitHub Issues for bug reports and feature requests
- Join our [Discord server](https://discord.gg/hexguard) for discussion
- For major changes, please open an issue first to discuss your proposed changes

## License

By contributing to ThingNix, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).

Thank you for helping make ThingNix better!
