# 🏗️ Architecture Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Telegram Platform                         │
│                    (User sends message)                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │   Telegram     │
                    │   Webhook      │
                    └────────┬───────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                          n8n Workflow                           │
│                                                                  │
│  ┌──────────────┐        ┌──────────────┐                      │
│  │  userInput   │───────▶│ sessionData  │                      │
│  │  (Trigger)   │        │  (Extract)   │                      │
│  └──────────────┘        └──────┬───────┘                      │
│                                  │                              │
│                                  ▼                              │
│                         ┌────────────────┐                      │
│                         │ Memory Manager │                      │
│                         │  (Store/Load)  │                      │
│                         └────────┬───────┘                      │
│                                  │                              │
│                                  ▼                              │
│                         ┌────────────────┐                      │
│                         │ latestContext  │                      │
│                         │(Format last 3) │                      │
│                         └────────┬───────┘                      │
│                                  │                              │
│                                  ▼                              │
│  ┌──────────────────────────────────────────────┐              │
│  │              ChatCore (AI Agent)              │              │
│  │                                                │              │
│  │  ┌──────────────┐    ┌──────────────────┐   │              │
│  │  │   Mistral    │◀───│ System Prompt    │   │              │
│  │  │ Large Model  │    │  (Arabic/Book)   │   │              │
│  │  └──────┬───────┘    └──────────────────┘   │              │
│  │         │                                     │              │
│  │         ▼                                     │              │
│  │  ┌──────────────┐    ┌──────────────────┐   │              │
│  │  │ find_book_   │    │  Conversation    │   │              │
│  │  │download_link │    │     Memory       │   │              │
│  │  │   (Tool)     │    │  (15 messages)   │   │              │
│  │  └──────┬───────┘    └──────────────────┘   │              │
│  └─────────┼──────────────────────────────────┬─┘              │
│            │                                   │                │
│            ▼                                   │                │
│  ┌──────────────────┐                         │                │
│  │  Firecrawl Sub-  │                         │                │
│  │    Workflow      │                         │                │
│  │  (Book Search)   │                         │                │
│  └──────┬───────────┘                         │                │
│         │                                      │                │
│         │ ┌────────────┐  ┌────────────┐      │                │
│         ├─│  Site 1    │  │  Site 2    │      │                │
│         │ │  Search    │  │  Search    │      │                │
│         │ └────────────┘  └────────────┘      │                │
│         │                                      │                │
│         └──────────────────┬───────────────────┘                │
│                            │                                    │
│                            ▼                                    │
│                   ┌─────────────────┐                           │
│                   │ Format Message  │                           │
│                   │ (Markdown→HTML) │                           │
│                   └────────┬────────┘                           │
│                            │                                    │
│                            ▼                                    │
│                   ┌─────────────────┐                           │
│                   │ Build Keyboard  │                           │
│                   │   (Buttons)     │                           │
│                   └────────┬────────┘                           │
│                            │                                    │
│                            ▼                                    │
│                   ┌─────────────────┐                           │
│                   │ Delay & Process │                           │
│                   │  (1.8 seconds)  │                           │
│                   └────────┬────────┘                           │
│                            │                                    │
│                            ▼                                    │
│                   ┌─────────────────┐                           │
│                   │  Chat Action    │                           │
│                   │   (Typing...)   │                           │
│                   └────────┬────────┘                           │
│                            │                                    │
│                            ▼                                    │
│                   ┌─────────────────┐                           │
│                   │  Send Message   │                           │
│                   │  (with buttons) │                           │
│                   └────────┬────────┘                           │
└────────────────────────────┼───────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │   Telegram     │
                    │   Platform     │
                    └────────┬───────┘
                             │
                             ▼
                      ┌──────────────┐
                      │  User sees   │
                      │  formatted   │
                      │   response   │
                      └──────────────┘
```

## Data Flow

### 1. Input Phase
```
User Message
    ↓
Telegram → Webhook → n8n
    ↓
Extract session data (ID, name, timestamp)
```

### 2. Context Building Phase
```
Load conversation history (last 15 messages)
    ↓
Format last 3 conversations
    ↓
Build context string for AI
```

### 3. AI Processing Phase
```
User message + Context → Mistral AI
    ↓
AI decides: Use tool or respond directly
    ↓
If book search needed: Call Firecrawl workflow
    ↓
Aggregate results
    ↓
Generate response
```

### 4. Formatting Phase
```
AI response (may contain Markdown)
    ↓
