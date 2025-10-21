-- ========================================
-- Telegram Book Bot - PostgreSQL Database Setup
-- Version: 1.0.0
-- Created: 2025-10-21
-- ========================================

-- Drop existing tables if they exist (use with caution in production!)
-- DROP TABLE IF EXISTS search_history CASCADE;
-- DROP TABLE IF EXISTS reviews CASCADE;
-- DROP TABLE IF EXISTS favorites CASCADE;
-- DROP TABLE IF EXISTS analytics_events CASCADE;
-- DROP TABLE IF EXISTS books CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- ========================================
-- 1. USERS TABLE
-- ========================================

CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    username VARCHAR(255),
    language_code VARCHAR(10) DEFAULT 'ar',
    is_bot BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    
    -- Activity tracking
    first_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_messages INT DEFAULT 0,
    total_searches INT DEFAULT 0,
    total_downloads INT DEFAULT 0,
    total_sessions INT DEFAULT 0,
    
    -- User preferences
    favorite_genre VARCHAR(100),
    favorite_author VARCHAR(255),
    preferred_language VARCHAR(10) DEFAULT 'ar',
    notification_enabled BOOLEAN DEFAULT TRUE,
    
    -- User stats
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    average_response_time DECIMAL(10,3) DEFAULT 0.000,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked', 'premium')),
    
    -- Admin notes
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for users table
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_last_seen ON users(last_seen_at DESC);
CREATE INDEX idx_users_total_searches ON users(total_searches DESC);

-- ========================================
-- 2. BOOKS TABLE
-- ========================================

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    book_title VARCHAR(500) NOT NULL,
    author VARCHAR(255),
    original_title VARCHAR(500),
    isbn VARCHAR(20),
    
    -- Book details
    genre VARCHAR(100),
    language VARCHAR(10) DEFAULT 'ar',
    publication_year INT,
    page_count INT,
    description TEXT,
    cover_image_url TEXT,
    
    -- Download information
    primary_download_link TEXT,
    alternative_links TEXT[], -- Array of alternative download links
    
    -- Statistics
    search_count INT DEFAULT 0,
    download_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    
    -- Ratings
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'unavailable', 'pending', 'removed')),
    
    -- SEO and tags
    tags TEXT[],
    popularity_score DECIMAL(10,2) DEFAULT 0.00,
    
    -- Timestamps
    first_searched_at TIMESTAMP WITH TIME ZONE,
    last_searched_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for books table
CREATE INDEX idx_books_title ON books USING gin(to_tsvector('arabic', book_title));
CREATE INDEX idx_books_author ON books USING gin(to_tsvector('arabic', author));
CREATE INDEX idx_books_genre ON books(genre);
CREATE INDEX idx_books_search_count ON books(search_count DESC);
CREATE INDEX idx_books_rating ON books(average_rating DESC);
CREATE INDEX idx_books_popularity ON books(popularity_score DESC);
CREATE INDEX idx_books_status ON books(status);

-- ========================================
-- 3. ANALYTICS EVENTS TABLE
-- ========================================

CREATE TABLE analytics_events (
    event_id BIGSERIAL PRIMARY KEY,
    event_uuid UUID DEFAULT gen_random_uuid() UNIQUE,
    
    -- Event type
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN 
        ('search', 'download', 'view', 'share', 'error', 'command', 'callback', 'rating', 'review', 'session_start', 'session_end')),
    
    -- References
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    book_id INT REFERENCES books(book_id) ON DELETE SET NULL,
    
    -- Event data
    search_query TEXT,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    error_type VARCHAR(100),
    
    -- Performance
    response_time_ms INT,
    workflow_used VARCHAR(100),
    
    -- Request info
    session_id VARCHAR(100),
    chat_id BIGINT,
    message_id BIGINT,
    chat_type VARCHAR(20) DEFAULT 'private' CHECK (chat_type IN ('private', 'group', 'supergroup', 'channel')),
    
    -- Results
    results_count INT DEFAULT 0,
    links_count INT DEFAULT 0,
    
    -- Metadata
    language VARCHAR(10) DEFAULT 'ar',
    button_clicked VARCHAR(100),
    metadata JSONB,
    
    -- Timestamp
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for analytics_events table
CREATE INDEX idx_events_user ON analytics_events(user_id);
CREATE INDEX idx_events_book ON analytics_events(book_id);
CREATE INDEX idx_events_type ON analytics_events(event_type);
CREATE INDEX idx_events_timestamp ON analytics_events(event_timestamp DESC);
CREATE INDEX idx_events_success ON analytics_events(success);
CREATE INDEX idx_events_session ON analytics_events(session_id);
CREATE INDEX idx_events_metadata ON analytics_events USING gin(metadata);

-- ========================================
-- 4. SEARCH HISTORY TABLE
-- ========================================

