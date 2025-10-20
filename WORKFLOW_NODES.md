# 📋 Workflow Nodes Reference

Detailed reference for each node in the Telegram Book Bot workflow.

## Table of Contents

1. [Input & Session Management](#input--session-management)
2. [Memory & Context](#memory--context)
3. [AI Processing](#ai-processing)
4. [Message Formatting](#message-formatting)
5. [Output & Delivery](#output--delivery)

---

## Input & Session Management

### 1. `userInput` - Telegram Trigger

**Type**: `n8n-nodes-base.telegramTrigger`

**Purpose**: Receives incoming messages from Telegram users.

**Configuration**:
```json
{
  "updates": ["message"],
  "additionalFields": {}
}
```

**Output Data Structure**:
```json
{
  "message": {
    "message_id": 123,
    "text": "user message",
    "chat": {
      "id": 123456789,
      "type": "private"
    },
    "from": {
      "id": 123456789,
      "first_name": "User",
      "username": "username",
      "language_code": "ar"
    }
  }
}
```

**Error Handling**:
- `retryOnFail`: true
- `onError`: continueRegularOutput

---

### 2. `sessionData` - Extract Session Info

**Type**: `n8n-nodes-base.set`

**Purpose**: Extracts and structures session information from incoming message.

**Configuration**:
```json
{
  "keepOnlySet": true,
  "values": {
    "string": [...],
    "number": [...],
    "boolean": [...]
  }
}
```

**Fields Extracted**:

| Field | Type | Source | Default |
|-------|------|--------|---------|
| message | string | `message.text` | - |
| sessionId | string | `message.chat.id` | - |
| firstName | string | `message.from.first_name` | "مستخدم" |
| username | string | `message.from.username` | "unknown" |
| language | string | `message.from.language_code` | "ar" |
| chatType | string | `message.chat.type` | - |
| timestamp | string | `$now.toISO()` | - |
| messageId | number | `message.message_id` | - |
| isGroup | boolean | `chat.type !== 'private'` | - |

**Output Example**:
```json
{
  "message": "ابحث عن كتاب 1984",
  "sessionId": "123456789",
  "firstName": "أحمد",
  "username": "ahmed123",
  "language": "ar",
  "chatType": "private",
  "timestamp": "2025-10-20T10:30:00.000Z",
  "messageId": 456,
  "isGroup": false
}
```

---

## Memory & Context

### 3. `conversationStore` - Memory Manager

**Type**: `@n8n/n8n-nodes-langchain.memoryManager`

**Purpose**: Central storage for conversation history.

**Configuration**:
```json
{
  "options": {
    "groupMessages": true
  }
}
```

**Features**:
- Groups messages by session
- Stores human/AI message pairs
- Provides retrieval interface

---

### 4. `memoryRetriever` - Buffer Window (Store)

**Type**: `@n8n/n8n-nodes-langchain.memoryBufferWindow`

**Purpose**: Retrieves conversation history for context building.

**Configuration**:
```json
{
  "sessionIdType": "customKey",
  "sessionKey": "={{ $('sessionData').item.json.sessionId }}",
  "contextWindowLength": 15
}
```

**Parameters**:
- **sessionKey**: Uses Telegram chat ID
- **contextWindowLength**: Keeps last 15 messages
- **Type**: Custom key for multi-user support

**Connection**: Connects to `conversationStore` via AI memory output.

---

### 5. `latestContext` - Format Context

**Type**: `n8n-nodes-base.code` (JavaScript)

**Purpose**: Formats the last 3 conversations for the AI prompt.

**Key Functions**:
```javascript
function extractFirstLine(text) {
  if (!text) return "";
  return text.split('\n')[0].replace(/^Input from user:\s*/, '');
}

function trimEndNewline(text) {
  if (!text) return "";
  return text.replace(/\n+$/, '');
}
```

**Logic**:
1. Retrieves all messages from memory
2. Selects last 3 message pairs
3. Formats each as:
   ```
   💬 محادثة 1:
   👤 المستخدم: [user message]
   🤖 البوت: [bot response]
   ```
4. Joins with separators

**Output**:
```json
{
  "messages": "formatted conversation string",
  "sessionData": {...},
  "messageCount": 3
}
```

---

### 6. `conversationMemory` - Buffer Window (Agent)

**Type**: `@n8n/n8n-nodes-langchain.memoryBufferWindow`

**Purpose**: Provides memory interface to the AI agent.

**Configuration**: Same as `memoryRetriever`

**Connection**: Connects to `ChatCore` via AI memory input.

---

## AI Processing

### 7. `Mistral Cloud Chat Model1` - Language Model

**Type**: `@n8n/n8n-nodes-langchain.lmChatMistralCloud`

**Purpose**: Provides AI language understanding and generation.

**Configuration**:
```json
{
  "model": "mistral-large-latest",
  "options": {
    "temperature": 0.3,
    "maxRetries": 2,
    "topP": 0.9
  }
}
```

**Parameters Explained**:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| model | mistral-large-latest | Latest Mistral Large model |
| temperature | 0.3 | Low creativity, high accuracy |
| topP | 0.9 | Nucleus sampling threshold |
| maxRetries | 2 | Retry failed API calls |

**Temperature Guide**:
- 0.0-0.3: Focused, deterministic (current)
- 0.4-0.7: Balanced creativity
- 0.8-1.0: High creativity, variability

**Connection**: Connects to `ChatCore` via AI language model input.

---

### 8. `find_book_download_link` - Search Tool

**Type**: `@n8n/n8n-nodes-langchain.toolWorkflow`

**Purpose**: Calls external workflow to search for book download links.

**Configuration**:
```json
{
  "description": "find download links",
  "workflowId": {
    "value": "0L23kFKfH7FjLarJ",
    "mode": "list"
  },
  "workflowInputs": {
    "mappingMode": "defineBelow",
    "schema": [...]
  }
}
```

**Input Schema**:
- `type` (string)
- `input` (string)
- `query` (string)
- `bookName` (string)
- `text` (string)
- `search` (string)

**Expected Output**:
```json
{
  "results": [
    {
      "url": "https://...",
      "site": "Site Name",
      "domain": "example.com",
      "title": "Book Title",
      "format": "PDF"
    }
  ]
}
```

**Connection**: Connects to `ChatCore` via AI tool input.

---

### 9. `ChatCore` - AI Agent

**Type**: `@n8n/n8n-nodes-langchain.agent`

**Purpose**: Main AI agent that orchestrates the conversation.

**Configuration**:
```json
{
  "promptType": "define",
  "text": "={{ $('sessionData').item.json.message || ... }}",
  "options": {
    "systemMessage": "...",
    "returnIntermediateSteps": true
  }
}
```

**System Message Components**:

1. **Role Definition** (Arabic):
   ```
   🤖 أنت مساعد ذكي متخصص في البحث عن الكتب والروايات العربية 📚
   ```

2. **Tasks**:
   - Search for download links using tool
   - Provide summaries and information
   - Suggest alternatives when needed

3. **Tool Usage Rules**:
   - When to use: keywords like "تحميل", "رابط", "PDF", "كتاب"
   - When user mentions specific book name

4. **Response Format Template**:
   ```
   📚 <b>[اسم الكتاب]</b>
   
   🔍 <b>نبذة:</b>
   [ملخص مختصر 2-3 أسطر فقط]
   
   🎯 <b>روابط التحميل:</b>
   
   1️⃣ <b>[اسم الموقع]</b>
   🔗 <a href="[URL]">[العنوان]</a>
   ```

5. **Strict Formatting Rules**:
   - ✅ Use HTML only: `<b>`, `<i>`, `<a>`
   - ❌ Never use Markdown: `**`, `*`, `__`

6. **Context Variables**:
   ```javascript
   👤 المستخدم: {{ firstName }}
   📩 الرسالة: {{ message }}
   💬 آخر 3 محادثات: {{ latestContext.messages }}
   ```

**Inputs**:
- Text: User message from session data
- Language Model: Mistral Cloud
- Memory: Conversation buffer
- Tools: Book search workflow

**Output**:
```json
{
  "output": "AI response text",
  "intermediateSteps": [
    {
      "action": {
        "tool": "find_book_download_link",
        "toolInput": {...}
      },
      "observation": "tool response"
    }
  ]
}
```

**Key Features**:
- Returns intermediate steps for debugging
- Uses conversation memory automatically
- Can call external tools
- Formats responses per system prompt

---

## Message Formatting

### 10. `Format Telegram Message` - Markdown to HTML

**Type**: `n8n-nodes-base.code` (JavaScript)

**Purpose**: Converts AI response to Telegram-compatible HTML format.

**Main Steps**:

1. **Extract Response**:
   ```javascript
   // Try multiple fields
   if (inputData.output) { ... }
   else if (inputData.text) { ... }
   else if (inputData.response) { ... }
   ```

2. **Convert Markdown to HTML**:
   ```javascript
   // **text** → <b>text</b>
   responseText = responseText.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>');
   
   // *text* → <i>text</i>
   responseText = responseText.replace(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/g, '<i>$1</i>');
   
   // __text__ → <b>text</b>
   responseText = responseText.replace(/__(.+?)__/g, '<b>$1</b>');
   
   // _text_ → <i>text</i>
   responseText = responseText.replace(/(?<!_)_(?!_)(.+?)(?<!_)_(?!_)/g, '<i>$1</i>');
   ```

3. **Clean Up**:
   ```javascript
   // Remove <web> tags
   responseText = responseText.replace(/<web>[\s\S]*?<\/web>/gi, '');
   
   // Remove source citations
   responseText = responseText.replace(/Source $$\d+$$.*?$/gim, '');
   
   // Normalize newlines
   responseText = responseText.replace(/\n{3,}/g, '\n\n');
   ```

4. **Extract Tool Results**:
   ```javascript
   if (inputData.intermediateSteps && Array.isArray(...)) {
     // Find book search tool results
     // Parse observation JSON
     // Extract results array
   }
   ```

5. **Add Footer**:
   ```javascript
   responseText += '\n\n━━━━━━━━━━━━━━━━\n💬 <i>اكتب اسم كتاب آخر للبحث عنه!</i>';
   ```

**Output**:
```json
{
  "text": "formatted HTML response",
  "parse_mode": "HTML",
  "disable_web_page_preview": true,
  "hasResults": true,
  "allResults": [...]
}
```

---

### 11. `Build Inline Keyboard` - Create Buttons

**Type**: `n8n-nodes-base.code` (JavaScript)

**Purpose**: Builds interactive inline keyboard with download links and actions.

**Logic**:

1. **Initialize Keyboard**:
   ```javascript
   const keyboard = {
     inline_keyboard: []
   };
   ```

2. **Add Download Links** (if results exist):
   ```javascript
   // First 3 links in row 1
   const topResults = results.slice(0, 3);
   topResults.forEach((result, idx) => {
     const emoji = ['1️⃣', '2️⃣', '3️⃣'][idx];
     const siteName = cleanSiteName(result.site);
     
     row.push({
       text: `${emoji} ${siteName}`,
       url: result.url
     });
   });
   
   // Links 4-5 in row 2
   const moreResults = results.slice(3, 5);
   // Same logic...
   ```

3. **Add Action Buttons**:
   ```javascript
   // Row 3: New search
   keyboard.inline_keyboard.push([
     {
       text: '🔍 بحث عن كتاب آخر',
       callback_data: 'new_search'
     }
   ]);
   
   // Row 4: Recommendations
   keyboard.inline_keyboard.push([
     {
       text: '⭐ كتب مشابهة',
       callback_data: 'similar_books'
     },
     {
       text: '📚 الأكثر شعبية',
       callback_data: 'popular_books'
     }
   ]);
   
   // Row 5: Share button
   keyboard.inline_keyboard.push([
     {
       text: '📤 شارك البوت مع أصدقائك',
       switch_inline_query: 'جرب بوت تحميل الكتب المجاني! 📚'
     }
   ]);
   ```

**Site Name Cleaning**:
```javascript
const siteName = (result.site || result.domain || 'موقع')
  .replace(/📚|📖|🌐|⭐|🏛️/g, '')  // Remove emojis
  .trim()
  .substring(0, 12);  // Max 12 characters
```

**Output**:
```json
{
  "text": "message text",
  "parse_mode": "HTML",
  "reply_markup": {
    "inline_keyboard": [
      [
        {"text": "1️⃣ Site1", "url": "..."},
        {"text": "2️⃣ Site2", "url": "..."}
      ],
      [
        {"text": "🔍 بحث عن كتاب آخر", "callback_data": "new_search"}
      ]
    ]
  },
  "disable_web_page_preview": true
}
```

---

### 12. `Delay and Pass Data` - Processing Simulation

**Type**: `n8n-nodes-base.code` (JavaScript)

**Purpose**: Simulates multi-stage processing with delays and passes data correctly.

**Processing Stages**:
```javascript
const stages = [
  '🔍 المرحلة 1/4: البحث في قواعد البيانات...',
  '📊 المرحلة 2/4: تحليل وترتيب النتائج...',
  '🎨 المرحلة 3/4: تنسيق الروابط والأزرار...',
  '✨ المرحلة 4/4: تجهيز الرد النهائي...'
];

for (const stage of stages) {
  console.log(stage);
  await new Promise(r => setTimeout(r, 450));  // 450ms delay
}
```

**Total Delay**: 450ms × 4 = 1.8 seconds

**Data Pass-Through**:
```javascript
// Get data from previous node
const buildKeyboardNode = $('Build Inline Keyboard');
const keyboardData = buildKeyboardNode.first().json;

// Pass through WITHOUT stringifying reply_markup
return [{
  json: {
    text: keyboardData.text,
    reply_markup: keyboardData.reply_markup,  // Object, not string!
    parse_mode: 'HTML',
    disable_web_page_preview: true
  }
}];
```

**Important**: The `reply_markup` must be an object, not a stringified JSON.

**Debug Logging**:
```javascript
console.log('🔍 Debug Info:');
console.log('text length:', keyboardData.text?.length || 0);
console.log('reply_markup exists:', !!keyboardData.reply_markup);
```

---

## Output & Delivery

### 13. `Send a chat action` - Typing Indicator

**Type**: `n8n-nodes-base.telegram`

**Purpose**: Shows "typing..." indicator in Telegram while preparing response.

**Configuration**:
```json
{
  "operation": "sendChatAction",
  "chatId": "={{ $('sessionData').item.json.sessionId }}"
}
```

**Actions Available**:
- `typing` - Typing text (default)
- `upload_photo` - Uploading photo
- `upload_document` - Uploading file
- `find_location` - Finding location

**Duration**: Lasts ~5 seconds or until message is sent.

**Error Handling**:
- `onError`: continueRegularOutput (non-critical)

---

### 14. `sendTextMessage` - Send to Telegram

**Type**: `n8n-nodes-base.telegram`

**Purpose**: Sends the final formatted message to the user.

**Configuration**:
```json
{
  "chatId": "={{ $('sessionData').item.json.sessionId }}",
  "text": "={{ $('Delay and Pass Data').first().json.text }}",
  "replyMarkup": "=={{ $('Delay and Pass Data').first().json.reply_markup }}",
  "additionalFields": {
    "disable_web_page_preview": true,
    "parse_mode": "HTML"
  }
}
```

**Parameters**:

| Parameter | Source | Purpose |
|-----------|--------|---------|
| chatId | sessionData.sessionId | Target chat |
| text | Delay node output | Message text |
| replyMarkup | Delay node output | Inline keyboard |
| parse_mode | Fixed: "HTML" | Enable HTML formatting |
| disable_web_page_preview | Fixed: true | No link previews |

**Supported HTML Tags**:
- `<b>bold</b>`
- `<i>italic</i>`
- `<a href="url">link</a>`
- `<code>code</code>`
- `<pre>preformatted</pre>`

**Character Limit**: 4096 characters (Telegram limit)

**Error Handling**: Uses default retry logic from Telegram node.

---

## Node Connection Flow

```
┌─────────────┐
│  userInput  │ (Telegram Trigger)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ sessionData │ (Extract session info)
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ conversationStore│ (Memory manager)
└──────┬───────────┘
       │
       ▼
┌──────────────┐
│latestContext │ (Format last 3 messages)
└──────┬───────┘
       │
       ▼
┌──────────┐
│ ChatCore │◄──┬── Mistral Cloud Chat Model
└────┬─────┘   ├── conversationMemory
     │          └── find_book_download_link
     │
     ▼
┌─────────────────────────┐
│ Format Telegram Message │ (Markdown → HTML)
└──────────┬──────────────┘
           │
           ▼
┌──────────────────────┐
│ Build Inline Keyboard│ (Create buttons)
└──────────┬───────────┘
           │
           ▼
┌────────────────────┐
│ Delay and Pass Data│ (Simulate processing)
└──────────┬─────────┘
           │
           ▼
┌───────────────────┐
│Send a chat action │ (Typing indicator)
└──────────┬────────┘
           │
           ▼
┌─────────────────┐
│ sendTextMessage │ (Send to Telegram)
└─────────────────┘
```

---

## Best Practices

### Node Naming
- Use descriptive names
- Avoid special characters
- Keep names concise

### Error Handling
- Set `retryOnFail` for API calls
- Use `continueRegularOutput` for non-critical nodes
- Log errors for debugging

### Performance
- Minimize node count where possible
- Use expressions over code nodes when simple
- Cache common responses

### Debugging
- Enable "returnIntermediateSteps" in ChatCore
- Add console.log in code nodes
- Use execution view to trace data flow

---

## Common Modifications

### Change AI Model
```json
// In "Mistral Cloud Chat Model1" node
{
  "model": "mistral-small-latest"  // Smaller, faster model
}
```

### Adjust Response Length
```json
// In "ChatCore" systemMessage
"[ملخص مختصر 2-3 أسطر فقط]"  // Change to "5-6 أسطر" for longer
```

### Add More Buttons
```javascript
// In "Build Inline Keyboard" node
keyboard.inline_keyboard.push([
  {
    text: '📖 قراءة أونلاين',
    callback_data: 'read_online'
  }
]);
```

### Change Memory Window
```json
// In "conversationMemory" node
{
  "contextWindowLength": 30  // Increase from 15
}
```

---

This reference document provides complete details about each node's configuration, purpose, and behavior in the workflow.
