#!/bin/bash

# Download invite data script for Me-gotchi Android app
# This script downloads data.json and images from Firebase Storage bucket using an invite code

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <invite_code> [options]"
    echo ""
    echo "Arguments:"
    echo "  invite_code    The invite code to download data for (format: XXXX-XXXX-XXXX)"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Verbose output"
    echo ""
    echo "Examples:"
    echo "  $0 1234-5678-9012"
    echo "  $0 1234-5678-9012 --verbose"
}

# Function to validate invite code format
validate_invite_code() {
    local invite_code=$1
    local pattern="^[0-9]{4}-[0-9]{4}-[0-9]{4}$"
    
    if [[ ! $invite_code =~ $pattern ]]; then
        print_error "Invalid invite code format. Expected format: XXXX-XXXX-XXXX"
        exit 1
    fi
}

# Function to check if curl is available
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
}

# Function to download file from Firebase Storage
download_file() {
    local invite_code=$1
    local filename=$2
    local local_path=$3
    
    local url="https://storage.googleapis.com/me-gotchi.firebasestorage.app/${invite_code}/${filename}"
    
    print_status "Downloading ${filename} from ${url}"
    
    if curl -f -s -o "$local_path" "$url"; then
        print_success "Downloaded ${filename} successfully"
        return 0
    else
        print_error "Failed to download ${filename}"
        return 1
    fi
}

# Function to list and download images
download_images() {
    local invite_code=$1
    local verbose=$2
    
    print_status "Attempting to download images for invite code: $invite_code"
    
    # Image assets based on generateCustomizedApk.js
    local image_assets=(
        "face-atlas.png"
        "food-atlas.png"
        "activities-atlas.png"
        "background1.jpg"
        "background2.jpg"
        "background3.jpg"
        "background4.jpg"
    )
    
    local downloaded_count=0
    
    for image in "${image_assets[@]}"; do
        local url="https://storage.googleapis.com/me-gotchi.firebasestorage.app/${invite_code}/${image}"
        local local_path="images/${image}"
        
        if [[ "$verbose" == "true" ]]; then
            print_status "Trying: $url"
        fi
        
        if curl -f -s -I "$url" > /dev/null 2>&1; then
            if download_file "$invite_code" "$image" "$local_path"; then
                ((downloaded_count++))
            fi
        else
            if [[ "$verbose" == "true" ]]; then
                print_warning "Image not found: $image"
            fi
        fi
    done
    
    if [[ $downloaded_count -eq 0 ]]; then
        print_warning "No images found for invite code: $invite_code"
    else
        print_success "Downloaded $downloaded_count image(s)"
    fi
}

# Main function
main() {
    local invite_code=""
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$invite_code" ]]; then
                    invite_code="$1"
                else
                    print_error "Multiple invite codes provided. Please provide only one."
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if invite code was provided
    if [[ -z "$invite_code" ]]; then
        print_error "Invite code is required"
        show_usage
        exit 1
    fi
    
    # Validate invite code format
    validate_invite_code "$invite_code"
    
    # Check dependencies
    check_dependencies
    
    print_status "Starting download for invite code: $invite_code"
    
    # Create directories if they don't exist
    mkdir -p data
    mkdir -p images
    
    # Download data.json
    print_status "Downloading data.json..."
    if download_file "$invite_code" "data.json" "data/data.json"; then
        print_success "data.json downloaded successfully"
    else
        print_error "Failed to download data.json. The invite code might not exist or data.json might not be available."
        exit 1
    fi
    
    # Download images
    download_images "$invite_code" "$verbose"
    
    print_success "Download completed for invite code: $invite_code"
    print_status "Files downloaded to:"
    print_status "  - data/data.json"
    print_status "  - images/ (if any images were found)"
}

# Run main function with all arguments
main "$@" 