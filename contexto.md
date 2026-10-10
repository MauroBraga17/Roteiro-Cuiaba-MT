# Contexto e escopo do projeto

## 1. Identificação

- **Nome:** Roteiro de Visitas — Cuiabá e Várzea Grande
- **Repositório:** `MauroBraga17/Roteiro-Cuiaba-MT`
- **Idioma:** português do Brasil (`pt-BR`)
- **Tipo:** aplicação web progressiva (PWA), responsiva e instalável
- **Público principal:** profissional responsável por organizar e executar visitas médicas durante a semana

## 2. Objetivo

O projeto transforma uma planilha de clínicas e médicos em uma agenda semanal visual. O sistema deve ajudar o usuário a identificar onde pode realizar visitas em cada dia, seguindo a ordem cronológica dos atendimentos e reduzindo o risco de consultar um médico no dia ou horário errado.

A aplicação possui dois modos complementares:

1. **Agenda diária:** mostra os atendimentos do dia em uma linha do tempo global, do menor para o maior horário.
2. **Cadastro por clínica:** mostra todos os registros da planilha, agrupados por clínica e com as colunas completas de segunda a sexta-feira.

## 3. Fonte oficial dos dados

A planilha Excel é a fonte oficial. O arquivo usado na importação atual é:

`Roteiro abril 2026 (1) (1).xlsx`

O arquivo `.xlsx` fica apenas no ambiente local e é ignorado pelo Git por conter dados pessoais. O site consome uma versão estruturada gerada em `data/schedule-data.js`.

Regras da fonte de dados:

- A aba da planilha determina a região.
- Uma linha anterior ao cabeçalho `Médico` determina o nome da clínica.
- Cada médico mantém os campos e horários exatamente na coluna em que aparecem.
- A importação não deve mover horários entre dias.
- Campos vazios permanecem vazios na base e são apresentados como `Não informado` na interface.
- Valores ambíguos ou não padronizados são preservados e sinalizados para revisão.

## 4. Estrutura dos registros

Cada registro importado contém:

- clínica;
- região;
- médico;
- ESP (especialidade);
- agendado (responsável ou status informado na planilha);
- telefone;
- segunda-feira;
- terça-feira;
- quarta-feira;
- quinta-feira;
- sexta-feira;
- aba e linha de origem na planilha, para auditoria.

## 5. Regras críticas de dia e horário

Dia e horário são dados críticos. A aplicação deve obedecer às seguintes regras:

1. Preservar exatamente o valor encontrado na planilha.
2. Nunca transferir automaticamente um médico de um dia para outro.
3. Nunca inventar horários, especialidades, telefones ou status.
4. Abrir no dia atual conforme a data local do aparelho.
5. Exibir a data, o dia da semana e a hora atuais.
6. Permitir seleção manual de qualquer dia da semana.
7. Exibir sábado e domingo como dias sem visitas quando não houver dados.
8. Ordenar globalmente todos os atendimentos do dia pelo primeiro horário informado, independentemente da clínica ou região.
9. Considerar `07:00` como o início operacional do roteiro, sem alterar registros anteriores caso sejam adicionados no futuro.
10. Ordenar intervalos pelo horário inicial. Exemplo: `08:00 às 11:00` é posicionado como `08:00`.
11. Manter textos como `Manhã`, `Tarde`, `Final da tarde`, `Alterna`, `M`, `M-T` ou `X` sem conversão automática.
12. Marcar registros sem horário numérico como `HORÁRIO A CONFIRMAR`.
13. Manter todos os registros que tenham o mesmo horário e mostrar `MESMO HORÁRIO`.
14. Destacar `PRÓXIMA VISITA` apenas quando o dia selecionado for o dia atual e existir um horário numérico futuro.
15. Atualizar o relógio e o cálculo da próxima visita enquanto a aplicação estiver aberta.

## 6. Agenda diária

A página principal é `index.html`.

No topo, a agenda apresenta:

- data atual;
- dia da semana;
- horário atual;
- quantidade de visitas encontradas;
- quantidade de regiões;
- próxima visita, quando aplicável.

Cada card de atendimento apresenta:

