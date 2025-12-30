#!/bin/bash
# Author: Vitaswift | Version: 1.0.0
#
# vs_gatekeeper_test.sh - Script de Test du Gatekeeper
#
# Ce script crée des scénarios de test pour valider le fonctionnement
# du Vitaswift Architecture Gatekeeper

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  TESTS DU VITASWIFT GATEKEEPER${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Créer un répertoire temporaire pour les tests
TEST_DIR=$(mktemp -d)
echo -e "${CYAN}Répertoire de test: ${TEST_DIR}${NC}"
echo ""

# Fonction pour nettoyer
cleanup() {
    echo -e "\n${CYAN}Nettoyage du répertoire de test...${NC}"
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test 1: Projet conforme (devrait PASSER)
test_compliant_project() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}TEST 1: Projet Conforme${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    local project_dir="$TEST_DIR/compliant_project"
    mkdir -p "$project_dir/server"
    
    # Créer fxmanifest.lua
    cat > "$project_dir/fxmanifest.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
fx_version 'cerulean'
game 'gta5'

dependencies {
    'vs_bridge'
}
EOF
    
    # Créer vs_main.lua avec auto-création de tables
    cat > "$project_dir/server/vs_main.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
local function InitializeDatabase()
    local query = [[
        CREATE TABLE IF NOT EXISTS vs_logs (
            id INT AUTO_INCREMENT PRIMARY KEY
        )
    ]]
    exports.oxmysql:execute(query)
end

function VerifyPlayerGrade(source, requiredGrade)
    return exports.vs_bridge:GetPlayerGrade(source) >= requiredGrade
end
EOF
    
    # Créer vs_sentinel.lua
    cat > "$project_dir/server/vs_sentinel.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
local honeyPotEvents = {"vs_test:fakeEvent"}

for _, event in ipairs(honeyPotEvents) do
    RegisterServerEvent(event)
end

function CheckSuspiciousPatterns(text)
    return 0, {}
end
EOF
    
    echo -e "${YELLOW}Exécution du Gatekeeper...${NC}"
    if bash vs_gatekeeper.sh "$project_dir"; then
        echo -e "${GREEN}✅ TEST 1 RÉUSSI: Projet conforme accepté${NC}"
        return 0
    else
        echo -e "${RED}❌ TEST 1 ÉCHOUÉ: Projet conforme rejeté${NC}"
        return 1
    fi
}

# Test 2: Fichier sans préfixe vs_ (devrait ÉCHOUER)
test_invalid_naming() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}TEST 2: Nommage Invalide${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    local project_dir="$TEST_DIR/invalid_naming"
    mkdir -p "$project_dir/server"
    
    cat > "$project_dir/fxmanifest.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
fx_version 'cerulean'
dependencies { 'vs_bridge' }
EOF
    
    # Fichier sans préfixe vs_
    cat > "$project_dir/server/logger.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
print("Logger")
EOF
    
    echo -e "${YELLOW}Exécution du Gatekeeper...${NC}"
    if bash vs_gatekeeper.sh "$project_dir"; then
        echo -e "${RED}❌ TEST 2 ÉCHOUÉ: Nommage invalide accepté${NC}"
        return 1
    else
        echo -e "${GREEN}✅ TEST 2 RÉUSSI: Nommage invalide rejeté${NC}"
        return 0
    fi
}

# Test 3: Fichier SQL présent (devrait ÉCHOUER)
test_sql_file_present() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}TEST 3: Fichier SQL Présent${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    local project_dir="$TEST_DIR/sql_present"
    mkdir -p "$project_dir/server"
    
    cat > "$project_dir/fxmanifest.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
fx_version 'cerulean'
dependencies { 'vs_bridge' }
EOF
    
    cat > "$project_dir/server/vs_main.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
function InitializeDatabase()
    local query = "CREATE TABLE IF NOT EXISTS vs_logs (id INT)"
    exports.oxmysql:execute(query)
end
EOF
    
    # Créer un fichier SQL (violation)
    cat > "$project_dir/install.sql" << 'EOF'
CREATE TABLE vs_logs (id INT);
EOF
    
    echo -e "${YELLOW}Exécution du Gatekeeper...${NC}"
    if bash vs_gatekeeper.sh "$project_dir"; then
        echo -e "${RED}❌ TEST 3 ÉCHOUÉ: Fichier SQL accepté${NC}"
        return 1
    else
        echo -e "${GREEN}✅ TEST 3 RÉUSSI: Fichier SQL rejeté${NC}"
        return 0
    fi
}

# Test 4: Dépendance ESX directe (devrait ÉCHOUER)
test_direct_esx_dependency() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}TEST 4: Dépendance ESX Directe${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    local project_dir="$TEST_DIR/direct_esx"
    mkdir -p "$project_dir/server"
    
    cat > "$project_dir/fxmanifest.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
fx_version 'cerulean'
dependencies { 'vs_bridge' }
EOF
    
    # Code avec dépendance ESX directe
    cat > "$project_dir/server/vs_main.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
function InitializeDatabase()
    local query = "CREATE TABLE IF NOT EXISTS vs_logs (id INT)"
    exports.oxmysql:execute(query)
end

function GetPlayer(source)
    return ESX.GetPlayerData(source)
end
EOF
    
    echo -e "${YELLOW}Exécution du Gatekeeper...${NC}"
    if bash vs_gatekeeper.sh "$project_dir"; then
        echo -e "${RED}❌ TEST 4 ÉCHOUÉ: Dépendance ESX acceptée${NC}"
        return 1
    else
        echo -e "${GREEN}✅ TEST 4 RÉUSSI: Dépendance ESX rejetée${NC}"
        return 0
    fi
}

# Test 5: Signature manquante (devrait ÉCHOUER)
test_missing_signature() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}TEST 5: Signature Manquante${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    local project_dir="$TEST_DIR/missing_signature"
    mkdir -p "$project_dir/server"
    
    cat > "$project_dir/fxmanifest.lua" << 'EOF'
-- Author: Vitaswift | Version: 1.0.0
fx_version 'cerulean'
dependencies { 'vs_bridge' }
EOF
    
    # Fichier sans signature
    cat > "$project_dir/server/vs_main.lua" << 'EOF'
-- Pas de signature Vitaswift
function InitializeDatabase()
    local query = "CREATE TABLE IF NOT EXISTS vs_logs (id INT)"
    exports.oxmysql:execute(query)
end
EOF
    
    echo -e "${YELLOW}Exécution du Gatekeeper...${NC}"
    if bash vs_gatekeeper.sh "$project_dir"; then
        echo -e "${RED}❌ TEST 5 ÉCHOUÉ: Signature manquante acceptée${NC}"
        return 1
    else
        echo -e "${GREEN}✅ TEST 5 RÉUSSI: Signature manquante rejetée${NC}"
        return 0
    fi
}

# Exécuter tous les tests
run_all_tests() {
    local passed=0
    local failed=0
    
    if test_compliant_project; then ((passed++)); else ((failed++)); fi
    if test_invalid_naming; then ((passed++)); else ((failed++)); fi
    if test_sql_file_present; then ((passed++)); else ((failed++)); fi
    if test_direct_esx_dependency; then ((passed++)); else ((failed++)); fi
    if test_missing_signature; then ((passed++)); else ((failed++)); fi
    
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  RÉSUMÉ DES TESTS${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Tests réussis: $passed${NC}"
    echo -e "${RED}Tests échoués: $failed${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✅ Tous les tests ont réussi!${NC}"
        return 0
    else
        echo -e "${RED}❌ Certains tests ont échoué${NC}"
        return 1
    fi
}

# Exécuter les tests
run_all_tests
