# 🚀 Setup Guide - Telegram Book Bot

Complete step-by-step guide to set up and deploy your Telegram Book Download Bot.

## Prerequisites

Before you begin, ensure you have:

- ✅ n8n instance running (cloud or self-hosted)
- ✅ Telegram account
- ✅ Mistral AI account (or alternative LLM)
- ✅ Access to book search APIs or databases

## Step 1: Create Telegram Bot

### 1.1 Talk to BotFather

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` command
3. Choose a name (e.g., "My Book Finder Bot")
4. Choose a username (e.g., "mybookfinder_bot")
5. **Save the API token** - you'll need it later

### 1.2 Configure Bot Settings

```
/setdescription - Set bot description
/setabouttext - Set about text
/setuserpic - Upload bot avatar
/setcommands - Set bot commands
```

Example commands to set:
```
start - Start the bot
help - Get help
search - Search for a book
```

### 1.3 Enable Inline Mode (Optional)

```
/setinline
/setinlinefeedback
```

## Step 2: Get Mistral AI API Key

### 2.1 Sign Up

1. Go to [console.mistral.ai](https://console.mistral.ai)
2. Create an account
3. Navigate to API Keys section
4. Create a new API key
5. **Copy and save the key**

### 2.2 Check Model Access

Ensure you have access to `mistral-large-latest` model in your plan.

## Step 3: Set Up n8n

### 3.1 Install n8n

**Option A: Cloud**
- Sign up at [n8n.cloud](https://n8n.cloud)

**Option B: Self-hosted (Docker)**
```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

**Option C: npm**
```bash
npm install n8n -g
n8n start
```

### 3.2 Access n8n

Open your browser and go to:
- Cloud: Your assigned URL
- Self-hosted: `http://localhost:5678`

## Step 4: Configure Credentials in n8n

### 4.1 Add Telegram Credential

1. Go to **Credentials** → **Add Credential**
2. Search for "Telegram"
3. Select "Telegram API"
4. Enter your bot token from Step 1
5. Name it "Telegram account" (or match the workflow)
6. Click **Save**

### 4.2 Add Mistral AI Credential

1. Go to **Credentials** → **Add Credential**
2. Search for "Mistral"
3. Select "Mistral Cloud API"
4. Enter your API key from Step 2
5. Name it "Mistral Cloud account"
6. Click **Save**

## Step 5: Create Book Search Workflow (Firecrawl)

Before importing the main workflow, you need to create the book search sub-workflow.

### 5.1 Create New Workflow

1. Click **New Workflow**
2. Name it "Firecrawl" or "Book Search Tool"

### 5.2 Add Search Logic

Example basic structure:
```
Webhook/Execute Workflow Trigger
    ↓
HTTP Request to Book Database 1
    ↓
HTTP Request to Book Database 2
    ↓
Merge Results
    ↓
Format Output
    ↓
Return Response
```

### 5.3 Configure Input Schema

The workflow should accept these parameters:
- `bookName` (string)
- `query` (string)
- `search` (string)

### 5.4 Configure Output Format

Return data in this structure:
```json
{
  "results": [
    {
      "url": "https://example.com/book",
      "site": "Site Name",
      "domain": "example.com",
      "title": "Book Title",
      "format": "PDF"
    }
  ]
}
```

### 5.5 Save and Get Workflow ID

1. Save the workflow
2. Copy the workflow ID from the URL
   - Example: `https://your-n8n.com/workflow/0L23kFKfH7FjLarJ`
   - ID: `0L23kFKfH7FjLarJ`
3. **Save this ID** for the next step

## Step 6: Import Main Bot Workflow

### 6.1 Import Workflow

1. In n8n, click **Import from File**
2. Select `telegram-book-bot-workflow.json`
3. Click **Import**

### 6.2 Update Workflow References

1. Open the workflow
2. Find the `find_book_download_link` node
3. Update the `workflowId` with your Firecrawl workflow ID:
   ```json
   "workflowId": {
     "value": "YOUR_WORKFLOW_ID_HERE"
   }
   ```

### 6.3 Verify Credentials

Check that these nodes have credentials assigned:

- ✅ `userInput` → Telegram API
- ✅ `sendTextMessage` → Telegram API
- ✅ `Send a chat action` → Telegram API
- ✅ `Mistral Cloud Chat Model1` → Mistral Cloud API

If any are missing, click the node and select the credential.

## Step 7: Configure Webhook (Important!)

### 7.1 Activate Workflow

1. Toggle the workflow to **Active**
2. This generates webhook URLs

### 7.2 Get Production Webhook URL

1. Click on the `userInput` (Telegram Trigger) node
2. Copy the **Production Webhook URL**
3. It should look like:
   ```
   https://your-n8n.com/webhook/4e9f6007-08b0-451c-a0f4-0739a51c6842
   ```

### 7.3 Register Webhook with Telegram

**Option A: Use Browser**
```
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=<YOUR_WEBHOOK_URL>
```

**Option B: Use curl**
```bash
curl -X POST \
  "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -d "url=<YOUR_WEBHOOK_URL>"
```

