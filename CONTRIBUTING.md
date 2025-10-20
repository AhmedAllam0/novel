# 🤝 Contributing to Telegram Book Bot

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Making Changes](#making-changes)
4. [Testing](#testing)
5. [Submitting Changes](#submitting-changes)
6. [Coding Standards](#coding-standards)

## Getting Started

### Before You Begin

1. **Read the documentation**
   - [README.md](README.md) - Project overview
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System design
   - [WORKFLOW_NODES.md](WORKFLOW_NODES.md) - Technical details

2. **Set up your environment**
   - Follow [SETUP.md](SETUP.md)
   - Get the workflow running locally
   - Test basic functionality

3. **Check existing issues**
   - Look for open issues
   - Check if your idea is already proposed
   - Comment on issues you want to work on

## Development Setup

### Prerequisites

- n8n instance (cloud or self-hosted)
- Node.js 18+ (for local development)
- Git
- Code editor (VS Code recommended)

### Local Setup

```bash
# Clone the repository
git clone <repository-url>
cd telegram-book-bot

# Import workflow to n8n
# Follow SETUP.md instructions

# Create a development branch
git checkout -b feature/your-feature-name
```

### Development Workflow Configuration

For testing, create a separate bot:
1. Create test bot with @BotFather
2. Duplicate the main workflow
3. Use test credentials
4. Test changes in isolation

## Making Changes

### Types of Contributions

We welcome:

- 🐛 **Bug Fixes**: Fix workflow errors or issues
- ✨ **Features**: New nodes, tools, or capabilities  
- 📝 **Documentation**: Improve guides and examples
- 🎨 **Formatting**: Better response templates
- 🌐 **Translations**: Multi-language support
- 🔧 **Optimization**: Performance improvements

### Workflow Modification Guidelines

#### Adding New Nodes

1. **Plan the node**
   - Define clear input/output
   - Document purpose
   - Consider error handling

2. **Create the node**
   - Use appropriate node type
   - Configure parameters
   - Test connections

3. **Document the node**
   - Add to WORKFLOW_NODES.md
   - Update architecture diagram
   - Add usage examples

#### Modifying System Prompt

```javascript
// Good: Clear, specific instructions
"When user asks for book summary, provide 2-3 sentences"

// Bad: Vague instructions
"Give a summary"
```

#### Adding JavaScript Code

```javascript
// Always include error handling
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  console.error('Operation failed:', error);
  return {
    error: true,
    message: 'User-friendly error message'
  };
}
```

### Code Style

#### JavaScript in Code Nodes

```javascript
// ✅ Good
const sessionId = $('sessionData').item.json.sessionId;
const message = inputData.text || '';

// ❌ Bad
var id = $('sessionData').item.json.sessionId
let msg = inputData.text || ''
```

**Standards:**
- Use `const` by default, `let` when needed
- Add semicolons
- Use meaningful variable names
- Add comments for complex logic
- Handle null/undefined cases

#### System Prompts (Arabic)

```javascript
// ✅ Good - Clear structure
`🤖 أنت مساعد...

المهام:
1. البحث...
2. التقديم...

القواعد:
• استخدم HTML فقط`

// ❌ Bad - Unstructured
`أنت بوت للبحث عن كتب ابحث واستخدم HTML`
```

#### HTML Formatting

```javascript
// ✅ Good
const formatted = `
📚 <b>${bookTitle}</b>

🔍 <b>نبذة:</b>
${summary}

🎯 <b>روابط:</b>
`;

// ❌ Bad - Mixing Markdown and HTML
const formatted = `
📚 **${bookTitle}**

🔍 <b>نبذة:</b>
${summary}
`;
```

## Testing

### Test Checklist

Before submitting changes:

- [ ] Test with Arabic book names
- [ ] Test with English book names
- [ ] Test with invalid input
- [ ] Test with very long messages
- [ ] Test memory/context retention
- [ ] Test error handling
- [ ] Test inline buttons work
- [ ] Test formatting displays correctly
- [ ] Check n8n execution logs
- [ ] No console errors

### Test Cases

#### Basic Functionality
```
Test: "ابحث عن كتاب 1984"
Expected: Returns formatted response with links

Test: "Find The Great Gatsby"  
Expected: Returns English response with links

Test: "xyz123random"
Expected: Returns "book not found" message
```

#### Edge Cases
```
Test: Empty message
Expected: Graceful error handling

Test: Very long book title (200+ chars)
Expected: Handles without truncation issues

Test: Special characters: "كتاب!@#$%"
Expected: Sanitizes and searches
```

#### Memory Tests
```
Test: Multiple consecutive messages
Expected: Maintains context across messages

Test: After restart
Expected: Loads previous conversation history
```

### Manual Testing Procedure

1. **Import test workflow**
   - Duplicate main workflow
   - Name: "Book Bot - TEST"

2. **Configure test bot**
   - Use separate Telegram bot
   - Use test credentials

3. **Run test suite**
   - Send test messages
   - Check responses
   - Verify formatting
   - Test all buttons

4. **Check logs**
   - Review execution logs
   - Check for errors
   - Verify data flow

## Submitting Changes

### Before Submitting

1. **Test thoroughly**
   - Run all test cases
   - Test on clean workflow
   - Check error handling

2. **Update documentation**
   - Update README if needed
   - Add to EXAMPLES.md if new feature
   - Update WORKFLOW_NODES.md if nodes changed

3. **Export workflow**
   - Export as JSON
   - Update `telegram-book-bot-workflow.json`
   - Remove sensitive data (credentials!)

### Commit Messages

Use clear, descriptive commit messages:

```bash
# ✅ Good
git commit -m "Add support for audio book search"
git commit -m "Fix HTML formatting in book titles"
git commit -m "Update system prompt to handle edge cases"

# ❌ Bad
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes"
```

### Pull Request Process

1. **Create a branch**
   ```bash
   git checkout -b feature/descriptive-name
   ```

2. **Make your changes**
   - Follow coding standards
   - Test thoroughly
   - Update docs

3. **Commit changes**
   ```bash
   git add .
   git commit -m "Clear description of changes"
   ```

4. **Push to your fork**
   ```bash
   git push origin feature/descriptive-name
   ```

5. **Create Pull Request**
   - Use descriptive title
   - Explain what changed
   - Reference any issues
   - Add screenshots if UI changes

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing Done
- [ ] Tested with Arabic input
- [ ] Tested with English input
- [ ] Tested error cases
- [ ] Updated documentation

## Screenshots (if applicable)
[Add screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed the code
- [ ] Commented complex code
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Tested thoroughly
```

## Coding Standards

### JavaScript

```javascript
// Variable naming
const userName = 'Ahmed';           // camelCase
const MAX_RETRIES = 3;              // UPPER_CASE for constants

// Function naming
function formatMessage(text) { }    // camelCase, verb prefix
function isValid(input) { }         // boolean: is/has/should prefix

// Error handling
try {
  await riskyOperation();
} catch (error) {
  console.error('Context:', error);
  return fallbackValue;
}

// Comments
// Single line for brief explanations

/**
 * Multi-line for complex functions
 * @param {string} bookName - The name of the book
 * @returns {Promise<Array>} Search results
 */
```

### n8n Expressions

```javascript
// ✅ Good - Clear, safe
={{ $('nodeName').item.json.field || 'default' }}

// ❌ Bad - Can throw errors
={{ $('nodeName').item.json.field }}
```

### Arabic Text

- Use Modern Standard Arabic
- Be concise and clear
- Include emojis for visual clarity
- Format consistently

### System Prompts

Structure:
1. Role definition
2. Tasks/capabilities
3. Usage rules
4. Format template
5. Examples (if needed)

## Documentation Standards

### Markdown

```markdown
# H1 for main title
## H2 for sections
### H3 for subsections

**Bold** for emphasis
`code` for technical terms
[Links](url) for references

```code blocks```
for examples
```

### Code Examples

```javascript
// Always include:
// 1. Comment explaining purpose
// 2. Complete, runnable code
// 3. Error handling
// 4. Sample input/output

// Example: Format book title
const formatTitle = (title) => {
  if (!title) return 'Unknown Book';
  return title.trim().substring(0, 100);
};

// Input: "  The Great Gatsby  "
// Output: "The Great Gatsby"
```

## Getting Help

- 💬 Ask questions in Issues
- 📧 Email maintainers
- 📖 Check documentation first
- 🔍 Search closed issues

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the idea, not the person
- Welcome newcomers
- Help others learn

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make this bot better! 🎉