- horário em destaque;
- nome da clínica;
- nome do médico;
- especialidade;
- responsável ou status do agendamento;
- telefone clicável quando possuir quantidade válida de dígitos;
- região;
- alertas de horário aproximado, coincidência ou próxima visita.

## 7. Cadastro por clínica

A página `clinicas.html` apresenta os dados agrupados primeiro por região e clínica.

Cada tabela contém as colunas:

1. Médico
2. ESP
3. Agendado
4. Telefone
5. Segunda-feira
6. Terça-feira
7. Quarta-feira
8. Quinta-feira
9. Sexta-feira

A página também apresenta:

- busca por clínica, médico, especialidade ou telefone;
- filtro por região;
- total de registros importados;
- nome do arquivo de origem;
- painel expansível com valores de horário que precisam de revisão;
- indicação `Não informado` para campos vazios.

## 8. Filtros da agenda

A agenda diária permite filtrar por:

- dia da semana;
- período: qualquer horário, manhã ou tarde;
- clínica;
- especialidade;
- situação do campo `Agendado`;
- texto livre para médico, clínica, região, especialidade, agendamento ou telefone.

Intervalos que atravessam 12:00 podem aparecer tanto no filtro da manhã quanto no da tarde. Isso evita ocultar uma visita que permanece disponível nos dois períodos.

## 9. Mapa

O mapa utiliza Leaflet e a camada pública de ruas da Esri.

Características:

- um marcador por região com visitas após os filtros;
- popup com horário, clínica, médico, especialidade e telefone;
- enquadramento automático dos marcadores visíveis;
- coordenadas regionais aproximadas, não coordenadas exatas das clínicas;
- indicador permanente de dia e período no mapa em telas pequenas.

O mapa serve como referência visual regional. Ele não deve ser tratado como navegação exata até que endereços e coordenadas de cada clínica sejam cadastrados e validados.

## 10. Responsividade e acessibilidade

O sistema deve funcionar em celular, tablet e desktop.

No desktop:

- filtros e agenda ficam em uma barra lateral;
- o mapa ocupa a área restante;
- o cadastro por clínica usa tabelas com rolagem horizontal quando necessário.

No celular:

- existe navegação inferior entre `Mapa`, `Agenda` e `Clínicas`;
- mapa e agenda são exibidos separadamente para aproveitar a tela;
- controles possuem tamanho adequado para toque;
- áreas seguras do aparelho são respeitadas;
- a tabela por clínica permite rolagem horizontal.

A interface usa HTML semântico, rótulos nos filtros, regiões com atualização acessível e suporte à preferência de movimento reduzido.

## 11. PWA e funcionamento offline

Arquivos principais do PWA:

- `manifest.webmanifest`: nome, cores, ícones, modo de exibição e atalhos;
- `sw.js`: service worker e estratégia de cache;
- `offline.html`: tela de contingência;
- `icons/`: ícones SVG e PNG.

Comportamento esperado:

- instalação em navegadores compatíveis;
- abertura em modo independente (`standalone`);
- agenda e cadastro disponíveis offline depois do primeiro acesso online;
- reaproveitamento de mapas já carregados quando estiverem no cache;
- indicação visual de estado online ou offline;
- atualização do nome da versão de cache a cada mudança relevante nos arquivos do site.

O PWA precisa ser servido por HTTPS. GitHub Pages atende a esse requisito.

## 12. Importação e atualização dos dados

O importador está em `scripts/import-schedule.ps1`.

Fluxo recomendado:

1. Salvar a planilha atualizada na raiz local do projeto.
2. Manter os cabeçalhos e a estrutura de clínicas da planilha.
3. Executar o importador em modo local:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\import-schedule.ps1 `
  -WorkbookPath ".\Roteiro abril 2026 (1) (1).xlsx" `
  -OutputPath ".\data\schedule-data.js"
