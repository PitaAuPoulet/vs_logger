# Vitaswift Architecture Gatekeeper

**Author:** Vitaswift  
**Version:** 1.0.0

## 🎯 Mission

Analyser la conformité du code avec les standards Vitaswift et appliquer un **VETO catégorique** si un seul des standards fondamentaux est violé.

## 🚨 Critères d'Acceptation (ZÉRO TOLÉRANCE)

Le Gatekeeper vérifie 5 critères essentiels :

### 1. Standard de Nommage (Prefix vs_)
- ✅ **TOUS** les nouveaux fichiers doivent être nommés `vs_*.lua`
- ✅ **TOUTES** les variables globales et exports doivent commencer par `vs_`
- ❌ Aucune exception autorisée (sauf fichiers système: `fxmanifest.lua`, `config.lua`)

**Exemples conformes:**
```
vs_main.lua
vs_sentinel.lua
vs_gatekeeper.lua
```

**Exemples non conformes:**
```
main.lua
sentinel.lua
logger.lua
```

### 2. Doctrine Zero-SQL
- ✅ **Interdiction totale** de fichiers `.sql`
- ✅ Vérification de la présence de l'auto-création de tables dans le code
- ✅ Les tables doivent être créées automatiquement au démarrage du serveur

**Code conforme:**
```lua
local function InitializeDatabase()
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS vs_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            ...
        )
    ]]
    exports.oxmysql:execute(createTableQuery)
end
```

**Code non conforme:**
```
❌ Présence de fichiers install.sql, schema.sql, etc.
❌ Pas de création automatique de tables
```

### 3. Intégrité du Bridge (vs_bridge)
- ✅ **Aucune dépendance directe** vers ESX ou QBCore
- ✅ Utilisation **exclusive** de `vs_bridge` pour toutes les interactions framework
- ✅ Dépendance `vs_bridge` déclarée dans `fxmanifest.lua`

**Code conforme:**
```lua
-- Utilisation du bridge
local grade = exports.vs_bridge:GetPlayerGrade(source)
```

**Code non conforme:**
```lua
-- Dépendance directe ESX
ESX.GetPlayerData()
exports.es_extended:getSharedObject()

-- Dépendance directe QBCore
QBCore.Functions.GetPlayer()
exports['qb-core']:GetCoreObject()
```

### 4. Validation Sentinel (Sécurité)
- ✅ **Validation server-side stricte** pour chaque event
- ✅ **Check de permissions** pour toutes les actions sensibles
- ✅ Présence du module Sentinel avec fonctionnalités de sécurité
- ✅ HoneyPot events et détection de patterns suspects

**Fonctionnalités requises:**
- Enregistrement d'événements serveur sécurisés
- HoneyPot events pour détecter les menus
- Détection de patterns suspects
- Validation des grades/permissions

### 5. Signature d'Architecte
- ✅ **Signature obligatoire** en header de chaque fichier: `-- Author: Vitaswift | Version: X.X.X`
- ✅ La signature doit apparaître dans les **10 premières lignes**

**Format correct:**
```lua
-- Author: Vitaswift | Version: 1.0.0
--[[
    vs_logger - Main Server Logic
    ...
]]
```

## 📋 Utilisation

### Installation

Le Gatekeeper est intégré automatiquement via GitHub Actions. Pour une utilisation locale :

```bash
# Rendre le script exécutable
chmod +x vs_gatekeeper.sh

# Exécuter l'audit
./vs_gatekeeper.sh .
```

### GitHub Actions

Le Gatekeeper s'exécute automatiquement sur chaque Pull Request vers les branches principales.

Le workflow vérifie :
- Tous les commits de la PR
- Tous les fichiers modifiés ou ajoutés
- La conformité globale du projet

### Format de Sortie

Le Gatekeeper génère un rapport détaillé :

```
========================================
  VITASWIFT ARCHITECTURE GATEKEEPER
  Senior Security & Architecture Auditor
========================================

[GATEKEEPER] Vérification du standard de nommage...
✅ PASS: Standard de nommage

[GATEKEEPER] Vérification de la doctrine Zero-SQL...
✅ PASS: Doctrine Zero-SQL

[GATEKEEPER] Vérification de l'intégrité du bridge...
✅ PASS: Intégrité du Bridge

[GATEKEEPER] Vérification de la validation Sentinel...
✅ PASS: Validation Sentinel

[GATEKEEPER] Vérification de la signature d'architecte...
✅ PASS: Signature d'Architecte

========================================
  RAPPORT DE CONFORMITÉ VITASWIFT
========================================

1. Standard de Nommage (vs_)
2. Doctrine Zero-SQL
3. Intégrité du Bridge
4. Validation Sentinel
5. Signature d'Architecte

Résultats: 5 PASS / 0 FAIL / 5 TOTAL

========================================
  DÉCISION FINALE
========================================

✅ APPROUVÉ - Tous les critères sont respectés
Le code est conforme aux standards Vitaswift.

========================================
```

