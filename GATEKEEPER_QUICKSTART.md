# Vitaswift Architecture Gatekeeper - Guide Rapide

## 🚀 Démarrage Rapide

### Installation Locale
```bash
# Cloner le repository
git clone https://github.com/PitaAuPoulet/vs_logger.git
cd vs_logger

# Rendre le script exécutable
chmod +x vs_gatekeeper.sh

# Exécuter l'audit
./vs_gatekeeper.sh .
```

### Résultat Attendu
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
  DÉCISION FINALE
========================================

✅ APPROUVÉ - Tous les critères sont respectés
```

## ⚡ Vérifications Effectuées

| # | Critère | Description | Règle |
|---|---------|-------------|-------|
| 1 | **Nommage** | Préfixe vs_ obligatoire | Tous les fichiers .lua doivent commencer par `vs_` |
| 2 | **Zero-SQL** | Pas de fichiers SQL | Aucun fichier .sql autorisé, auto-création uniquement |
| 3 | **Bridge** | Intégrité du bridge | Utilisation exclusive de `vs_bridge`, pas de dépendances ESX/QBCore |
| 4 | **Sentinel** | Sécurité | Validation server-side, permissions, HoneyPot events |
| 5 | **Signature** | En-tête | `-- Author: Vitaswift \| Version: X.X.X` obligatoire |

## 🔧 Correction Rapide des Erreurs

### Erreur 1: "Fichier ne commence pas par 'vs_'"
```bash
# Renommer le fichier
mv logger.lua vs_logger.lua

# Mettre à jour les références dans fxmanifest.lua
```

### Erreur 2: "Fichier SQL détecté"
```bash
# Supprimer le fichier SQL
rm install.sql schema.sql

# Implémenter l'auto-création dans vs_main.lua
```

### Erreur 3: "Dépendance directe ESX/QBCore"
```lua
-- ❌ Avant
local xPlayer = ESX.GetPlayerFromId(source)

-- ✅ Après
local xPlayer = exports.vs_bridge:GetPlayerFromId(source)
```

### Erreur 4: "Signature manquante"
```lua
-- Ajouter en haut du fichier:
-- Author: Vitaswift | Version: 1.0.0
```

### Erreur 5: "vs_bridge manquant dans dependencies"
```lua
-- Dans fxmanifest.lua, ajouter:
dependencies {
    'vs_bridge'
}
```

## 📊 Codes de Sortie

| Code | Signification |
|------|---------------|
| 0 | ✅ Tous les tests passent - Projet conforme |
| 1 | ❌ Au moins un test échoue - Corrections requises |

## 🔄 Intégration CI/CD

### GitHub Actions (Automatique)
Le workflow `.github/workflows/vitaswift-gatekeeper.yml` s'exécute automatiquement sur chaque PR.

### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/bash
./vs_gatekeeper.sh .
exit $?
```

### GitLab CI
```yaml
gatekeeper:
  stage: test
  script:
    - bash vs_gatekeeper.sh .
```

## 📚 Documentation Complète

Pour plus de détails, consultez:
- **GATEKEEPER.md** - Documentation complète
- **README.md** - Vue d'ensemble du projet
- **.github/copilot-instructions.md** - Standards de développement

## 🆘 Support

En cas de problème:
1. Lisez les messages d'erreur détaillés du Gatekeeper
2. Consultez la section "Correction Rapide" ci-dessus
3. Vérifiez GATEKEEPER.md pour des exemples détaillés
4. Ouvrez une issue sur GitHub avec les logs complets

## ⚠️ Important

Le Gatekeeper applique une politique de **zéro tolérance**:
- Un seul critère échoué = VETO immédiat
- Pas d'exceptions
- Qualité garantie pour tout code accepté

---

**Vitaswift Architecture Gatekeeper** - Garant de la qualité du code 🛡️