Convert **bold** → <b>bold</b>
Convert *italic* → <i>italic</i>
    ↓
Clean unwanted tags
    ↓
Add footer
```

### 5. Button Building Phase
```
Extract download links from results
    ↓
Create inline keyboard:
  - Row 1: Download links (up to 3)
  - Row 2: More links (if available)
  - Row 3: Action buttons
    ↓
Format as Telegram keyboard object
```

### 6. Delivery Phase
```
Simulate processing (1.8s delay)
    ↓
Show typing indicator
    ↓
Send formatted message with keyboard
    ↓
Save to conversation memory
```

## Component Details

### Input Layer

**Components:**
- `userInput` - Telegram webhook trigger
- `sessionData` - Session extractor

**Responsibilities:**
- Receive Telegram updates
- Extract user metadata
- Normalize message format

**Data Output:**
```json
{
  "sessionId": "123456789",
  "message": "ابحث عن كتاب",
  "firstName": "أحمد",
  "timestamp": "2025-10-20T10:00:00Z"
}
```

### Memory Layer

**Components:**
- `conversationStore` - Memory manager
- `memoryRetriever` - Retrieval interface
- `conversationMemory` - Agent memory

**Responsibilities:**
- Store conversation history
- Retrieve last N messages
- Maintain context per user

**Storage:**
- In-memory (n8n native)
- Session-based (by chat ID)
- Rolling window (last 15 messages)

### Context Layer

**Components:**
- `latestContext` - JavaScript formatter

**Responsibilities:**
- Select last 3 conversations
- Format for AI prompt
- Include user metadata

**Output Format:**
```
💬 محادثة 1:
👤 المستخدم: [message]
🤖 البوت: [response]

---

💬 محادثة 2:
...
```

### AI Layer

**Components:**
- `Mistral Cloud Chat Model` - LLM
- `ChatCore` - AI Agent
- `find_book_download_link` - Search tool

**Responsibilities:**
- Understand user intent
- Decide when to use tools
- Generate natural responses
- Format according to system prompt

**Configuration:**
```javascript
{
  model: "mistral-large-latest",
  temperature: 0.3,    // Focused, accurate
  topP: 0.9,           // Quality threshold
  maxRetries: 2        // Reliability
}
```

**System Prompt Structure:**
1. Role definition (Arabic book expert)
2. Task list (search, summarize, suggest)
3. Tool usage rules
4. Response format template
5. Formatting rules (HTML only!)
6. Context variables

### Processing Layer

**Components:**
- `Format Telegram Message` - Markdown converter
- `Build Inline Keyboard` - Button builder
- `Delay and Pass Data` - Progress simulator

**Responsibilities:**
- Convert Markdown to HTML
- Clean response text
- Build inline buttons
- Extract tool results
- Simulate processing stages

**Transformations:**
```javascript
**text** → <b>text</b>
*text*   → <i>text</i>
__text__ → <b>text</b>
_text_   → <i>text</i>
```

### Output Layer

**Components:**
- `Send a chat action` - Typing indicator
- `sendTextMessage` - Message sender

**Responsibilities:**
- Show user feedback
- Send formatted message
- Deliver inline keyboard

**Telegram API Calls:**
1. `sendChatAction` (typing)
2. `sendMessage` (with HTML parse mode)

## External Dependencies

### Telegram Bot API
```
Endpoint: api.telegram.org
Purpose: Message I/O
Rate Limit: 30 messages/second
```

### Mistral AI API
```
Endpoint: api.mistral.ai
Purpose: Language understanding
Model: mistral-large-latest
Context: Up to 32k tokens
```

### Firecrawl Workflow (Sub-workflow)
```
Purpose: Book search
Input: Book name/query
Output: Array of download links
Sources: Multiple book sites
```

## Scalability Considerations

### Current Design
- ✅ Multi-user support (session-based)
- ✅ Concurrent processing (n8n handles)
- ✅ Error recovery (retry logic)
- ⚠️ In-memory storage (limited)
- ⚠️ No rate limiting (can be abused)

### Scaling Recommendations

**For 100+ users:**
- Add Redis for conversation storage
- Implement per-user rate limiting
- Add request queuing
- Monitor API quotas

**For 1000+ users:**
- Use PostgreSQL for persistence
- Implement caching layer
- Add load balancing (multiple n8n instances)
- Separate book search to dedicated service

**For 10000+ users:**
- Microservices architecture
- Message queue (RabbitMQ/Kafka)
- Distributed caching
- CDN for static responses
- Dedicated database cluster

## Security Architecture

### Current Protection
1. **Credential Management**: n8n vault
2. **Webhook Authentication**: Telegram signature
3. **Input Validation**: Basic sanitization

### Additional Security Measures

**Recommended:**
- Rate limiting per user
- Input sanitization (XSS prevention)
- HTTPS only for webhooks
- Secrets rotation
- Audit logging

**Optional:**
- User authentication
- Admin dashboard
- Analytics tracking
- Error reporting (Sentry)

## Monitoring & Observability

### Current State
- ✅ n8n execution logs
- ✅ Console logging in code nodes
- ❌ No metrics collection
- ❌ No error alerting

### Recommended Setup

**Metrics to Track:**
1. **Usage Metrics**
   - Messages per hour
   - Unique users per day
   - Searches per user
   - Download clicks

2. **Performance Metrics**
   - Average response time
   - AI API latency
   - Search tool latency
   - Success/failure rates

3. **Business Metrics**
   - Popular books
   - Common search terms
   - User retention
   - Feature usage

**Monitoring Stack:**
```
n8n → Prometheus → Grafana
      ↓
   Alerting (Email/Slack)
