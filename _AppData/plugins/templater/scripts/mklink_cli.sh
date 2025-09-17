#!/bin/bash

# mklink_cli.sh - A CLI tool to create symbolic links from origin to destination folder
# Usage: ./mklink_cli.sh [origin_folder] [destination_folder]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0 <origin_folder> <destination_folder>"
    echo ""
    echo -e "${BLUE}Description:${NC}"
    echo "  Creates symbolic links from all files/folders in origin_folder to destination_folder"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 /path/to/source /path/to/destination"
    echo "  $0 \"C:\\Source Folder\" \"C:\\Destination Folder\""
    echo ""
}

# Function to create symbolic links
create_links() {
    local origin="$1"
    local destination="$2"
    local count=0
    local errors=0
    
    echo -e "${BLUE}Creating symbolic links...${NC}"
    echo -e "Origin: ${YELLOW}$origin${NC}"
    echo -e "Destination: ${YELLOW}$destination${NC}"
    echo ""
    
    # Check if running on Windows (Git Bash, WSL, etc.)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "$WINDIR" ]]; then
        # Windows environment - use mklink command
        while IFS= read -r -d '' item; do
            local basename=$(basename "$item")
            local dest_path="$destination/$basename"
            
            if [[ -d "$item" ]]; then
                # Directory - create directory junction
                echo -e "Creating directory link: ${GREEN}$basename${NC}"
                if cmd //c "mklink /J \"$(cygpath -w "$dest_path")\" \"$(cygpath -w "$item")\"" > /dev/null 2>&1; then
                    ((count++))
                    echo -e "  ✓ ${GREEN}Success${NC}"
                else
                    ((errors++))
                    echo -e "  ✗ ${RED}Failed${NC}"
                fi
            else
                # File - create symbolic link
                echo -e "Creating file link: ${GREEN}$basename${NC}"
                if cmd //c "mklink \"$(cygpath -w "$dest_path")\" \"$(cygpath -w "$item")\"" > /dev/null 2>&1; then
                    ((count++))
                    echo -e "  ✓ ${GREEN}Success${NC}"
                else
                    ((errors++))
                    echo -e "  ✗ ${RED}Failed${NC}"
                fi
            fi
        done < <(find "$origin" -maxdepth 1 -mindepth 1 -print0)
    else
        # Unix/Linux environment - use ln command
        while IFS= read -r -d '' item; do
            local basename=$(basename "$item")
            local dest_path="$destination/$basename"
            
            echo -e "Creating link: ${GREEN}$basename${NC}"
            if ln -sf "$item" "$dest_path" 2>/dev/null; then
                ((count++))
                echo -e "  ✓ ${GREEN}Success${NC}"
            else
                ((errors++))
                echo -e "  ✗ ${RED}Failed${NC}"
            fi
        done < <(find "$origin" -maxdepth 1 -mindepth 1 -print0)
    fi
    
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo -e "  Links created: ${GREEN}$count${NC}"
    echo -e "  Errors: ${RED}$errors${NC}"
}

# Function to validate directories
validate_directories() {
    local origin="$1"
    local destination="$2"
    
    # Check if origin exists
    if [[ ! -d "$origin" ]]; then
        echo -e "${RED}Error: Origin directory does not exist: $origin${NC}" >&2
        return 1
    fi
    
    # Create destination directory if it doesn't exist
    if [[ ! -d "$destination" ]]; then
        echo -e "${YELLOW}Destination directory does not exist. Creating: $destination${NC}"
        if ! mkdir -p "$destination" 2>/dev/null; then
            echo -e "${RED}Error: Could not create destination directory: $destination${NC}" >&2
            return 1
        fi
    fi
    
    # Check if origin is empty
    if [[ -z "$(ls -A "$origin" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Warning: Origin directory is empty: $origin${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Main function
main() {
    echo -e "${BLUE}=== Symbolic Link Creator ===${NC}"
    echo ""
    
    # Check arguments
    if [[ $# -eq 0 ]]; then
        # Interactive mode
        echo "Interactive mode - please provide the required information:"
        echo ""
        
        read -p "Enter origin folder path: " origin_folder
        read -p "Enter destination folder path: " destination_folder
        
        # Remove quotes if present
        origin_folder=$(echo "$origin_folder" | sed 's/^"\(.*\)"$/\1/')
        destination_folder=$(echo "$destination_folder" | sed 's/^"\(.*\)"$/\1/')
        
    elif [[ $# -eq 2 ]]; then
        # Command line arguments
        origin_folder="$1"
        destination_folder="$2"
    else
        echo -e "${RED}Error: Invalid number of arguments${NC}" >&2
        echo ""
        show_usage
        exit 1
    fi
    
    # Validate input
    if [[ -z "$origin_folder" || -z "$destination_folder" ]]; then
        echo -e "${RED}Error: Both origin and destination folders must be specified${NC}" >&2
        exit 1
    fi
    
    # Validate directories
    if ! validate_directories "$origin_folder" "$destination_folder"; then
        exit 1
    fi
    
    # Confirm action
    echo ""
    echo -e "${YELLOW}About to create symbolic links:${NC}"
    echo -e "  From: ${BLUE}$origin_folder${NC}"
    echo -e "  To:   ${BLUE}$destination_folder${NC}"
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_links "$origin_folder" "$destination_folder"
    else
        echo -e "${YELLOW}Operation cancelled${NC}"
        exit 0
    fi
}

# Handle help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"