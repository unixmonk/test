-- 1. Update the 'users' Table

-- a. Modify the 'password' column to have a maximum length of 128 characters
ALTER TABLE public."user"
    ALTER COLUMN password TYPE VARCHAR(128);

-- 2. Update the 'chat_session' Table

-- a. Add 'agent_type' and 'model_used' columns
ALTER TABLE public.chat_session
    ADD COLUMN IF NOT EXISTS agent_type VARCHAR(50),
    ADD COLUMN IF NOT EXISTS model_used VARCHAR(255);

-- b. Handle existing NULL 'user_id' values
-- Replace '1' with an appropriate default user ID
UPDATE public.chat_session
SET user_id = 1
WHERE user_id IS NULL;

-- c. Set 'user_id' to NOT NULL
ALTER TABLE public.chat_session
    ALTER COLUMN user_id SET NOT NULL;

-- d. Add foreign key constraint for 'user_id' with ON DELETE CASCADE
ALTER TABLE public.chat_session
    ADD CONSTRAINT chat_session_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public."user"(id)
    ON DELETE CASCADE;

-- e. Add index on 'user_id'
CREATE INDEX IF NOT EXISTS idx_chat_session_user_id ON public.chat_session(user_id);

-- 3. Update the 'chat' Table

-- a. Remove 'agent_type' column
ALTER TABLE public.chat
    DROP COLUMN IF EXISTS agent_type;

-- b. Handle existing NULL 'session_id' values
-- Replace '1' with an appropriate default session ID
UPDATE public.chat
SET session_id = 1
WHERE session_id IS NULL;

-- c. Set 'session_id' to NOT NULL
ALTER TABLE public.chat
    ALTER COLUMN session_id SET NOT NULL;

-- d. Drop existing foreign key constraints if necessary
ALTER TABLE public.chat
    DROP CONSTRAINT IF EXISTS chat_user_id_fkey,
    DROP CONSTRAINT IF EXISTS chat_session_id_fkey;

-- e. Add foreign key constraint for 'user_id' with ON DELETE CASCADE
ALTER TABLE public.chat
    ADD CONSTRAINT chat_user_id_fkey
    FOREIGN KEY (user_id)
    REFERENCES public."user"(id)
    ON DELETE CASCADE;

-- f. Add foreign key constraint for 'session_id' with ON DELETE CASCADE
ALTER TABLE public.chat
    ADD CONSTRAINT chat_session_id_fkey
    FOREIGN KEY (session_id)
    REFERENCES public.chat_session(id)
    ON DELETE CASCADE;

-- g. Add indexes on 'user_id' and 'session_id'
CREATE INDEX IF NOT EXISTS idx_chat_user_id ON public.chat(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_session_id ON public.chat(session_id);

-- 4. Ensure Proper Sequencing and Defaults

-- For 'chat' table
ALTER TABLE ONLY public.chat 
    ALTER COLUMN id SET DEFAULT nextval('public.chat_id_seq'::regclass);

-- For 'chat_session' table
ALTER TABLE ONLY public.chat_session 
    ALTER COLUMN id SET DEFAULT nextval('public.chat_session_id_seq'::regclass);

-- For 'user' table
ALTER TABLE ONLY public."user" 
    ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);

-- 5. Finalizing Constraints and Indexes

-- Primary Key Constraints
ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);

-- Unique Constraints
ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);
