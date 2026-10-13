(function () {
  "use strict";

  function getConfig() {
    const config = window.supabaseConfig;
    const invalid = !config?.url || !config?.publishableKey ||
      config.url.includes("COLE_AQUI") || config.publishableKey.includes("COLE_AQUI");
    if (invalid) throw new Error("Supabase ainda não configurado. Consulte SUPABASE-SETUP.md.");
    if (!/^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(config.url)) {
      throw new Error("A URL pública do Supabase é inválida.");
    }
    return config;
  }

  function getClient() {
    if (window.roteiroSupabase) return window.roteiroSupabase;
    if (!window.supabase?.createClient) throw new Error("Biblioteca do Supabase indisponível.");
    const config = getConfig();
    window.roteiroSupabase = window.supabase.createClient(config.url, config.publishableKey, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
    });
    return window.roteiroSupabase;
  }

  async function requireSession() {
    const client = getClient();
    const { data, error } = await client.auth.getSession();
    if (error) throw error;
    if (!data.session) {
      const target = encodeURIComponent(location.pathname.split("/").pop() + location.search);
      location.replace(`login.html?next=${target}`);
      return null;
    }
    return data.session;
  }

  window.RoteiroAuth = Object.freeze({ getConfig, getClient, requireSession });
})();