## 🔧 Intégration dans votre Projet

### Option 1: GitHub Actions (Recommandé)

1. Copiez le workflow dans votre projet :
```bash
mkdir -p .github/workflows
cp vitaswift-gatekeeper.yml .github/workflows/
```

2. Copiez le script de validation :
```bash
cp vs_gatekeeper.sh ./
chmod +x vs_gatekeeper.sh
```

3. Le Gatekeeper s'exécutera automatiquement sur chaque PR

### Option 2: Pre-commit Hook

Ajoutez au fichier `.git/hooks/pre-commit` :

```bash
#!/bin/bash
echo "🚀 Exécution du Vitaswift Gatekeeper..."
./vs_gatekeeper.sh .
exit $?
```

### Option 3: CI/CD Manuel

Ajoutez à votre pipeline CI/CD :

```yaml
- name: Vitaswift Audit
  run: bash vs_gatekeeper.sh .
```

## 🛡️ Philosophie de Zéro Tolérance

Le Gatekeeper applique une politique de **zéro tolérance** :

- ❌ **Un seul critère échoué = VETO immédiat**
- ❌ **Pas d'exceptions** - même pour les "petites" violations
- ❌ **Pas de contournement** - tous les fichiers sont vérifiés
- ✅ **Qualité assurée** - le code qui passe est garanti conforme

### Pourquoi cette rigueur?

1. **Cohérence du Code** : Tous les projets Vitaswift suivent les mêmes standards
2. **Maintenance Facilitée** : Un code uniforme est plus facile à maintenir
3. **Sécurité Renforcée** : Les standards incluent des règles de sécurité critiques
4. **Professionnalisme** : Reflète un niveau de qualité professionnel

## 📊 Statistiques et Métriques

Le Gatekeeper suit :
- Nombre total de vérifications : **5**
- Critères passés / échoués
- Fichiers analysés
- Problèmes détectés par catégorie

## 🔍 Dépannage

### Le Gatekeeper échoue mais je pense que mon code est correct

1. **Vérifiez les logs détaillés** : Le Gatekeeper indique exactement quel fichier pose problème
2. **Consultez les exemples** : Comparez votre code avec les exemples conformes ci-dessus
3. **Relisez les critères** : Assurez-vous de bien comprendre chaque critère

### Comment corriger les erreurs communes?

#### Erreur: "Fichier ne commence pas par 'vs_'"
```bash
# Renommez le fichier
mv logger.lua vs_logger.lua

# Mettez à jour fxmanifest.lua en conséquence
```

#### Erreur: "Fichier SQL détecté"
```bash
# Supprimez le fichier SQL
rm install.sql

# Implémentez l'auto-création dans le code
```

#### Erreur: "Signature manquante"
```lua
-- Ajoutez en début de fichier:
-- Author: Vitaswift | Version: 1.0.0
```

#### Erreur: "Dépendance directe ESX/QBCore"
```lua
-- Remplacez:
ESX.GetPlayerData()

-- Par:
exports.vs_bridge:GetPlayerData()
```

## 🎓 Meilleures Pratiques

1. **Testez localement** avant de push
   ```bash
   ./vs_gatekeeper.sh .
   ```

2. **Corrigez immédiatement** les problèmes détectés

3. **Ne contournez pas** le Gatekeeper - il est là pour garantir la qualité

4. **Documentez vos choix** si vous pensez qu'une règle devrait être modifiée

## 📝 Contribuer

Pour proposer des modifications au Gatekeeper :

1. Ouvrez une issue expliquant le problème
2. Proposez une solution alternative
3. Justifiez pourquoi le changement est nécessaire

Les standards Vitaswift sont stricts par design et ne sont modifiés qu'avec une justification solide.

## 📄 Licence

Ce Gatekeeper fait partie de l'écosystème Vitaswift et suit les mêmes règles de licence que les autres composants.

---

**Remember:** Le Gatekeeper n'est pas un obstacle - c'est un garde-fou qui assure la qualité et la cohérence de l'écosystème Vitaswift! 🛡️
