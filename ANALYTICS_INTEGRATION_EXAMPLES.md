# 📊 Analytics Integration Examples

Complete guide with practical examples for integrating analytics and rate limiting into your Telegram Book Bot.

---

## Table of Contents

1. [Quick Integration](#quick-integration)
2. [Main Bot Integration](#main-bot-integration)
3. [Event Logging Examples](#event-logging-examples)
4. [Rate Limiting Implementation](#rate-limiting-implementation)
5. [Custom Reports](#custom-reports)
6. [Dashboard Commands](#dashboard-commands)
7. [Advanced Patterns](#advanced-patterns)

---

## Quick Integration

### Step 1: Import Workflows

1. Import `analytics-dashboard-workflow.json`
2. Import `rate-limiter-workflow.json`
3. Activate both workflows
4. Note webhook URLs

### Step 2: Add to Main Bot

Add two new code nodes to your main bot workflow:

1. **Rate Check Node** (before ChatCore)
2. **Analytics Logger** (after response)

---

## Main Bot Integration

### Complete Integration Flow

```
userInput (Telegram)
    ↓
sessionData (Extract)
    ↓
[NEW] Rate Limiter Check ← Check if user is allowed
    ↓ (if blocked, send error and stop)
    ↓ (if allowed, continue)
conversationStore (Memory)
    ↓
latestContext
    ↓
ChatCore (AI)
    ↓
Format Message
    ↓
Build Keyboard
    ↓
sendTextMessage
    ↓
[NEW] Log Analytics Event ← Log successful interaction
```

---

## Event Logging Examples

### Example 1: Log Book Search

Add this code node after sending a message:

```javascript
// Node: Log Book Search Event
// Position: After sendTextMessage

const sessionData = $('sessionData').first().json;
const chatCoreData = $('ChatCore').first().json;
const messageData = $('sendTextMessage').first().json;

// Extract book name from the message
const bookName = extractBookNameFromResponse(chatCoreData.output);

// Log the event
await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
  headers: {
    'Content-Type': 'application/json'
  },
  body: {
    action: 'log',
    eventType: 'book_search',
    userId: sessionData.sessionId,
    sessionId: sessionData.sessionId,
    firstName: sessionData.firstName,
    username: sessionData.username,
    language: sessionData.language,
    chatType: sessionData.chatType,
    bookName: bookName,
    searchQuery: sessionData.message,
    workflowUsed: 'book-download',
    success: true,
    linksCount: countLinksInResponse(messageData.text)
  },
  json: true
});

function extractBookNameFromResponse(output) {
  // Extract book name from AI response
  const match = output.match(/📚 <b>(.+?)<\/b>/);
  return match ? match[1] : null;
}

function countLinksInResponse(text) {
  // Count links in response
  const matches = text.match(/<a href/g);
  return matches ? matches.length : 0;
}

// Pass through original data
return $input.all();
```

### Example 2: Log Button Clicks

Add callback query handler:

```javascript
// Node: Log Button Click
// Trigger: On callback query

const callbackQuery = $('userInput').item.json.callback_query;

if (callbackQuery) {
  const userId = callbackQuery.from.id;
  const buttonData = callbackQuery.data;
  
  await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: {
      action: 'log',
      eventType: 'button_click',
      userId: userId,
      sessionId: userId,
      firstName: callbackQuery.from.first_name,
      username: callbackQuery.from.username,
      buttonClicked: buttonData,
      success: true
    },
    json: true
  });
}

return $input.all();
```

### Example 3: Log Errors

Add error logging to your error handler:

```javascript
// Node: Log Error Event
// Trigger: On workflow error

const error = $('ChatCore').first().json.error || $input.first().json.error;
const sessionData = $('sessionData').first().json;

await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
  body: {
    action: 'log',
    eventType: 'error',
    userId: sessionData.sessionId,
    sessionId: sessionData.sessionId,
    firstName: sessionData.firstName,
    errorMessage: error.message || 'Unknown error',
    success: false,
    workflowUsed: 'book-download'
  },
  json: true
});

return $input.all();
```

---

## Rate Limiting Implementation

### Example 1: Basic Rate Limiting

Add this node immediately after sessionData:

```javascript
// Node: Check Rate Limit
// Position: After sessionData, before conversationStore

const userId = $('sessionData').first().json.sessionId;

// Check rate limit
const rateLimitCheck = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/rate-limiter',
  headers: {
    'Content-Type': 'application/json'
  },
  body: {
    action: 'check',
    userId: userId
  },
  json: true
});

console.log('Rate limit check:', rateLimitCheck);

if (!rateLimitCheck.allowed) {
  // User is rate limited - send error message and stop
  const errorMessage = {
    chatId: userId,
    text: rateLimitCheck.text,
    parse_mode: 'HTML'
  };
  
  // Send rate limit message
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: errorMessage,
    json: true
  });
  
  // Stop workflow execution
  throw new Error('RATE_LIMIT_EXCEEDED');
}

// User is allowed - continue with normal flow
return $input.all();
```

### Example 2: Rate Limiting with Headers

Send rate limit info to user:

```javascript
// Node: Enhanced Rate Limiter
// Position: After sessionData

const userId = $('sessionData').first().json.sessionId;

const rateLimitCheck = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/rate-limiter',
  body: {
    action: 'check',
    userId: userId
  },
  json: true
});

if (!rateLimitCheck.allowed) {
  // Blocked - send detailed error
  const waitTime = rateLimitCheck.error.waitTime;
  const retryAfter = new Date(rateLimitCheck.error.retryAfter);
  
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: {
      chatId: userId,
      text: rateLimitCheck.text,
      parse_mode: 'HTML'
    },
    json: true
  });
  
  throw new Error('RATE_LIMIT_EXCEEDED');
}

// Allowed - attach rate limit info to output
const output = $input.all();
output.forEach(item => {
  item.json.rateLimitInfo = {
    remaining: rateLimitCheck.limits.remaining,
    resetIn: rateLimitCheck.limits.resetIn
  };
});

return output;
```

### Example 3: Graceful Degradation

Allow with warnings at 90% limit:

```javascript
// Node: Smart Rate Limiter
// Position: After sessionData

const userId = $('sessionData').first().json.sessionId;

const rateLimitCheck = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/rate-limiter',
  body: {
    action: 'check',
    userId: userId
  },
  json: true
});

if (!rateLimitCheck.allowed) {
  // Blocked
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: {
      chatId: userId,
      text: rateLimitCheck.text,
      parse_mode: 'HTML'
    },
    json: true
  });
  throw new Error('RATE_LIMIT_EXCEEDED');
}

// Check if approaching limit (90%)
const remaining = rateLimitCheck.limits.remaining.minute;
const limit = 10; // per minute limit

if (remaining <= 2) {
  // Send warning
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: {
      chatId: userId,
      text: `⚠️ <i>تنبيه: لديك ${remaining} طلبات متبقية في هذه الدقيقة</i>`,
      parse_mode: 'HTML'
    },
    json: true
  });
}

return $input.all();
```

---

## Custom Reports

### Example 1: Daily Summary Command

Add `/daily_report` command:

```javascript
// Node: Handle Daily Report Command
// Position: In command router

const message = $('userInput').item.json.message.text;

if (message === '/daily_report' || message === '/تقرير_يومي') {
  // Generate report
  const report = await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: {
      action: 'generate_report',
      reportType: 'summary',
      format: 'html'
    },
    json: true
  });
  
  return [{
    json: {
      chatId: $('sessionData').item.json.sessionId,
      text: report.text,
      parse_mode: 'HTML'
    }
  }];
}

return $input.all();
```

### Example 2: Quick Stats Command

Add `/stats` command:

```javascript
// Node: Handle Stats Command

const message = $('userInput').item.json.message.text;

if (message === '/stats' || message === '/إحصائيات') {
  // Get quick stats
  const stats = await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: {
      action: 'get_stats',
      timeRange: '24h'
    },
    json: true
  });
  
  return [{
    json: {
      chatId: $('sessionData').item.json.sessionId,
      text: stats.text,
      parse_mode: 'HTML'
    }
  }];
}

return $input.all();
```

### Example 3: Custom Report with Filters

Generate report for specific user:

```javascript
// Node: User-Specific Report

const userId = $('sessionData').item.json.sessionId;

// Get user's activity
const userStats = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
  body: {
    action: 'get_stats',
    timeRange: '7d',
    userId: userId  // Filter by user
  },
  json: true
});

// Format personalized message
const personalizedStats = `
📊 <b>إحصائياتك الشخصية</b>

📅 آخر 7 أيام

🔍 عمليات البحث: <b>${userStats.userSearches || 0}</b>
📥 التحميلات: <b>${userStats.userDownloads || 0}</b>
⏱️ الوقت المستخدم: <b>${userStats.totalTime || 0} دقيقة</b>

📚 أكثر الكتب التي بحثت عنها:
${formatUserTopBooks(userStats.userTopBooks)}

💡 <i>شكراً لاستخدام البوت!</i>
`;

return [{
  json: {
    chatId: userId,
    text: personalizedStats,
    parse_mode: 'HTML'
  }
}];
```

---

## Dashboard Commands

### Complete Command Handler

```javascript
// Node: Analytics Command Router
// Position: Early in workflow, after sessionData

const message = $('userInput').item.json.message.text;
const userId = $('sessionData').item.json.sessionId;
const isAdmin = checkIfAdmin(userId);

// Only allow admins to access analytics
if (!isAdmin) {
  return $input.all();
}

switch(message) {
  case '/stats':
  case '/إحصائيات':
    return await handleStatsCommand(userId);
    
  case '/report':
  case '/تقرير':
    return await handleReportCommand(userId);
    
  case '/errors':
  case '/أخطاء':
    return await handleErrorsCommand(userId);
    
  case '/users':
  case '/مستخدمين':
    return await handleUsersCommand(userId);
    
  case '/performance':
  case '/أداء':
    return await handlePerformanceCommand(userId);
    
  default:
    return $input.all();
}

async function handleStatsCommand(userId) {
  const stats = await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: { action: 'get_stats', timeRange: '24h' },
    json: true
  });
  
  return [{
    json: {
      chatId: userId,
      text: stats.text,
      parse_mode: 'HTML'
    }
  }];
}

async function handleReportCommand(userId) {
  const report = await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: { 
      action: 'generate_report', 
      reportType: 'summary',
      format: 'html'
    },
    json: true
  });
  
  return [{
    json: {
      chatId: userId,
      text: report.text,
      parse_mode: 'HTML'
    }
  }];
}

async function handleErrorsCommand(userId) {
  const stats = await $http.request({
    method: 'POST',
    url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
    body: { action: 'get_stats', timeRange: '24h' },
    json: true
  });
  
  const errorReport = `
🚨 <b>تقرير الأخطاء</b>

📊 معدل الأخطاء: ${stats.stats.performance.errorRate}%
📈 إجمالي الأخطاء: ${calculateTotalErrors(stats.stats.topErrors)}

🔝 أكثر الأخطاء شيوعاً:
${formatErrors(stats.stats.topErrors)}
`;
  
  return [{
    json: {
      chatId: userId,
      text: errorReport,
      parse_mode: 'HTML'
    }
  }];
}

function checkIfAdmin(userId) {
  // List of admin user IDs
  const admins = ['123456789', '987654321'];
  return admins.includes(userId.toString());
}

function formatErrors(errors) {
  return errors.map((err, i) => 
    `${i+1}. ${err.error}: ${err.count} (${err.percentage}%)`
  ).join('\\n');
}

function calculateTotalErrors(errors) {
  return errors.reduce((sum, err) => sum + err.count, 0);
}
```

---

## Advanced Patterns

### Pattern 1: Batch Logging

Log multiple events at once:

```javascript
// Node: Batch Analytics Logger
// Position: End of workflow

const sessionData = $('sessionData').first().json;
const events = [];

// Collect all events
events.push({
  action: 'log',
  eventType: 'session_start',
  userId: sessionData.sessionId,
  timestamp: sessionData.timestamp
});

events.push({
  action: 'log',
  eventType: 'book_search',
  userId: sessionData.sessionId,
  bookName: extractBookName(),
  success: true
});

// Send batch
await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
  body: {
    action: 'log_batch',
    events: events
  },
  json: true
});

return $input.all();
```

### Pattern 2: Real-Time Monitoring

Send alerts for critical events:

```javascript
// Node: Real-Time Monitor
// Position: After analytics logging

const stats = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/analytics-dashboard',
  body: { action: 'get_stats', timeRange: '5m' },
  json: true
});

// Check for anomalies
if (stats.stats.performance.errorRate > 10) {
  // Send alert to admin
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: {
      chatId: $env.ADMIN_CHAT_ID,
      text: `🚨 <b>تحذير</b>\\n\\nمعدل الأخطاء مرتفع: ${stats.stats.performance.errorRate}%`,
      parse_mode: 'HTML'
    },
    json: true
  });
}

return $input.all();
```

### Pattern 3: Predictive Rate Limiting

Predict and warn before hitting limits:

```javascript
// Node: Predictive Rate Limiter

const userId = $('sessionData').first().json.sessionId;

const rateLimitCheck = await $http.request({
  method: 'POST',
  url: 'https://your-n8n-instance.com/webhook/rate-limiter',
  body: { action: 'check', userId: userId },
  json: true
});

// Calculate prediction
const remainingMinute = rateLimitCheck.limits.remaining.minute;
const remainingHour = rateLimitCheck.limits.remaining.hour;

// Predict if user will hit hourly limit
const avgPerMinute = (100 - remainingHour) / 60;
const predictedMinutesUntilLimit = remainingHour / avgPerMinute;

if (predictedMinutesUntilLimit < 10 && remainingMinute > 5) {
  // Warn user
  const warning = `
⚠️ <b>تنبيه استباقي</b>

أنت تستخدم البوت بكثافة عالية.
بهذا المعدل، ستصل للحد الأقصى خلال ${Math.round(predictedMinutesUntilLimit)} دقيقة.

💡 نصيحة: حاول تقليل الطلبات للحفاظ على الوصول المستمر.
`;
  
  await $http.request({
    method: 'POST',
    url: `https://api.telegram.org/bot${$env.TELEGRAM_BOT_TOKEN}/sendMessage`,
    body: {
      chatId: userId,
      text: warning,
      parse_mode: 'HTML'
    },
    json: true
  });
}

return $input.all();
```

---

## Testing Your Integration

### Test Script

```bash
#!/bin/bash

# Test analytics logging
curl -X POST https://your-n8n.com/webhook/analytics-dashboard \
  -H "Content-Type: application/json" \
  -d '{
    "action": "log",
    "userId": "test_user_123",
    "eventType": "book_search",
    "bookName": "1984",
    "success": true
  }'

# Test rate limiter
for i in {1..15}; do
  echo "Request $i:"
  curl -X POST https://your-n8n.com/webhook/rate-limiter \
    -H "Content-Type: application/json" \
    -d '{
      "action": "check",
      "userId": "test_user_123"
    }'
  echo ""
  sleep 1
done

# Test statistics
curl -X POST https://your-n8n.com/webhook/analytics-dashboard \
  -H "Content-Type: application/json" \
  -d '{
    "action": "get_stats",
    "timeRange": "24h"
  }'

# Test report generation
curl -X POST https://your-n8n.com/webhook/analytics-dashboard \
  -H "Content-Type: application/json" \
  -d '{
    "action": "generate_report",
    "reportType": "summary",
    "format": "html"
  }'
```

---

## Production Checklist

- [ ] Analytics workflow activated
- [ ] Rate limiter workflow activated
- [ ] Webhook URLs configured in main bot
- [ ] Rate limit check added before ChatCore
- [ ] Analytics logging added after response
- [ ] Error logging implemented
- [ ] Admin commands configured
- [ ] Database integration (for production)
- [ ] Redis setup (for rate limiting)
- [ ] Monitoring alerts configured
- [ ] Backup and recovery setup

---

## Support

For questions or issues:
- See [ANALYTICS_AND_MONITORING.md](ANALYTICS_AND_MONITORING.md)
- Check [README.md](README.md)
- Review main workflow documentation

---

**Created**: 2025-10-21  
**Version**: 1.0.0  
**Status**: Production Ready ✅
