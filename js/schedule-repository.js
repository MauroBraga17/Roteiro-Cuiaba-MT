(function () {
  "use strict";

  async function loadSchedule() {
    const client = window.RoteiroAuth.getClient();
    const [citiesResult, doctorsResult, locationsResult, hoursResult] = await Promise.all([
      client.from("cities").select("id,name,state").eq("active", true).order("name"),
      client.from("doctors").select("id,full_name,specialty,updated_at").eq("active", true),
      client.from("practice_locations").select("id,doctor_id,city_id,name,neighborhood,full_address,latitude,longitude,phone,updated_at").eq("active", true),
      client.from("office_hours").select("id,practice_location_id,weekday,starts_at,ends_at,original_label,availability_notes,updated_at").eq("active", true)
    ]);
    const failure = [citiesResult, doctorsResult, locationsResult, hoursResult].find(result => result.error);
    if (failure) throw failure.error;

    const doctors = new Map(doctorsResult.data.map(item => [item.id, item]));
    const locations = new Map(locationsResult.data.map(item => [item.id, item]));
    const visits = [];
    for (const hour of hoursResult.data) {
      const location = locations.get(hour.practice_location_id);
      const doctor = location && doctors.get(location.doctor_id);
      if (!location || !doctor) continue;
      const updates = [hour.updated_at, location.updated_at, doctor.updated_at].filter(Boolean).sort();
      visits.push({
        ...hour,
        city_id: location.city_id,
        doctor_id: doctor.id,
        doctor_name: doctor.full_name,
        specialty: doctor.specialty,
        clinic_name: location.name,
        neighborhood: location.neighborhood,
        full_address: location.full_address,
        latitude: location.latitude,
        longitude: location.longitude,
        phone: location.phone,
        updated_at: updates.length ? updates[updates.length - 1] : null
      });
    }
    return { cities: citiesResult.data, visits };
  }

  window.ScheduleRepository = Object.freeze({ loadSchedule });
})();
