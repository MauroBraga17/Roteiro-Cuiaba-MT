window.excelOnlineConfig = {
  clientId: "COLE_AQUI_O_CLIENT_ID",
  authority: "https://login.microsoftonline.com/common",
  redirectUri: new URL("editar.html", window.location.href).href,
  workbook: {
    itemId: "COLE_AQUI_O_ITEM_ID_DO_ARQUIVO",
    tableName: "AgendaMedicos"
  }
};
