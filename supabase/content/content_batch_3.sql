-- Content batch 3: Database component + a full TinyURL system design
-- topic walkthrough (steps + diagram data).
-- Run after content_batch_2.sql, plain "Run" button.
-- NOTE: uses E'...' strings for any text needing real line breaks, since
-- plain '...' strings don't interpret \n in Postgres (this is what caused
-- the flat-code bug — fixed going forward).

-- ============ COMPONENT: Database (SQL vs NoSQL) ============

insert into components (slug, name, category, description) values
('database', 'Database', 'database',
 'Persistent storage for application data. The SQL vs NoSQL choice is one of the most commonly probed trade-offs in system design interviews.');

insert into component_options (component_id, name, when_to_use, tradeoffs, notes)
select id, 'PostgreSQL / MySQL (SQL)',
  'Data has clear relationships and you need strong consistency and complex queries/joins — e.g. financial transactions, anything requiring ACID guarantees.',
  'Harder to horizontally scale writes past a point (though read replicas and sharding help); schema changes require migrations.',
  'Default answer when the question doesn''t scream "massive scale" — most interviewers are fine with SQL unless you''re explicitly asked to handle huge write volume.'
from components where slug = 'database'
union all
select id, 'DynamoDB (NoSQL, key-value/document)',
  'Need predictable low-latency at very large scale, access patterns are known in advance (lookup by key), and you''re already on AWS.',
  'Query flexibility is limited compared to SQL — you design your table around your access patterns up front, and ad-hoc queries/joins are painful.',
  'Common answer for "design a system at massive scale" questions — but be ready to explain *why* NoSQL over SQL, not just name it.'
from components where slug = 'database'
union all
select id, 'Cassandra (NoSQL, wide-column)',
  'Need to write huge volumes of data across many nodes with no single point of failure — e.g. time-series or event data at very high write throughput.',
  'Eventual consistency by default (tunable), and like DynamoDB, you model tables around query patterns rather than normalizing freely.',
  'Good answer when a question specifically stresses write-heavy, multi-datacenter scale.'
from components where slug = 'database'
union all
select id, 'MongoDB (NoSQL, document)',
  'Data is naturally document-shaped (nested/variable structure) and you want more query flexibility than a pure key-value store while still avoiding rigid schemas.',
  'Joins across documents are weaker than SQL; a flexible schema can drift into inconsistent data shapes if not disciplined.',
  null
from components where slug = 'database';

-- ============ TOPIC: TinyURL ============

insert into system_design_topics (slug, name, difficulty, description) values
('tinyurl', 'TinyURL', 'easy',
 'Design a URL shortening service: given a long URL, generate a short one that redirects to it, at scale.');

-- Step 1: Client -> Load Balancer
insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, 'Request hits the Load Balancer',
  E'A user submits a long URL (or requests a redirect). The request first hits a load balancer, which distributes it across a pool of API servers so no single server is overwhelmed and the system can scale horizontally.',
  array[(select id from components where slug = 'load-balancer')]
from system_design_topics where slug = 'tinyurl';

-- Step 2: Rate Limiter
insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, 'Rate limiting protects the write path',
  E'Shortening a URL is a write, so before it reaches the API service, a rate limiter caps how many shortening requests a single client can make per minute — this prevents abuse (e.g. someone scripting millions of shorten requests).',
  array[(select id from components where slug = 'rate-limiter')]
from system_design_topics where slug = 'tinyurl';

-- Step 3: Cache check on reads
insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, 'Reads check the cache first',
  E'When someone visits a short URL, the API service first checks a cache (e.g. Redis) mapping short code -> long URL, since reads (redirects) vastly outnumber writes (new URLs) in this system. A cache hit returns the redirect immediately without touching the database.',
  array[(select id from components where slug = 'cache')]
from system_design_topics where slug = 'tinyurl';

-- Step 4: Database on cache miss / writes
insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, 'Database stores the mapping',
  E'On a cache miss, the API service looks up the mapping in the database and populates the cache for next time. On a new short URL request, the API service generates a unique short code (e.g. base62 encoding of an auto-incrementing ID, or a hash with collision handling) and writes the mapping to the database. Given the access pattern is a simple key lookup (short code -> long URL) at high read scale, a NoSQL key-value store like DynamoDB is a common fit here — though a well-indexed SQL table works fine at moderate scale too.',
  array[(select id from components where slug = 'database')]
from system_design_topics where slug = 'tinyurl';

-- Step 5: CDN for redirect responses at the edge
insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, 'CDN serves redirects close to the user',
  E'Since redirects are simple, cacheable HTTP responses, a CDN can cache short-code redirects at edge locations close to users, cutting latency and further reducing load on the origin servers for very popular links.',
  array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = 'tinyurl';
