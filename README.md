# vs_logger (Sentinel Edition)

**Author:** Vitaswift  
**Version:** 1.1.0  
**Type:** FiveM Server-Side Resource

Advanced logging and security monitoring system for FiveM servers with built-in anti-cheat capabilities.

## 🌟 Features

### Core Logging
- **Zero-SQL Architecture**: Automatic database table creation - no manual setup required
- **Multiple Log Types**: Player, Admin, Security, System, Suspect logs
- **Discord Integration**: Dual webhook support (Standard logs + Security alerts)
- **Grade Verification**: Integration with `vs_bridge` for permission checking
- **Performance Optimized**: Async operations, query queuing, minimal server impact

### Sentinel Security Module
- **HoneyPot Events**: Trap menu executors with fake events
- **Pattern Detection**: Identify suspicious keywords in logs
- **Rate Limiting**: Prevent log flooding and trigger spam
- **Smart Alerting**: No false positives - suspicious activities logged as "Suspect"
- **Real-time Monitoring**: Immediate security alerts for critical events

## 📋 Requirements

- FiveM Server (Build 2802 or newer)
- `vs_bridge` resource (for grade verification)
- MySQL/oxmysql (optional, for persistent storage)

## 🚀 Installation

1. Download and extract to your `resources` folder
2. Add to your `server.cfg`:
```cfg
ensure vs_bridge
ensure vs_logger
```

3. Configure webhooks in `config.lua`:
```lua
Config.Webhooks = {
    Standard = {
        enabled = true,
        url = "YOUR_DISCORD_WEBHOOK_URL"
    },
    Security = {
        enabled = true,
        url = "YOUR_SECURITY_WEBHOOK_URL"
    }
}
```

4. Restart your server

## 💡 Usage

### Basic Logging
```lua
-- From any server-side script
exports.vs_logger:SendLog('player', 'Player Connected', 'John Doe has joined the server', source)

exports.vs_logger:SendLog('admin', 'Admin Action', 'Player was kicked', source, {
    Target = 'Player ID 5',
    Reason = 'Rule violation'
})

exports.vs_logger:SendLog('security', 'Security Alert', 'Suspicious activity detected', source)
```

### Log Types
- `player` - Standard player actions
- `admin` - Admin commands and actions (requires grade 3+)
- `security` - Critical security events (requires grade 4+)
- `system` - System-level events
- `suspect` - Automatically generated for suspicious activities

### Available Exports

#### SendLog
```lua
exports.vs_logger:SendLog(logType, title, message, source, metadata)
```
- **logType**: string - Type of log (player, admin, security, system, suspect)
- **title**: string - Log title
- **message**: string - Log message/description
- **source**: number - Player source (optional)
- **metadata**: table - Additional key-value data (optional)

#### CheckSuspiciousPatterns
```lua
local score, keywords = exports.vs_logger:CheckSuspiciousPatterns(text)
```
- **text**: string - Text to analyze
- Returns: score (number), keywords (table)

#### GetSuspiciousPlayerStats
```lua
local stats = exports.vs_logger:GetSuspiciousPlayerStats(identifier)
```
- **identifier**: string - Player license identifier
- Returns: table with detection statistics

#### GetSentinelStatus
```lua
local status = exports.vs_logger:GetSentinelStatus()
```
- Returns: table with sentinel module status

## 🔒 Security Features

### HoneyPot Events
The following fake events are registered to trap menu executors:
- `vs_logger:giveAllWeapons`
- `vs_logger:addMoney`
- `vs_logger:teleportToCoords`
- `vs_logger:setGodMode`
- `vs_logger:healPlayer`
- `vs_logger:reviveAll`
- `vs_logger:nukeServer`
- `vs_logger:bypassAnticheat`

**Any trigger of these events results in immediate security alert!**

### Pattern Detection
Automatically scans log messages for suspicious keywords:
- **Cheats**: aimbot, wallhack, ESP, etc.
- **Menus**: Eulen, Lynx, RedEngine, etc.
- **Exploits**: injection, bypass, etc.
- **Suspicious Actions**: money drop, spawn vehicle, etc.

### Rate Limiting
- Default: 30 requests per minute per player
- Automatic cooldown after limit exceeded
- Security alerts after repeated violations
- Whitelist support for trusted identifiers

