#!/bin/bash

# /scripts/new.sh

#!/bin/bash

# First, let's check for our required environment variables. These are crucial for proper project setup and file locations.
if [ -z "$APP_NAME" ]; then
    echo "Error: APP_NAME environment variable is required"
    echo "Usage: APP_NAME=Intrepion.MyProject GITHUB_NAME=intrepion REPO_NAME=my-project docker compose run --rm c-sharp-new"
    exit 1
fi

if [ -z "$GITHUB_NAME" ]; then
    echo "Error: GITHUB_NAME environment variable is required"
    echo "Usage: APP_NAME=Intrepion.MyProject GITHUB_NAME=intrepion REPO_NAME=my-project docker compose run --rm c-sharp-new"
    exit 1
fi

if [ -z "$REPO_NAME" ]; then
    echo "Error: REPO_NAME environment variable is required"
    echo "Usage: APP_NAME=Intrepion.MyProject GITHUB_NAME=intrepion REPO_NAME=my-project docker compose run --rm c-sharp-new"
    exit 1
fi

# Before creating any new directories, we'll copy the GitHub workflow files.
# The -R flag ensures we copy the directory recursively, preserving its structure.
cp -R ../files/.* ./

# Now we check if the project directory already exists before proceeding
if [ -d "/app/$APP_NAME" ]; then
    echo "Directory $APP_NAME already exists. Stopping..."
    exit 1
fi

# Create main directory and navigate into it
cd /app
mkdir "$APP_NAME"
cd "$APP_NAME"

# Create new solution
dotnet new sln -n "$APP_NAME"

# Create a .gitignore file that's pre-configured for .NET projects
dotnet new gitignore

# Create a global.json file to specify the .NET SDK version
dotnet new globaljson

# Create class library project
dotnet new classlib -n "$APP_NAME.BusinessLogic" -o "$APP_NAME.BusinessLogic" --framework net8.0

# Create test project
dotnet new mstest -n "$APP_NAME.BusinessLogic.UnitTests" -o "$APP_NAME.BusinessLogic.UnitTests" --framework net8.0

# Add projects to solution
dotnet sln add "$APP_NAME.BusinessLogic/$APP_NAME.BusinessLogic.csproj"
dotnet sln add "$APP_NAME.BusinessLogic.UnitTests/$APP_NAME.BusinessLogic.UnitTests.csproj"

# Add reference from test project to class library
dotnet add "$APP_NAME.BusinessLogic.UnitTests/$APP_NAME.BusinessLogic.UnitTests.csproj" reference "$APP_NAME.BusinessLogic/$APP_NAME.BusinessLogic.csproj"

# Create or update README.md with status badge at the repository root level
# Note that we're now working with ../README.md instead of a local README.md
if [ ! -f "../README.md" ]; then
    # If README doesn't exist, create it with a default title using the APP_NAME
    echo "# $APP_NAME" > "../README.md"
fi

# Add a blank line and the status badge to the README at the repository root
echo "" >> "../README.md"
echo "[![.NET](https://github.com/${GITHUB_NAME}/${REPO_NAME}/actions/workflows/dotnet.yml/badge.svg?branch=mstest)](https://github.com/${GITHUB_NAME}/${REPO_NAME}/actions/workflows/dotnet.yml)" >> "../README.md"

echo "Project $APP_NAME initialization completed successfully!"
echo "Created:"
echo "  - Solution file"
echo "  - .gitignore for .NET projects"
echo "  - global.json for SDK version pinning"
echo "  - Business Logic library"
echo "  - Unit Tests project"
echo "  - README.md at repository root with status badge"
echo "  - GitHub Actions workflow configuration"
