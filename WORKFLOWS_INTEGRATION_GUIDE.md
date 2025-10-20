# 🔗 Workflows Integration Guide

Complete guide for integrating the extended book workflows with the main Telegram Bot.

## 📑 Table of Contents

1. [Integration Overview](#integration-overview)
2. [Method 1: AI Tools Integration](#method-1-ai-tools-integration)
3. [Method 2: Button Callbacks](#method-2-button-callbacks)
4. [Method 3: Command Handlers](#method-3-command-handlers)
5. [Complete Implementation](#complete-implementation)
6. [Testing & Debugging](#testing--debugging)

---

## Integration Overview

The main Telegram Book Bot can be extended with the additional workflows using three methods:

| Method | Use Case | Complexity | User Experience |
|--------|----------|------------|-----------------|
| AI Tools | Automatic tool selection by AI | Medium | Seamless, natural |
| Button Callbacks | User clicks inline buttons | Low | Interactive, visual |
| Command Handlers | User types commands | Low | Direct, explicit |

You can use **one or all** methods depending on your needs.

---

## Method 1: AI Tools Integration

### Overview

Let the AI agent automatically decide when to use each workflow based on user queries.

### Step 1: Add Tool Nodes to ChatCore

In the main `telegram-book-bot-workflow.json`, add new tool nodes that connect to the ChatCore agent.

#### 1.1 Book Recommendations Tool

```json
{
  "parameters": {
    "description": "Get AI-powered book recommendations based on a reference book and user preferences. Use when user asks for similar books, recommendations, or books like another book.",
    "workflowId": {
      "__rl": true,
      "value": "YOUR_RECOMMENDATIONS_WORKFLOW_ID",
      "mode": "list",
      "cachedResultName": "Book Recommendations Engine"
    },
    "workflowInputs": {
      "mappingMode": "defineBelow",
      "value": {
        "bookName": "={{ $json.bookName }}",
        "preferences": "={{ $json.preferences || '' }}",
        "count": "={{ $json.count || 5 }}"
      }
    }
  },
  "id": "tool-recommendations-001",
  "name": "get_book_recommendations",
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow",
  "typeVersion": 2.2,
  "position": [1280, 260]
}
```

#### 1.2 Author Profile Tool

```json
{
  "parameters": {
    "description": "Get detailed information about an author including biography, famous works, and literary style. Use when user asks about an author, writer, or wants to know who wrote a book.",
    "workflowId": {
      "__rl": true,
      "value": "YOUR_AUTHOR_PROFILE_WORKFLOW_ID",
      "mode": "list",
      "cachedResultName": "Author Profile & Works"
    },
    "workflowInputs": {
      "mappingMode": "defineBelow",
      "value": {
        "author": "={{ $json.author }}",
        "includeBooks": true
      }
    }
  },
  "id": "tool-author-001",
  "name": "get_author_profile",
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow",
  "typeVersion": 2.2,
  "position": [1280, 360]
}
```

#### 1.3 Book Quotes Tool

```json
{
  "parameters": {
    "description": "Extract memorable quotes from books with context. Use when user asks for quotes, excerpts, or famous lines from a book.",
    "workflowId": {
      "__rl": true,
      "value": "YOUR_QUOTES_WORKFLOW_ID",
      "mode": "list",
      "cachedResultName": "Book Quotes Extractor"
    },
    "workflowInputs": {
      "mappingMode": "defineBelow",
      "value": {
        "bookName": "={{ $json.bookName }}",
        "author": "={{ $json.author || '' }}",
        "count": "={{ $json.count || 5 }}",
        "theme": "={{ $json.theme || 'general' }}"
      }
    }
  },
  "id": "tool-quotes-001",
  "name": "get_book_quotes",
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow",
  "typeVersion": 2.2,
  "position": [1280, 460]
}
```

#### 1.4 Book Metadata Tool

```json
{
  "parameters": {
    "description": "Extract detailed metadata about a book including author, publication year, genre, summary, and ratings. Use when user asks for book information, details, or description.",
    "workflowId": {
      "__rl": true,
      "value": "YOUR_METADATA_WORKFLOW_ID",
      "mode": "list",
      "cachedResultName": "Book Metadata Extractor"
    },
    "workflowInputs": {
      "mappingMode": "defineBelow",
      "value": {
        "bookName": "={{ $json.bookName }}",
        "author": "={{ $json.author || '' }}"
      }
    }
  },
  "id": "tool-metadata-001",
  "name": "get_book_metadata",
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow",
  "typeVersion": 2.2,
  "position": [1280, 560]
}
```

### Step 2: Connect Tools to ChatCore

Add connections in the workflow JSON:

```json
{
  "connections": {
    "ChatCore": {
      "main": [[{
        "node": "Format Telegram Message",
        "type": "main",
        "index": 0
      }]]
    },
    "get_book_recommendations": {
      "ai_tool": [[{
        "node": "ChatCore",
        "type": "ai_tool",
        "index": 0
      }]]
    },
    "get_author_profile": {
      "ai_tool": [[{
        "node": "ChatCore",
        "type": "ai_tool",
        "index": 0
      }]]
    },
    "get_book_quotes": {
      "ai_tool": [[{
        "node": "ChatCore",
        "type": "ai_tool",
        "index": 0
      }]]
    },
    "get_book_metadata": {
      "ai_tool": [[{
        "node": "ChatCore",
        "type": "ai_tool",
        "index": 0
      }]]
    }
  }
}
```

### Step 3: Update System Prompt

Modify the ChatCore system message to include the new tools:

```javascript
"systemMessage": "🤖 أنت مساعد ذكي متخصص في البحث عن الكتب والروايات العربية 📚

🎯 المهام:
1. البحث عن روابط تحميل باستخدام find_book_download_link
2. تقديم توصيات بكتب مشابهة باستخدام get_book_recommendations
3. استخراج معلومات الكتب باستخدام get_book_metadata
4. الحصول على اقتباسات باستخدام get_book_quotes
5. توفير معلومات المؤلفين باستخدام get_author_profile

✅ متى تستخدم كل أداة:

📥 find_book_download_link:
- عند طلب تحميل، رابط، PDF

📚 get_book_recommendations:
- عند طلب كتب مشابهة
- \"اقترح لي كتب مثل...\"
- \"ماذا أقرأ بعد...\"

📖 get_book_metadata:
- عند السؤال عن معلومات الكتاب
- \"ما هو كتاب...\"
- \"أخبرني عن...\"

💭 get_book_quotes:
- عند طلب اقتباسات
- \"أريد مقولات من...\"
- \"اقتباس من كتاب...\"

✍️ get_author_profile:
- عند السؤال عن المؤلف
- \"من هو...\"
- \"معلومات عن الكاتب...\"

📝 تنسيق الرد (HTML فقط):
- استخدم <b>، <i>، <a>
- ❌ لا تستخدم Markdown أبداً

👤 المستخدم: {{ $('sessionData').item.json.firstName }}
📩 الرسالة: {{ $('sessionData').item.json.message }}
💬 آخر 3 محادثات: {{ $('latestContext').item.json.messages || 'لا توجد' }}"
```

---

## Method 2: Button Callbacks

### Overview

Add interactive buttons that trigger specific workflows when clicked.

### Step 1: Update "Build Inline Keyboard" Node

Modify the keyboard building code to include new action buttons:

```javascript
// في نود "Build Inline Keyboard"
const messageData = $input.first().json;
const hasResults = messageData.hasResults || false;
const results = messageData.allResults || [];

// استخراج اسم الكتاب من النص
const bookNameMatch = messageData.text.match(/📚\s*<b>(.+?)<\/b>/);
const bookName = bookNameMatch ? bookNameMatch[1] : '';

const keyboard = {
  inline_keyboard: []
};

// ═══════════════════════════════════════════════════════════
// 🔗 أزرار الروابط (كما هو)
// ═══════════════════════════════════════════════════════════
if (hasResults && results.length > 0) {
  // ... existing link buttons code ...
}

// ═══════════════════════════════════════════════════════════
// 🎬 الإجراءات الموسعة (جديد!)
// ═══════════════════════════════════════════════════════════

// صف 1: التوصيات والاقتباسات
keyboard.inline_keyboard.push([
  {
    text: '⭐ كتب مشابهة',
    callback_data: JSON.stringify({
      action: 'recommendations',
      book: bookName
    })
  },
  {
    text: '💭 اقتباسات',
    callback_data: JSON.stringify({
      action: 'quotes',
      book: bookName
    })
  }
]);

// صف 2: معلومات الكتاب والمؤلف
keyboard.inline_keyboard.push([
  {
    text: '📖 معلومات الكتاب',
    callback_data: JSON.stringify({
      action: 'metadata',
      book: bookName
    })
  },
  {
    text: '✍️ عن المؤلف',
    callback_data: JSON.stringify({
      action: 'author',
      book: bookName
    })
  }
]);

// صف 3: القائمة والمراجعات
keyboard.inline_keyboard.push([
  {
    text: '📝 أضف لقائمتي',
    callback_data: JSON.stringify({
      action: 'add_to_list',
      book: bookName
    })
  },
  {
    text: '⭐ المراجعات',
    callback_data: JSON.stringify({
      action: 'reviews',
      book: bookName
    })
  }
]);

// صف 4: بحث جديد
keyboard.inline_keyboard.push([
  {
    text: '🔍 بحث عن كتاب آخر',
    callback_data: JSON.stringify({
      action: 'new_search'
    })
  }
]);

// صف 5: مشاركة
keyboard.inline_keyboard.push([
  {
    text: '📤 شارك البوت مع أصدقائك',
    switch_inline_query: 'جرب بوت تحميل الكتب المجاني! 📚'
  }
]);

return [{
  json: {
    text: messageData.text,
    parse_mode: 'HTML',
    reply_markup: keyboard,
    disable_web_page_preview: true
  }
}];
```

### Step 2: Add Callback Handler Node

Add a new node after the Telegram Trigger to handle callback queries:

```json
{
  "parameters": {
    "updates": [
      "callback_query"
    ]
  },
  "id": "callback-handler-001",
  "name": "Callback Handler",
  "type": "n8n-nodes-base.telegramTrigger",
  "typeVersion": 1.2,
  "position": [0, 200],
  "webhookId": "callback-webhook-unique-id",
  "credentials": {
    "telegramApi": {
      "id": "xnP9fkvEEq9ew47g",
      "name": "Telegram account"
    }
  }
}
```

### Step 3: Add Callback Router Node

Create a code node to route callback queries:

```javascript
// نود "Route Callback Actions"
const callbackQuery = $input.first().json.callback_query;

if (!callbackQuery || !callbackQuery.data) {
  return [];
}

const chatId = callbackQuery.message.chat.id;
const messageId = callbackQuery.message.message_id;
const callbackData = JSON.parse(callbackQuery.data);
const action = callbackData.action;
const bookName = callbackData.book || '';

// Answer callback query first (remove loading state)
const axios = require('axios');
const botToken = 'YOUR_BOT_TOKEN'; // Or use credentials

await axios.post(
  `https://api.telegram.org/bot${botToken}/answerCallbackQuery`,
  {
    callback_query_id: callbackQuery.id,
    text: 'جاري التحميل...'
  }
);

return [{
  json: {
    action: action,
    bookName: bookName,
    chatId: chatId,
    messageId: messageId,
    userId: callbackQuery.from.id
  }
}];
```

### Step 4: Add Action Switch Node

Create a switch node to route to different workflows:

```json
{
  "parameters": {
    "mode": "expression",
    "output": "multipleOutputs",
    "rules": {
      "rules": [
        {
          "outputKey": "recommendations",
          "renameOutput": false,
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "recommendations",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "outputKey": "quotes",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "quotes",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "outputKey": "metadata",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "metadata",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "outputKey": "author",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "author",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "outputKey": "add_to_list",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "add_to_list",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        },
        {
          "outputKey": "reviews",
          "conditions": {
            "conditions": [
              {
                "leftValue": "={{ $json.action }}",
                "rightValue": "reviews",
                "operator": {
                  "type": "string",
                  "operation": "equals"
                }
              }
            ]
          }
        }
      ]
    }
  },
  "id": "action-switch-001",
  "name": "Action Switch",
  "type": "n8n-nodes-base.switch",
  "typeVersion": 3.2,
  "position": [640, 200]
}
```

### Step 5: Add HTTP Request Nodes for Each Action

For each action, add an HTTP Request node:

```json
{
  "parameters": {
    "method": "POST",
    "url": "={{ $env.N8N_WEBHOOK_BASE_URL }}/webhook/book-recommendations",
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "bookName",
          "value": "={{ $json.bookName }}"
        },
        {
          "name": "count",
          "value": 5
        }
      ]
    },
    "options": {}
  },
  "id": "call-recommendations-001",
  "name": "Call Recommendations Workflow",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [880, 100]
}
```

### Step 6: Send Response Back to User

Add a Telegram node to send the result:

```json
{
  "parameters": {
    "chatId": "={{ $('Route Callback Actions').item.json.chatId }}",
    "text": "={{ $json.text }}",
    "additionalFields": {
      "parse_mode": "HTML",
      "disable_web_page_preview": true
    }
  },
  "id": "send-callback-response-001",
  "name": "Send Callback Response",
  "type": "n8n-nodes-base.telegram",
  "typeVersion": 1.2,
  "position": [1120, 200],
  "credentials": {
    "telegramApi": {
      "id": "xnP9fkvEEq9ew47g",
      "name": "Telegram account"
    }
  }
}
```

---

## Method 3: Command Handlers

### Overview

Allow users to trigger workflows using text commands like `/recommendations`, `/quotes`, etc.

### Step 1: Add Command Detection

In the main workflow, add a code node after `sessionData`:

```javascript
// نود "Detect Commands"
const message = $('sessionData').item.json.message;

// تحديد الأوامر
const commands = {
  '/recommendations': 'recommendations',
  '/توصيات': 'recommendations',
  '/quotes': 'quotes',
  '/اقتباسات': 'quotes',
  '/metadata': 'metadata',
  '/معلومات': 'metadata',
  '/author': 'author',
  '/مؤلف': 'author',
  '/list': 'reading_list',
  '/قائمتي': 'reading_list',
  '/reviews': 'reviews',
  '/مراجعات': 'reviews'
};

// البحث عن أمر في الرسالة
let detectedCommand = null;
let bookName = message;

for (const [cmd, action] of Object.entries(commands)) {
  if (message.startsWith(cmd)) {
    detectedCommand = action;
    // استخراج اسم الكتاب بعد الأمر
    bookName = message.substring(cmd.length).trim();
    break;
  }
}

return [{
  json: {
    ...$ input.first().json,
    isCommand: detectedCommand !== null,
    command: detectedCommand,
    bookName: bookName,
    originalMessage: message
  }
}];
```

### Step 2: Add Routing Logic

Add a switch node to route commands:

```json
{
  "parameters": {
    "conditions": {
      "conditions": [
        {
          "leftValue": "={{ $json.isCommand }}",
          "rightValue": true,
          "operator": {
            "type": "boolean",
            "operation": "equals"
          }
        }
      ]
    }
  },
  "id": "is-command-switch-001",
  "name": "Is Command?",
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "position": [480, 0]
}
```

### Step 3: Connect to Workflows

Connect the "true" branch to workflow callers similar to Method 2.

---

## Complete Implementation

Here's a complete example integrating all methods:

### Updated Main Workflow Structure

```
userInput (Telegram Trigger)
    ↓
sessionData (Extract session)
    ↓
Detect Commands (Check for commands)
    ↓
    ├─→ [If Command] → Route Command → Call Workflow → Send Response
    │
    └─→ [If Not Command] → conversationStore → latestContext → ChatCore
                                                                   ↓
                              [With AI Tools]: find_book_download_link
                                              get_book_recommendations
                                              get_author_profile
                                              get_book_quotes
                                              get_book_metadata
                                                                   ↓
                                              Format Telegram Message
                                                                   ↓
                                              Build Inline Keyboard [With Callbacks]
                                                                   ↓
                                              Delay and Pass Data
                                                                   ↓
                                              Send Message

Callback Handler (Separate Trigger)
    ↓
Route Callback Actions
    ↓
Action Switch → [recommendations, quotes, metadata, author, etc.]
    ↓
Call Respective Workflows
    ↓
Send Callback Response
```

---

## Testing & Debugging

### Test Scenarios

#### 1. Test AI Tools Integration

```
User: "أريد كتب مشابهة لرواية 1984"
Expected: AI uses get_book_recommendations tool automatically
```

#### 2. Test Button Callbacks

```
User: "ابحث عن كتاب الخيميائي"
Bot: Shows download links + buttons
User: Clicks "⭐ كتب مشابهة"
Expected: Recommendations appear
```

#### 3. Test Commands

```
User: "/recommendations الخيميائي"
Expected: Direct recommendations response
```

### Debug Checklist

- [ ] All workflow IDs are correct
- [ ] Webhook URLs are reachable
- [ ] Credentials are configured
- [ ] All workflows are active
- [ ] Callback query handler is set up
- [ ] JSON parsing in callbacks works
- [ ] AI tools are connected to ChatCore
- [ ] System prompt includes tool descriptions

### Common Issues

**Issue**: Callback buttons don't work  
**Solution**: Ensure callback_data is properly JSON stringified and handler is active

**Issue**: AI doesn't use tools  
**Solution**: Check tool descriptions and system prompt, ensure tools are connected

**Issue**: Commands not detected  
**Solution**: Verify command detection code and ensure proper string matching

---

## Next Steps

1. Import all workflows
2. Choose integration method(s)
3. Update main workflow
4. Test thoroughly
5. Monitor performance
6. Iterate and improve

---

**Happy Integrating! 🚀**
