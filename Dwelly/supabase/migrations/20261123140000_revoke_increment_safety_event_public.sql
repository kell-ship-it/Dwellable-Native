-- T-307: the safety counter is bumped only by llm-proxy (service role). Functions are
-- executable by PUBLIC by default, which would let any app client inflate the counter.
revoke execute on function public.increment_safety_event(date, text) from public, anon, authenticated;
grant execute on function public.increment_safety_event(date, text) to service_role;
