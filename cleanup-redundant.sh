#!/bin/bash

echo "🧹 Cleaning Up Redundant Files"
echo "==============================="

# Function to show what will be removed
show_redundant_files() {
    echo ""
    echo "📋 Redundant files found:"
    echo ""
    
    echo "🗂️  Backup files (created by optimization scripts):"
    find . -name "*.backup" -type f 2>/dev/null | while read file; do
        echo "   📄 $file"
    done
    
    echo ""
    echo "🔧 One-time setup scripts (completed and no longer needed):"
    if [ -f "organize-project.sh" ]; then
        echo "   📄 organize-project.sh (project organization completed)"
    fi
    if [ -f "cleanup-redundant.sh" ]; then
        echo "   📄 cleanup-redundant.sh (cleanup script itself - after use)"
    fi
    
    echo ""
    echo "🪟 Windows .bat files (duplicates of .sh files):"
    
    # Environment scripts (redundant since we have .sh versions)
    if [ -f "scripts/environment/start-environment.bat" ]; then
        echo "   📄 scripts/environment/start-environment.bat (duplicate of .sh)"
    fi
    if [ -f "scripts/environment/stop-environment.bat" ]; then
        echo "   📄 scripts/environment/stop-environment.bat (duplicate of .sh)"
    fi
    
    # Infrastructure .bat files (redundant since we have .sh versions)
    if [ -f "vault-docker/start-vault.bat" ]; then
        echo "   📄 vault-docker/start-vault.bat (duplicate of .sh)"
    fi
    if [ -f "vault-docker/load-secrets.bat" ]; then
        echo "   📄 vault-docker/load-secrets.bat (duplicate of .sh)"
    fi
    if [ -f "kafka-docker/start-kafka.bat" ]; then
        echo "   📄 kafka-docker/start-kafka.bat (duplicate of .sh)"
    fi
    if [ -f "kafka-docker/test-bus-refresh.bat" ]; then
        echo "   📄 kafka-docker/test-bus-refresh.bat (duplicate of .sh)"
    fi
    
    echo ""
    echo "🏗️  Empty build cache directories:"
    find . -name "build-cache" -type d 2>/dev/null | while read dir; do
        if [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null | grep -v 'gc.properties')" ]; then
            echo "   📁 $dir (only contains gc.properties)"
        fi
    done
}

# Function to remove backup files
remove_backup_files() {
    echo ""
    echo "🗑️  Removing backup files..."
    
    backup_files=$(find . -name "*.backup" -type f 2>/dev/null)
    if [ -n "$backup_files" ]; then
        echo "$backup_files" | while read file; do
            rm -f "$file"
            echo "   ✅ Removed: $file"
        done
    else
        echo "   ℹ️  No backup files found"
    fi
}

# Function to remove one-time setup scripts
remove_onetime_scripts() {
    echo ""
    echo "🔧 Removing completed one-time setup scripts..."
    
    if [ -f "organize-project.sh" ]; then
        rm -f "organize-project.sh"
        echo "   ✅ Removed: organize-project.sh (project organization completed)"
    fi
    
    echo "   ℹ️  Keeping cleanup-redundant.sh until after this cleanup completes"
}
remove_bat_files() {
    echo ""
    echo "🪟 Removing redundant Windows .bat files..."
    
    # Environment scripts
    if [ -f "scripts/environment/start-environment.bat" ]; then
        rm -f "scripts/environment/start-environment.bat"
        echo "   ✅ Removed: scripts/environment/start-environment.bat"
    fi
    if [ -f "scripts/environment/stop-environment.bat" ]; then
        rm -f "scripts/environment/stop-environment.bat"
        echo "   ✅ Removed: scripts/environment/stop-environment.bat"
    fi
    
    # Infrastructure .bat files
    if [ -f "vault-docker/start-vault.bat" ]; then
        rm -f "vault-docker/start-vault.bat"
        echo "   ✅ Removed: vault-docker/start-vault.bat"
    fi
    if [ -f "vault-docker/load-secrets.bat" ]; then
        rm -f "vault-docker/load-secrets.bat"
        echo "   ✅ Removed: vault-docker/load-secrets.bat"
    fi
    if [ -f "kafka-docker/start-kafka.bat" ]; then
        rm -f "kafka-docker/start-kafka.bat"
        echo "   ✅ Removed: kafka-docker/start-kafka.bat"
    fi
    if [ -f "kafka-docker/test-bus-refresh.bat" ]; then
        rm -f "kafka-docker/test-bus-refresh.bat"
        echo "   ✅ Removed: kafka-docker/test-bus-refresh.bat"
    fi
    
    echo "   ℹ️  Keeping gradlew.bat files (needed for Windows Gradle builds)"
}

