#!/bin/bash
# Author: Vitaswift | Version: 1.0.0
#
# vs_gatekeeper - Script d'Audit d'Architecture Vitaswift
#
# Mission: Analyser la conformité du code avec les standards Vitaswift
# et appliquer un VETO si les règles fondamentales sont violées.

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Compteurs
TOTAL_CHECKS=5
PASSED_CHECKS=0
FAILED_CHECKS=0

# Répertoire du projet (par défaut, répertoire courant)
PROJECT_DIR="${1:-.}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  VITASWIFT ARCHITECTURE GATEKEEPER${NC}"
echo -e "${BLUE}  Senior Security & Architecture Auditor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Vérifier le Standard de Nommage
check_naming_standard() {
    echo -e "${CYAN}[GATEKEEPER] Vérification du standard de nommage...${NC}"
    
    local issues=0
    
    # Trouver tous les fichiers .lua qui ne commencent pas par vs_
    while IFS= read -r file; do
        filename=$(basename "$file")
        
        # Ignorer les fichiers spéciaux
        if [[ ! "$filename" =~ ^(fxmanifest|config|examples)\.lua$ ]]; then
            if [[ ! "$filename" =~ ^vs_ ]]; then
                echo -e "  ${YELLOW}❌ Fichier '$filename' ne commence pas par 'vs_'${NC}"
                ((issues++))
            fi
        fi
    done < <(find "$PROJECT_DIR" -name "*.lua" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f)
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: Standard de nommage${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}❌ FAIL: Standard de nommage${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

# 2. Vérifier la Doctrine Zero-SQL
check_zero_sql() {
    echo -e "${CYAN}[GATEKEEPER] Vérification de la doctrine Zero-SQL...${NC}"
    
    local issues=0
    
    # Vérifier l'absence de fichiers .sql
    sql_files=$(find "$PROJECT_DIR" -name "*.sql" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f 2>/dev/null | wc -l)
    
    if [ "$sql_files" -gt 0 ]; then
        echo -e "  ${YELLOW}❌ $sql_files fichier(s) .sql détecté(s)${NC}"
        find "$PROJECT_DIR" -name "*.sql" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f | while read -r file; do
            echo -e "     - $(basename "$file")"
        done
        ((issues++))
    fi
    
    # Vérifier la présence de l'auto-création de tables
    auto_create_found=false
    if [ -f "$PROJECT_DIR/server/vs_main.lua" ]; then
        if grep -q "CREATE TABLE IF NOT EXISTS\|InitializeDatabase\|AutoCreateTables" "$PROJECT_DIR/server/vs_main.lua"; then
            auto_create_found=true
        fi
    fi
    
    if [ "$auto_create_found" = false ]; then
        echo -e "  ${YELLOW}❌ Pas d'auto-création de tables détectée dans le code${NC}"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: Doctrine Zero-SQL${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}❌ FAIL: Doctrine Zero-SQL${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

# 3. Vérifier l'Intégrité du Bridge
check_bridge_integrity() {
    echo -e "${CYAN}[GATEKEEPER] Vérification de l'intégrité du bridge...${NC}"
    
    local issues=0
    
    # Vérifier la dépendance vs_bridge dans fxmanifest.lua
    if [ -f "$PROJECT_DIR/fxmanifest.lua" ]; then
        if ! grep -q "vs_bridge" "$PROJECT_DIR/fxmanifest.lua"; then
            echo -e "  ${YELLOW}❌ Dépendance 'vs_bridge' manquante dans fxmanifest.lua${NC}"
            ((issues++))
        fi
    else
        echo -e "  ${YELLOW}❌ Fichier fxmanifest.lua introuvable${NC}"
        ((issues++))
    fi
    
    # Vérifier l'absence de dépendances directes ESX/QBCore dans les fichiers serveur
    if [ -d "$PROJECT_DIR/server" ]; then
        while IFS= read -r file; do
            if grep -q "ESX\.GetPlayerData\|QBCore\.Functions\|exports\.es_extended\|exports\['qb-core'\]" "$file"; then
                echo -e "  ${YELLOW}❌ Dépendance directe ESX/QBCore détectée dans $(basename "$file")${NC}"
                ((issues++))
            fi
        done < <(find "$PROJECT_DIR/server" -name "*.lua" -type f)
    fi
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: Intégrité du Bridge${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}❌ FAIL: Intégrité du Bridge${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

# 4. Vérifier la Validation Sentinel
check_sentinel_validation() {
    echo -e "${CYAN}[GATEKEEPER] Vérification de la validation Sentinel...${NC}"
    
    local issues=0
    
    # Vérifier la présence du module Sentinel
    if [ ! -f "$PROJECT_DIR/server/vs_sentinel.lua" ]; then
        echo -e "  ${YELLOW}❌ Module Sentinel manquant (vs_sentinel.lua)${NC}"
        ((issues++))
    else
        # Vérifier les fonctionnalités essentielles
        if ! grep -q "RegisterServerEvent" "$PROJECT_DIR/server/vs_sentinel.lua"; then
            echo -e "  ${YELLOW}❌ Fonctionnalité manquante: Enregistrement d'événements serveur${NC}"
            ((issues++))
        fi
        
        if ! grep -q "honeyPot" "$PROJECT_DIR/server/vs_sentinel.lua"; then
            echo -e "  ${YELLOW}❌ Fonctionnalité manquante: HoneyPot events${NC}"
            ((issues++))
        fi
        
        if ! grep -q "CheckSuspiciousPatterns" "$PROJECT_DIR/server/vs_sentinel.lua"; then
            echo -e "  ${YELLOW}❌ Fonctionnalité manquante: Détection de patterns suspects${NC}"
            ((issues++))
        fi
    fi
    
    # Vérifier la validation server-side
    if [ -f "$PROJECT_DIR/server/vs_main.lua" ]; then
        if ! grep -q "VerifyPlayerGrade\|requiresGrade" "$PROJECT_DIR/server/vs_main.lua"; then
            echo -e "  ${YELLOW}❌ Validation des permissions manquante${NC}"
            ((issues++))
        fi
    fi
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: Validation Sentinel${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}❌ FAIL: Validation Sentinel${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

# 5. Vérifier la Signature d'Architecte
check_architect_signature() {
    echo -e "${CYAN}[GATEKEEPER] Vérification de la signature d'architecte...${NC}"
    
    local issues=0
    
    # Vérifier la signature dans tous les fichiers Lua
    while IFS= read -r file; do
        if ! head -n 10 "$file" | grep -q "Author:.*Vitaswift"; then
            echo -e "  ${YELLOW}❌ Signature manquante dans $(basename "$file")${NC}"
            ((issues++))
        fi
    done < <(find "$PROJECT_DIR" -name "*.lua" -not -path "*/node_modules/*" -not -path "*/.git/*" -type f)
    
    if [ $issues -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: Signature d'Architecte${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}❌ FAIL: Signature d'Architecte${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

# Générer le rapport de conformité
generate_report() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  RAPPORT DE CONFORMITÉ VITASWIFT${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "1. Standard de Nommage (vs_)"
    echo "2. Doctrine Zero-SQL"
    echo "3. Intégrité du Bridge"
    echo "4. Validation Sentinel"
    echo "5. Signature d'Architecte"
    echo ""
    echo -e "Résultats: ${GREEN}$PASSED_CHECKS PASS${NC} / ${RED}$FAILED_CHECKS FAIL${NC} / $TOTAL_CHECKS TOTAL"
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  DÉCISION FINALE${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    if [ "$PASSED_CHECKS" -eq "$TOTAL_CHECKS" ]; then
        echo -e "${GREEN}✅ APPROUVÉ - Tous les critères sont respectés${NC}"
        echo -e "${GREEN}Le code est conforme aux standards Vitaswift.${NC}"
        echo ""
        echo -e "${BLUE}========================================${NC}"
        return 0
    else
        echo -e "${RED}❌ VETO - Standards Vitaswift violés${NC}"
        echo -e "${RED}Cette Pull Request ne peut pas être acceptée.${NC}"
        echo ""
        echo -e "${YELLOW}Corrections requises avant approbation.${NC}"
        echo ""
        echo -e "${BLUE}========================================${NC}"
        return 1
    fi
}

# Exécution principale
main() {
    check_naming_standard || true
    check_zero_sql || true
    check_bridge_integrity || true
    check_sentinel_validation || true
    check_architect_signature || true
    
    generate_report
    exit_code=$?
    
    exit $exit_code
}

main
