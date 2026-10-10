(function () {
  const scopes = ["User.Read", "Files.ReadWrite"];
  const columns = ["ID", "Regiao", "Clinica", "Medico", "ESP", "Agendado", "Telefone", "Segunda", "Terca", "Quarta", "Quinta", "Sexta", "AtualizadoEm"];
  let client;
  let account;

  function getConfig() {
    const config = window.excelOnlineConfig;
    if (!config || !config.clientId || config.clientId.includes("COLE_AQUI") || !config.workbook?.itemId || config.workbook.itemId.includes("COLE_AQUI")) {
      throw new Error("Integração ainda não configurada. Preencha config/excel-online.js.");
    }
    return config;
  }

  async function initialize() {
    const config = getConfig();
    client = new msal.PublicClientApplication({ auth: { clientId: config.clientId, authority: config.authority, redirectUri: config.redirectUri }, cache: { cacheLocation: "sessionStorage" } });
    if (typeof client.initialize === "function") await client.initialize();
    const response = await client.handleRedirectPromise();
    account = response?.account || client.getAllAccounts()[0] || null;
    if (account) client.setActiveAccount(account);
    return account;
  }

  async function signIn() {
    if (!client) await initialize();
    const response = await client.loginPopup({ scopes, prompt: "select_account" });
    account = response.account;
    client.setActiveAccount(account);
    return account;
  }

  async function signOut() {
    if (client && account) await client.logoutPopup({ account });
    account = null;
  }

  async function token() {
    if (!account) await signIn();
    try { return (await client.acquireTokenSilent({ scopes, account })).accessToken; }
    catch { return (await client.acquireTokenPopup({ scopes, account })).accessToken; }
  }

  async function graph(path, options = {}) {
    const accessToken = await token();
    const response = await fetch(`https://graph.microsoft.com/v1.0${path}`, { ...options, headers: { Authorization: `Bearer ${accessToken}`, "Content-Type": "application/json", ...(options.headers || {}) } });
    if (!response.ok) {
      const details = await response.json().catch(() => ({}));
      throw new Error(details.error?.message || `Microsoft Graph retornou ${response.status}.`);
    }
    return response.status === 204 ? null : response.json();
  }

  function basePath() {
    const config = getConfig();
    return `/me/drive/items/${encodeURIComponent(config.workbook.itemId)}/workbook/tables/${encodeURIComponent(config.workbook.tableName)}`;
  }

  async function listRecords() {
    const result = await graph(`${basePath()}/rows?$top=500`);
    return (result.value || []).map(row => ({ rowIndex: row.index, ...Object.fromEntries(columns.map((column, index) => [column, row.values?.[0]?.[index] ?? ""])) }));
  }

  async function updateRecord(id, values) {
    const records = await listRecords();
    const record = records.find(item => String(item.ID) === String(id));
    if (!record) throw new Error("Médico não encontrado na tabela AgendaMedicos.");
    const rowValues = columns.map(column => column === "ID" ? record.ID : (values[column] ?? record[column] ?? ""));
    return graph(`${basePath()}/rows/${record.rowIndex}`, { method: "PATCH", body: JSON.stringify({ values: [rowValues] }) });
  }

  window.ExcelOnline = { columns, getConfig, initialize, signIn, signOut, listRecords, updateRecord, getAccount: () => account };
})();