CREATE TABLE search_history (
    search_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    book_id INT REFERENCES books(book_id) ON DELETE SET NULL,
    
    -- Search details
    search_query TEXT NOT NULL,
    search_type VARCHAR(50) DEFAULT 'title' CHECK (search_type IN ('title', 'author', 'genre', 'keyword', 'isbn')),
    
    -- Results
    success BOOLEAN DEFAULT TRUE,
    results_count INT DEFAULT 0,
    response_time_ms INT,
    
    -- Error tracking
    error_type VARCHAR(100),
    error_message TEXT,
    
    -- Session
    session_id VARCHAR(100),
    
    -- Metadata
    language VARCHAR(10) DEFAULT 'ar',
    workflow_used VARCHAR(100),
    
    -- Timestamp
    searched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for search_history table
CREATE INDEX idx_search_user ON search_history(user_id);
CREATE INDEX idx_search_book ON search_history(book_id);
CREATE INDEX idx_search_query ON search_history USING gin(to_tsvector('arabic', search_query));
CREATE INDEX idx_search_timestamp ON search_history(searched_at DESC);
CREATE INDEX idx_search_success ON search_history(success);

-- ========================================
-- 5. FAVORITES TABLE
-- ========================================

CREATE TABLE favorites (
    favorite_id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    
    -- Metadata
    notes TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    reading_progress INT DEFAULT 0 CHECK (reading_progress >= 0 AND reading_progress <= 100),
    
    -- Timestamps
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, book_id)
);

-- Indexes for favorites table
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_book ON favorites(book_id);
CREATE INDEX idx_favorites_added ON favorites(added_at DESC);

-- ========================================
-- 6. REVIEWS TABLE
-- ========================================

CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    
    -- Review content
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    
    -- Moderation
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'published', 'rejected', 'flagged')),
    moderator_notes TEXT,
    
    -- Engagement
    helpful_count INT DEFAULT 0,
    report_count INT DEFAULT 0,
    
    -- Metadata
    language VARCHAR(10) DEFAULT 'ar',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(user_id, book_id)
);

-- Indexes for reviews table
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_book ON reviews(book_id);
CREATE INDEX idx_reviews_rating ON reviews(rating DESC);
CREATE INDEX idx_reviews_status ON reviews(status);
CREATE INDEX idx_reviews_created ON reviews(created_at DESC);

-- ========================================
-- 7. PERFORMANCE METRICS TABLE
-- ========================================

