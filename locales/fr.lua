-- Author: Vitaswift | Version: 1.0.0

Locales['fr'] = {
    -- Système principal
    ['system_starting'] = 'vs_logger - Sentinel Edition',
    ['system_author'] = 'Auteur: %s',
    ['system_version'] = 'Version: %s',
    ['system_ready'] = 'Système de journalisation prêt!',
    ['system_stopped'] = 'Système de journalisation arrêté',
    
    -- Base de données
    ['db_initializing'] = 'Initialisation de la base de données Zero-SQL...',
    ['db_initialized'] = 'Tables de base de données initialisées avec succès!',
    ['db_error'] = 'ERREUR: Échec de l\'initialisation des tables de base de données',
    ['db_no_mysql'] = 'ATTENTION: Aucune ressource MySQL trouvée (oxmysql ou mysql-async requis)',
    ['db_saved'] = 'Log sauvegardé dans la base de données: %s - %s',
    ['db_save_failed'] = 'Échec de la sauvegarde du log dans la base de données: %s - %s',
    ['db_processing_queue'] = 'Traitement de %d logs restants avant l\'arrêt...',
    ['db_processed'] = 'Traité %d logs en file d\'attente',
    
    -- Limitation de taux
    ['ratelimit_cooldown'] = 'Cooldown de limitation de taux actif pour %s',
    ['ratelimit_exceeded'] = 'Limitation de taux dépassée pour %s (violations: %d)',
    
    -- Logs
    ['log_invalid_type'] = 'Type de log invalide: %s',
    ['log_disabled'] = 'Le type de log \'%s\' est désactivé',
    ['log_ratelimit'] = 'Limitation de taux dépassée pour la source %d',
    ['log_unauthorized'] = 'Tentative de log non autorisée par la source %d pour le type \'%s\'',
    
    -- Webhook
    ['webhook_not_configured'] = 'URL du webhook non configurée, notification Discord ignorée',
    ['webhook_success'] = 'Envoyé avec succès au webhook Discord',
    ['webhook_error'] = 'Erreur du webhook Discord: %d - %s',
    
    -- Sentinel
    ['sentinel_enabled'] = 'Module de sécurité Sentinel: ACTIVÉ',
    ['sentinel_disabled'] = 'Module Sentinel: DÉSACTIVÉ',
    ['sentinel_ready'] = 'Module Sentinel prêt!',
    ['sentinel_stopped'] = 'Module Sentinel arrêté',
    ['sentinel_initializing'] = 'Initialisation des événements HoneyPot...',
    ['sentinel_honeypots_registered'] = '%d événements HoneyPot enregistrés',
    ['sentinel_honeypot_triggered'] = 'HoneyPot déclenché: %s par %s [%d]',
    ['sentinel_keyword_detected'] = 'Mot-clé suspect détecté: %s (catégorie: %s)',
    ['sentinel_cleanup'] = 'Nettoyage périodique des données effectué',
    ['sentinel_cleanup_stopped'] = 'Thread de nettoyage arrêté',
    ['sentinel_pattern_active'] = 'Détection de motifs: ACTIVE',
    ['sentinel_sensitivity'] = 'Sensibilité: %s',
    ['sentinel_commands'] = 'Commandes: /vs_suspicious, /vs_honeypot',
    ['sentinel_cleared_data'] = 'Données suspectes effacées pour l\'identifiant: %s',
    ['sentinel_unauthorized_clear'] = 'Tentative non autorisée de clearPlayerData par la source %d',
    
    -- Rapports
    ['report_suspicious_header'] = '========== Rapport des Joueurs Suspects ==========',
    ['report_suspicious_entry'] = '[%d] %s - Détections: %d, Premier: %s',
    ['report_suspicious_none'] = 'Aucun joueur suspect suivi',
    ['report_suspicious_footer'] = '===============================================',
    ['report_honeypot_header'] = '========== Rapport des Déclenchements HoneyPot ==========',
    ['report_honeypot_entry'] = '[%d] %s - Déclenchements: %d',
    ['report_honeypot_trigger'] = '    [%d] %s à %s',
    ['report_honeypot_none'] = 'Aucun déclenchement honeypot enregistré',
    ['report_honeypot_footer'] = '===============================================',
}