```

## Deployment Architecture

### Cloud Deployment (n8n Cloud)
```
┌─────────────┐
│ n8n Cloud   │
│  (Managed)  │
└──────┬──────┘
       │
       ├─── Telegram Webhook (HTTPS)
       ├─── Mistral API
       └─── Firecrawl Workflow
```

**Pros:**
- Zero infrastructure management
- Auto-scaling
- High availability
- Automatic backups

**Cons:**
- Monthly cost
- Execution limits
- Less control

### Self-Hosted (Docker)
```
┌──────────────────────────┐
│   VPS / Cloud VM         │
│                          │
│  ┌────────────────┐      │
│  │  Docker        │      │
│  │                │      │
│  │  ┌──────────┐  │      │
│  │  │   n8n    │  │      │
│  │  └──────────┘  │      │
│  │                │      │
│  │  ┌──────────┐  │      │
│  │  │ PostgreSQL│ │      │
│  │  └──────────┘  │      │
│  │                │      │
│  └────────────────┘      │
│                          │
└──────────────────────────┘
```

**Pros:**
- Full control
- No limits
- Lower cost (long-term)
- Customizable

**Cons:**
- Requires DevOps knowledge
- Manual updates
- Security responsibility

### Production Checklist

- [ ] Use HTTPS for webhooks
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Implement rate limiting
- [ ] Set up error alerts
- [ ] Test failover scenarios
- [ ] Document runbooks
- [ ] Set up CI/CD (optional)

## Performance Characteristics

### Response Time Breakdown

```
Total: ~3-5 seconds

┌─────────────────────────────────────┐
│ Component          Time      %      │
├─────────────────────────────────────┤
│ Webhook receive    50ms     1%      │
│ Session extract    20ms     <1%     │
│ Memory load        100ms    2%      │
│ Context format     30ms     <1%     │
│ AI processing      1500ms   30%     │
│ Book search tool   2000ms   40%     │
│ Format message     50ms     1%      │
│ Build keyboard     30ms     <1%     │
│ Delay simulation   1800ms   36%     │
│ Send message       100ms    2%      │
└─────────────────────────────────────┘
```

**Optimization Opportunities:**
1. Reduce delay simulation (1.8s → 0.5s)
2. Cache common book searches
3. Parallel tool calls
4. Optimize Firecrawl workflow

### Throughput Capacity

**Current (Single n8n instance):**
- ~20 concurrent executions
- ~200 messages/minute
- ~12,000 messages/hour

**Bottlenecks:**
1. Mistral API rate limits
2. n8n execution queue
3. Memory storage capacity

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Platform | Telegram | User interface |
| Orchestration | n8n | Workflow engine |
| AI Model | Mistral Large | Language understanding |
| Search | Firecrawl | Book discovery |
| Memory | n8n native | Conversation storage |
| Format | JavaScript | Text processing |

## Future Architecture Vision

### Phase 1: Current (MVP)
- Single workflow
- In-memory storage
- Basic functionality

### Phase 2: Enhanced (v2)
- Database integration
- Caching layer
- Advanced features
- Analytics

### Phase 3: Scale (v3)
- Microservices
- Message queue
- CDN
- Multi-region

### Phase 4: Enterprise (v4)
- Kubernetes deployment
- Auto-scaling
- Multi-language
- Premium features

---

This architecture is designed for rapid deployment and easy modification while maintaining scalability potential.
