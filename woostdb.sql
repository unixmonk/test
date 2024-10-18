--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8 (Debian 15.8-0+deb12u1)
-- Dumped by pg_dump version 15.8 (Debian 15.8-0+deb12u1)

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
    prompt text NOT NULL,
    response text,
    "timestamp" timestamp without time zone NOT NULL,
    session_id integer NOT NULL
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
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    agent_type character varying(50),
    model_used character varying(255),
    lastupdated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
    password character varying(128) NOT NULL,
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

COPY public.chat (id, user_id, prompt, response, "timestamp", session_id) FROM stdin;
268	11	test1	It looks like you mentioned "test1." Could you provide more context or details so I can assist you better?	2024-10-14 23:19:21.192392	56
269	11	test11	It looks like you're testing the chat function! How can I assist you today?	2024-10-14 23:19:25.470885	56
270	11	test2	It looks like you're trying to test something. Could you please provide more details or specify what you need help with?	2024-10-14 23:19:33.698131	57
271	11	test332	It seems like you've input "test332." Could you provide more context or clarify what you'd like to know or do with it?	2024-10-14 23:19:37.953409	57
272	11	test 56	I'm not sure what specific test you're referring to with "test 56." Without more context, I can't provide a meaningful response. If you have a particular question or topic in mind, please provide more details or clarify what you'd like to know. I'd be happy to help if you can give me more information.	2024-10-14 23:19:44.908139	58
273	11	test 5612	I'm sorry, but "test 5612" doesn't provide me with enough context to give you a meaningful response. Could you please provide more information about what you're trying to test or what kind of information you're looking for? This will help me better understand your request and provide a more appropriate and helpful answer.	2024-10-14 23:19:48.987666	58
274	11	last test	Could you please provide more context or details so I can better understand what you're asking about the last test? For example, are you referring to an academic test, a software test, a medical test, or something else?	2024-10-14 23:21:34.473123	59
275	11	last test5	Could you please provide more context or clarify your request? Are you referring to a specific test, exam, product, software, or something else labeled "test5"?	2024-10-14 23:21:37.554021	59
276	11	test	Sure, I am here to help. What would you like to test or discuss?	2024-10-14 23:22:03.148132	60
277	11	test1	It looks like you mentioned "test1." How can I assist you? If you're conducting a test or have a specific question or need, feel free to elaborate!	2024-10-14 23:22:06.646795	60
278	11	test1	It seems like you're referring to "test1," but I'm not sure what specific information or assistance you're seeking. Could you please provide more context or clarify your request?	2024-10-14 23:38:46.412978	60
279	11	test	Sure, if you have any questions or need assistance with something, feel free to let me know!	2024-10-14 23:38:56.342455	59
280	11	tsadf	It looks like your input might be a jumble of letters. Could you please clarify or rephrase your question or request? I'm here to help!	2024-10-14 23:53:09.646207	61
281	11	tsadfasdf	It looks like your message might be a typo or scrambled text. Could you please clarify or rephrase your question?	2024-10-14 23:53:12.774744	61
282	11	test	Of course! If you have any questions or need assistance with anything specific, feel free to let me know.	2024-10-15 00:01:35.613818	62
283	11	test	Certainly! If you need help with something specific or would like to test a particular feature, feel free to let me know how I can assist you.	2024-10-15 00:05:45.581052	63
284	11	test2	It seems like you've entered "test2." Could you please provide more context or details about what you would like to know or discuss?	2024-10-15 00:05:49.033003	63
285	11	write me a c program that outputs the list of active processes in linux and sorts by their current cpu usage.	Here's a C program that outputs the list of active processes in Linux and sorts them by their current CPU usage:\n\n#include <stdio.h>\n#include <stdlib.h>\n#include <string.h>\n#include <dirent.h>\n#include <ctype.h>\n\n#define MAX_PROCESSES 1024\n#define MAX_FILENAME 256\n\ntypedef struct {\n    int pid;\n    char name[256];\n    float cpu_usage;\n} Process;\n\nint compare_cpu_usage(const void *a, const void *b) {\n    Process *p1 = (Process *)a;\n    Process *p2 = (Process *)b;\n    if (p1->cpu_usage < p2->cpu_usage) return 1;\n    if (p1->cpu_usage > p2->cpu_usage) return -1;\n    return 0;\n}\n\nfloat get_cpu_usage(int pid) {\n    char filename[MAX_FILENAME];\n    char line[256];\n    FILE *file;\n    unsigned long long int utime, stime;\n    float cpu_usage = 0.0;\n\n    snprintf(filename, sizeof(filename), "/proc/%d/stat", pid);\n    file = fopen(filename, "r");\n    if (file) {\n        if (fgets(line, sizeof(line), file)) {\n            sscanf(line, "%*d %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %llu %llu", &utime, &stime);\n            cpu_usage = (float)(utime + stime) / sysconf(_SC_CLK_TCK);\n        }\n        fclose(file);\n    }\n    return cpu_usage;\n}\n\nint main() {\n    DIR *dir;\n    struct dirent *ent;\n    Process processes[MAX_PROCESSES];\n    int process_count = 0;\n\n    dir = opendir("/proc");\n    if (dir == NULL) {\n        perror("Unable to open /proc directory");\n        return 1;\n    }\n\n    while ((ent = readdir(dir)) != NULL && process_count < MAX_PROCESSES) {\n        if (isdigit(ent->d_name[0])) {\n            int pid = atoi(ent->d_name);\n            char filename[MAX_FILENAME];\n            char line[256];\n            FILE *file;\n\n            snprintf(filename, sizeof(filename), "/proc/%d/comm", pid);\n            file = fopen(filename, "r");\n            if (file) {\n                if (fgets(line, sizeof(line), file)) {\n                    line[strcspn(line, "\\n")] = 0;\n                    processes[process_count].pid = pid;\n                    strncpy(processes[process_count].name, line, sizeof(processes[process_count].name) - 1);\n                    processes[process_count].cpu_usage = get_cpu_usage(pid);\n                    process_count++;\n                }\n                fclose(file);\n            }\n        }\n    }\n\n    closedir(dir);\n\n    qsort(processes, process_count, sizeof(Process), compare_cpu_usage);\n\n    printf("PID\\tCPU Usage\\tProcess Name\\n");\n    printf("---\\t---------\\t------------\\n");\n    for (int i = 0; i < process_count; i++) {\n        printf("%d\\t%.2f\\t\\t%s\\n", processes[i].pid, processes[i].cpu_usage, processes[i].name);\n    }\n\n    return 0;\n}\n\nThis program does the following:\n\n1. It defines a `Process` struct to store information about each process.\n\n2. The `compare_cpu_usage` function is used for sorting processes based on CPU usage.\n\n3. The `get_cpu_usage` function reads the CPU usage of a process from its `/proc/{pid}/stat` file.\n\n4. In the `main` function:\n   - It reads the `/proc` directory to get all active processes.	2024-10-15 00:21:35.546659	58
286	11	test	Sure, I’m here to help! What would you like to test or discuss?	2024-10-18 09:46:44.162587	63
\.


