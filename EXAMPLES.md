# 💡 Examples & Extensions

Practical examples and extension ideas for the Telegram Book Bot.

## Table of Contents

1. [Usage Examples](#usage-examples)
2. [Response Examples](#response-examples)
3. [Extension Ideas](#extension-ideas)
4. [Code Snippets](#code-snippets)
5. [Custom Workflows](#custom-workflows)

---

## Usage Examples

### Basic Book Search

**User Input**:
```
ابحث عن كتاب 1984
```

**Bot Response**:
```
📚 رواية 1984

🔍 نبذة:
رواية ديستوبية للكاتب جورج أورويل، تصور مجتمعاً شمولياً يسيطر 
عليه "الأخ الأكبر". تعتبر من أهم الروايات التحذيرية في القرن العشرين.

🎯 روابط التحميل:

1️⃣ مكتبة نور
🔗 https://www.noor-book.com/...
📄 PDF - 2.3 MB

2️⃣ مكتبة الكتب
🔗 https://kotobbook.com/...
📄 PDF - 2.1 MB

3️⃣ عصير الكتب
🔗 https://www.aseralkotob.com/...
📄 EPUB - 1.8 MB

💡 نصيحة: جرب الرابط الأول أولاً!

━━━━━━━━━━━━━━━━
💬 اكتب اسم كتاب آخر للبحث عنه!
```

**Inline Keyboard**:
```
[1️⃣ مكتبة نور] [2️⃣ مكتبة الكتب] [3️⃣ عصير الكتب]
[🔍 بحث عن كتاب آخر]
[⭐ كتب مشابهة] [📚 الأكثر شعبية]
[📤 شارك البوت مع أصدقائك]
```

---

### English Book Search

**User Input**:
```
Find "The Great Gatsby" PDF
```

**Bot Response**:
```
📚 The Great Gatsby by F. Scott Fitzgerald

🔍 Summary:
A classic American novel set in the 1920s Jazz Age, exploring 
themes of wealth, love, and the American Dream through the 
mysterious millionaire Jay Gatsby.

🎯 Download Links:

1️⃣ Project Gutenberg
🔗 https://www.gutenberg.org/...
📄 PDF - Free

2️⃣ Archive.org
🔗 https://archive.org/...
📄 EPUB - Free

💡 Tip: Try the first link first!

━━━━━━━━━━━━━━━━
💬 Type another book name to search!
```

---

### Author Search

**User Input**:
```
كتب نجيب محفوظ
```

**Bot Response**:
```
📚 مؤلفات نجيب محفوظ

وجدت عدة كتب للكاتب نجيب محفوظ:

1️⃣ الثلاثية (بين القصرين، قصر الشوق، السكرية)
2️⃣ أولاد حارتنا
3️⃣ زقاق المدق
4️⃣ الحرافيش
5️⃣ ميرامار

🔍 اختر كتاباً محدداً للحصول على روابط التحميل
```

---

## Response Examples

### When Book Not Found

```
❌ عذراً، لم أجد كتاب "xyz" في قواعد البيانات المتاحة.

💡 اقتراحات:
• تأكد من كتابة اسم الكتاب بشكل صحيح
• جرب البحث باسم المؤلف
• اطلب كتباً مشابهة في نفس الموضوع

🔍 هل تريد البحث عن شيء آخر؟
```

---

### Multiple Results

```
📚 وجدت عدة نتائج لـ "الخيميائي":

1️⃣ الخيميائي - باولو كويلو (الأكثر شيوعاً)
2️⃣ الخيميائي - نيوتن وعلم الكيمياء
3️⃣ سر الخيميائي - مايكل سكوت

أي منها تريد؟
```

---

### With Additional Information

```
📚 هاري بوتر وحجر الفيلسوف

👤 المؤلف: ج. ك. رولينج
📅 سنة النشر: 1997
🏷️ التصنيف: فانتازيا، مغامرات
⭐ التقييم: 4.8/5
📖 عدد الصفحات: 332

🔍 نبذة:
الجزء الأول من سلسلة هاري بوتر الشهيرة. يكتشف الصبي اليتيم 
هاري بوتر في عيد ميلاده الحادي عشر أنه ساحر...

🎯 روابط التحميل:
[...links...]
```

---

## Extension Ideas

### 1. Book Recommendations System

**Feature**: Recommend books based on user preferences.

**Implementation**:

Add new node after `ChatCore`:

```javascript
// recommendationEngine.js

const userHistory = await getUserReadingHistory(sessionId);
const currentBook = extractBookFromMessage(message);

if (currentBook) {
  const recommendations = await findSimilarBooks(currentBook);
  
  return {
    recommendations: recommendations.slice(0, 5),
    reason: 'Based on your interest in ' + currentBook
  };
}
```

**System Prompt Addition**:
```
عندما يطلب المستخدم كتباً مشابهة، استخدم:
- نفس المؤلف
- نفس النوع الأدبي
- نفس الحقبة الزمنية
- تقييمات مشابهة
```

---

### 2. Reading Progress Tracker

**Feature**: Track user's reading progress.

**Add Database Node**:
```sql
CREATE TABLE reading_progress (
  user_id BIGINT,
  book_title VARCHAR(255),
  current_page INT,
  total_pages INT,
  started_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**New Commands**:
```javascript
// Handle /progress command
if (message.startsWith('/progress')) {
  const progress = await getReadingProgress(userId);
  
  return `📚 تقدمك في القراءة:
  
📖 ${progress.bookTitle}
📊 صفحة ${progress.currentPage} من ${progress.totalPages}
⏱️ بدأت منذ ${daysAgo(progress.startedAt)} يوم
📈 ${calculatePercentage(progress)}% مكتمل`;
}
```

---

### 3. Multi-Language Support

**Feature**: Detect and respond in user's language.

**Add Language Detection**:
```javascript
// In latestContext node

const detectLanguage = (text) => {
  const arabicRegex = /[\u0600-\u06FF]/;
  const englishRegex = /^[A-Za-z\s]+$/;
  
  if (arabicRegex.test(text)) return 'ar';
  if (englishRegex.test(text)) return 'en';
  return 'ar'; // default
};

const userLang = detectLanguage(message);
```

**Dynamic System Prompts**:
```javascript
const systemPrompts = {
  ar: `🤖 أنت مساعد ذكي متخصص في البحث عن الكتب...`,
  en: `🤖 You are an intelligent assistant specialized in finding books...`,
  fr: `🤖 Vous êtes un assistant intelligent spécialisé...`
};

const prompt = systemPrompts[userLang] || systemPrompts.ar;
```

---

### 4. Book Reviews & Ratings

**Feature**: Show user reviews and ratings.

**Add Review Aggregation**:
```javascript
// reviewAggregator.js

const getBookReviews = async (bookTitle) => {
  const sources = [
    'goodreads',
    'amazon',
    'local_reviews'
  ];
  
  const reviews = await Promise.all(
    sources.map(source => fetchReviews(source, bookTitle))
  );
  
  return {
    averageRating: calculateAverage(reviews),
    totalReviews: reviews.reduce((sum, r) => sum + r.count, 0),
    topReview: findTopReview(reviews)
  };
};
```

**Response Format**:
```
⭐ التقييمات:

📊 المتوسط: 4.5/5 (2,341 تقييم)

💬 أفضل مراجعة:
"رواية رائعة تأخذك في رحلة فلسفية عميقة..."
👤 أحمد م. - ⭐⭐⭐⭐⭐

📈 توزيع التقييمات:
⭐⭐⭐⭐⭐ 65%
⭐⭐⭐⭐   25%
⭐⭐⭐     7%
⭐⭐       2%
⭐         1%
```

---

### 5. Audio Book Support

**Feature**: Provide audio book links.

**Extend Search Tool**:
```javascript
// In find_book_download_link workflow

const searchResults = {
  pdf: await searchPDF(bookName),
  epub: await searchEPUB(bookName),
  audio: await searchAudiobooks(bookName) // NEW
};

return {
  results: [
    ...searchResults.pdf,
    ...searchResults.epub,
    ...searchResults.audio
  ]
};
```

**Format Audio Results**:
```
🎧 نسخ صوتية:

1️⃣ 🎵 Audible
المدة: 8 ساعات 23 دقيقة
الراوي: محمد صبحي
🔗 [رابط الاستماع]

2️⃣ 🎵 Storytel
المدة: 8 ساعات 15 دقيقة
الراوي: خالد الصاوي
🔗 [رابط الاستماع]
```

---

### 6. Offline Mode (Cached Results)

**Feature**: Cache popular book searches.

**Add Redis Node**:
```javascript
// cacheManager.js

const getCachedBook = async (bookTitle) => {
  const cacheKey = `book:${normalizeTitle(bookTitle)}`;
  const cached = await redis.get(cacheKey);
  
  if (cached) {
    return JSON.parse(cached);
  }
  
  return null;
};

const cacheBook = async (bookTitle, data) => {
  const cacheKey = `book:${normalizeTitle(bookTitle)}`;
  await redis.set(cacheKey, JSON.stringify(data), 'EX', 86400); // 24h
};
```

**Update ChatCore Logic**:
```javascript
// Before calling search tool
const cached = await getCachedBook(bookName);

if (cached) {
  return formatCachedResponse(cached);
} else {
  const results = await searchBookLinks(bookName);
  await cacheBook(bookName, results);
  return formatResponse(results);
}
```

---

### 7. User Favorites

**Feature**: Save and manage favorite books.

**Add Database**:
```sql
CREATE TABLE user_favorites (
  id SERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  book_title VARCHAR(255),
  book_url TEXT,
  added_at TIMESTAMP DEFAULT NOW()
);
```

**New Commands**:
```javascript
// /favorite - Add to favorites
if (message.startsWith('/favorite')) {
  await addToFavorites(userId, currentBook);
  return '⭐ تمت الإضافة إلى المفضلة!';
}

// /favorites - List all favorites
if (message.startsWith('/favorites')) {
  const favorites = await getUserFavorites(userId);
  
  return `📚 كتبك المفضلة (${favorites.length}):
  
${favorites.map((book, i) => `
${i+1}️⃣ ${book.title}
📅 أضيف في: ${formatDate(book.addedAt)}
🔗 [تحميل](${book.url})
`).join('\n')}`;
}
```

**Add Favorite Button**:
```javascript
// In Build Inline Keyboard

keyboard.inline_keyboard.push([
  {
    text: '⭐ إضافة للمفضلة',
    callback_data: `fav:${bookId}`
  }
]);
```

---

### 8. Book Collections/Lists

**Feature**: Curated book lists by topic.

**Predefined Lists**:
```javascript
const collections = {
  classics: {
    title: 'الكلاسيكيات العالمية',
    books: [
      'رواية 1984',
      'مزرعة الحيوانات',
      'البؤساء',
      'الجريمة والعقاب',
      'الحرب والسلام'
    ]
  },
  arabic: {
    title: 'روائع الأدب العربي',
    books: [
      'الثلاثية - نجيب محفوظ',
      'موسم الهجرة إلى الشمال',
      'رجال في الشمس',
      'الخبز الحافي'
    ]
  },
  selfdev: {
    title: 'التطوير الذاتي',
    books: [
      'العادات السبع',
      'فن اللامبالاة',
      'قوة الآن',
      'الأب الغني والأب الفقير'
    ]
  }
};
```

**Command Handler**:
```javascript
// /list <category>
if (message.startsWith('/list')) {
  const category = message.split(' ')[1] || 'classics';
  const collection = collections[category];
  
  return `📚 ${collection.title}:
  
${collection.books.map((book, i) => 
  `${i+1}️⃣ ${book}`
).join('\n')}

💡 اكتب اسم أي كتاب للحصول على رابط التحميل`;
}
```

---

### 9. Book Summary Generator

**Feature**: Generate AI summaries for books.

**Add Summary Node**:
```javascript
// summaryGenerator.js

const generateSummary = async (bookTitle, bookText) => {
  const prompt = `
Summarize this book in 3-4 sentences in Arabic:

Title: ${bookTitle}
Content: ${bookText.substring(0, 5000)}

Summary:`;

  const response = await mistralAPI.complete(prompt);
  return response.trim();
};
```

**Update Response**:
```
📚 ${bookTitle}

🔍 نبذة (مُنشأة بالذكاء الاصطناعي):
${aiGeneratedSummary}

💡 هذا ملخص تلقائي. قد لا يكون دقيقاً بنسبة 100%
```

---

### 10. Reading Time Estimator

**Feature**: Estimate reading time based on page count.

**Add Calculator**:
```javascript
const estimateReadingTime = (pages, readingSpeed = 250) => {
  // Average words per page: 250
  // Average reading speed: 250 words/min
  
  const totalWords = pages * 250;
  const minutes = Math.ceil(totalWords / readingSpeed);
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  
  return {
    hours,
    minutes: remainingMinutes,
    totalMinutes: minutes,
    formatted: hours > 0 
      ? `${hours} ساعة و ${remainingMinutes} دقيقة`
      : `${remainingMinutes} دقيقة`
  };
};
```

**Display in Response**:
```
📖 عدد الصفحات: 332
⏱️ وقت القراءة المقدر: 4 ساعات و 30 دقيقة
💡 بناءً على سرعة قراءة متوسطة (250 كلمة/دقيقة)
```

---

## Code Snippets

### Handle Callback Queries

Add new node after `userInput`:

```javascript
// callbackHandler.js

if (update.callback_query) {
  const callbackData = update.callback_query.data;
  const chatId = update.callback_query.message.chat.id;
  
  switch (callbackData) {
    case 'new_search':
      return {
        action: 'prompt',
        message: '🔍 اكتب اسم الكتاب الذي تريد البحث عنه:'
      };
      
    case 'similar_books':
      const lastBook = await getLastSearchedBook(chatId);
      return {
        action: 'search',
        query: `كتب مشابهة لـ ${lastBook}`
      };
      
    case 'popular_books':
      return {
        action: 'list',
        collection: 'popular'
      };
      
    default:
      if (callbackData.startsWith('fav:')) {
        const bookId = callbackData.split(':')[1];
        await addToFavorites(chatId, bookId);
        return {
          action: 'notify',
          message: '⭐ تمت الإضافة للمفضلة!'
        };
      }
  }
}
```

---

### Error Handling Wrapper

```javascript
// errorHandler.js

const handleWithRetry = async (fn, maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      console.error(`Attempt ${i + 1} failed:`, error);
      
      if (i === maxRetries - 1) {
        return {
          error: true,
          message: '❌ عذراً، حدث خطأ. حاول مرة أخرى لاحقاً.',
          details: error.message
        };
      }
      
      await sleep(1000 * (i + 1)); // Exponential backoff
    }
  }
};
```

---

### Rate Limiter

```javascript
// rateLimiter.js

const userRequests = new Map();

const checkRateLimit = (userId, maxRequests = 10, windowMs = 60000) => {
  const now = Date.now();
  const userHistory = userRequests.get(userId) || [];
  
  // Remove old requests outside window
  const recentRequests = userHistory.filter(
    timestamp => now - timestamp < windowMs
  );
  
  if (recentRequests.length >= maxRequests) {
    return {
      allowed: false,
      resetIn: windowMs - (now - recentRequests[0]),
      message: `⏱️ لقد وصلت للحد الأقصى من الطلبات (${maxRequests} طلب/دقيقة). حاول مرة أخرى بعد ${Math.ceil((windowMs - (now - recentRequests[0])) / 1000)} ثانية.`
    };
  }
  
  recentRequests.push(now);
  userRequests.set(userId, recentRequests);
  
  return {
    allowed: true,
    remaining: maxRequests - recentRequests.length
  };
};
```

---

### Analytics Tracker

```javascript
// analyticsTracker.js

const trackEvent = async (event) => {
  await database.insert('analytics', {
    user_id: event.userId,
    event_type: event.type,
    event_data: JSON.stringify(event.data),
    timestamp: new Date()
  });
};

// Usage
await trackEvent({
  userId: sessionId,
  type: 'book_search',
  data: {
    bookTitle: bookName,
    resultsFound: results.length,
    searchDuration: performance.now() - startTime
  }
});

await trackEvent({
  userId: sessionId,
  type: 'download_click',
  data: {
    bookTitle: bookName,
    downloadUrl: url,
    source: siteName
  }
});
```

---

## Custom Workflows

### Daily Book Recommendation

**Workflow**: Sends daily book recommendations to subscribed users.

```
Schedule Trigger (daily 9 AM)
    ↓
Get Subscribed Users (Database)
    ↓
For Each User:
    ├─ Get User Preferences
    ├─ Find Recommended Book
    ├─ Format Message
    └─ Send to Telegram
```

**Implementation**:
```javascript
// dailyRecommendation.js

const users = await getSubscribedUsers();

for (const user of users) {
  const preferences = await getUserPreferences(user.id);
  const recommendation = await findBookByPreferences(preferences);
  
  const message = `
📚 توصية اليوم

${recommendation.title}
👤 ${recommendation.author}

${recommendation.summary}

🎯 ${recommendation.genre}
⭐ ${recommendation.rating}/5

هل تريد تحميله؟`;

  await telegram.sendMessage(user.chatId, message, {
    reply_markup: {
      inline_keyboard: [[
        { text: '✅ نعم', callback_data: `recommend:${recommendation.id}` },
        { text: '❌ لا', callback_data: 'recommend:skip' }
      ]]
    }
  });
}
```

---

### Book Club Feature

**Workflow**: Monthly book club with discussion.

```javascript
// bookClub.js

const currentBook = await getCurrentMonthBook();

// Week 1: Announcement
await announceNewBook(currentBook);

// Week 2-3: Reading period
await sendReadingReminders(currentBook);

// Week 4: Discussion
await openDiscussion(currentBook);

// Generate monthly stats
await generateBookClubStats();
```

**Message Format**:
```
📚 نادي القراءة - ${month}

📖 كتاب هذا الشهر:
${bookTitle}

👤 المؤلف: ${author}
📄 الصفحات: ${pages}
⏱️ الوقت المقدر: ${readingTime}

🗓️ جدول النادي:
• الأسبوع 1-2: القراءة الفردية
• الأسبوع 3: المناقشات الجماعية  
• الأسبوع 4: التقييم والاختيار التالي

🔗 [تحميل الكتاب]
💬 [انضم للمناقشة]
```

---

This document provides practical examples and ideas for extending your Telegram Book Bot with additional features and functionality.
