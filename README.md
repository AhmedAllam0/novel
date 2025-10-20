# 🤖💬 Telegram Book Download Bot

An intelligent Telegram bot that helps users find and download Arabic books and novels using AI-powered search.

[![n8n](https://img.shields.io/badge/n8n-workflow-orange)](https://n8n.io)
[![Telegram](https://img.shields.io/badge/Telegram-Bot-blue)](https://telegram.org)
[![Mistral AI](https://img.shields.io/badge/Mistral-AI-purple)](https://mistral.ai)

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK_START.md](QUICK_START.md)** | ⚡ Get started in 10 minutes |
| **[SETUP.md](SETUP.md)** | 🛠️ Detailed installation guide |
| **[WORKFLOW_NODES.md](WORKFLOW_NODES.md)** | 📋 Complete node reference |
| **[EXAMPLES.md](EXAMPLES.md)** | 💡 Extension ideas & code samples |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | 🏗️ System architecture & design |

## 🚀 Quick Start

```bash
# 1. Get your credentials
- Telegram Bot Token from @BotFather
- Mistral AI API Key from console.mistral.ai

# 2. Import to n8n
Import telegram-book-bot-workflow.json

# 3. Configure credentials
Add Telegram API and Mistral Cloud API credentials

# 4. Activate workflow
Toggle workflow to Active

# 5. Register webhook
https://api.telegram.org/bot<TOKEN>/setWebhook?url=<WEBHOOK_URL>
```

See **[QUICK_START.md](QUICK_START.md)** for detailed instructions.

## 📋 Overview

This n8n workflow creates a sophisticated Telegram bot that:
- 🔍 Searches for book download links across multiple sources
- 💬 Maintains conversation context with users
- 🤖 Uses AI (Mistral Large) to understand user requests
- 📚 Provides formatted responses with download links
- ⌨️ Offers interactive inline keyboard buttons

## 🏗️ Workflow Architecture

### Node Flow

```
userInput (Telegram Trigger)
    ↓
sessionData (Extract session info)
    ↓
conversationStore (Memory Manager)
    ↓
latestContext (Format last 3 messages)
    ↓
ChatCore (AI Agent with Mistral)
    ↓
Format Telegram Message (Markdown → HTML)
    ↓
Build Inline Keyboard (Create buttons)
    ↓
Delay and Pass Data (Processing stages)
    ↓
Send a chat action (Typing indicator)
    ↓
sendTextMessage (Send to Telegram)
```

### Key Components

#### 1. **User Input Handler**
- Receives messages from Telegram
- Triggers on new messages
- Extracts user information and message content

#### 2. **Session Management**
- Tracks user sessions by chat ID
- Stores user metadata (name, username, language)
- Maintains conversation context (last 15 messages)

#### 3. **AI Processing (ChatCore)**
- Uses Mistral Large language model
- Temperature: 0.3 (focused responses)
- System prompt in Arabic for book search specialization
- Integrates with book search tool

#### 4. **Book Search Tool**
- Calls external Firecrawl workflow
- Searches multiple book repositories
- Returns structured download link data

#### 5. **Response Formatting**
- Converts Markdown to HTML (Telegram compatible)
- Cleans up unwanted tags and formatting
- Adds emojis and structured layout
- Extracts intermediate tool results

#### 6. **Inline Keyboard Builder**
- Creates up to 5 download link buttons
- Adds action buttons (search, similar books, etc.)
- Share button for viral growth

#### 7. **Message Delivery**
- Simulates processing stages with delays
- Sends typing indicator
- Delivers formatted message with buttons

## 🎯 Features

### AI Capabilities
- Understands Arabic book requests
- Provides book summaries
- Suggests alternatives when needed
- Maintains conversation context

### Response Format
The bot formats responses in Arabic with:
- 📚 Book title
- 🔍 Brief summary (2-3 lines)
- 🎯 Download links from multiple sources
- 💡 Tips for users

### Interactive Buttons
- **Direct Download Links**: 1-5 numbered buttons with site names
- **🔍 New Search**: Start a new book search
- **⭐ Similar Books**: Get recommendations
- **📚 Popular Books**: View trending titles
- **📤 Share**: Invite friends to use the bot

## ⚙️ Configuration

### Required Credentials

1. **Telegram Bot Token**
   - Create bot via @BotFather
   - Configure webhook for message reception

2. **Mistral Cloud API Key**
   - Sign up at Mistral AI
   - Use `mistral-large-latest` model

3. **Firecrawl Workflow**
   - Sub-workflow ID: `0L23kFKfH7FjLarJ`
   - Handles actual book search operations

### Node Parameters

#### ChatCore (AI Agent)
```javascript
{
  "model": "mistral-large-latest",
  "temperature": 0.3,
  "topP": 0.9,
  "maxRetries": 2,
  "contextWindowLength": 15
}
```

#### Memory Settings
- Session key: Chat ID from Telegram
- Context window: 15 messages
- Groups messages for efficiency

## 📝 Formatting Rules

### Critical: HTML Only (No Markdown)

The bot enforces strict HTML formatting:

✅ **Correct:**
- `<b>bold text</b>`
- `<i>italic text</i>`
- `<a href="url">link text</a>`

❌ **Incorrect:**
- `**bold**` (Markdown)
- `*italic*` (Markdown)
- `__bold__` (Markdown)

The `Format Telegram Message` node automatically converts any Markdown to HTML to prevent formatting errors.

## 🔧 Customization

### Modify System Prompt
Edit the `systemMessage` in the `ChatCore` node to:
- Change bot personality
- Adjust response format
- Add/remove features
- Support other languages

### Adjust Keyboard Buttons
Modify `Build Inline Keyboard` node to:
- Change button labels
- Add custom callback actions
- Reorder button layout
- Add more/fewer links

### Update Delay Timing
Edit `Delay and Pass Data` stages:
```javascript
// Current: 450ms per stage
await new Promise(r => setTimeout(r, 450));
```

## 📊 Data Flow

### Input Data Structure
```json
{
  "message": {
    "text": "user message",
    "chat": { "id": 123456 },
    "from": {
      "first_name": "User",
      "username": "username",
      "language_code": "ar"
    }
  }
}
```

### Output Data Structure
```json
{
  "text": "formatted response with HTML",
  "reply_markup": {
    "inline_keyboard": [[...buttons...]]
  },
  "parse_mode": "HTML",
  "disable_web_page_preview": true
}
```

## 🚀 Deployment

### Import to n8n

1. Copy `telegram-book-bot-workflow.json`
2. In n8n: **Import from File**
3. Configure credentials:
   - Telegram API
   - Mistral Cloud API
4. Update workflow IDs for tools
5. Activate workflow

### Testing

Send these test messages to your bot:
```
تحميل رواية 1984
ابحث عن كتاب الخيميائي
رابط تحميل كتاب البؤساء PDF
```

## 🔍 Troubleshooting

### Common Issues

**Bot doesn't respond:**
- Check Telegram webhook is active
- Verify credentials are set
- Check n8n workflow is activated

**Formatting errors:**
- Ensure HTML conversion is working
- Check for conflicting Markdown
- Verify parse_mode is "HTML"

**No download links:**
- Verify Firecrawl workflow is active
- Check sub-workflow ID is correct
- Test book search tool independently

**Memory issues:**
- Clear old sessions manually
- Reduce context window length
- Check memory node configuration

## 📈 Performance Optimization

- **Temperature 0.3**: Balanced between creativity and accuracy
- **Context Window 15**: Enough history without slowdown
- **Retry Logic**: 2 retries on API failures
- **Error Handling**: `continueRegularOutput` on node errors
- **Delay Stages**: User feedback during processing

## 🛡️ Security Considerations

- User data stored temporarily in memory
- No persistent storage of messages
- API credentials stored in n8n vault
- Webhook IDs are unique per instance

## 📄 License

This workflow configuration is provided as-is for educational and personal use.

## 🤝 Contributing

To improve this workflow:
1. Test thoroughly before proposing changes
2. Document any new nodes or features
3. Maintain Arabic language support
4. Keep HTML formatting standards

## 📞 Support

For issues with:
- **n8n**: Check [n8n documentation](https://docs.n8n.io)
- **Telegram API**: See [Telegram Bot API](https://core.telegram.org/bots/api)
- **Mistral AI**: Visit [Mistral docs](https://docs.mistral.ai)

---

**Version**: 1.0  
**Last Updated**: 2025-10-20  
**Workflow ID**: sEeJx76h8FVxpkrq