## 🎮 Admin Commands

### /vs_suspicious
View all players flagged with suspicious activity
- Shows detection count and timestamps
- Requires admin grade (3+)

### /vs_honeypot
View all honeypot event triggers
- Shows triggered events and timestamps
- Requires admin grade (3+)

## ⚙️ Configuration

### Rate Limiting
```lua
Config.RateLimit = {
    enabled = true,
    maxRequestsPerMinute = 30,
    cooldownAfterLimit = 60,
    alertAfterViolations = 3
}
```

### Pattern Sensitivity
```lua
Config.Sentinel.patterns = {
    enabled = true,
    sensitivity = "medium", -- low, medium, high
    thresholds = {
        low = 1,
        medium = 2,
        high = 3
    }
}
```

### Performance Tuning
```lua
Config.Performance = {
    asyncDatabase = true,
    maxConcurrentQueries = 5
}
```

## 🔧 Advanced Configuration

### Custom HoneyPot Events
Add custom fake events in `config.lua`:
```lua
Config.Sentinel.honeyPotEvents = {
    "vs_logger:giveAllWeapons",
    "your_custom_event",
    -- Add more...
}
```

### Custom Suspicious Keywords
Add custom keywords to detect:
```lua
Config.Sentinel.patterns.keywords.custom = {
    "your_keyword",
    "another_keyword"
}
```

### Webhook Customization
```lua
Config.Webhooks.Standard.colors = {
    info = 3447003,    -- Blue
    success = 3066993, -- Green
    warning = 15844367, -- Orange
    error = 15158332   -- Red
}
```

## 📊 How It Works

### Zero-SQL Philosophy
1. Script starts and checks for database tables
2. If tables don't exist, they're created automatically
3. No manual SQL execution needed
4. Seamless integration with MySQL/oxmysql

### Grade Verification Flow
1. Log request received with sensitive log type
2. System checks player grade via `vs_bridge`
3. If unauthorized, security alert is triggered
4. Legitimate request proceeds normally

### HoneyPot Detection
1. Fake events registered on server start
2. Menu executor triggers fake event
3. Immediate detection and logging
4. Security alert sent to Discord
5. Player flagged for manual review

### Pattern Detection
1. Every log message is scanned
2. Keywords matched against configured patterns
3. Score calculated based on matches
4. Threshold checked against sensitivity
5. Multiple detections trigger suspect alert

## 🛡️ False Positive Prevention

The system is designed to **NEVER auto-ban or auto-kick**:
- Suspicious activities logged as "Suspect" status
- Manual review recommended for all alerts
- Multiple detections required before alerting
- Clear distinction between confirmed and suspected issues
- Admin commands for investigating flagged players

## 📝 Events

### Server Events (Internal)
- `vs_sentinel:honeyPotTriggered` - When honeypot event is triggered
- `vs_sentinel:patternDetected` - When suspicious pattern is detected
- `vs_sentinel:logSuspicious` - General suspicious activity logging
- `vs_sentinel:clearPlayerData` - Clear suspicious player data (admin only)

## 🔍 Troubleshooting

### Logs not appearing in Discord
- Check webhook URLs in `config.lua`
- Verify webhook URLs are valid
- Check server console for error messages
- Enable debug mode: `Config.Debug = true`

### vs_bridge errors
- Ensure `vs_bridge` resource is started before `vs_logger`
- Check `Config.UseBridge` is set to `true`
- Verify `Config.BridgeName` matches your bridge resource name

### Rate limiting too strict
- Adjust `Config.RateLimit.maxRequestsPerMinute`
- Add trusted identifiers to whitelist
- Disable rate limiting: `Config.RateLimit.enabled = false`

## 📄 License

This resource is part of the Vitaswift ecosystem.

## 🤝 Support

For issues, questions, or contributions:
- Check the configuration options in `config.lua`
- Enable debug mode for verbose logging
- Review console output for errors
- Check `.github/copilot-instructions.md` for development standards

## 🎯 Roadmap

- [ ] Web dashboard for log viewing
- [ ] Advanced AI-based pattern detection
- [ ] Integration with more framework bridges
- [ ] Automatic threat scoring system
- [ ] Historical data analysis tools

---

**Remember:** This is a security tool - configure it properly and review alerts regularly!