--
-- Data for Name: chat_session; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public.chat_session (id, user_id, session_name, "timestamp", agent_type, model_used, lastupdated) FROM stdin;
56	11	Session 2024-10-14 23:19:18	2024-10-14 23:19:18.765855	openai	gpt-4o	2024-10-14 23:19:21.191607
57	11	Session 2024-10-14 23:19:29	2024-10-14 23:19:29.893012	openai	gpt-4o	2024-10-14 23:19:33.697707
58	11	Session 2024-10-14 23:19:39	2024-10-14 23:19:39.600755	anthropic	claude-3-5-sonnet-20240620	2024-10-14 23:19:44.907757
59	11	Session 2024-10-14 23:21:29	2024-10-14 23:21:29.461808	openai	gpt-4o	2024-10-14 23:21:34.472751
60	11	Session 2024-10-14 23:21:58	2024-10-14 23:21:58.502083	openai	gpt-4o	2024-10-14 23:22:03.147761
61	11	Session 2024-10-14 23:49:19	2024-10-14 23:49:19.28666	openai	gpt-4o	2024-10-14 23:53:09.64581
62	11	Session 2024-10-15 00:01:33	2024-10-15 00:01:33.326442	openai	gpt-4o	2024-10-15 00:01:35.613477
63	11	Session 2024-10-15 00:05:41	2024-10-15 00:05:41.63157	openai	gpt-4o	2024-10-15 00:05:45.58063
64	11	Session 2024-10-15 00:23:00	2024-10-15 00:23:00.774998	\N	\N	2024-10-15 00:23:00.775002
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: woostdb
--

COPY public."user" (id, username, password, openai_api_key_encrypted, anthropic_api_key_encrypted) FROM stdin;
11	monk	pbkdf2:sha256:260000$JrQUtHTAINn2ZoCL$6bc9732bag0137755129e843e51484611ce45cb59aa9da59739de0cfc5a16c12	gAAAAABnDYltlt61qtJVWydl6oJ_WET0naH2zciRVfG_Vu9xzaybniIf5Khewil42xZs0CdsVKdIRk_SaKvEs2kEoqUYVfNZNjbLZQ5g0eTaRKnFjad3xCxi5RR99I7mzNuTxclqZJg4ZAMOszMMdbXTkapPtIzB3NVv9k3iq4y9DcCrH7jfKwqzRttJgy3zO8Bn0roL-5KWwWrNoUNhnLOLbxCM4J9m85ZXrUhWixGGG9n3u5mVRmdqjKEIHuJR6lYFDKWveYXSy1z9lDA9P_-DIy7UoAI7rzIrJVJ9iuMNj9g1Y2e91xo=	gAAAAABnDYltVpoYhcIuiINzzSEiuT7mWmayLIS8tn8U-pjQF1pQPBOW9atsag1SgW3qqq_ER6rA7BWsIiQ8Z7C3jcjMJ-P-mdoy2_Tnu1b_KMF9zcfMyIbqYk_u5B07TmafuBE93qLTDveRs3VXLC741ugmzqjhpjysADjMX3iJ0X1vmCQX-OXY9ChNysGTE5lWnHN-za_acbVMzPp95d5YSFVrZAEwSA==
\.


--
-- Name: chat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: woostdb
--

SELECT pg_catalog.setval('public.chat_id_seq', 286, true);


--
-- Name: chat_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: woostdb
--

SELECT pg_catalog.setval('public.chat_session_id_seq', 64, true);


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
-- Name: idx_chat_session_id; Type: INDEX; Schema: public; Owner: woostdb
--

CREATE INDEX idx_chat_session_id ON public.chat USING btree (session_id);


--
-- Name: idx_chat_session_user_id; Type: INDEX; Schema: public; Owner: woostdb
--

CREATE INDEX idx_chat_session_user_id ON public.chat_session USING btree (user_id);


--
-- Name: idx_chat_user_id; Type: INDEX; Schema: public; Owner: woostdb
--

CREATE INDEX idx_chat_user_id ON public.chat USING btree (user_id);


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
    ADD CONSTRAINT chat_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

