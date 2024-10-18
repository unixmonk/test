--
-- PostgreSQL database dump
--

-- Dumped from database version 14.13 (Ubuntu 14.13-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.13 (Ubuntu 14.13-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: update_chat_session_title(); Type: FUNCTION; Schema: public; Owner: woostdb
--

CREATE FUNCTION public.update_chat_session_title() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE chat_sessions
    SET title = LEFT(NEW.prompt, 50) || '...'
    WHERE id = NEW.chat_session_id
      AND (SELECT COUNT(*) FROM chat WHERE chat_session_id = NEW.chat_session_id) = 1;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_chat_session_title() OWNER TO woostdb;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: woostdb
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO woostdb;

--
-- Name: chat; Type: TABLE; Schema: public; Owner: woostdb
--

CREATE TABLE public.chat (
    id integer NOT NULL,
    user_id integer NOT NULL,
    agent_type character varying(20) NOT NULL,
    prompt text NOT NULL,
    response text,
    "timestamp" timestamp without time zone NOT NULL,
    session_id integer
);


ALTER TABLE public.chat OWNER TO woostdb;

--
-- Name: chat_id_seq; Type: SEQUENCE; Schema: public; Owner: woostdb
--

CREATE SEQUENCE public.chat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chat_id_seq OWNER TO woostdb;

--
-- Name: chat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: woostdb
--

ALTER SEQUENCE public.chat_id_seq OWNED BY public.chat.id;


--
-- Name: chat_session; Type: TABLE; Schema: public; Owner: woostdb
--

CREATE TABLE public.chat_session (
    id integer NOT NULL,
    user_id integer,
    session_name character varying(50) NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.chat_session OWNER TO woostdb;

--
-- Name: chat_session_id_seq; Type: SEQUENCE; Schema: public; Owner: woostdb
--

CREATE SEQUENCE public.chat_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chat_session_id_seq OWNER TO woostdb;

--
-- Name: chat_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: woostdb
--

ALTER SEQUENCE public.chat_session_id_seq OWNED BY public.chat_session.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: woostdb
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    username character varying(20) NOT NULL,
    password character varying(255) NOT NULL,
    openai_api_key_encrypted text,
    anthropic_api_key_encrypted text
);


ALTER TABLE public."user" OWNER TO woostdb;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: woostdb
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO woostdb;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: woostdb
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: chat id; Type: DEFAULT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat ALTER COLUMN id SET DEFAULT nextval('public.chat_id_seq'::regclass);


--
-- Name: chat_session id; Type: DEFAULT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat_session ALTER COLUMN id SET DEFAULT nextval('public.chat_session_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public.alembic_version (version_num) FROM stdin;
6c4f2ddb0c1f
\.


--
-- Data for Name: chat; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public.chat (id, user_id, agent_type, prompt, response, "timestamp", session_id) FROM stdin;
90	11	openai	test session	It looks like you're referring to a "test session." Could you please provide more details or specify what you'd like to test? I'm here to help with any questions or information you might need!	2024-10-06 22:20:50.157323	17
91	11	openai	test session message 2\r\n	It seems like you might be testing the chat functionality. If you have any questions or need assistance, feel free to ask!	2024-10-06 22:21:25.933029	17
92	11	openai	test session 2, message 1	It seems like you're referencing a specific session and message sequence. Could you please provide more context or let me know how I can assist you further?	2024-10-06 22:22:20.755973	18
93	11	openai	test session 2, message 2	It looks like you might be referring to a sequence or a specific process. Could you provide more context or details about what you need help with in "test session 2, message 2"? This will help me assist you better.	2024-10-06 22:25:25.118854	18
94	11	openai	Testing a longer prompt to see if jinja will truncate the sidebar title down to 20 characters	If you're using Jinja to render content, and you want to ensure that titles or other text elements fit within a specified length (like 20 characters for a sidebar title), you can use Jinja's string manipulation filters to truncate or format the text accordingly. Here's a basic example of how you can achieve this:\n\n```html\n{% set full_title = "Testing a longer prompt to see if jinja will truncate the sidebar title down to 20 characters" %}\n{% set truncated_title = full_title[:20] %}\n\n<div class="sidebar-title">{{ truncated_title }}</div>\n```\n\nIn this example, the `full_title` string is sliced to the first 20 characters using `[:20]`, which is a simple way to truncate it in Jinja. You can adjust the number to whatever length is suitable for your sidebar.\n\nFurthermore, if you want a more sophisticated solution that handles word boundaries (so you don't cut words in the middle), you'd need to implement a custom filter or use Jinja's built-in `truncate` filter, if available:\n\n```html\n{% set truncated_title = full_title|truncate(20) %}\n<div class="sidebar-title">{{ truncated_title }}</div>\n```\n\nThe `truncate` filter is more intelligent than simple slicing, as it tries to preserve whole words and appends `...` if the text is shortened. It’s a handy option if your Jinja environment supports it. Make sure to check your template engine's documentation to see if additional filters or options are available for text handling.	2024-10-06 22:34:23.854512	19
\.


--
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public.chat_session (id, user_id, session_name, "timestamp") FROM stdin;
17	\N	2024-10-07 06:20:43	2024-10-06 22:20:43.670319
18	\N	2024-10-07 06:22:13	2024-10-06 22:22:13.620732
19	\N	2024-10-07 06:28:13	2024-10-06 22:28:13.643521
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public."user" (id, username, password, openai_api_key_encrypted, anthropic_api_key_encrypted) FROM stdin;
11	monk	pbkdf2:sha256:260000$JrQUtHTAINn2ZoCL$6bc95376db0137755129e843e51484611ce45cb59aa9da59739de0cfc5a16c12	gAAAAABnAte057WJHZUUCl7Xws98DvZMrmYulhVamhppibpoKbphxlzAJ4x_KxrTd5FbYC4pz0B9-obVhqf0ybLOuWu94mY2paf6wfo8wBWZcavL-RAdw9s5506jsLHylsPNT8fPEFsf4iRnxUBeOGaqLdHq4baggSBhGGY0_p5QzM2b-LIFxFUaCnZc0tyh28DUNcOHeBNtEEQoS8OvR0pOSEYeDKXPQ_rzVRweiI0nTtUBJv_FufNGTj_jID7fesim8T2fYqIWoiSESzXsPMOAZc5wPG0zGucMyPawX4uvKhg_wqpHuOg=	\N
\.


--
-- Name: chat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: woostdb
--

SELECT pg_catalog.setval('public.chat_id_seq', 94, true);


--
-- Name: chat_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: woostdb
--

SELECT pg_catalog.setval('public.chat_session_id_seq', 19, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: woostdb
--

SELECT pg_catalog.setval('public.user_id_seq', 11, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: chat chat_pkey; Type: CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);


--
-- Name: chat_session chat_session_pkey; Type: CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_username_key; Type: CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_username_key UNIQUE (username);


--
-- Name: chat chat_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.chat_session(id) ON DELETE CASCADE;


--
-- Name: chat_session chat_session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat_session
    ADD CONSTRAINT chat_session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat chat_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: woostdb
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