**Option C: Use n8n HTTP Request Node**
Create a separate workflow with:
- HTTP Request to Telegram setWebhook API
- Execute once to register

### 7.4 Verify Webhook

```bash
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo
```

Should return:
```json
{
  "ok": true,
  "result": {
    "url": "your-webhook-url",
    "has_custom_certificate": false,
    "pending_update_count": 0
  }
}
```

## Step 8: Test Your Bot

### 8.1 Send Test Message

1. Open Telegram
2. Search for your bot username
3. Send `/start`
4. Try: "ابحث عن كتاب 1984"

### 8.2 Check n8n Executions

1. Go to **Executions** tab in n8n
2. You should see a new execution
3. Click to view execution details

### 8.3 Debug Issues

If the bot doesn't respond:

**Check Webhook Status:**
```bash
curl https://api.telegram.org/bot<TOKEN>/getWebhookInfo
```

**Check n8n Logs:**
```bash
# Docker
docker logs n8n

# npm
Check terminal where n8n is running
```

**Test Manually:**
1. Right-click the `userInput` node
2. Select "Execute Node"
3. Provide sample Telegram message data

## Step 9: Customize Bot Behavior

### 9.1 Modify System Prompt

1. Open `ChatCore` node
2. Edit the `systemMessage` parameter
3. Adjust tone, language, or instructions
4. Save workflow

### 9.2 Change Response Format

Edit the `Format Telegram Message` node to:
- Add custom emojis
- Change HTML structure
- Modify footer text

### 9.3 Update Buttons

Edit the `Build Inline Keyboard` node to:
- Add more action buttons
- Change button labels
- Modify callback data

## Step 10: Production Optimization

### 10.1 Enable Error Handling

Most nodes already have:
```
"onError": "continueRegularOutput"
```

For critical nodes, consider:
```
"retryOnFail": true,
"maxTries": 3
```

### 10.2 Set Up Monitoring

1. Enable execution logging
2. Set up error notifications
3. Monitor API quota usage

### 10.3 Add Rate Limiting (Optional)

Create a rate limiter workflow:
- Track user requests
- Limit to X requests per hour
- Return friendly error message

### 10.4 Backup Your Workflow

1. Export workflow regularly
2. Save to version control (Git)
3. Document any changes

## Troubleshooting

### Bot Not Responding

**Problem**: Messages sent but no reply

**Solutions**:
1. Check webhook is registered correctly
2. Verify workflow is **Active**
3. Check n8n execution logs
4. Test Telegram API token
5. Verify Mistral API has credits

### Formatting Issues

**Problem**: Messages show raw HTML or broken formatting

**Solutions**:
1. Ensure `parse_mode: "HTML"` in send node
2. Check `Format Telegram Message` node is converting Markdown
3. Verify no conflicting HTML tags

### Book Search Fails

**Problem**: AI responds but no links provided

**Solutions**:
1. Check Firecrawl workflow is active
2. Verify workflow ID is correct
3. Test sub-workflow independently
4. Check book search APIs are working

### Memory Issues

**Problem**: Bot doesn't remember previous messages

**Solutions**:
1. Check `conversationMemory` node is connected
2. Verify session key is using chat ID
3. Clear old sessions if database is full
4. Increase context window if needed

### API Rate Limits

**Problem**: Bot stops working after many requests

**Solutions**:
1. Check Mistral API quota
2. Implement request throttling
3. Upgrade API plan if needed
4. Cache common responses

## Advanced Configuration

### Multi-Language Support

Modify the system prompt to detect language:
```javascript
const userLang = $('sessionData').item.json.language;
if (userLang === 'en') {
  // Use English prompts
} else if (userLang === 'ar') {
  // Use Arabic prompts
}
```

### Database Integration

Add persistence:
1. Add PostgreSQL node
2. Store user preferences
3. Track search history
4. Implement favorites

### Analytics

Track usage:
1. Log every search
2. Count successful downloads
3. Identify popular books
4. Monitor user engagement

## Security Best Practices

1. **Never expose API keys** in workflow JSON
2. **Use n8n credentials** for all sensitive data
3. **Validate user input** before processing
4. **Rate limit** to prevent abuse
5. **Sanitize HTML** to prevent injection
6. **Use HTTPS** for all webhooks
7. **Regularly update** n8n and dependencies

## Next Steps

✅ Bot is running successfully!

Consider adding:
- 📊 Analytics dashboard
- 🔔 Notification system for new books
- ⭐ User favorites and bookmarks
- 💾 Search history
- 🎨 Rich media (book covers)
- 📱 Inline query support
- 🌐 Multi-language support
- 💳 Premium features

## Support Resources

- **n8n Community**: [community.n8n.io](https://community.n8n.io)
- **Telegram Bot API**: [core.telegram.org/bots](https://core.telegram.org/bots)
- **Mistral AI Docs**: [docs.mistral.ai](https://docs.mistral.ai)
- **n8n Documentation**: [docs.n8n.io](https://docs.n8n.io)

---

🎉 **Congratulations!** Your Telegram Book Bot is now live!

Need help? Check the troubleshooting section or visit the n8n community forum.
