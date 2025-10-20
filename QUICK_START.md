# ⚡ Quick Start Guide

Get your Telegram Book Bot up and running in 10 minutes!

## 📦 What You'll Need

- [ ] n8n account (cloud or self-hosted)
- [ ] Telegram Bot Token from @BotFather
- [ ] Mistral AI API Key

## 🚀 5-Step Setup

### Step 1: Create Telegram Bot (2 min)

1. Open Telegram and message `@BotFather`
2. Send `/newbot`
3. Follow the prompts
4. **Copy your bot token** - looks like: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`

### Step 2: Get Mistral API Key (2 min)

1. Visit [console.mistral.ai](https://console.mistral.ai)
2. Sign up/Login
3. Create new API key
4. **Copy the key** - looks like: `sk-proj-...`

### Step 3: Import Workflow to n8n (2 min)

1. Login to your n8n instance
2. Click **"Import from File"**
3. Upload `telegram-book-bot-workflow.json`
4. Click **"Import"**

### Step 4: Configure Credentials (2 min)

#### Add Telegram Credential:
1. Go to **Credentials** → **Add Credential**
2. Search "Telegram" → Select "Telegram API"
3. Paste your bot token
4. Name: "Telegram account"
5. Save

#### Add Mistral Credential:
1. Go to **Credentials** → **Add Credential**
2. Search "Mistral" → Select "Mistral Cloud API"  
3. Paste your API key
4. Name: "Mistral Cloud account"
5. Save

### Step 5: Activate & Register Webhook (2 min)

1. **Activate** the workflow (toggle switch)
2. Click on `userInput` node
3. **Copy the Production Webhook URL**
4. Open in browser:
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<YOUR_WEBHOOK_URL>
   ```
5. Replace `<YOUR_BOT_TOKEN>` and `<YOUR_WEBHOOK_URL>`
6. You should see: `{"ok":true,"result":true}`

## ✅ Test Your Bot

1. Open Telegram
2. Search for your bot (the username you created)
3. Send: `/start`
4. Try: `ابحث عن كتاب 1984`

**Expected Response**: Bot should search and return download links!

## 🔧 Important Notes

### ⚠️ Before You Start

This workflow requires a **Book Search Sub-Workflow** (Firecrawl). You have two options:

**Option A: Create Simple Mock Search** (Recommended for testing)

Create a new workflow named "Book Search Tool":

```javascript
// Simple mock response
return [{
  json: {
    results: [
      {
        url: "https://archive.org/search?query=" + $input.first().json.bookName,
        site: "Archive.org",
        domain: "archive.org",
        title: $input.first().json.bookName,
        format: "PDF"
      },
      {
        url: "https://www.gutenberg.org/ebooks/search/?query=" + $input.first().json.bookName,
        site: "Project Gutenberg", 
        domain: "gutenberg.org",
        title: $input.first().json.bookName,
        format: "EPUB"
      }
    ]
  }
}];
```

**Option B: Build Real Search** (For production)

See [SETUP.md](SETUP.md#step-5-create-book-search-workflow-firecrawl) for detailed instructions on creating a real book search workflow.

### 📝 Update Workflow ID

After creating your search workflow:

1. Open the main bot workflow
2. Find `find_book_download_link` node
3. Click "Workflow" dropdown
4. Select your book search workflow
5. Save

## 🐛 Troubleshooting

### Bot doesn't respond?

```bash
# Check webhook status
curl https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo
```

Should show:
```json
{
  "ok": true,
  "result": {
    "url": "your-webhook-url",
    "pending_update_count": 0
  }
}
```

### Webhook not working?

1. Make sure workflow is **Active** (green toggle)
2. Verify webhook URL doesn't have trailing slash
3. Check n8n is accessible from internet (if self-hosted)

### API errors?

1. Check Mistral API has credits
2. Verify credentials are saved correctly
3. Check credential names match the workflow

### Wrong formatting?

1. Ensure `parse_mode: "HTML"` in send message node
2. Check Format node is converting Markdown properly

## 📚 Next Steps

Now that your bot is running:

- ✅ Test with different book names
- 📖 Read [README.md](README.md) for full documentation
- 🎨 Customize the system prompt in `ChatCore` node
- 🔧 Add features from [EXAMPLES.md](EXAMPLES.md)
- 🛠️ Build a real search workflow (see [SETUP.md](SETUP.md))

## 📖 Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | Full overview and architecture |
| [SETUP.md](SETUP.md) | Detailed setup instructions |
| [WORKFLOW_NODES.md](WORKFLOW_NODES.md) | Every node explained |
| [EXAMPLES.md](EXAMPLES.md) | Extension ideas and code samples |

## 🆘 Need Help?

1. Check [SETUP.md](SETUP.md) troubleshooting section
2. Review node connections in n8n
3. Check execution logs in n8n
4. Visit [n8n community forum](https://community.n8n.io)

## 🎉 Success!

Your bot is now live! Send it book names and it will search for download links.

**Example commands to try**:
```
ابحث عن رواية 1984
Find "The Great Gatsby"
تحميل كتاب الخيميائي PDF
Harry Potter download
```

---

**Enjoy your book bot! 📚🤖**
