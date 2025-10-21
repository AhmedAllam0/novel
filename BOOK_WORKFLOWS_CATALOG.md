# 📚 Book Workflows Catalog

Complete collection of book-related n8n workflows for the Telegram Book Bot ecosystem.

## 📑 Table of Contents

1. [Overview](#overview)
2. [Workflow List](#workflow-list)
3. [Installation Guide](#installation-guide)
4. [Integration with Main Bot](#integration-with-main-bot)
5. [Workflow Details](#workflow-details)
6. [Usage Examples](#usage-examples)
7. [API Reference](#api-reference)

---

## Overview

This catalog contains **8 specialized workflows** that extend the functionality of the main Telegram Book Bot. Each workflow focuses on a specific feature and can be used independently or integrated with the main bot.

### Main Workflow
- **telegram-book-bot-workflow.json** - The primary bot for finding book download links

### Book Feature Workflows
1. **book-recommendations-workflow.json** - AI-powered book recommendations
2. **book-metadata-extractor-workflow.json** - Extract detailed book information
3. **reading-list-manager-workflow.json** - Manage personal reading lists
4. **book-reviews-summarizer-workflow.json** - Summarize book reviews
5. **book-quotes-extractor-workflow.json** - Extract memorable quotes
6. **author-profile-workflow.json** - Get author information and works

### Monitoring & Analytics Workflows 🆕
7. **analytics-dashboard-workflow.json** - Comprehensive analytics and monitoring
8. **rate-limiter-workflow.json** - Rate limiting and abuse prevention

---

## Workflow List

| Workflow | Purpose | Input | Output | Status |
|----------|---------|-------|--------|--------|
| 📚 Book Recommendations | Suggest similar books based on preferences | Book name, preferences | List of 5 recommended books | ✅ Ready |
| 📖 Metadata Extractor | Extract comprehensive book information | Book name, author, ISBN | Detailed metadata (author, year, genre, etc.) | ✅ Ready |
| 📝 Reading List Manager | Manage personal reading lists | Action (add/remove/list), user ID, book data | Updated reading list | ✅ Ready |
| ⭐ Reviews Summarizer | Analyze and summarize book reviews | Book name, reviews text | Summary with pros/cons | ✅ Ready |
| 💭 Quotes Extractor | Extract memorable quotes from books | Book name, count, theme | List of quotes with context | ✅ Ready |
| ✍️ Author Profile | Get author biography and works | Author name | Complete author profile | ✅ Ready |
| 📊 Analytics Dashboard 🆕 | Track usage, performance, and generate reports | Action (log/stats/report), event data | Statistics, reports, insights | ✅ Ready |
| 🛡️ Rate Limiter 🆕 | Prevent abuse with rate limiting | User ID, action | Allow/block with limits | ✅ Ready |

---

## Installation Guide

### Prerequisites
- n8n instance (cloud or self-hosted)
- Mistral AI API key
- Telegram Bot Token (for main bot)

### Step 1: Import Workflows

1. Open your n8n instance
2. Go to **Workflows** → **Import from File**
3. Import each workflow JSON file:
   ```
   book-recommendations-workflow.json
   book-metadata-extractor-workflow.json
   reading-list-manager-workflow.json
   book-reviews-summarizer-workflow.json
   book-quotes-extractor-workflow.json
   author-profile-workflow.json
   analytics-dashboard-workflow.json 🆕
   rate-limiter-workflow.json 🆕
   ```

### Step 2: Configure Credentials

Each workflow requires Mistral AI credentials:

1. Go to **Credentials** → **Add Credential**
2. Select **Mistral Cloud API**
3. Add your API key
4. Save as "Mistral Cloud account"

### Step 3: Activate Workflows

1. Open each workflow
2. Click **Active** toggle to enable
3. Note the webhook URL for each workflow

### Step 4: Test Workflows

Test each workflow using the webhook endpoints:

```bash
# Test Book Recommendations
curl -X POST https://your-n8n-instance.com/webhook/book-recommendations \
  -H "Content-Type: application/json" \
  -d '{"bookName": "رواية 1984", "count": 5}'

# Test Metadata Extractor
curl -X POST https://your-n8n-instance.com/webhook/book-metadata \
  -H "Content-Type: application/json" \
  -d '{"bookName": "الخيميائي", "author": "باولو كويلو"}'
```

---

## Integration with Main Bot

### Method 1: As AI Tools

Add workflows as tools in the main ChatCore agent:

```json
{
  "parameters": {
    "description": "Get book recommendations",
    "workflowId": {
      "value": "YOUR_RECOMMENDATIONS_WORKFLOW_ID",
      "mode": "list"
    }
  },
  "name": "get_book_recommendations",
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow"
}
```

### Method 2: As Callback Handlers

Handle button callbacks in the main bot:

```javascript
// In Build Inline Keyboard node
keyboard.inline_keyboard.push([
  {
    text: '⭐ كتب مشابهة',
    callback_data: 'similar_books'
  },
  {
    text: '💭 اقتباسات',
    callback_data: 'get_quotes'
  },
  {
    text: '✍️ عن المؤلف',
    callback_data: 'author_info'
  }
]);
```

Then add a callback handler node:

```javascript
// Handle callback queries
const callbackData = $('userInput').item.json.callback_query?.data;

switch(callbackData) {
  case 'similar_books':
    // Call book-recommendations workflow
    break;
  case 'get_quotes':
    // Call quotes-extractor workflow
    break;
  case 'author_info':
    // Call author-profile workflow
    break;
}
```

### Method 3: Direct HTTP Requests

Call workflows directly from code nodes:

```javascript
// In any code node
const axios = require('axios');

const response = await axios.post(
  'https://your-n8n-instance.com/webhook/book-recommendations',
  {
    bookName: bookTitle,
    count: 5,
    preferences: userPreferences
  }
);

const recommendations = response.data.recommendations;
```

---

## Workflow Details

### 1. 📚 Book Recommendations Engine

**File**: `book-recommendations-workflow.json`

**Purpose**: Generate personalized book recommendations based on a reference book and user preferences.

**Nodes**:
1. Webhook Input - Receives recommendation request
2. Extract Input Data - Parses request parameters
3. Mistral AI Model - AI language model
4. Generate Recommendations - Creates recommendation list
5. Format Response - Structures output
6. Respond to Webhook - Returns results

**Input Schema**:
```json
{
  "bookName": "اسم الكتاب المرجعي",
  "preferences": "تفضيلات المستخدم (اختياري)",
  "language": "ar",
  "count": 5
}
```

**Output Schema**:
```json
{
  "text": "HTML formatted recommendations",
  "parse_mode": "HTML",
  "recommendations": [
    {
      "title": "اسم الكتاب",
      "author": "المؤلف",
      "genre": "النوع",
      "rating": "التقييم"
    }
  ],
  "baseBook": "الكتاب المرجعي",
  "count": 5
}
```

**Features**:
- AI-powered similarity analysis
- Genre-based recommendations
- Author similarity matching
- Thematic connections
- Customizable count (1-10 books)

---

### 2. 📖 Book Metadata Extractor

**File**: `book-metadata-extractor-workflow.json`

**Purpose**: Extract comprehensive metadata about books including publication details, genre, ratings, and summaries.

**Nodes**:
1. Webhook Input
2. Extract Input
3. Mistral AI
4. Extract Metadata
5. Format Metadata
6. Respond to Webhook

**Input Schema**:
```json
{
  "bookName": "اسم الكتاب",
  "author": "المؤلف (اختياري)",
  "isbn": "رقم ISBN (اختياري)"
}
```

**Output Schema**:
```json
{
  "text": "HTML formatted metadata",
  "parse_mode": "HTML",
  "metadata": {
    "title": "العنوان الكامل",
    "author": "المؤلف",
    "year": "سنة النشر",
    "publisher": "دار النشر",
    "genre": "النوع الأدبي",
    "language": "اللغة",
    "pages": "عدد الصفحات",
    "isbn": "رقم ISBN",
    "rating": "التقييم"
  },
  "searchQuery": "الاستعلام الأصلي"
}
```

**Features**:
- Complete bibliographic data
- Publication information
- Genre classification
- Rating aggregation
- Awards and accolades
- Target audience identification

---

### 3. 📝 Reading List Manager

**File**: `reading-list-manager-workflow.json`

**Purpose**: Manage personalized reading lists with add, remove, and view capabilities.

**Nodes**:
1. Webhook Input
2. Extract Action
3. Switch Action (routes to add/list/remove)
4. Add to List
5. Get List
6. Remove from List
7. Respond to Webhook

**Input Schema**:
```json
{
  "action": "add|list|remove",
  "userId": "user_id_or_session_id",
  "book": {
    "title": "اسم الكتاب",
    "author": "المؤلف"
  },
  "listType": "to_read|reading|completed"
}
```

**Output Schema**:
```json
{
  "success": true,
  "message": "رسالة التأكيد",
  "text": "HTML formatted list",
  "parse_mode": "HTML",
  "lists": {
    "to_read": [],
    "reading": [],
    "completed": []
  },
  "totalBooks": 10
}
```

**Features**:
- Three list types: To Read, Reading, Completed
- Per-user storage
- Add/remove operations
- List viewing
- Book count tracking

**Note**: Currently uses in-memory storage. For production, integrate with a database (PostgreSQL, MongoDB, etc.).

---

### 4. ⭐ Book Reviews Summarizer

**File**: `book-reviews-summarizer-workflow.json`

**Purpose**: Analyze multiple book reviews and generate a comprehensive summary with pros, cons, and overall sentiment.

**Nodes**:
1. Webhook Input
2. Extract Input
3. Mistral AI
4. Summarize Reviews
5. Format Summary
6. Respond to Webhook

**Input Schema**:
```json
{
  "bookName": "اسم الكتاب",
  "reviews": "نص المراجعات (اختياري)",
  "language": "ar"
}
```

**Output Schema**:
```json
{
  "text": "HTML formatted summary",
  "parse_mode": "HTML",
  "bookName": "اسم الكتاب",
  "rating": 4,
  "positivePoints": [
    "نقطة إيجابية 1",
    "نقطة إيجابية 2"
  ],
  "negativePoints": [
    "نقطة سلبية 1",
    "نقطة سلبية 2"
  ],
  "summary": true
}
```

**Features**:
- Sentiment analysis
- Pros and cons extraction
- Overall rating calculation
- Common themes identification
- Reader demographic matching
- Balanced, objective summaries

---

### 5. 💭 Book Quotes Extractor

**File**: `book-quotes-extractor-workflow.json`

**Purpose**: Extract meaningful, shareable quotes from books with context.

**Nodes**:
1. Webhook Input
2. Extract Input
3. Mistral AI
4. Extract Quotes
5. Format Quotes
6. Respond to Webhook

**Input Schema**:
```json
{
  "bookName": "اسم الكتاب",
  "author": "المؤلف (اختياري)",
  "count": 5,
  "theme": "general|love|wisdom|life|philosophy"
}
```

**Output Schema**:
```json
{
  "text": "HTML formatted quotes",
  "parse_mode": "HTML",
  "bookName": "اسم الكتاب",
  "author": "المؤلف",
  "quotes": [
    {
      "text": "نص الاقتباس",
      "context": "السياق"
    }
  ],
  "count": 5
}
```

**Features**:
- Thematic quote selection
- Context provision
- Variety in topics
- Share-friendly formatting
- Customizable count
- Theme filtering

---

### 6. ✍️ Author Profile & Works

**File**: `author-profile-workflow.json`

**Purpose**: Provide comprehensive author information including biography, famous works, and literary style.

**Nodes**:
1. Webhook Input
2. Extract Input
3. Mistral AI
4. Generate Profile
5. Format Profile
6. Respond to Webhook

**Input Schema**:
```json
{
  "author": "اسم المؤلف",
  "includeBooks": true,
  "language": "ar"
}
```

**Output Schema**:
```json
{
  "text": "HTML formatted profile",
  "parse_mode": "HTML",
  "authorName": "اسم المؤلف",
  "nationality": "الجنسية",
  "famousBooks": [
    {
      "title": "اسم الكتاب",
      "year": "السنة"
    }
  ],
  "booksCount": 5,
  "awards": "الجوائز"
}
```

**Features**:
- Complete biography
- Famous works listing
- Literary style description
- Awards and recognition
- Main themes and topics
- Reading recommendations
- Famous quotes

---

## Usage Examples

### Example 1: Get Book Recommendations

```javascript
// Request
POST /webhook/book-recommendations
{
  "bookName": "رواية 1984",
  "preferences": "أحب الكتب التي تناقش الأنظمة الشمولية",
  "count": 5
}

// Response
{
  "text": "📚 <b>توصيات كتب مشابهة</b>\n\n1️⃣ <b>عالم جديد شجاع</b>\n👤 المؤلف: ألدوس هكسلي\n📖 النوع: خيال علمي ديستوبي\n⭐ التقييم: 4.5/5\n🔍 السبب: تشابه في نقد المجتمعات الشمولية...",
  "recommendations": [...],
  "count": 5
}
```

### Example 2: Extract Book Metadata

```javascript
// Request
POST /webhook/book-metadata
{
  "bookName": "الخيميائي",
  "author": "باولو كويلو"
}

// Response
{
  "text": "📚 <b>الخيميائي</b>\n\n👤 <b>المؤلف:</b> باولو كويلو\n📅 <b>سنة النشر:</b> 1988...",
  "metadata": {
    "title": "الخيميائي",
    "author": "باولو كويلو",
    "year": "1988",
    ...
  }
}
```

### Example 3: Manage Reading List

```javascript
// Add book
POST /webhook/reading-list
{
  "action": "add",
  "userId": "123456789",
  "book": {
    "title": "رواية 1984",
    "author": "جورج أورويل"
  },
  "listType": "to_read"
}

// Get list
POST /webhook/reading-list
{
  "action": "list",
  "userId": "123456789",
  "listType": "all"
}

// Remove book
POST /webhook/reading-list
{
  "action": "remove",
  "userId": "123456789",
  "book": {
    "title": "رواية 1984"
  },
  "listType": "to_read"
}
```

### Example 4: Summarize Reviews

```javascript
// Request
POST /webhook/book-reviews
{
  "bookName": "مئة عام من العزلة",
  "reviews": "مجموعة من المراجعات..."
}

// Response
{
  "text": "⭐ <b>ملخص المراجعات</b>\n\n✅ <b>النقاط الإيجابية:</b>\n• أسلوب سردي مميز...",
  "rating": 5,
  "positivePoints": [...],
  "negativePoints": [...]
}
```

### Example 5: Extract Quotes

```javascript
// Request
POST /webhook/book-quotes
{
  "bookName": "النبي",
  "author": "جبران خليل جبران",
  "count": 3,
  "theme": "wisdom"
}

// Response
{
  "text": "💭 <b>اقتباسات من النبي</b>\n\n1️⃣ <i>\"في قلب كل شتاء ربيع يختلج\"</i>\n📍 السياق: عن الأمل والتفاؤل...",
  "quotes": [...],
  "count": 3
}
```

### Example 6: Get Author Profile

```javascript
// Request
POST /webhook/author-profile
{
  "author": "نجيب محفوظ",
  "includeBooks": true
}

// Response
{
  "text": "✍️ <b>نجيب محفوظ</b>\n\n👤 <b>نبذة عن المؤلف:</b>\nأول عربي يحصل على جائزة نوبل في الأدب...",
  "authorName": "نجيب محفوظ",
  "famousBooks": [...],
  "awards": "جائزة نوبل للآداب 1988"
}
```

---

## API Reference

### Common Headers

All workflows accept the following headers:

```
Content-Type: application/json
```

### Common Response Format

All workflows return JSON with the following structure:

```json
{
  "text": "HTML formatted text for Telegram",
  "parse_mode": "HTML",
  "...additional_fields": "specific to each workflow"
}
```

### Error Handling

All workflows include error handling:

```json
{
  "text": "❌ عذراً، حدث خطأ في معالجة الطلب",
  "error": true,
  "message": "Error description"
}
```

---

## Advanced Integration Patterns

### Pattern 1: Chained Workflows

Call multiple workflows in sequence:

```javascript
// 1. Get book metadata
const metadata = await callWorkflow('book-metadata', {bookName});

// 2. Get author profile
const authorProfile = await callWorkflow('author-profile', {
  author: metadata.metadata.author
});

// 3. Get recommendations
const recommendations = await callWorkflow('book-recommendations', {
  bookName: bookName,
  preferences: metadata.metadata.genre
});

// 4. Combine results
const fullResponse = combineResults(metadata, authorProfile, recommendations);
```

### Pattern 2: Parallel Execution

Execute multiple workflows simultaneously:

```javascript
const [metadata, reviews, quotes] = await Promise.all([
  callWorkflow('book-metadata', {bookName}),
  callWorkflow('book-reviews', {bookName}),
  callWorkflow('book-quotes', {bookName, count: 3})
]);
```

### Pattern 3: Conditional Routing

Route to different workflows based on user intent:

```javascript
const userMessage = $('userInput').item.json.message.text;

if (userMessage.includes('توصيات') || userMessage.includes('مشابه')) {
  // Call recommendations workflow
  return callWorkflow('book-recommendations', {bookName});
}
else if (userMessage.includes('اقتباس') || userMessage.includes('مقولة')) {
  // Call quotes workflow
  return callWorkflow('book-quotes', {bookName});
}
else if (userMessage.includes('المؤلف') || userMessage.includes('كاتب')) {
  // Call author profile workflow
  return callWorkflow('author-profile', {author});
}
```

---

## Performance Optimization

### Tips for Better Performance

1. **Cache Common Requests**
   ```javascript
   // Check cache before calling workflow
   const cacheKey = `metadata:${bookName}`;
   let metadata = cache.get(cacheKey);
   
   if (!metadata) {
     metadata = await callWorkflow('book-metadata', {bookName});
     cache.set(cacheKey, metadata, 3600); // Cache for 1 hour
   }
   ```

2. **Reduce AI Token Usage**
   - Set appropriate `maxTokens` limits
   - Use lower `temperature` for factual queries
   - Cache AI responses when possible

3. **Parallel Execution**
   - Use Promise.all() for independent workflows
   - Avoid sequential calls when not necessary

4. **Request Batching**
   - Combine multiple small requests into one
   - Process in bulk when possible

---

## Deployment Checklist

- [ ] Import all workflow files
- [ ] Configure Mistral AI credentials
- [ ] Activate all workflows
- [ ] Test each workflow individually
- [ ] Integrate with main bot (if applicable)
- [ ] Set up error monitoring
- [ ] Configure rate limiting
- [ ] Enable caching (optional)
- [ ] Document webhook URLs
- [ ] Set up backup/recovery

---

## Future Enhancements

### Planned Features

1. **Database Integration**
   - PostgreSQL for reading lists
   - Redis for caching
   - Vector database for semantic search

2. **Additional Workflows**
   - Book comparison tool
   - Reading progress tracker
   - Book club manager
   - Audiobook finder

3. **Enhanced AI Features**
   - Fine-tuned models for Arabic literature
   - Multi-language support
   - Image generation for book covers
   - Voice narration for quotes

4. **Analytics & Insights**
   - User reading statistics
   - Popular books tracking
   - Genre preferences analysis
   - Reading speed estimation

---

## 🆕 New Analytics & Monitoring Features

For detailed documentation on the new analytics and monitoring capabilities:

- **[ANALYTICS_AND_MONITORING.md](ANALYTICS_AND_MONITORING.md)** - Complete guide to analytics system
- **[ANALYTICS_INTEGRATION_EXAMPLES.md](ANALYTICS_INTEGRATION_EXAMPLES.md)** - Integration examples and patterns

### Analytics Dashboard Features
- Real-time user statistics
- Popular books and genres tracking
- Performance metrics (response times, P95, P99)
- Error tracking and monitoring
- User engagement metrics
- Automated reports (daily/weekly/monthly)
- Multi-language analytics

### Rate Limiter Features
- Per-minute limits (10 req/min)
- Per-hour limits (100 req/hour)
- Per-day limits (500 req/day)
- Burst protection
- Graceful Arabic error messages
- Retry-after headers

---

## Support & Contributions

### Getting Help

- Check the main [README.md](README.md) for general information
- Review [WORKFLOW_NODES.md](WORKFLOW_NODES.md) for technical details
- See [EXAMPLES.md](EXAMPLES.md) for more examples
- Read [ANALYTICS_AND_MONITORING.md](ANALYTICS_AND_MONITORING.md) for analytics 🆕

### Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### License

MIT License - see [LICENSE](LICENSE) file for details

---

**Last Updated**: 2025-10-21  
**Version**: 2.0.0  
**Total Workflows**: 9 (1 main + 6 book features + 2 monitoring)
