# Configuração do Excel Online

Esta integração permite editar médicos no aplicativo e salvar as mudanças diretamente em uma tabela do Excel Online por meio do Microsoft Graph.

## Segurança

- O editor exige login Microsoft.
- A permissão usada é delegada: `Files.ReadWrite`.
- O aplicativo atua em nome do usuário conectado.
- Não crie nem publique um `client secret` neste projeto.
- `Client ID`, `tenant/authority` e `item ID` são configurações públicas do cliente, não senhas.
- O usuário conectado precisa ter permissão para editar o arquivo no OneDrive.

## 1. Arquivo preparado

O arquivo local `AgendaMedicos-Online.xlsx` foi gerado com:

- uma planilha chamada `AgendaMedicos`;
- uma tabela chamada `AgendaMedicos`;
- 80 registros;
- coluna `ID` estável;
- região, clínica, médico, especialidade, agendamento e telefone;
- horários de segunda a sexta-feira;
- coluna `AtualizadoEm`.

Esse arquivo é ignorado pelo Git. Faça o upload manual para o OneDrive da conta que administrará a agenda.

## 2. Registrar o aplicativo

1. Acesse o [Microsoft Entra admin center](https://entra.microsoft.com/).
2. Abra `Aplicativos` → `Registros de aplicativo` → `Novo registro`.
3. Use o nome `Roteiro Cuiabá`.
4. Escolha os tipos de conta que realmente poderão editar.
5. Em plataforma, selecione `Aplicativo de página única (SPA)`.
6. Cadastre o endereço de redirecionamento:

```text
https://maurobraga17.github.io/Roteiro-Cuiaba-MT/editar.html
```

7. Para testes locais, adicione também o endereço HTTPS ou localhost usado no desenvolvimento.
8. Copie o `ID do aplicativo (cliente)`.

Aplicações SPA devem usar o fluxo de código de autorização com PKCE. Não habilite o fluxo implícito e não adicione segredo ao JavaScript.

## 3. Permissões do Microsoft Graph

Em `Permissões de API`, adicione permissões delegadas do Microsoft Graph:

- `User.Read`
- `Files.ReadWrite`

Dependendo das regras da organização, um administrador poderá precisar conceder consentimento.

## 4. Localizar o item ID do Excel

Depois de enviar `AgendaMedicos-Online.xlsx` ao OneDrive:

1. Abra o [Microsoft Graph Explorer](https://developer.microsoft.com/graph/graph-explorer).
2. Entre com a mesma conta.
3. Autorize `Files.ReadWrite`.
4. Execute:

```http
GET https://graph.microsoft.com/v1.0/me/drive/root:/AgendaMedicos-Online.xlsx
```

5. Copie o valor da propriedade `id` retornada.

Se o arquivo estiver em uma pasta, inclua o caminho completo depois de `root:`.

## 5. Configurar o projeto

Edite `config/excel-online.js`:

```javascript
window.excelOnlineConfig = {
  clientId: "ID_DO_APLICATIVO",
  authority: "https://login.microsoftonline.com/common",
  redirectUri: new URL("editar.html", window.location.href).href,
  workbook: {
    itemId: "ID_DO_ARQUIVO_NO_ONEDRIVE",
    tableName: "AgendaMedicos"
  }
};
```

Para restringir o login a uma organização, substitua `common` pelo ID do locatário Microsoft Entra.

## 6. Publicar e testar

1. Publique a configuração no GitHub Pages.
2. Abra `editar.html`.
3. Selecione `Entrar com Microsoft`.
4. Escolha um médico.
5. Altere um campo de teste.
6. Confirme a atualização.
7. Abra o arquivo no Excel Online e confira a linha e a coluna `AtualizadoEm`.
8. Desfaça o teste, se necessário.

## 7. Comportamento do editor

- Carrega até 500 linhas da tabela `AgendaMedicos`.
- Localiza a linha pelo `ID`, não pelo nome.
- Atualiza a linha completa preservando o ID.
- Exige confirmação adicional quando um campo de segunda a sexta é alterado.
- Registra a data e hora em `AtualizadoEm`.
- Mostra erros retornados pelo Microsoft Graph.

## 8. Limitação atual

O editor atualiza o Excel Online imediatamente. A agenda pública continua usando `data/schedule-data.js`; portanto, ela não reflete automaticamente a edição até ocorrer uma nova importação/publicação.

Uma evolução posterior pode usar um fluxo automatizado para validar mudanças no Excel e publicar uma nova base, ou exigir login também para a leitura direta do Excel Online.

## 9. Referências oficiais

- [Fluxos de autenticação MSAL](https://learn.microsoft.com/en-us/entra/identity-platform/msal-authentication-flows)
- [Listar linhas de uma tabela do Excel](https://learn.microsoft.com/en-us/graph/api/table-list-rows?view=graph-rest-1.0)
- [Atualizar uma linha do Excel](https://learn.microsoft.com/en-us/graph/api/tablerow-update?view=graph-rest-1.0)
