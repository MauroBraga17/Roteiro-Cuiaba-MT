(function () {
  "use strict";

  const TIME_ZONE = "America/Cuiaba";
  const WEEKDAYS = Object.freeze({ Sun: 7, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 });

  function cuiabaNow(date = new Date()) {
    const parts = Object.fromEntries(new Intl.DateTimeFormat("en-CA", {
      timeZone: TIME_ZONE, weekday: "short", year: "numeric", month: "2-digit",
      day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit", hourCycle: "h23"
    }).formatToParts(date).filter(part => part.type !== "literal").map(part => [part.type, part.value]));
    return {
      weekday: WEEKDAYS[parts.weekday],
      minutes: Number(parts.hour) * 60 + Number(parts.minute),
      dateLabel: `${parts.day}/${parts.month}/${parts.year}`,
      timeLabel: `${parts.hour}:${parts.minute}`
    };
  }

  function timeToMinutes(value) {
    const match = /^(\d{2}):(\d{2})(?::\d{2})?$/.exec(value || "");
    if (!match) return null;
    const hour = Number(match[1]), minute = Number(match[2]);
    return hour <= 23 && minute <= 59 ? hour * 60 + minute : null;
  }

  function classify(hour, clock) {
    const start = timeToMinutes(hour.starts_at);
    const end = timeToMinutes(hour.ends_at);
    if (hour.weekday !== clock.weekday) return "other-day";
    if (start === null) return "confirm";
    if (end !== null) {
      if (clock.minutes >= start && clock.minutes < end) return "now";
      return clock.minutes < start ? "later" : "finished";
    }
    if (clock.minutes === start) return "now";
    return clock.minutes < start ? "later" : "finished";
  }

  function filterByCity(items, cityId) {
    return cityId === "all" ? [...items] : items.filter(item => item.city_id === cityId);
  }

  function sortVisits(items) {
    return [...items].sort((a, b) =>
      (timeToMinutes(a.starts_at) ?? 9999) - (timeToMinutes(b.starts_at) ?? 9999) ||
      (a.neighborhood || "").localeCompare(b.neighborhood || "", "pt-BR") ||
      a.doctor_name.localeCompare(b.doctor_name, "pt-BR")
    );
  }

  window.ScheduleRules = Object.freeze({ TIME_ZONE, cuiabaNow, timeToMinutes, classify, filterByCity, sortVisits });
})();
