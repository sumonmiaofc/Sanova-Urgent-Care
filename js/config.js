/* =========================================================
   SANOVA BLOG — Supabase Config & Shared Utilities
   ========================================================= */

const SUPABASE_URL = 'https://fogkdxevecwnqbmezdnu.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZvZ2tkeGV2ZWN3bnFibWV6ZG51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NDg0NzgsImV4cCI6MjA4NTUyNDQ3OH0.Gy8nDxKZFvPHrp2-r7bQILCn-zl0QmH5bb52tIVDOv0';

const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

/* ---- Auth helpers ---- */
async function requireAuth(redirectTo = '/admin/login.html') {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) { location.href = redirectTo; return null; }
  return session;
}

async function getUser() {
  const { data: { session } } = await sb.auth.getSession();
  return session?.user || null;
}

/* ---- Date helpers ---- */
function fmtDate(d, opts = {}) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('en-US', {
    month: 'long', day: 'numeric', year: 'numeric', ...opts
  });
}

function fmtDateShort(d) {
  if (!d) return '—';
  return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

function timeAgo(d) {
  if (!d) return '';
  const s = Math.floor((Date.now() - new Date(d)) / 1000);
  if (s < 60) return 'just now';
  if (s < 3600) return Math.floor(s/60) + 'm ago';
  if (s < 86400) return Math.floor(s/3600) + 'h ago';
  return Math.floor(s/86400) + 'd ago';
}

/* ---- Slug generator ---- */
function makeSlug(text) {
  return text.toLowerCase().trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');
}

/* ---- Reading time ---- */
function readingTime(html) {
  const text = html?.replace(/<[^>]+>/g, '') || '';
  const words = text.trim().split(/\s+/).length;
  return Math.max(1, Math.round(words / 200)) + ' min read';
}

/* ---- Toast notification ---- */
function showToast(msg, type = 'success') {
  let wrap = document.getElementById('toastWrap');
  if (!wrap) {
    wrap = document.createElement('div');
    wrap.id = 'toastWrap';
    wrap.style.cssText = 'position:fixed;top:1.25rem;right:1.25rem;z-index:99999;display:flex;flex-direction:column;gap:.5rem;';
    document.body.appendChild(wrap);
  }
  const t = document.createElement('div');
  const colors = { success: '#15803d', error: '#dc2626', warn: '#a16207', info: '#1d4ed8' };
  t.style.cssText = `background:${colors[type]||colors.info};color:#fff;padding:.85rem 1.5rem;border-radius:10px;font-size:.9rem;font-weight:600;box-shadow:0 8px 24px rgba(0,0,0,.15);animation:slideIn .3s ease;max-width:320px;`;
  t.textContent = msg;
  wrap.appendChild(t);
  setTimeout(() => { t.style.opacity='0'; t.style.transition='opacity .3s'; setTimeout(()=>t.remove(),300); }, 3000);
}

/* ---- Modal confirm ---- */
function confirmModal(title, msg, onConfirm) {
  const backdrop = document.createElement('div');
  backdrop.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:9998;display:flex;align-items:center;justify-content:center;padding:1rem;backdrop-filter:blur(4px);';
  backdrop.innerHTML = `
    <div style="background:#fff;border-radius:16px;padding:2rem;max-width:420px;width:100%;box-shadow:0 24px 64px rgba(0,0,0,.2);">
      <h3 style="font-size:1.2rem;font-weight:700;color:#0f1923;margin-bottom:.75rem;">${title}</h3>
      <p style="color:#64788a;font-size:.95rem;line-height:1.6;margin-bottom:1.75rem;">${msg}</p>
      <div style="display:flex;gap:.75rem;justify-content:flex-end;">
        <button id="modalCancel" style="padding:.7rem 1.5rem;border:1.5px solid #e2eaee;background:#fff;border-radius:8px;font-weight:600;cursor:pointer;font-size:.9rem;">Cancel</button>
        <button id="modalConfirm" style="padding:.7rem 1.5rem;background:#dc2626;color:#fff;border:none;border-radius:8px;font-weight:600;cursor:pointer;font-size:.9rem;">Delete</button>
      </div>
    </div>`;
  document.body.appendChild(backdrop);
  document.getElementById('modalCancel').onclick = () => backdrop.remove();
  document.getElementById('modalConfirm').onclick = () => { backdrop.remove(); onConfirm(); };
  backdrop.addEventListener('click', e => { if(e.target===backdrop) backdrop.remove(); });
}

/* ---- Category color ---- */
function catColor(name) {
  const map = {
    'IV Therapy': '#0d6e7a', 'Urgent Care': '#1d4ed8',
    'Prevention': '#15803d', 'Arizona Health': '#b45309',
    'Insurance & Billing': '#7c3aed', 'Wellness': '#0891b2',
    'Physicals': '#a16207', 'Health Tips': '#0d6e7a',
  };
  return map[name] || '#0d6e7a';
}

/* ---- Track page view ---- */
async function trackView(blogId) {
  await sb.from('blogs').update({ views: sb.rpc('increment') }).eq('id', blogId);
  await sb.from('analytics').insert({ blog_id: blogId, views: 1, visitors: 1 });
}
