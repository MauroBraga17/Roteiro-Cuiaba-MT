(function () {
  "use strict";
  let dataset = { cities: [], visits: [] };
  let selectedCity = "";
  let mode = "now";
  let map;
  let markers = [];

  const escapeHtml = value => String(value ?? "").replace(/[&<>'"]/g, char => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;" })[char]);
  const cityName = id => dataset.cities.find(city => city.id === id)?.name || "Cidade não informada";
  const formatTime = visit => visit.starts_at
    ? `${visit.starts_at.slice(0, 5)}${visit.ends_at ? `–${visit.ends_at.slice(0, 5)}` : ""}`
    : (visit.original_label || "Horário a confirmar");

  function updateClock() {
    const clock = ScheduleRules.cuiabaNow();
    document.getElementById("headerClock").textContent = clock.timeLabel;
    document.getElementById("headerDay").textContent = `${clock.dateLabel} · Cuiabá`;
  }

  function buildControls() {
    const host = document.getElementById("regionFilter");
    host.innerHTML = "";
    const select = document.createElement("select");
    select.id = "citySelect";
    select.setAttribute("aria-label", "Selecionar cidade");
    select.style.cssText = "min-height:42px;border:1px solid #d5e0e7;border-radius:9px;padding:8px 10px;background:#fff;font:inherit;font-weight:700";
    select.add(new Option("Selecione uma cidade", ""));
    select.add(new Option("Todas as cidades", "all"));
    dataset.cities.forEach(city => select.add(new Option(`${city.name} - ${city.state}`, city.id)));
    select.value = selectedCity;
    select.addEventListener("change", () => { selectedCity = select.value; localStorage.setItem("selected_city_id", selectedCity); render(); });
    host.appendChild(select);
    [["now", "Agora"], ["later", "Mais tarde"]].forEach(([value, label]) => {
      const button = document.createElement("button");
      button.className = `region-chip${mode === value ? " active" : ""}`;
      button.textContent = label;
      button.addEventListener("click", () => { mode = value; buildControls(); render(); });
      host.appendChild(button);
    });
  }

  function mapDestination(visit) {
    if (visit.latitude !== null && visit.longitude !== null) return `${visit.latitude},${visit.longitude}`;
    const address = [visit.full_address, visit.neighborhood, cityName(visit.city_id), "MT"].filter(Boolean).join(", ");
    return address || null;
  }

  function renderMap(visits) {
    if (!window.L) return;
    if (!map) {
      map = L.map("map").setView([-15.601, -56.098], 12);
      L.tileLayer("https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}", { attribution: "Esri" }).addTo(map);
    }
    markers.forEach(marker => marker.remove());
    markers = visits.filter(visit => visit.latitude !== null && visit.longitude !== null).map(visit =>
      L.marker([visit.latitude, visit.longitude]).addTo(map).bindPopup(`<strong>${escapeHtml(visit.doctor_name)}</strong><br>${escapeHtml(visit.clinic_name)}`)
    );
    if (markers.length) map.fitBounds(L.featureGroup(markers).getBounds().pad(.25), { maxZoom: 15 });
  }

  function render() {
    const list = document.getElementById("nowList");
    if (!selectedCity) {
      list.innerHTML = '<div class="empty-state"><div class="empty-icon">📍</div><h2>Selecione uma cidade</h2><p>A consulta não mistura cidades automaticamente.</p></div>';
      document.getElementById("countText").textContent = "Escolha onde você está";
      document.getElementById("countSub").textContent = "";
      renderMap([]);
      return;
    }
    const clock = ScheduleRules.cuiabaNow();
    const cityVisits = ScheduleRules.filterByCity(dataset.visits, selectedCity);
    const visits = ScheduleRules.sortVisits(cityVisits.filter(visit => ScheduleRules.classify(visit, clock) === mode));
    document.getElementById("countText").textContent = mode === "now" ? `${visits.length} atendimento(s) compatível(is) agora` : `${visits.length} próximo(s) horário(s) hoje`;
    document.getElementById("countSub").textContent = `${clock.timeLabel} no fuso de Mato Grosso`;
    list.innerHTML = "";
    if (!visits.length) {
      list.innerHTML = `<div class="empty-state"><div class="empty-icon">🕒</div><h2>Nenhum atendimento ${mode === "now" ? "compatível agora" : "mais tarde"}</h2><p>${mode === "now" ? "Consulte os próximos horários cadastrados." : "Não há outro horário completo para hoje."}</p></div>`;
      renderMap([]);
      return;
    }
    for (const visit of visits) {
      const destination = mapDestination(visit);
      const address = [visit.full_address, visit.neighborhood].filter(Boolean).join(" · ") || "Endereço não informado";
      const card = document.createElement("article");
      card.className = "doctor-card";
      card.innerHTML = `<div class="card-top"><div class="time-pill">${escapeHtml(formatTime(visit))}</div><div><div class="card-doctor">${escapeHtml(visit.doctor_name)}</div><div class="card-specialty">${escapeHtml(visit.specialty || "Especialidade não informada")}</div></div></div><div class="card-clinic">🏥 ${escapeHtml(visit.clinic_name)}</div><div class="card-region">📍 ${escapeHtml(cityName(visit.city_id))}${visit.neighborhood ? ` · ${escapeHtml(visit.neighborhood)}` : ""}</div><div class="meta-row"><span>${escapeHtml(address)}</span></div><p style="font-size:.72rem;color:#8a4b00;margin:8px 0">Horário cadastrado não confirma presença ou disponibilidade.</p><div class="card-actions">${destination ? `<a class="action-btn maps" href="https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(destination)}" target="_blank" rel="noopener">Google Maps</a><a class="action-btn" href="https://maps.apple.com/?daddr=${encodeURIComponent(destination)}" target="_blank" rel="noopener">Apple Maps</a>` : ""}<a class="action-btn" href="editar.html?doctor=${encodeURIComponent(visit.doctor_id)}">Editar</a></div>`;
      list.appendChild(card);
    }
    renderMap(visits);
  }

  async function start() {
    updateClock();
    document.getElementById("locateBtn").hidden = true;
    document.getElementById("locText").textContent = "Consulta por cidade";
    document.getElementById("locSub").textContent = "Os mapas usam o endereço ou as coordenadas cadastradas.";
    try {
      dataset = await ScheduleRepository.loadSchedule();
      selectedCity = localStorage.getItem("selected_city_id") || "";
      if (selectedCity !== "all" && !dataset.cities.some(city => city.id === selectedCity)) selectedCity = "";
      buildControls();
      render();
      setInterval(() => { updateClock(); render(); }, 60000);
    } catch (error) {
      document.getElementById("countText").textContent = "Não foi possível sincronizar";
      document.getElementById("countSub").textContent = "Confira sua conexão e tente novamente.";
      document.getElementById("nowList").innerHTML = `<div class="empty-state"><h2>Erro ao carregar agenda</h2><p>${escapeHtml(error.message)}</p></div>`;
    }
  }
  document.addEventListener("DOMContentLoaded", start);
})();
