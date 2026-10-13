(function () {
  "use strict";

  function layout() {
    const signOutButton = document.querySelector(".auth-signout");
    document.body.innerHTML = `<header class="simple-header"><div><h1>Roteiro de Visitas</h1><p>Organize seu roteiro por cidade, dia e horário.</p></div></header><main class="simple-home"><section class="home-card"><label for="homeCity">Cidade atual</label><select id="homeCity"><option value="">Selecione uma cidade</option><option value="all">Todas as cidades</option></select></section><a id="nowLink" class="now-cta" href="agora.html"><strong>🕒 Quem posso visitar agora?</strong><span>Mostra oportunidades pelo horário atual de Mato Grosso.</span></a><section class="home-card"><label for="quickSearch">Busca rápida</label><input id="quickSearch" type="search" placeholder="Médico, clínica ou especialidade"><p class="home-note">A busca completa será aberta na agenda.</p></section><div class="quick-grid"><a id="agendaLink" class="quick-link" href="index.html?view=list">📋 Agenda por dia</a><a class="quick-link" href="clinicas.html">🏥 Médicos e clínicas</a><a class="quick-link" href="editar.html">✏️ Adicionar ou editar</a><a class="quick-link" href="index.html?view=map">🗺️ Mapa</a></div><p class="home-note">Os horários cadastrados representam oportunidades de visita e não confirmam a presença ou disponibilidade do médico.</p></main>`;
    if (signOutButton) document.body.appendChild(signOutButton);
  }

  async function start() {
    layout();
    const select = document.getElementById("homeCity");
    const agenda = document.getElementById("agendaLink");
    const search = document.getElementById("quickSearch");
    try {
      const { cities } = await ScheduleRepository.loadSchedule();
      cities.forEach(city => select.add(new Option(`${city.name} - ${city.state}`, city.id)));
      const saved = localStorage.getItem("selected_city_id") || "";
      if (saved === "all" || cities.some(city => city.id === saved)) select.value = saved;
    } catch (error) {
      select.innerHTML = '<option value="">Não foi possível carregar cidades</option>';
      select.disabled = true;
    }
    select.addEventListener("change", () => localStorage.setItem("selected_city_id", select.value));
    search.addEventListener("keydown", event => {
      if (event.key !== "Enter") return;
      agenda.href = `index.html?view=list&q=${encodeURIComponent(search.value.trim())}`;
      location.href = agenda.href;
    });
  }
  document.addEventListener("DOMContentLoaded", start);
})();
