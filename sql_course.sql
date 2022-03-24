--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: birds; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.birds (
    name text,
    length numeric(4,1),
    wingspan numeric(4,1),
    family text,
    extinct boolean
);


ALTER TABLE public.birds OWNER TO aikanu;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.employees (
    first_name character varying(100),
    last_name character varying(100),
    department character varying(100) DEFAULT 'unassigned'::character varying NOT NULL,
    vacation_remaining integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.employees OWNER TO aikanu;

--
-- Name: films; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.films (
    title character varying(255),
    year integer,
    genre character varying(100),
    director text,
    duration integer
);


ALTER TABLE public.films OWNER TO aikanu;

--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.menu_items (
    item text,
    prep_time integer,
    ingredient_cost numeric(4,2),
    sales integer,
    menu_price numeric(4,2)
);


ALTER TABLE public.menu_items OWNER TO aikanu;

--
-- Name: people; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.people (
    name text,
    age integer,
    occupation text
);


ALTER TABLE public.people OWNER TO aikanu;

--
-- Name: weather; Type: TABLE; Schema: public; Owner: aikanu
--

CREATE TABLE public.weather (
    date date NOT NULL,
    low integer NOT NULL,
    high integer NOT NULL,
    rainfall numeric(6,3) DEFAULT 0
);


ALTER TABLE public.weather OWNER TO aikanu;

--
-- Data for Name: birds; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.birds (name, length, wingspan, family, extinct) FROM stdin;
Spotted Towhee	21.6	26.7	Emberizidae	f
American Robin	25.5	36.0	Turdidae	f
Greater Koa Finch	19.0	24.0	Fringillidae	t
Carolina Parakeet	33.0	55.8	Psittacidae	t
Common Kestrel	35.5	73.5	Falconidae	f
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.employees (first_name, last_name, department, vacation_remaining) FROM stdin;
Leonardo	Ferreira	finance	14
Sara	Mikaelsen	operations	14
Lian	Ma	marketing	13
Haiden	Smith	unassigned	0
\.


--
-- Data for Name: films; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.films (title, year, genre, director, duration) FROM stdin;
Die Hard	1988	action	John MicTiernan	132
Casablanca	1942	drama	Michael Curtiz	102
The Conversation	1974	thriller	Francis Ford Coppola	113
1984	1956	scifi	Michael Anderson	90
Tinker Tailor Soldier Spy	2011	espionage	Tomas Alfredson	127
The birdcage	1996	comedy	Mike Nichols	118
\.


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.menu_items (item, prep_time, ingredient_cost, sales, menu_price) FROM stdin;
omelette	10	1.50	182	7.99
tacos	5	2.00	254	8.99
oatmeal	1	0.50	79	5.99
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.people (name, age, occupation) FROM stdin;
Abby	34	biologist
Mu'nisah	26	\N
Mirabelle	40	contractor
\.


--
-- Data for Name: weather; Type: TABLE DATA; Schema: public; Owner: aikanu
--

COPY public.weather (date, low, high, rainfall) FROM stdin;
2016-03-07	29	32	0.000
2016-03-08	23	31	0.000
2016-03-09	17	28	0.000
2016-03-01	34	43	0.117
2016-03-02	32	44	0.117
2016-03-03	31	47	0.156
2016-03-04	33	42	0.078
2016-03-05	39	46	0.273
2016-03-06	32	43	0.078
\.


--
-- PostgreSQL database dump complete
--