# Function to clean build cache directories
clean_build_cache() {
    echo ""
    echo "🏗️  Cleaning build cache directories..."
    
    find . -name "build-cache" -type d 2>/dev/null | while read dir; do
        if [ -d "$dir" ]; then
            # Keep the directory but remove everything except essential files
            find "$dir" -type f ! -name "gc.properties" -delete 2>/dev/null || true
            echo "   🧹 Cleaned: $dir"
        fi
    done
}

# Function to update .gitignore to prevent future redundant files
update_gitignore() {
    echo ""
    echo "📝 Updating .gitignore to prevent redundant files..."
    
    # Check if patterns already exist
    if ! grep -q "# Redundant Windows files" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'EOF'

# Redundant Windows files
**/*.backup
**/*.bak
**/*.tmp
**/build-cache/**
!**/build-cache/gc.properties

# Windows batch files (use .sh equivalents)
start-environment.bat
stop-environment.bat
start-vault.bat
load-secrets.bat
start-kafka.bat
test-bus-refresh.bat
EOF
        echo "   ✅ Updated .gitignore with redundancy patterns"
    else
        echo "   ℹ️  .gitignore already contains redundancy patterns"
    fi
}

# Function to show cleanup summary
show_cleanup_summary() {
    echo ""
    echo "📊 Cleanup Summary:"
    echo "=================="
    echo "✅ Removed backup files from optimization scripts"
    echo "✅ Removed completed one-time setup scripts"
    echo "✅ Removed redundant Windows .bat files" 
    echo "✅ Cleaned build cache directories"
    echo "✅ Updated .gitignore to prevent future redundancy"
    echo "✅ Kept essential files (gradlew.bat, ongoing scripts, etc.)"
    echo ""
    echo "💡 Benefits:"
    echo "   • Cleaner repository"
    echo "   • Reduced file duplication"
    echo "   • Focus on cross-platform .sh scripts"
    echo "   • Removed completed one-time scripts"
    echo "   • Smaller repository size"
    echo ""
    echo "🎯 Remaining .bat files:"
    find . -name "*.bat" -type f 2>/dev/null | grep -v "gradlew.bat" || echo "   None (only gradlew.bat files remain)"
}

# Function to show space saved
show_space_saved() {
    echo ""
    echo "💾 Repository cleanup statistics:"
    
    total_files=$(find . -type f | wc -l)
    bat_files=$(find . -name "*.bat" -not -name "gradlew.bat" | wc -l)
    backup_files=$(find . -name "*.backup" | wc -l)
    onetime_scripts=0
    [ -f "organize-project.sh" ] && ((onetime_scripts++))
    
    echo "   📁 Total files in repository: $total_files"
    echo "   🗑️  Redundant .bat files removed: $bat_files"
    echo "   🗑️  Backup files removed: $backup_files"
    echo "   🔧 One-time scripts removed: $onetime_scripts"
    echo "   ✨ Repository is now cleaner and more focused"
}

# Main execution function
main() {
    show_redundant_files
    
    echo ""
    read -p "🤔 Proceed with cleanup? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        remove_backup_files
        remove_onetime_scripts
        remove_bat_files
        clean_build_cache
        update_gitignore
        show_cleanup_summary
        show_space_saved
        
        echo ""
        echo "🎉 Cleanup completed successfully!"
        echo ""
        echo "💡 Next steps:"
        echo "   1. Review changes: git status"
        echo "   2. Test functionality: ./start.sh status"
        echo "   3. Commit changes: git add . && git commit -m 'chore: remove redundant files and one-time scripts'"
        echo "   4. Optional: rm cleanup-redundant.sh (after confirming everything works)"
    else
        echo "❌ Cleanup cancelled"
    fi
}

# Handle script arguments
case "${1:-cleanup}" in
    "cleanup")
        main
        ;;
    "preview"|"show")
        show_redundant_files
        show_space_saved
        ;;
    "force")
        echo "🚨 Force cleanup (no confirmation)..."
        remove_backup_files
        remove_onetime_scripts
        remove_bat_files
        clean_build_cache
        update_gitignore
        show_cleanup_summary
        ;;
    *)
        echo "Usage: $0 {cleanup|preview|force}"
        echo ""
        echo "  cleanup  - Interactive cleanup with confirmation (default)"
        echo "  preview  - Show what would be removed without doing it"
        echo "  force    - Remove files without confirmation"
        exit 1
        ;;
esac