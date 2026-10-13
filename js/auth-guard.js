(function () {
  "use strict";
  const style = document.createElement("style");
  style.textContent = ".auth-loading{position:fixed;inset:0;z-index:99999;display:grid;place-items:center;background:#f4f7f9;color:#17324d;font:700 1rem system-ui}.auth-signout{position:fixed;right:12px;top:12px;z-index:9998;min-height:38px;border:1px solid #ffffff99;border-radius:8px;padding:8px 11px;background:#17324de8;color:#fff;font:700 .78rem system-ui;cursor:pointer}";
  document.head.appendChild(style);
  const loading = document.createElement("div");
  loading.className = "auth-loading";
  loading.setAttribute("role", "status");
  loading.textContent = "Verificando acesso…";
  document.documentElement.appendChild(loading);

  async function start() {
    try {
      const session = await window.RoteiroAuth.requireSession();
      if (!session) return;
      loading.remove();
      const button = document.createElement("button");
      button.type = "button";
      button.className = "auth-signout";
      button.textContent = "Sair";
      button.setAttribute("aria-label", "Encerrar sessão");
      button.addEventListener("click", async () => {
        button.disabled = true;
        try {
          await window.RoteiroAuth.getClient().auth.signOut({ scope: "local" });
          location.replace("login.html");
        } catch (error) {
          button.disabled = false;
          alert(error.message || "Não foi possível encerrar a sessão.");
        }
      });
      document.body.appendChild(button);
    } catch (error) {
      loading.textContent = error.message || "Não foi possível verificar o acesso.";
    }
  }
  start();
})();
