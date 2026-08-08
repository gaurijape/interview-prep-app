-- TinyURL's step titles were written as full sentences, which look cramped
-- as diagram box labels compared to the short names used in later batches
-- (e.g. "Feed Write Path"). Shortening titles only — content is untouched.
update system_design_steps set title = 'Load Balancer'
where title = 'Request hits the Load Balancer';

update system_design_steps set title = 'Rate Limiter'
where title = 'Rate limiting protects the write path';

update system_design_steps set title = 'Cache Check'
where title = 'Reads check the cache first';

update system_design_steps set title = 'Database Write'
where title = 'Database stores the mapping';

update system_design_steps set title = 'CDN Edge Delivery'
where title = 'CDN serves redirects close to the user';