```

4. Conferir a quantidade de registros e inconsistências relatadas.
5. Validar visualmente a agenda de cada dia.
6. Conferir especialmente valores não padronizados e médicos que mudaram de dia.
7. Atualizar a versão do cache em `sw.js`.
8. Criar o commit e publicar somente depois da validação.

O importador abre a planilha em modo somente leitura e não modifica o arquivo original.

## 13. Validações obrigatórias antes da publicação

- Confirmar que cada médico está associado ao dia correto.
- Comparar horários e intervalos com as respectivas colunas da planilha.
- Confirmar que a ordenação diária começa pelo menor horário disponível.
- Confirmar que registros simultâneos permanecem visíveis.
- Revisar a lista de horários não padronizados.
- Confirmar especialidade, agendamento e telefone.
- Testar busca e todos os filtros.
- Testar as telas de agenda, mapa e clínicas em largura mobile e desktop.
- Validar `manifest.webmanifest` e arquivos incluídos no cache.
- Executar `git diff --check` antes do commit.

## 14. Inconsistências e correções

Inconsistências encontradas devem ser apresentadas ao usuário com clínica, médico, dia, valor e linha de origem. O sistema não deve corrigir automaticamente:

- abreviações sem significado confirmado;
- horários sem separador ou com múltiplos valores ambíguos;
- textos como `Alterna`, `X`, `Tel`, `M` ou `M-T`;
- valores inseridos em uma coluna aparentemente inadequada;
- duplicidades de clínicas ou médicos.

Uma correção confirmada deve ser feita primeiro na planilha oficial. Depois, os dados devem ser importados novamente para evitar divergência entre a planilha e o aplicativo.

## 15. Privacidade e publicação

O aplicativo publicado contém nomes, telefones, especialidades e informações de agendamento. A publicação desses dados exige autorização explícita do responsável.

Cuidados obrigatórios:

- não versionar arquivos `.xlsx`;
- não publicar arquivos temporários do Excel;
- não adicionar credenciais, tokens ou chaves ao repositório;
- confirmar a autorização antes de ampliar os dados pessoais publicados;
- remover dados do arquivo gerado e do histórico, quando solicitado pelo responsável.

O `.gitignore` bloqueia planilhas e arquivos temporários correspondentes.

## 16. Arquitetura do projeto

```text
Roteiro-Cuiaba-MT/
├── index.html                 # Agenda diária, filtros e mapa
├── clinicas.html              # Cadastro completo agrupado por clínica
├── data/
│   └── schedule-data.js       # Dados estruturados gerados da planilha
├── scripts/
│   └── import-schedule.ps1    # Importador da planilha
├── icons/                     # Ícones do PWA
├── manifest.webmanifest       # Manifesto do aplicativo
├── sw.js                      # Cache e suporte offline
├── offline.html               # Contingência offline
├── .gitignore                 # Proteção contra publicação da planilha
├── LICENSE
└── contexto.md                # Este documento
```

O projeto utiliza HTML, CSS e JavaScript sem framework ou etapa de compilação. Leaflet é carregado por CDN.

## 17. Limitações atuais

- As coordenadas são aproximadas por região.
- Não existe autenticação ou controle de acesso.
- Alterações feitas na planilha não chegam automaticamente ao site; é necessário executar o importador e publicar.
- O progresso das visitas não é salvo como concluído.
- Não há integração com Google Maps, Waze, calendário ou sistema externo.
- Os valores sinalizados como inconsistentes dependem de confirmação humana.
- O funcionamento offline do mapa depende dos blocos já armazenados no cache.

## 18. Possíveis evoluções

- endereço e coordenadas exatas por clínica;
- botão para abrir rota no Google Maps ou Waze;
- marcação de visita concluída com persistência local;
- observações por visita;
- autenticação e acesso restrito aos dados pessoais;
- importação pela própria interface;
- relatório de alterações entre versões da planilha;
- testes automatizados do importador e da ordenação;
- sincronização com calendário;
- painel de conflitos e dados pendentes de confirmação.

## 19. Critérios de aceite

Uma versão pode ser considerada pronta quando:

- os dados exibidos correspondem à planilha aprovada;
- dias e horários não foram deslocados;
- a agenda está em ordem cronológica global;
- os campos completos aparecem no cadastro por clínica;
- filtros e busca funcionam;
- inconsistências permanecem visíveis e sem correção automática;
- celular e desktop apresentam boa legibilidade;
- o PWA pode ser instalado e reaberto offline após o primeiro acesso;
- a planilha original não foi publicada;
- o repositório está sincronizado e sem alterações pendentes.
