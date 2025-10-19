CREATE TABLE IF NOT EXISTS follows (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    follower_id BIGINT NOT NULL,
    followed_id BIGINT NOT NULL,
    CONSTRAINT fk_follower FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_followed FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_follow UNIQUE (follower_id, followed_id)
);