-- Author: Vitaswift | Version: 1.0.0

Locales['en'] = {
    -- Main system
    ['system_starting'] = 'vs_logger - Sentinel Edition',
    ['system_author'] = 'Author: %s',
    ['system_version'] = 'Version: %s',
    ['system_ready'] = 'Logger system ready!',
    ['system_stopped'] = 'Logger system stopped',
    
    -- Database
    ['db_initializing'] = 'Initializing Zero-SQL database...',
    ['db_initialized'] = 'Database tables initialized successfully!',
    ['db_error'] = 'ERROR: Failed to initialize database tables',
    ['db_no_mysql'] = 'WARNING: No MySQL resource found (oxmysql or mysql-async required)',
    ['db_saved'] = 'Saved log to database: %s - %s',
    ['db_save_failed'] = 'Failed to save log to database: %s - %s',
    ['db_processing_queue'] = 'Processing %d remaining logs before shutdown...',
    ['db_processed'] = 'Processed %d queued logs',
    
    -- Rate limiting
    ['ratelimit_cooldown'] = 'Rate limit cooldown active for %s',
    ['ratelimit_exceeded'] = 'Rate limit exceeded for %s (violations: %d)',
    
    -- Logs
    ['log_invalid_type'] = 'Invalid log type: %s',
    ['log_disabled'] = 'Log type \'%s\' is disabled',
    ['log_ratelimit'] = 'Rate limit exceeded for source %d',
    ['log_unauthorized'] = 'Unauthorized log attempt by source %d for type \'%s\'',
    
    -- Webhook
    ['webhook_not_configured'] = 'Webhook URL not configured, skipping Discord notification',
    ['webhook_success'] = 'Successfully sent to Discord webhook',
    ['webhook_error'] = 'Discord webhook error: %d - %s',
    
    -- Sentinel
    ['sentinel_enabled'] = 'Sentinel security module: ENABLED',
    ['sentinel_disabled'] = 'Sentinel module: DISABLED',
    ['sentinel_ready'] = 'Sentinel module ready!',
    ['sentinel_stopped'] = 'Sentinel module stopped',
    ['sentinel_initializing'] = 'Initializing HoneyPot events...',
    ['sentinel_honeypots_registered'] = '%d HoneyPot events registered',
    ['sentinel_honeypot_triggered'] = 'HoneyPot triggered: %s by %s [%d]',
    ['sentinel_keyword_detected'] = 'Suspicious keyword detected: %s (category: %s)',
    ['sentinel_cleanup'] = 'Performed periodic data cleanup',
    ['sentinel_cleanup_stopped'] = 'Cleanup thread stopped',
    ['sentinel_pattern_active'] = 'Pattern detection: ACTIVE',
    ['sentinel_sensitivity'] = 'Sensitivity: %s',
    ['sentinel_commands'] = 'Commands: /vs_suspicious, /vs_honeypot',
    ['sentinel_cleared_data'] = 'Cleared suspicious data for identifier: %s',
    ['sentinel_unauthorized_clear'] = 'Unauthorized clearPlayerData attempt by source %d',
    
    -- Reports
    ['report_suspicious_header'] = '========== Suspicious Players Report ==========',
    ['report_suspicious_entry'] = '[%d] %s - Detections: %d, First: %s',
    ['report_suspicious_none'] = 'No suspicious players tracked',
    ['report_suspicious_footer'] = '===============================================',
    ['report_honeypot_header'] = '========== HoneyPot Triggers Report ==========',
    ['report_honeypot_entry'] = '[%d] %s - Triggers: %d',
    ['report_honeypot_trigger'] = '    [%d] %s at %s',
    ['report_honeypot_none'] = 'No honeypot triggers recorded',
    ['report_honeypot_footer'] = '===============================================',
}
