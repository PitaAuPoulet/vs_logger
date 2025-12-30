# Vitaswift Copilot Standards - vs_logger

**Author:** Vitaswift  
**Version:** 1.1.0  
**Project:** vs_logger (Sentinel Edition)

## Core Standards

### Naming Convention
- **Prefix:** All exports, events, and functions must use the `vs_` prefix
- **Example:** `vs_logger:sendLog`, `SendLog`, `vs_sentinel:checkPattern`

### Zero-SQL Philosophy
- Auto-creation of database tables at script startup
- No manual database setup required
- Efficient schema design for minimal performance impact
- Example: Logs table created automatically on first run

### Bridge Integration
- **Dependency:** `vs_bridge` for grade/permission verification
- **Usage:** Always verify user privileges before executing sensitive operations
- **Example:** Admin-only logs must verify grade through vs_bridge

### Security First
- **Validation:** Strict source validation for all server events
- **Injection Protection:** All input sanitized before database storage
- **Rate Limiting:** Prevent trigger spam from clients
- **HoneyPot Events:** Trap menu executors with fake events
- **No False Positives:** When in doubt, log as "Suspect" - never auto-ban

### Performance Requirements
- **Critical:** Must not impact server thread during mass logging
- **Async Operations:** Use async database operations where possible
- **Rate Limiter:** Built-in protection against log flooding
- **Efficient Pattern Matching:** Optimized algorithms for suspicious keyword detection

## File Structure

```
vs_logger/
├── .github/
│   └── copilot-instructions.md
├── server/
│   ├── vs_main.lua          # Core logging logic + Zero-SQL
│   └── vs_sentinel.lua      # Security monitoring + HoneyPots
├── fxmanifest.lua           # FiveM manifest with Vitaswift metadata
└── config.lua               # Webhooks, thresholds, patterns
```

## Code Standards

### Lua Style Guide
- Use 4 spaces for indentation
- Clear variable naming (descriptive, not abbreviated)
- Comments for complex logic only
- Defensive programming (check nil values)

### Event Naming
- Server events: `vs_logger:serverAction`
- Client events: `vs_logger:clientAction`
- Internal events: `vs_logger:internal:action`

### Export Standards
- Export name: `SendLog` (main export)
- Parameters must be validated
- Return values for success/failure
- Error handling with descriptive messages

## Security Implementation

### Grade Verification
```lua
-- Always check grade for sensitive operations
local isAdmin = exports.vs_bridge:GetPlayerGrade(source) >= Config.MinAdminGrade
if not isAdmin and logType == "Security" then
    -- Trigger security alert
end
```

### Rate Limiting
```lua
-- Track requests per player
-- Reject excessive requests
-- Log abusers automatically
```

### HoneyPot Events
```lua
-- Register fake events that should never be triggered
-- If triggered, log suspicious activity
-- Examples: vs_logger:giveAllWeapons, vs_logger:addMoney
```

### Pattern Detection
```lua
-- Scan logs for suspicious keywords
-- Categories: cheats, exploits, menu names
-- Match with configurable sensitivity
```

## Webhook Configuration

### Standard Logs
- Player actions
- Admin commands
- System events
- Format: Embed with color coding

### Security Alerts
- Separate webhook for critical alerts
- Rate limit violations
- HoneyPot triggers
- Suspicious pattern matches
- Format: High visibility, immediate attention

## Testing Requirements

- Test with high-load scenarios (100+ logs/second)
- Verify no false positives in pattern detection
- Confirm vs_bridge integration works correctly
- Validate Zero-SQL table creation
- Check rate limiter effectiveness

## Deployment Notes

- No database setup required (Zero-SQL)
- Configure webhooks in config.lua
- Set appropriate rate limits for your server
- Customize suspicious patterns as needed
- Restart script to apply configuration changes
