-- Content batch 4: 18 full system design topics across 5 categories
-- (Social Media, Inventory, Video, Distributed Infra, Maps),
-- converted from the provided study guide. Run AFTER
-- migration_topic_columns.sql. Plain "Run" button.

-- ===== TOPIC: News Feed (Facebook / Instagram) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$news-feed-facebook-instagram$q$, $q$News Feed (Facebook / Instagram)$q$, 'hard', $q$Design a scalable News Feed for 500M DAU. Each user follows up to 5,000 accounts. Display ranked, paginated posts with likes and comments.$q$, $q$Fan-out-on-write: fast reads, high write cost for influencers. Fan-out-on-read: cheap writes, slow reads for users with many followed accounts. Hybrid: pre-compute for normal users, merge at read time for celebrity accounts.$q$, array[$q$How do you handle a celebrity with 100M followers posting?$q$,$q$How do you implement feed pagination without cursors drifting?$q$,$q$How would you A/B test ranking algorithms?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Feed Write Path$q$, $q$Post Service → Pub/Sub (Kafka) → Fan-out Worker → Pre-computed Feed Cache (Redis sorted set, scored by timestamp or ML rank). For celebrities (>1M followers) use Fan-out on Read at query time to avoid write amplification.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$news-feed-facebook-instagram$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Feed Read Path$q$, $q$API Gateway → Feed Service → Redis (pre-built feed list per user_id, ZREVRANGE for top N) → Post Service for hydration (author, media). Cache miss: fall back to DB query + async warm.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$news-feed-facebook-instagram$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Ranking / ML$q$, $q$Offline: Spark ML job computes engagement probability per (user, post) pair. Online: at read time, merge pre-computed feed + real-time signals (recency, network activity). Score = w1*engagement_prob + w2*recency + w3*affinity.$q$, array[]::uuid[]
from system_design_topics where slug = $q$news-feed-facebook-instagram$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Storage$q$, $q$Post metadata: Cassandra (wide-row keyed by user_id + timestamp). Media: S3 + CDN (CloudFront). Feed list: Redis sorted set per user (capped at ~1000 items). Interactions (likes/comments): Cassandra counter tables.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$news-feed-facebook-instagram$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Scale Numbers$q$, $q$500M DAU, ~10 posts/day/user = 5B writes/day. Fan-out workers sharded by user_id. Kafka topics partitioned by author_id. Feed Redis cluster: ~200 nodes at 16GB each. Read path p99 < 200ms.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$news-feed-facebook-instagram$q$;

-- ===== TOPIC: Real-Time Messaging (WhatsApp / Slack) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$real-time-messaging-whatsapp-slack$q$, $q$Real-Time Messaging (WhatsApp / Slack)$q$, 'hard', $q$Design a messaging system supporting 1:1 and group chats, message delivery receipts (sent/delivered/read), and offline message queueing for 2B users.$q$, $q$WebSocket requires sticky sessions → use consistent hashing for load balancing. Cassandra chosen over MySQL for write-heavy, append-only workload. Redis pub/sub for server-to-server routing is fast but not durable — Kafka as the durable backbone.$q$, array[$q$How do you handle messages sent while offline?$q$,$q$How do you implement E2E encryption without storing keys server-side?$q$,$q$How do you scale group chat to millions of members?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Connection Layer$q$, $q$Clients hold persistent WebSocket to a Chat Server (stateful). Chat Servers register user→server mapping in Redis (user_id → server_id). On message send: sender's server looks up recipient's server, routes via internal gRPC, or queues if offline.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$real-time-messaging-whatsapp-slack$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Message Flow$q$, $q$Client → WS → Chat Server → Kafka (message_topic) → Message Processor → (1) Persist to Cassandra, (2) Push to recipient's Chat Server via pub/sub, (3) Send push notification (APNs/FCM) if offline.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$real-time-messaging-whatsapp-slack$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Delivery Receipts$q$, $q$Each message has a client-generated idempotency ID. States: SENT (ACK from server), DELIVERED (ACK from recipient device), READ (explicit read receipt). States stored in Cassandra. WebSocket events flow back to sender.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$real-time-messaging-whatsapp-slack$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Group Chat$q$, $q$For groups ≤500: fan-out to each member's inbox. Groups >500: pub/sub topic per group_id; each member's Chat Server subscribes. Message stored once, delivery tracked per member in a separate receipt table.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$real-time-messaging-whatsapp-slack$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Storage Schema$q$, $q$messages table: (conversation_id, message_id [TIMEUUID], sender_id, content, type, status). Conversations: (user_id, conversation_id, last_read_message_id). Index on conversation_id for history paging.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$real-time-messaging-whatsapp-slack$q$;

-- ===== TOPIC: Online Presence / Last Seen =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$online-presence-last-seen$q$, $q$Online Presence / Last Seen$q$, 'hard', $q$Show whether a user is online or when they were last active. Must handle 500M concurrent users with sub-second staleness.$q$, $q$TTL-based expiry is simpler than explicit disconnect events (network drops make explicit events unreliable). Trade-off: 10s staleness window. Could reduce TTL for more accuracy at higher write cost.$q$, array[$q$How do you handle presence for users with multiple devices?$q$,$q$How would you implement 'typing...' indicators?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Heartbeat$q$, $q$Client sends heartbeat every 5s over existing WebSocket. Presence Service writes user_id → {status: ONLINE, ts: now} to Redis with TTL=10s. If no heartbeat for 10s, key expires → user considered offline.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$online-presence-last-seen$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Presence Read$q$, $q$On open a chat: client requests presence for contact list. Presence Service batches Redis GET calls (pipeline). Returns: ONLINE, AWAY (<30s since last seen), or LAST_SEEN timestamp.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$online-presence-last-seen$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Fan-out$q$, $q$When a user comes online/offline, Presence Service publishes to a user's contact fan-out list (stored in Redis Set). Each subscribed Chat Server pushes presence update to connected clients.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$online-presence-last-seen$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Scaling$q$, $q$500M users × 1 heartbeat/5s = 100M writes/sec. Shard Redis by user_id. Separate cluster for presence (not shared with feed/session data). Use Redis Cluster with 100+ nodes. Coalesce fan-out updates with 200ms debounce.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$online-presence-last-seen$q$;

-- ===== TOPIC: Comments & Threaded Links (Reddit / HN) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$comments-threaded-links-reddit-hn$q$, $q$Comments & Threaded Links (Reddit / HN)$q$, 'hard', $q$Design a comment system supporting threaded replies, voting, sorting (top/new/controversial), and deep nesting up to 10 levels for millions of posts.$q$, $q$Adjacency list is simple but N+1 on reads. Nested sets are fast to read but expensive to update. Materialized path is a good middle ground for read-heavy systems like Reddit.$q$, array[$q$How do you handle vote manipulation / bots?$q$,$q$How would you implement 'collapse subtree' efficiently?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Storage Model$q$, $q$Adjacency list: comment(id, post_id, parent_id, author_id, content, score, created_at). For reading full thread: recursive CTE in Postgres or fetch by post_id and reconstruct tree in application layer. Materialized path for fast subtree queries: path = '/root/child1/child2'.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$comments-threaded-links-reddit-hn$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Voting$q$, $q$Vote events → Kafka → Vote Aggregator → update score in DB. Use Redis counter (INCR) for hot posts, flush to DB every 30s. Upvote and downvote stored separately to compute Wilson score for 'controversial' sort.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$comments-threaded-links-reddit-hn$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Sort Algorithms$q$, $q$Top: SQL ORDER BY score DESC. New: ORDER BY created_at DESC. Hot: decay formula score / (age_hours + 2)^1.5. Controversial: score where |upvotes - downvotes| is large relative to total. Pre-compute and store sort keys.$q$, array[]::uuid[]
from system_design_topics where slug = $q$comments-threaded-links-reddit-hn$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Link Previews$q$, $q$When user pastes URL → async Link Preview Service fetches OG tags (title, description, image). Store in link_previews(url_hash, title, description, image_url, fetched_at). CDN proxy to avoid SSRF and cache media.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$comments-threaded-links-reddit-hn$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Pagination$q$, $q$Cursor-based: cursor = (sort_key, comment_id). For nested comments: lazy load children beyond depth 3. 'Load more replies' triggers request with parent_id filter.$q$, array[]::uuid[]
from system_design_topics where slug = $q$comments-threaded-links-reddit-hn$q$;

-- ===== TOPIC: Amazon-Scale Inventory =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$amazon-scale-inventory$q$, $q$Amazon-Scale Inventory$q$, 'hard', $q$Design Amazon's inventory system: 350M products, flash sales (10K orders/sec spikes), distributed warehouses, and strong consistency for 'in-stock' guarantees.$q$, $q$Redis for hot-path availability checks (fast, not durable). DB for durable inventory records. Eventual consistency between Redis and DB is acceptable for display ('~10 left') but not for final deduction.$q$, array[$q$How do you handle a SKU available in 5 warehouses with a user in the middle?$q$,$q$How do you prevent the thundering herd on a flash sale start?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Inventory Service$q$, $q$Core entity: inventory_item(sku_id, warehouse_id, quantity_on_hand, quantity_reserved, quantity_available). quantity_available = on_hand - reserved. Never oversell: atomic decrement using optimistic locking (compare-and-swap on version field) or DB-level CHECK constraints.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$amazon-scale-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Reservation Pattern$q$, $q$On Add-to-Cart: reserve(sku_id, qty, ttl=15min) → creates reservation record, decrements available. On Checkout: confirm_reservation → decrements on_hand. On Timeout/Cancel: release_reservation → increments available. Saga pattern coordinates these steps.$q$, array[]::uuid[]
from system_design_topics where slug = $q$amazon-scale-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Flash Sale Handling$q$, $q$Pre-warm Redis with available qty per SKU before sale. On purchase attempt: Lua script on Redis (atomic DECR + check > 0). If > 0: emit order event to Kafka, process asynchronously. Redis is source of truth for hot SKUs; async DB sync every 100ms.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$amazon-scale-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Multi-Warehouse$q$, $q$Inventory Router: given (sku, user_location) → ranks warehouses by (availability, proximity, shipping cost). Writes go to specific warehouse. Reads aggregate across warehouses. Rebalancing jobs run nightly via distributed scheduler.$q$, array[]::uuid[]
from system_design_topics where slug = $q$amazon-scale-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Consistency$q$, $q$Use serializable isolation for final inventory deduction at payment. Two-phase commit across Inventory DB + Order DB avoided via Outbox Pattern: write order + inventory update to same DB transaction, CDC streams to downstream services.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$amazon-scale-inventory$q$;

-- ===== TOPIC: TicketMaster — Limited Inventory =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$ticketmaster-limited-inventory$q$, $q$TicketMaster — Limited Inventory$q$, 'hard', $q$Design ticket sales for a stadium concert: 70K seats, on-sale at 10am sharp, 500K concurrent users. Each seat can only be sold once. Prevent scalpers.$q$, $q$Seat locks with TTL are simple but can cause 'phantom availability' if a user holds a lock and never pays. Short TTL (8min) balances UX against inventory accuracy.$q$, array[$q$How do you handle a Stripe webhook arriving out of order?$q$,$q$What if 50K users all try to grab the same front-row section?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Virtual Queue$q$, $q$At on-sale time, all requests → Queue Service (Redis sorted set, score = arrival timestamp + random jitter). Issue position tokens. Meter users into the purchase flow at controlled rate (e.g. 2K users/min). Display real-time queue position via long-polling.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$ticketmaster-limited-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Seat Locking$q$, $q$User enters seat selection: Lock Service acquires distributed lock on seat_id (Redis SET NX with 8-minute TTL). Lock = exclusive hold. On payment completion: lock converted to sale. On timeout: lock released, seat back to pool.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$ticketmaster-limited-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Seat Map Service$q$, $q$Seat availability stored in Redis Bitmap (1 bit per seat, 0=available, 1=sold/locked). Atomic GETBIT/SETBIT operations. Full seat map streamed via WebSocket with diff updates (only changed seats) to avoid re-rendering 70K seats each second.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$ticketmaster-limited-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Anti-Scalper$q$, $q$Rate limit by IP + account age + device fingerprint. CAPTCHA at queue entry. Max tickets per account per event (enforced at DB level). Purchase velocity checks: >2 orders/60s from same IP → challenge. Resale integration (Verified Fan, Ticketmaster SafeTix).$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$ticketmaster-limited-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Payment via Stripe$q$, $q$Create Stripe PaymentIntent on lock acquisition (amount = ticket price + fees). 3D Secure for high-value tickets. Webhook: payment_intent.succeeded → confirm sale, release lock, issue ticket. payment_intent.payment_failed → release lock back to pool. Idempotency key = lock_id.$q$, array[]::uuid[]
from system_design_topics where slug = $q$ticketmaster-limited-inventory$q$;

-- ===== TOPIC: Instacart — Real-Time Grocery Inventory =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$instacart-real-time-grocery-inventory$q$, $q$Instacart — Real-Time Grocery Inventory$q$, 'hard', $q$Design grocery inventory that reflects real store shelves: items can be OOS at any moment, quantities are imprecise, and shoppers need real-time guidance.$q$, $q$Soft inventory accepts over-selling risk in exchange for simplicity. Substitution complexity (customer preferences, allergies, dietary restrictions) makes naive 'similar item' insufficient — ML model on product attributes outperforms rule-based.$q$, array[$q$How do you handle a customer allergy conflicting with a shopper's substitution?$q$,$q$How do you prevent two shoppers from grabbing the last item for different orders?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Soft vs Hard Inventory$q$, $q$Unlike warehouse inventory, grocery store quantities are probabilistic (shopper-reported). Maintain a confidence_score per item per store. Decrement on order placement (soft reserve), update on shopper scan. Crowdsource corrections: shopper marks 'out of stock' → update all pending orders for that SKU at that store.$q$, array[]::uuid[]
from system_design_topics where slug = $q$instacart-real-time-grocery-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Real-Time Sync$q$, $q$Shopper app → Inventory Update Service → WebSocket push to customer app. Customer sees live updates: 'Your shopper couldn't find X, they're looking for a substitute.' Redis pub/sub channel per order_id for real-time events.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$instacart-real-time-grocery-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Substitution Engine$q$, $q$Pre-compute substitution graph per SKU: (semantic similarity of product name + category + nutritional profile + price band). On OOS: Substitution Service returns ranked substitutes. Customer can pre-approve 'smart substitutions' or must approve in real-time (2-min timeout).$q$, array[]::uuid[]
from system_design_topics where slug = $q$instacart-real-time-grocery-inventory$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Payments + Stripe$q$, $q$Authorize Stripe hold for estimated total at checkout. Final charge after delivery (actual items picked). If order changes >20% of estimated amount: re-authorize. Use Stripe's incremental authorization for grocery (supported for Visa/MC). Refund for OOS items not substituted.$q$, array[]::uuid[]
from system_design_topics where slug = $q$instacart-real-time-grocery-inventory$q$;

-- ===== TOPIC: Cinemark — Theater Seat Booking =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$cinemark-theater-seat-booking$q$, $q$Cinemark — Theater Seat Booking$q$, 'hard', $q$Design movie seat booking: 50 screens × 200 seats, multiple showtimes/day. Prevent double booking. Handle group seating (contiguous seats). Integrate with Stripe.$q$, $q$SELECT FOR UPDATE (pessimistic locking) is simpler and correct for low-contention scenarios like seat booking. Optimistic locking with retries works too but needs careful handling of the group-seat case where partial success is invalid.$q$, array[$q$How do you handle a Stripe webhook arriving twice (duplicate)?$q$,$q$How do you implement dynamic pricing (weekend premium)?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Seat Model$q$, $q$seat(theater_id, showtime_id, row, col, status: AVAILABLE|LOCKED|SOLD, locked_by_session, lock_expiry). Composite PK = (showtime_id, row, col). ACID transactions: SELECT FOR UPDATE on target seats, validate all AVAILABLE, UPDATE to LOCKED, COMMIT. Serializable isolation.$q$, array[]::uuid[]
from system_design_topics where slug = $q$cinemark-theater-seat-booking$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Contiguous Seat Finder$q$, $q$Query: for showtime X, find N contiguous available seats in same row. SQL: window function (ROW_NUMBER over available seats, partitioned by row, ordered by col). Find runs of N where consecutive. Pre-compute and cache availability per showtime.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$cinemark-theater-seat-booking$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Session + Lock Timeout$q$, $q$Lock expires in 10 minutes. Background job (every 30s): UPDATE seats SET status=AVAILABLE WHERE status=LOCKED AND lock_expiry < NOW(). WebSocket pushes seat-map diffs to all clients viewing same showtime.$q$, array[]::uuid[]
from system_design_topics where slug = $q$cinemark-theater-seat-booking$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Stripe Integration$q$, $q$Lock seats → create Stripe PaymentIntent (amount = seats × price + convenience fee, metadata includes showtime_id, seat_ids). On payment_intent.succeeded webhook → ACID transaction: UPDATE seats SET status=SOLD, INSERT order record. On payment failure → release locks. Idempotent webhook handler (check if order already exists).$q$, array[]::uuid[]
from system_design_topics where slug = $q$cinemark-theater-seat-booking$q$;

-- ===== TOPIC: Video Upload Pipeline =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$video-upload-pipeline$q$, $q$Video Upload Pipeline$q$, 'hard', $q$Design YouTube's video upload: accept raw video from any device, transcode to multiple resolutions (240p–4K), generate thumbnails, and make available within 10 minutes of upload for 500 hours of video uploaded per minute.$q$, $q$Parallel transcoding reduces time-to-availability but increases compute cost. AV1 is 30% smaller than H.264 but 10× slower to encode — use for popular videos, skip for fresh uploads.$q$, array[$q$How do you handle upload of a corrupted video mid-chunk?$q$,$q$How do you prioritize transcoding for live events vs normal uploads?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Chunked Upload$q$, $q$Client splits video into 5MB chunks. Resumable upload protocol (similar to GCS Resumable): POST to Upload Service to get upload_id, PUT each chunk with byte range. Upload Service writes chunks to S3 with multipart upload. On final chunk: emit 'upload_complete' event to Kafka.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$video-upload-pipeline$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Transcoding Pipeline$q$, $q$Transcoding Orchestrator consumes Kafka event → creates DAG of tasks: (1) Extract audio, (2) Extract keyframes, (3) Transcode to [240p, 360p, 480p, 720p, 1080p, 1440p, 2160p] in parallel. Each resolution = separate worker pod. Workers pull from job queue (SQS). Output written to S3 per resolution.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$video-upload-pipeline$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Adaptive Bitrate (ABR)$q$, $q$Each resolution encoded into fixed-duration segments (2–10s) in HLS (.m3u8 + .ts) or DASH (.mpd + .mp4 frag) format. Master manifest lists all variants + bandwidth hints. Player (e.g. hls.js) selects resolution based on measured throughput, switches segment-by-segment.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-upload-pipeline$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Codec & Quality$q$, $q$H.264 for broad compatibility, H.265/HEVC for 4K (50% size reduction), VP9/AV1 for web (royalty-free). Two-pass encoding for VOD (better quality at same bitrate). CRF (Constant Rate Factor) targeting VMAF score ≥90. Hardware transcoding: NVIDIA T4 GPUs via FFmpeg NVENC.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-upload-pipeline$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$CDN Distribution$q$, $q$Transcoded segments pushed to origin S3. CDN (CloudFront) edge nodes cache segments at PoPs near users. Cache-key = (video_id, resolution, segment_number). Long TTL (30 days) since segments are immutable. Origin shield reduces S3 load.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$video-upload-pipeline$q$;

-- ===== TOPIC: Video Streaming =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$video-streaming$q$, $q$Video Streaming$q$, 'hard', $q$Stream a video at the right quality for any device and network condition. Handle 1B daily streams with <3s startup, <1% buffering ratio.$q$, $q$Smaller segments = lower latency but more HTTP requests. Larger segments = better compression but higher startup latency. 6s is common sweet spot for VOD.$q$, array[$q$How do you handle a CDN edge node failing mid-stream?$q$,$q$How do you implement chapter markers and seeking for a 3-hour video?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Playback Initiation$q$, $q$Client requests manifest URL from API Gateway → Video Metadata Service returns master manifest (with resolution variants and CDN-signed URLs). Player fetches manifest → selects starting resolution based on first-segment probe or user's historical bandwidth.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$video-streaming$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$ABR Algorithm$q$, $q$Buffer-based ABR (BOLA/BELLE): track buffer level, available bandwidth estimate. If buffer < 10s: drop to lower bitrate. If buffer > 30s and bandwidth stable: step up resolution. Switches happen on segment boundaries, not mid-segment. Hysteresis prevents thrashing.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-streaming$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$CDN Layer$q$, $q$Edge nodes store popular segments. Long-tail segments served from origin. Anycast DNS routes user to nearest PoP. TCP BBR congestion control on edge-to-client. HTTP/2 multiplexing to reduce connection overhead per segment request.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$video-streaming$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$DRM$q$, $q$Widevine (Android/Chrome), FairPlay (iOS/Safari), PlayReady (Windows). License Server issues AES-128 decryption keys after validating auth token. Keys stored in HSM. Segments encrypted at segment level; keys unique per content + user tier.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-streaming$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Live Streaming Delta$q$, $q$Live: encoder → RTMP → Ingest Servers → low-latency transcoding (1-2s segments instead of 6-10s). DVR window: keep last 4 hours of segments. Low-Latency HLS (LL-HLS) / DASH-LL reduces latency to 2-3s vs 10-30s for standard HLS.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-streaming$q$;

-- ===== TOPIC: Video Feed (TikTok / Reels) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$video-feed-tiktok-reels$q$, $q$Video Feed (TikTok / Reels)$q$, 'hard', $q$Design an infinite vertical video feed where the next video is already playing before the user swipes. <200ms transition time. 1B DAU.$q$, $q$Preloading 3 videos ahead = 3× bandwidth consumption for user. Mobile data cost is real. Adaptive preloading: on WiFi prefetch 3, on 4G prefetch 1, on 3G no prefetch.$q$, array[$q$How do you handle a user with no watch history (cold start)?$q$,$q$How do you detect and surface 'breakout' viral videos in real-time?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Preloading Strategy$q$, $q$Client preloads N+1 and N+2 videos while user watches N. Prefetch service: given current video_id + user_id, call Recommendation Service for next 3 videos. Background fetch of first 2 segments of each. Store in client-side segment buffer. On swipe: instant play from buffer.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-feed-tiktok-reels$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Feed Service$q$, $q$Feed Service maintains a candidate pool of ~200 ranked videos per user (refreshed every 5 min or on scroll to bottom). Returns paginated cursor. Each page = 5–10 videos with metadata and CDN URLs. Cursor-based pagination (not offset) for stable results as new videos are added.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$video-feed-tiktok-reels$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Video Metadata$q$, $q$Per-video: video_id, author_id, cdn_base_url, duration, aspect_ratio, thumbnail_url, loop_point. CDN URL signed with 1-hour expiry (renewable). Metadata cached in Redis per user session to avoid DB hit on every swipe.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$video-feed-tiktok-reels$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Recommendation$q$, $q$Two-tower model: user embedding + video embedding → dot product score. User features: watch history, completions, shares, follows. Video features: audio features, visual features, caption text, engagement velocity. Real-time signals merged with batch embeddings. A/B tested via experiment framework.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-feed-tiktok-reels$q$;

-- ===== TOPIC: Video Recommendations =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$video-recommendations$q$, $q$Video Recommendations$q$, 'hard', $q$Design YouTube's recommendation system: 'Up Next' sidebar + homepage recommendations. Must balance exploration vs exploitation, filter inappropriate content, and update based on real-time watch signals.$q$, $q$Two-stage (retrieval + ranking) is standard because running a heavy ranker on billions of videos is infeasible. Retrieval trades recall for efficiency; ranking trades efficiency for precision.$q$, array[$q$How do you handle a new video with zero history (cold start)?$q$,$q$How do you evaluate recommendation quality offline vs online?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Candidate Generation$q$, $q$Matrix factorization or Two-Tower DNN generates top-K (~500) candidate videos from corpus of billions. User tower: user_id embedding + watch history + demographics. Video tower: video_id embedding + content features. Approximate Nearest Neighbor (FAISS/ScaNN) for retrieval.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-recommendations$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Ranking Model$q$, $q$Wide & Deep or Transformer-based ranker scores 500 candidates → top 10. Features: (user, video, context) cross-features. Predicts: P(watch >50%), P(like), P(share), P(not-interested). Multi-objective: weighted sum of signals. Output: ranked list.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-recommendations$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Real-Time Signals$q$, $q$Kafka stream of watch events (start, 25%, 50%, 75%, complete, skip). Flink job computes rolling features: avg watch duration last 7 days, top categories last 24h. Feature Store (Redis + offline Hive) serves fresh features to ranking model at <10ms.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$video-recommendations$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Diversity & Freshness$q$, $q$MMR (Maximal Marginal Relevance): re-rank to reduce topic clustering. Freshness boost: multiply score by recency_factor = e^(-age_days/7). Exploration budget: 10% of recommendations are 'explore' picks outside user's usual categories.$q$, array[]::uuid[]
from system_design_topics where slug = $q$video-recommendations$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Safety Layer$q$, $q$Policy classifier runs on every candidate. Multi-label: nudity, violence, misinformation, hate speech. Soft filters (reduce score) vs hard filters (remove). Human review queue for borderline cases. Regional policy variations.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$video-recommendations$q$;

-- ===== TOPIC: Distributed Rate Limiter (Enterprise Multi-Tenant) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$distributed-rate-limiter-enterprise-multi-tenant$q$, $q$Distributed Rate Limiter (Enterprise Multi-Tenant)$q$, 'hard', $q$Design a rate limiter for a SaaS API platform: per-tenant limits, per-endpoint limits, global limits. 100K tenants, 1M requests/sec total. Low latency (<5ms overhead). Fair queuing across tenants.$q$, $q$Redis-centralized counting is accurate but adds latency. Token gossip/local counters are faster but can allow burst overages. Choose based on SLA strictness. For metered billing, accuracy matters; for abuse prevention, approximate is fine.$q$, array[$q$How do you rate limit by IP for unauthenticated requests?$q$,$q$How do you handle a Redis node failure?$q$,$q$How would you implement per-user limits within a tenant?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Algorithm: Token Bucket$q$, $q$Each (tenant_id, endpoint, tier) has a bucket: capacity (burst), refill_rate (steady-state). Redis key: ratelimit:{tenant}:{endpoint}. Lua script (atomic): check tokens_available, if ≥ 1 decrement and return ALLOW + remaining, else return DENY + retry_after. Lua atomicity avoids race conditions without WATCH/MULTI/EXEC overhead.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-rate-limiter-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Sliding Window Log (Premium)$q$, $q$For precise 'N requests per minute' with no burst: store timestamps of recent requests in Redis sorted set (score = timestamp). ZREMRANGEBYSCORE to expire old entries, ZCARD to count, ZADD if count < limit. More accurate than fixed window but higher memory (O(N) per user).$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-rate-limiter-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Multi-Tenant Config$q$, $q$Tenant config stored in Config Service (backed by Postgres + Redis cache). Tenant tiers: Free (100 req/min), Pro (10K req/min), Enterprise (custom). Config hot-reload via Kafka change events to Rate Limiter nodes. Endpoint-level overrides: /api/export limited more strictly than /api/read.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-rate-limiter-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Distributed Enforcement$q$, $q$Rate Limiter runs as sidecar or as dedicated service. Multiple Rate Limiter nodes each see subset of traffic. Problem: a tenant could get N×rate if requests are distributed across N nodes. Solution: (a) Consistent hash routing by tenant_id to a Rate Limiter shard, or (b) Redis central counter (accepts ~5ms Redis RTT overhead), or (c) Token gossip: nodes sync token grants every 100ms (approximate, suitable for high-burst tolerance).$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-rate-limiter-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Response Headers + Queuing$q$, $q$Return X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, Retry-After. For Enterprise: priority queue — when tenant is rate-limited, queue excess requests (Redis List) and drain as tokens refill. Max queue depth = 100 requests; beyond that → 429.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-rate-limiter-enterprise-multi-tenant$q$;

-- ===== TOPIC: Distributed Job Scheduler (Enterprise Multi-Tenant) =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$distributed-job-scheduler-enterprise-multi-tenant$q$, $q$Distributed Job Scheduler (Enterprise Multi-Tenant)$q$, 'hard', $q$Design a job scheduler like AWS EventBridge Scheduler or Airflow: support cron jobs, one-off delayed jobs, job dependencies (DAGs), and multi-tenant isolation. 10M scheduled jobs, 100K tenants, sub-second scheduling accuracy.$q$, $q$Polling DB every second at scale causes write amplification. Alternative: time-sorted priority queue in Redis (ZADD score=next_run_timestamp, ZPOPMIN) — faster but less durable. Hybrid: Redis as fast scheduling buffer, Postgres as source of truth.$q$, array[$q$How do you guarantee at-least-once execution vs exactly-once?$q$,$q$How do you handle a job that runs for 6 hours and the worker dies?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Scheduler Core$q$, $q$Jobs stored in Postgres: job(id, tenant_id, schedule_cron, next_run_at, status, payload, max_retries). Poller (every 1s): SELECT FOR UPDATE SKIP LOCKED WHERE next_run_at <= NOW() AND status=SCHEDULED LIMIT 500. Claimed jobs → enqueued to Kafka partitioned by tenant_id. next_run_at updated for recurring jobs. SKIP LOCKED enables multi-poller without contention.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$distributed-job-scheduler-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Distributed Locking$q$, $q$Each Scheduler node acquires a leader lock (Zookeeper/etcd ephemeral node or Redis Redlock). Only leader runs the poller. On leader failure, standby acquires lock within election_timeout (3s). Follower nodes only execute jobs, not schedule. Prevents duplicate scheduling.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-job-scheduler-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Execution Workers$q$, $q$Workers consume from Kafka. Each job = isolated execution in k8s Job or Lambda. Worker reports job_status (RUNNING, SUCCESS, FAILED) back via Kafka. Job Service updates DB. Retry with exponential backoff: delay = min(2^attempt × base_delay, max_delay). Dead letter queue after max_retries.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$distributed-job-scheduler-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Multi-Tenant Isolation$q$, $q$Kafka topics partitioned by tenant_id. Worker pools have dedicated partitions per Enterprise tenant (noisy-neighbor prevention). Resource quotas: max concurrent jobs per tenant (enforced via semaphore in Redis). Rate limit job submissions per tenant.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-job-scheduler-enterprise-multi-tenant$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$DAG Execution$q$, $q$Dependencies: job stores depends_on=[job_id_list]. DAG Engine: on job SUCCESS, check if all dependencies of downstream jobs are met. If yes, enqueue downstream job. Store DAG state in Redis (fast) + Postgres (durable). Cycle detection at DAG creation time (DFS).$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$distributed-job-scheduler-enterprise-multi-tenant$q$;

-- ===== TOPIC: Web Crawler — Wikipedia & Full Web =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$web-crawler-wikipedia-full-web$q$, $q$Web Crawler — Wikipedia & Full Web$q$, 'hard', $q$Design a crawler that can index Wikipedia (6M articles) and scale to the full web (50B+ URLs). Handle politeness (robots.txt), deduplication, re-crawl scheduling, and multi-tenant white-label crawl service.$q$, $q$Bloom filter accepts false positives (skip some new URLs) to save memory. For Wikipedia, accuracy matters more — use exact URL set in Redis. For full web, false positive rate of 0.1% is acceptable.$q$, array[$q$How do you handle JavaScript-rendered pages (SPAs)?$q$,$q$How do you detect and prevent crawl traps (infinitely generated URLs)?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$URL Frontier$q$, $q$Priority queue of URLs to crawl. Organized as: (1) per-host queues (politeness — one request/host/second), (2) priority tiers (PageRank estimate, recency). Frontier backed by Redis sorted sets (score = priority × recency) + Postgres for durable large-scale storage. Separate frontier per tenant.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Fetcher$q$, $q$Distributed fetcher fleet (k8s pods). Each pod owns a set of host queues. Respects robots.txt (cached per host, TTL=24h). Throttles per host: 1 req/sec default, faster for allowed domains. Handles redirects, retries on 429/503 with exponential backoff. User-Agent rotation per tenant.$q$, array[]::uuid[]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Deduplication$q$, $q$URL dedup: Bloom filter (100B items, ~2GB at 1% FP rate) checks if URL seen. Near-duplicate content: SimHash fingerprint of page text (64-bit hash). If Hamming distance(new, stored) < 3: duplicate. Bloom filter for fast rejection, SimHash for content-level dedup.$q$, array[]::uuid[]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Content Processing Pipeline$q$, $q$Fetched HTML → Content Extractor (Readability/Trafilatura) → Text Cleaning → Language Detection → Chunking → Embedding (sentence-transformers or OpenAI) → Index (Elasticsearch / vector DB). Link Extractor: parse href tags, normalize URLs, add to frontier.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Multi-Tenant Enterprise$q$, $q$Each tenant gets: isolated frontier, configurable crawl rules (domain whitelist/blacklist, depth limit, rate), data isolation (separate indexes or tenant_id partitioning). Usage metered: pages crawled/month. Tenant API: submit seed URLs, query crawl status, retrieve indexed content.$q$, array[]::uuid[]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 6, $q$Re-Crawl Scheduling$q$, $q$Re-crawl frequency based on content change rate. Monitor: compare SimHash of new crawl vs stored → if different, mark as changed. Adapt schedule: if page changes daily, re-crawl daily; static pages: monthly. Store (url, last_crawl_ts, change_frequency, next_crawl_ts) in Postgres.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$web-crawler-wikipedia-full-web$q$;

-- ===== TOPIC: Uber / AV Ride Matching =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$uber-av-ride-matching$q$, $q$Uber / AV Ride Matching$q$, 'hard', $q$Design Uber's ride matching: match a rider to the nearest available driver within 5 seconds. Handle 10M concurrent drivers, surge pricing, and autonomous vehicle (AV) dispatch.$q$, $q$Geohash has discontinuity at cell boundaries (two nearby points can have very different geohashes). S2/H3 handle this better. For Uber's scale, H3 was chosen precisely to handle the boundary problem and enable consistent hexagon-based analytics.$q$, array[$q$How do you handle driver GPS spoofing?$q$,$q$How does the matching change for carpooling (multiple riders in one car)?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Location Storage with Geohash$q$, $q$Driver location updates every 4s → Location Service. Storage: Redis GEOADD (backed by sorted set with geohash score). Query: GEORADIUS(lat, lng, 2km) returns nearby driver IDs. Geohash precision 6 (~1.2km cells) for initial filter, then compute exact Haversine distance for top candidates. Partition Redis by Geohash prefix for global scale.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$S2 / H3 Alternative$q$, $q$S2 (Google): hierarchical spherical geometry. Level-13 cells ≈ 1km². Efficient range queries without edge discontinuities of Geohash. H3 (Uber): hexagonal hierarchical grid. Hexagons have more uniform neighbor distance. Use H3 resolution 9 (~0.1km²) for dense cities. Store driver→cell mapping in Redis Hash.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Matching Engine$q$, $q$On ride request: (1) Find candidate drivers in radius (GEORADIUS), (2) Filter by: available status, vehicle type, rating, ETA. (3) Score: w1/ETA + w2*rating + w3*acceptance_rate. (4) Send dispatch to top-3 drivers simultaneously. First ACCEPT wins. Offer expires in 15s → try next batch.$q$, array[]::uuid[]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$AV Dispatch Delta$q$, $q$AVs have no 'acceptance' — fleet management system assigns. Matching considers: battery level, route efficiency, maintenance schedule. AV dispatcher = centralized optimizer (Hungarian algorithm for batch assignment every 10s). AV communicates via V2X or cellular. Fallback: human remote operator pool.$q$, array[]::uuid[]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Surge Pricing$q$, $q$Supply/demand ratio per H3 cell (resolution 7, ~5km²). If demand > 2× supply: surge multiplier = f(demand/supply). Surge computed every 1 minute by Pricing Service. Displayed to rider before confirming. Driver incentive bonuses in surge areas to attract supply.$q$, array[]::uuid[]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 6, $q$ETA Computation$q$, $q$Routing Service (OSRM/Google Maps API): compute drive time from driver's current location to pickup, then pickup to destination. Real-time traffic data from HERE or TomTom, blended with Uber's own aggregate GPS trace data. ML correction on top of routing engine for time-of-day/day-of-week patterns.$q$, array[]::uuid[]
from system_design_topics where slug = $q$uber-av-ride-matching$q$;

-- ===== TOPIC: Location Heat Map =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$location-heat-map$q$, $q$Location Heat Map$q$, 'hard', $q$Design a real-time location heat map showing driver/user density across a city. Refresh every 30s. Support zoom levels 1–20. 10M data points per city.$q$, $q$Pre-rendered tiles: fast delivery, static granularity. Dynamic cell queries: flexible zoom, more server computation. Hybrid: pre-render for standard zoom levels, dynamic for analytical dashboards.$q$, array[$q$How do you handle a city with 100M pings/hour?$q$,$q$How do you add a time-slider to show historical density?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Data Ingestion$q$, $q$Location pings from 10M drivers/users → Kafka. Flink consumer aggregates: count events per H3 cell (resolution varies by zoom level) in 30s tumbling windows. Writes aggregated counts to Redis Hash: HSET heatmap:{city}:{zoom}:{timestamp} {cell_id} {count}. TTL = 5 minutes.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$location-heat-map$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Zoom Level Mapping$q$, $q$H3 resolution 5 (zoom 8–10, ~252km²), res 7 (zoom 11–13, ~5km²), res 9 (zoom 14–16, ~0.1km²), res 11 (zoom 17–19, ~0.001km²). Client request includes viewport bounds + zoom level → server computes overlapping H3 cells → returns cell_id + count.$q$, array[]::uuid[]
from system_design_topics where slug = $q$location-heat-map$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Tile-Based Delivery$q$, $q$Pre-render heat map tiles (256×256 PNG) for standard zoom/tile coordinates (XYZ scheme). Tile generation: Flink → writes to S3 every 30s. CDN serves tiles. Client (Mapbox/Leaflet) requests tiles like standard map layers. Cache-key: {zoom}/{x}/{y}/{timestamp_bucket}.$q$, array[(select id from components where slug = 'cdn')]
from system_design_topics where slug = $q$location-heat-map$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Real-Time Updates$q$, $q$For live dashboard: WebSocket subscription to a city+zoom. Server pushes diff (changed cell counts) every 30s. Client re-colors changed H3 cells. Colormap: logarithmic scale (green→yellow→red) normalized to max density in viewport.$q$, array[]::uuid[]
from system_design_topics where slug = $q$location-heat-map$q$;

-- ===== TOPIC: IoT — Sending Messages to Devices =====
insert into system_design_topics (slug, name, difficulty, description, tradeoffs, followup_questions) values ($q$iot-sending-messages-to-devices$q$, $q$IoT — Sending Messages to Devices$q$, 'hard', $q$Design a message delivery system for 100M IoT devices (sensors, smart home, vehicles). Devices can be online/offline. Messages must be delivered reliably. Support device commands (bidirectional), telemetry ingestion, and device groups.$q$, $q$MQTT QoS 2 (exactly-once) has highest overhead (4 messages per delivery). Most IoT systems use QoS 1 with idempotent message handlers. Device Shadow decouples command sending from device availability — the key pattern for reliable IoT.$q$, array[$q$How do you handle a firmware OTA update rollout to 10M devices?$q$,$q$How do you detect a device that's online but not sending telemetry?$q$]);

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 1, $q$Protocol Layer: MQTT$q$, $q$MQTT over TCP (or MQTT over WebSocket for browser devices). Lightweight pub/sub protocol designed for constrained networks. QoS levels: 0 (at most once), 1 (at least once, with ACK), 2 (exactly once, 4-way handshake). Broker: EMQX or HiveMQ (horizontally scalable). 100M devices → cluster of 500 broker nodes.$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 2, $q$Device Shadow / Twin$q$, $q$Each device has a Shadow document: {desired: {brightness: 80}, reported: {brightness: 60}, delta: {brightness: 80}}. Device subscribes to shadow/update/delta topic. When desired ≠ reported: broker pushes delta to device. Device applies change, updates reported. Enables offline command delivery: shadow stores desired state, device syncs on reconnect.$q$, array[]::uuid[]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 3, $q$Command Fan-out$q$, $q$Send command to device group (e.g., 'turn off all lights in building 3'): (1) Resolve group → list of device_ids (from Device Registry), (2) Fan-out Service publishes to each device's command topic, (3) Track delivery: per-device ACK. For 100K devices in a group: use group MQTT topic (all devices in group subscribe). Multi-level topic hierarchy: devices/{building}/{floor}/{device_id}/cmd.$q$, array[]::uuid[]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 4, $q$Telemetry Ingestion$q$, $q$Devices publish sensor data → MQTT broker → Kafka (bridge via Kafka MQTT Source Connector). Kafka consumers: (a) Time-series DB (InfluxDB/TimescaleDB) for storage, (b) Stream processor (Flink) for real-time anomaly detection, (c) S3 for raw archive. Schema: {device_id, timestamp, metric, value}. Compression: CBOR/MessagePack instead of JSON (3× smaller).$q$, array[(select id from components where slug = 'message-queue')]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 5, $q$Offline Handling$q$, $q$MQTT persistent sessions: broker stores QoS≥1 messages for offline clients (configurable retention window, e.g. 24h). Device Shadow: desired state persisted in DB; pushed on reconnect. For critical commands: Command Service polls pending commands on device CONNECT event. Expiry: commands older than TTL discarded.$q$, array[(select id from components where slug = 'database')]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

insert into system_design_steps (topic_id, step_order, title, content, component_ids)
select id, 6, $q$Geospatial Routing (IoT + Maps)$q$, $q$For location-emitting devices (vehicles, assets): device publishes GPS coordinates → MQTT → Kafka → Location Service → stores in PostGIS / Redis GEO. Query: find all devices within H3 cell or polygon (geofencing). Geofence triggers: when device enters/exits polygon → trigger alert via notification service.$q$, array[(select id from components where slug = 'cache')]
from system_design_topics where slug = $q$iot-sending-messages-to-devices$q$;