CREATE TABLE performance_metrics (
    metric_id SERIAL PRIMARY KEY,
    
    -- Metric details
    metric_name VARCHAR(100) NOT NULL,
    metric_type VARCHAR(50) NOT NULL CHECK (metric_type IN ('performance', 'usage', 'error', 'system')),
    metric_value DECIMAL(15,6) NOT NULL,
    
    -- Context
    workflow VARCHAR(100),
    time_period VARCHAR(20), -- '1min', '5min', '1hour', '1day'
    
    -- Statistical values
    min_value DECIMAL(15,6),
    max_value DECIMAL(15,6),
    avg_value DECIMAL(15,6),
    p95_value DECIMAL(15,6),
    p99_value DECIMAL(15,6),
    sample_count INT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'normal' CHECK (status IN ('normal', 'warning', 'critical')),
    threshold_value DECIMAL(15,6),
    
    -- Metadata
    metadata JSONB,
    
    -- Timestamp
    metric_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance_metrics table
CREATE INDEX idx_metrics_name ON performance_metrics(metric_name);
CREATE INDEX idx_metrics_type ON performance_metrics(metric_type);
CREATE INDEX idx_metrics_timestamp ON performance_metrics(metric_timestamp DESC);
CREATE INDEX idx_metrics_status ON performance_metrics(status);

-- ========================================
-- 8. SESSIONS TABLE
-- ========================================

CREATE TABLE sessions (
    session_id VARCHAR(100) PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Session info
    chat_id BIGINT NOT NULL,
    chat_type VARCHAR(20) DEFAULT 'private',
    
    -- Activity
    message_count INT DEFAULT 0,
    command_count INT DEFAULT 0,
    search_count INT DEFAULT 0,
    
    -- Duration
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Metadata
    metadata JSONB
);

-- Indexes for sessions table
CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_started ON sessions(started_at DESC);
CREATE INDEX idx_sessions_active ON sessions(is_active);

-- ========================================
-- FUNCTIONS AND TRIGGERS
-- ========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for users table
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for books table
CREATE TRIGGER update_books_updated_at BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for reviews table
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment book search count
CREATE OR REPLACE FUNCTION increment_book_search_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.book_id IS NOT NULL AND NEW.event_type = 'search' THEN
        UPDATE books SET 
            search_count = search_count + 1,
            last_searched_at = NEW.event_timestamp
        WHERE book_id = NEW.book_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for analytics_events to increment book counts
CREATE TRIGGER increment_book_counts AFTER INSERT ON analytics_events
    FOR EACH ROW EXECUTE FUNCTION increment_book_search_count();

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users SET
        total_messages = total_messages + 1,
        total_searches = total_searches + CASE WHEN NEW.event_type = 'search' THEN 1 ELSE 0 END,
        total_downloads = total_downloads + CASE WHEN NEW.event_type = 'download' THEN 1 ELSE 0 END,
        last_seen_at = NEW.event_timestamp
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for analytics_events to update user stats
CREATE TRIGGER update_user_stats_trigger AFTER INSERT ON analytics_events
    FOR EACH ROW EXECUTE FUNCTION update_user_stats();

-- ========================================
-- VIEWS FOR COMMON QUERIES
-- ========================================

-- View: Popular Books
CREATE OR REPLACE VIEW popular_books AS
SELECT 
    b.book_id,
    b.book_title,
    b.author,
    b.genre,
    b.search_count,
    b.download_count,
    b.average_rating,
    b.total_ratings,
    b.popularity_score
FROM books b
WHERE b.status = 'available'
ORDER BY b.popularity_score DESC, b.search_count DESC;

-- View: Active Users
CREATE OR REPLACE VIEW active_users AS
SELECT 
    u.user_id,
    u.first_name,
    u.username,
    u.total_searches,
    u.total_downloads,
    u.success_rate,
    u.last_seen_at
FROM users u
WHERE u.status = 'active' 
    AND u.last_seen_at > CURRENT_TIMESTAMP - INTERVAL '7 days'
ORDER BY u.total_searches DESC;

-- View: Recent Errors
CREATE OR REPLACE VIEW recent_errors AS
SELECT 
    e.event_id,
    e.event_type,
    e.user_id,
    u.first_name,
    e.error_type,
    e.error_message,
    e.workflow_used,
    e.event_timestamp
FROM analytics_events e
LEFT JOIN users u ON e.user_id = u.user_id
WHERE e.success = FALSE
    AND e.event_timestamp > CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY e.event_timestamp DESC;

-- View: Top Searches Today
CREATE OR REPLACE VIEW top_searches_today AS
SELECT 
    search_query,
    COUNT(*) as search_count,
    AVG(response_time_ms) as avg_response_time,
    SUM(CASE WHEN success THEN 1 ELSE 0 END)::FLOAT / COUNT(*) * 100 as success_rate
FROM search_history
WHERE searched_at > CURRENT_DATE
GROUP BY search_query
ORDER BY search_count DESC
LIMIT 20;

-- ========================================
-- SAMPLE DATA (Optional - for testing)
-- ========================================

-- Insert sample users
-- INSERT INTO users (user_id, first_name, username, language_code) VALUES
-- (123456, 'أحمد', 'ahmed_reader', 'ar'),
-- (789012, 'سارة', 'sara_books', 'ar'),
-- (345678, 'محمد', 'mohamed_lit', 'ar');

-- Insert sample books
-- INSERT INTO books (book_title, author, genre, language) VALUES
-- ('1984', 'جورج أورويل', 'رواية', 'ar'),
-- ('الخيميائي', 'باولو كويلو', 'رواية', 'ar'),
-- ('البؤساء', 'فيكتور هوجو', 'رواية', 'ar');

-- ========================================
-- MAINTENANCE QUERIES
-- ========================================

-- Calculate book popularity score (run periodically)
CREATE OR REPLACE FUNCTION calculate_popularity_scores()
RETURNS void AS $$
BEGIN
    UPDATE books SET popularity_score = (
        (search_count * 1.0) + 
        (download_count * 2.0) + 
        (average_rating * 20.0) + 
        (share_count * 3.0)
    );
END;
$$ language 'plpgsql';

-- Clean old sessions (run daily)
CREATE OR REPLACE FUNCTION clean_old_sessions()
RETURNS void AS $$
BEGIN
    UPDATE sessions SET 
        is_active = FALSE,
        ended_at = last_activity_at,
        duration_seconds = EXTRACT(EPOCH FROM (last_activity_at - started_at))
    WHERE is_active = TRUE 
        AND last_activity_at < CURRENT_TIMESTAMP - INTERVAL '1 hour';
END;
$$ language 'plpgsql';

-- ========================================
-- GRANTS (Adjust as needed)
-- ========================================

-- Create application user (if needed)
-- CREATE USER book_bot_app WITH PASSWORD 'your_secure_password';
-- GRANT CONNECT ON DATABASE your_database TO book_bot_app;
-- GRANT USAGE ON SCHEMA public TO book_bot_app;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO book_bot_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO book_bot_app;

-- ========================================
-- END OF SETUP
-- ========================================

-- Summary
SELECT 'PostgreSQL Database Setup Complete!' as status;
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
