# Planejamento de execução — Sprints

## 1. Visão geral

Este documento organiza a execução do projeto **Roteiro de Visitas — Cuiabá e Várzea Grande** em ciclos curtos, verificáveis e publicáveis.

O planejamento considera:

- a planilha como fonte oficial dos dados;
- dia e horário como informações críticas;
- validação humana para dados ambíguos;
- funcionamento em celular e desktop;
- instalação como PWA;
- proteção dos arquivos originais;
- entregas incrementais na branch `main`;
- documentação e rastreabilidade das alterações.

## 2. Modelo de trabalho

### Duração sugerida

- Sprints de **1 semana** para atividades funcionais.
- Correções críticas de dados podem ser publicadas imediatamente, fora da cadência regular.
- Cada sprint deve terminar com uma versão utilizável e validada.

### Prioridades

1. **P0 — Crítica:** risco de mostrar dia, médico ou horário incorreto; vazamento de dados; aplicação indisponível.
2. **P1 — Alta:** falha de importação, ordenação, busca, filtros, instalação ou uso mobile.
3. **P2 — Média:** melhoria visual, produtividade e redução de etapas.
4. **P3 — Baixa:** conveniência, personalização ou evolução sem impacto imediato na operação.

### Estados de uma tarefa

- `A fazer`
- `Em andamento`
- `Em validação`
- `Concluída`
- `Bloqueada`

## 3. Marcos do projeto

| Marco | Resultado | Situação |
|---|---|---|
| M1 | Site inicial com mapa e agenda | Concluído |
| M2 | Repositório Git e publicação | Concluído |
| M3 | PWA responsivo e instalável | Concluído |
| M4 | Ordenação cronológica e segurança de horários | Concluído |
| M5 | Importação completa da planilha | Concluído |
| M6 | Cadastro completo por clínica | Concluído |
| M7 | Auditoria e saneamento dos dados ambíguos | Planejado |
| M8 | Rotas por clínica e produtividade em campo | Planejado |
| M9 | Segurança e controle de acesso | Planejado |
| M10 | Automação da atualização e testes | Planejado |

## 4. Backlog por épico

### Épico A — Confiabilidade dos dados

- Importar planilha sem deslocar colunas.
- Preservar valores originais.
- Detectar horários ambíguos.
- Comparar versões da planilha.
- Validar médicos, clínicas, telefones e dias.
- Impedir publicação quando houver erro estrutural.

### Épico B — Agenda e produtividade

- Ordenação cronológica global.
- Próxima visita.
- Alertas de horários coincidentes.
- Marcação de visita concluída.
- Observações locais.
- Resumo diário e progresso.

### Épico C — Clínicas e localização

- Cadastro agrupado por clínica.
- Endereço completo.
- Coordenadas exatas.
- Rota no Google Maps e Waze.
- Distância e sequência sugerida.

### Épico D — Experiência mobile e desktop

- Interface responsiva.
- Navegação entre mapa, agenda e clínicas.
- Acessibilidade.
- Tema claro/escuro.
- Melhorias de leitura e contraste.

### Épico E — PWA e disponibilidade

- Manifesto e ícones.
- Service worker.
- Agenda offline.
- Atualização segura do cache.
- Aviso de nova versão.

### Épico F — Segurança e privacidade

- Não publicar a planilha original.
- Revisar exposição de dados pessoais.
- Controle de acesso.
- Política de retenção e remoção.
- Registro de autorização de publicação.

### Épico G — Qualidade e automação

- Testes do importador.
- Testes de ordenação e filtros.
- Validação do PWA.
- Integração contínua.
- Implantação automática controlada.

## 5. Sprint 0 — Descoberta e estrutura inicial

**Situação:** concluída

### Objetivo

Definir o problema, organizar o repositório e produzir a primeira versão navegável.

### Atividades

- Identificar regiões, clínicas, médicos e horários disponíveis.
- Definir a agenda semanal como fluxo principal.
- Criar o repositório Git.
- Configurar a branch `main` e o remoto GitHub.
- Criar a primeira página com mapa, filtros e lista.
- Validar a abertura local do projeto.

### Entregáveis

- `index.html` inicial.
- Histórico Git preservado.
- Repositório conectado ao GitHub.

### Critérios de aceite

- O site abre sem erro.
- O usuário seleciona um dia e vê os registros correspondentes.
- O mapa apresenta as regiões disponíveis.

## 6. Sprint 1 — PWA e responsividade

**Situação:** concluída

### Objetivo

Transformar o site em aplicativo instalável, adequado para celular e desktop.

### Atividades

- Criar `manifest.webmanifest`.
- Criar `sw.js` e estratégia de cache.
- Criar `offline.html`.
- Criar ícones SVG e PNG.
- Implementar instalação do PWA.
- Criar layout responsivo.
- Criar navegação mobile entre mapa e agenda.
- Exibir indicador online/offline.
- Validar visualmente em tamanhos mobile e desktop.

### Entregáveis

- PWA instalável.
- Agenda disponível offline após o primeiro acesso.
- Interface adaptada para celular e desktop.

### Critérios de aceite

- O manifesto é carregado.
- O service worker é registrado em HTTPS.
- O site permanece utilizável sem conexão depois do primeiro acesso.
- Não existe rolagem ou sobreposição que impeça o uso dos filtros.

## 7. Sprint 2 — Segurança de dias e horários

**Situação:** concluída

### Objetivo

Reduzir o risco de consultar uma visita no dia ou horário errado.

### Atividades

- Abrir automaticamente no dia atual.
- Exibir data e hora locais.
- Adicionar abas de segunda a domingo.
- Tratar sábado e domingo sem agenda.
- Interpretar horários numéricos e intervalos.
- Preservar textos aproximados.
- Sinalizar horários que precisam de confirmação.
- Detectar registros no mesmo horário.
- Destacar a próxima visita.
- Exibir o dia e período ativos sobre o mapa mobile.

### Entregáveis

- Cabeçalho com data e hora.
- Alertas `HORÁRIO A CONFIRMAR`, `MESMO HORÁRIO` e `PRÓXIMA VISITA`.
- Lógica de período para manhã e tarde.

### Critérios de aceite

- O dia atual é selecionado corretamente.
- Um horário aproximado não recebe um horário inventado.
- Um intervalo é classificado usando seu início e fim.
- Registros simultâneos permanecem visíveis.

## 8. Sprint 3 — Ordenação cronológica global

**Situação:** concluída

### Objetivo

Mostrar o roteiro completo do menor para o maior horário, sem agrupamentos que prejudiquem a sequência diária.

### Atividades

- Substituir a ordenação isolada por região.
- Criar uma única linha do tempo do dia.
- Ordenar pelo primeiro horário do intervalo.
- Manter clínica e região em cada card.
- Ordenar horários iguais por clínica.
- Validar dias com grande quantidade de visitas.

### Entregáveis

- Agenda cronológica global.
- Cards individuais de visitas.

### Critérios de aceite

- `07:00` aparece antes de `07:30`, `08:00` e horários posteriores.
- A região não altera a ordem cronológica.
- Intervalos como `07:00 às 12:00` usam `07:00` na ordenação.

## 9. Sprint 4 — Importação completa da planilha

**Situação:** concluída

### Objetivo

Substituir a base manual pelos dados estruturados da planilha oficial.

### Atividades

- Ler todas as abas do Excel em modo somente leitura.
- Identificar clínica por bloco e região por aba.
- Importar médico, ESP, agendado, telefone e dias úteis.
- Registrar aba e linha de origem.
- Criar `scripts/import-schedule.ps1`.
- Gerar `data/schedule-data.js`.
- Ignorar arquivos `.xlsx` no Git.
- Preservar valores não padronizados.
- Gerar lista de inconsistências.

### Entregáveis

- 80 registros importados.
- 16 valores não padronizados sinalizados.
- Importador reproduzível.
- Planilha original fora do repositório.

### Critérios de aceite

- A planilha não é modificada.
- Ana Gisela permanece na quarta-feira às `08:30`.
- Cada registro guarda sua origem.
- Campos vazios aparecem como `Não informado`.
- Nenhum valor ambíguo é corrigido automaticamente.

## 10. Sprint 5 — Cadastro e filtros completos

**Situação:** concluída

### Objetivo

Disponibilizar a visão completa da planilha e facilitar consultas operacionais.

### Atividades

- Criar `clinicas.html`.
- Agrupar registros por região e clínica.
- Exibir todas as colunas de segunda a sexta.
- Criar busca por clínica, médico, especialidade e telefone.
- Criar filtro por região.
- Adicionar filtros de especialidade e agendamento na agenda.
- Tornar telefones válidos clicáveis.
- Exibir painel de inconsistências.
- Adicionar acesso à tela de clínicas no desktop e mobile.

### Entregáveis

- Cadastro completo por clínica.
- Novos filtros na agenda.
- Painel de revisão de horários.

### Critérios de aceite

- Todos os registros importados aparecem na tela de clínicas.
- A busca encontra valores com ou sem acentos.
- A tabela mantém as cinco colunas de dias úteis.
- A interface funciona em celular e desktop.

## 11. Sprint 6 — Auditoria e saneamento assistido

**Situação:** próxima sprint recomendada

### Objetivo

Revisar os valores ambíguos da planilha com confirmação humana e reduzir inconsistências futuras.

### Atividades

- Revisar os 16 valores não padronizados.
- Definir o significado oficial de `M`, `M-T`, `X`, `Tel` e `Alterna`.
- Revisar horários sem separadores claros.
- Identificar telefones colocados em colunas inadequadas.
- Identificar clínicas duplicadas ou com grafias diferentes.
- Identificar médicos duplicados entre clínicas ou regiões.
- Produzir relatório `auditoria-dados.md`.
- Corrigir somente a planilha oficial após confirmação.
- Reimportar e comparar o resultado.

### Entregáveis

- Relatório de inconsistências com decisão para cada item.
- Planilha oficial revisada pelo responsável.
- Nova base gerada sem correções implícitas.

### Critérios de aceite

- Cada inconsistência possui estado: confirmada, corrigida ou mantida.
- Toda correção tem referência à aba e linha original.
- O aplicativo e a planilha permanecem sincronizados.
- Nenhuma decisão é tomada sem confirmação do responsável.

## 12. Sprint 7 — Endereços e rotas

**Situação:** planejada

### Objetivo

Transformar o mapa regional em uma ferramenta de navegação até cada clínica.

### Dependência

Cadastro e validação dos endereços oficiais das clínicas.

### Atividades

- Adicionar endereço completo à fonte de dados.
- Validar endereço e coordenadas de cada clínica.
- Criar um marcador por clínica.
- Agrupar marcadores próximos.
- Adicionar botão `Abrir no Google Maps`.
- Adicionar botão `Abrir no Waze`.
- Diferenciar marcadores por período ou situação.
- Manter aviso quando a localização for apenas aproximada.

### Entregáveis

- Mapa por clínica.
- Links externos de navegação.
- Cadastro validado de coordenadas.

### Critérios de aceite

- Cada botão abre a clínica correta.
- Nenhuma coordenada aproximada é apresentada como endereço exato.
- O mapa continua utilizável em telas pequenas.

## 13. Sprint 8 — Execução e acompanhamento das visitas

**Situação:** planejada

### Objetivo

Ajudar o usuário a acompanhar o progresso do roteiro durante o dia.

### Atividades

- Adicionar estado `Pendente`, `Concluída` e `Não realizada`.
- Salvar progresso localmente no aparelho.
- Permitir observações por visita.
- Exibir progresso diário em quantidade e percentual.
- Adicionar filtro por situação da visita.
- Criar botão `Próxima visita pendente`.
- Permitir limpar o progresso com confirmação.
- Definir comportamento ao mudar a planilha.

### Entregáveis

- Controle local de execução.
- Resumo de progresso.
- Observações por visita.

### Critérios de aceite

- Reabrir o aplicativo preserva o progresso.
- O usuário não perde observações ao ficar offline.
- A limpeza de dados exige confirmação.
- Dados de progresso não alteram a planilha oficial.

## 14. Sprint 9 — Segurança e controle de acesso

**Situação:** planejada e recomendada antes de ampliar o uso

### Objetivo

Reduzir a exposição pública de nomes, telefones e informações de agendamento.

### Atividades

- Confirmar se o repositório e o site devem permanecer públicos.
- Mapear quais campos realmente precisam ser publicados.
- Avaliar autenticação e hospedagem com acesso restrito.
- Criar política de autorização e remoção de dados.
- Remover dados desnecessários do cliente.
- Revisar histórico Git em caso de solicitação de exclusão.
- Documentar responsáveis e permissões.

### Entregáveis

- Decisão formal de exposição dos dados.
- Plano de controle de acesso.
- Política mínima de privacidade e retenção.

### Critérios de aceite

- Apenas usuários autorizados acessam dados pessoais, caso o acesso restrito seja aprovado.
- Existe procedimento documentado para corrigir ou remover informações.
- Nenhuma credencial é armazenada no repositório.

## 15. Sprint 10 — Testes e integração contínua

**Situação:** planejada

### Objetivo

Automatizar verificações críticas antes de cada publicação.

### Atividades

- Separar funções de parsing e ordenação em módulos testáveis.
- Criar testes para dias e intervalos.
- Criar testes para manhã, tarde e horários aproximados.
- Criar teste específico para deslocamento de colunas.
- Validar estrutura do arquivo gerado.
- Validar manifesto e arquivos do cache.
- Criar verificação de links internos.
- Configurar workflow de CI no GitHub.
- Bloquear publicação quando testes críticos falharem.

### Entregáveis

- Suíte de testes automatizados.
- Workflow de integração contínua.
- Relatório de validação em cada commit.

### Critérios de aceite

- Erros de ordenação provocam falha no teste.
- Médico associado ao dia incorreto é detectado pela comparação com a fonte.
- Arquivo ausente no cache é detectado.
- A branch principal só recebe versão validada.

## 16. Sprint 11 — Atualização simplificada da planilha

**Situação:** planejada

### Objetivo

Reduzir o trabalho manual e o risco na atualização dos dados.

### Atividades

- Criar comando único para importar, validar e gerar relatório.
- Comparar a planilha nova com a versão anterior.
- Mostrar médicos adicionados, removidos ou alterados.
- Exigir confirmação para mudanças de dia ou horário.
- Atualizar automaticamente a versão do cache.
- Gerar resumo pronto para o commit.
- Manter a planilha fora do Git.

### Entregáveis

- Pipeline local de atualização.
- Relatório de diferenças.
- Checklist automático de publicação.

### Critérios de aceite

- Uma mudança de quarta para segunda é destacada antes da publicação.
- O processo nunca modifica a planilha de entrada.
- A base gerada é reproduzível usando o mesmo arquivo.

## 17. Sprint 12 — Refinamento visual e acessibilidade

**Situação:** planejada

### Objetivo

Melhorar leitura, consistência visual e uso por pessoas com diferentes necessidades.

### Atividades

- Revisar contraste de cores.
- Revisar tamanhos de fonte e áreas de toque.
- Criar estado de foco visível.
- Melhorar navegação por teclado.
- Testar leitores de tela.
- Adicionar tema escuro opcional.
- Padronizar ícones e mensagens.
- Melhorar visualização de tabelas no celular.

### Entregáveis

- Interface revisada.
- Checklist de acessibilidade.
- Tema escuro, se aprovado.

### Critérios de aceite

- Principais fluxos funcionam por teclado.
- Campos possuem rótulos compreensíveis.
- Alertas não dependem apenas de cor.
- A interface permanece legível com zoom de 200%.

## 18. Cronograma sugerido

| Semana | Sprint | Foco |
|---|---|---|
| 1 | Sprint 6 | Auditoria dos dados ambíguos |
| 2 | Sprint 7 | Endereços e rotas |
| 3 | Sprint 8 | Execução e progresso das visitas |
| 4 | Sprint 9 | Segurança e controle de acesso |
| 5 | Sprint 10 | Testes e integração contínua |
| 6 | Sprint 11 | Atualização simplificada |
| 7 | Sprint 12 | Visual e acessibilidade |

O cronograma deve ser ajustado conforme a disponibilidade para validar dados, endereços e decisões de privacidade.

## 19. Definição de pronto para iniciar

Uma tarefa está pronta para entrar em sprint quando:

- o objetivo está claro;
- existe fonte de dados ou referência disponível;
- as dependências foram identificadas;
- os riscos de privacidade foram avaliados;
- os critérios de aceite podem ser testados;
- decisões que alteram dados críticos foram confirmadas.

## 20. Definição de concluído

Uma tarefa só é considerada concluída quando:

- a implementação está completa;
- dias e horários foram comparados com a fonte;
- não há erros em `git diff --check`;
- a interface foi testada em celular e desktop;
- filtros e buscas relacionados continuam funcionando;
- o PWA foi testado online e offline quando aplicável;
- dados ambíguos não foram alterados sem confirmação;
- a versão do cache foi atualizada quando necessário;
- a documentação foi atualizada;
- o commit foi publicado e a branch está sincronizada.

## 21. Estratégia de testes

### Dados

- Conferir quantidade de registros importados.
- Comparar amostras de todas as abas.
- Validar médicos com horários em mais de um dia.
- Validar campos vazios e valores não padronizados.

### Agenda

- Conferir primeiro e último horário de cada dia.
- Conferir intervalos.
- Conferir horários simultâneos.
- Conferir próxima visita no dia atual.
- Conferir sábado e domingo.

### Filtros

- Combinar dia, período, clínica, especialidade e agendamento.
- Buscar com e sem acentos.
- Limpar filtros e recuperar todos os resultados.

### Interface

- Testar larguras de 360 px, 768 px e 1440 px.
- Testar mapa, agenda e clínicas.
- Testar telefone clicável.
- Testar rolagem das tabelas.

### PWA

- Instalar em navegador compatível.
- Abrir offline após o primeiro acesso.
- Confirmar atualização após mudança da versão do cache.
- Confirmar presença de todos os arquivos essenciais.

## 22. Riscos e respostas

| Risco | Impacto | Resposta |
|---|---|---|
| Médico no dia errado | Crítico | Comparação automática por coluna e validação humana |
| Horário ambíguo convertido incorretamente | Crítico | Preservar texto e marcar para confirmação |
| Dados pessoais públicos | Alto | Autorização explícita e sprint de controle de acesso |
| Planilha publicada por engano | Alto | `.gitignore` e conferência antes do commit |
| Cache mantém versão antiga | Médio | Incrementar versão do cache em toda publicação relevante |
| Coordenada regional interpretada como exata | Médio | Aviso claro e validação antes de criar rotas |
| Alteração quebra mobile | Médio | Validação visual em largura reduzida |
| Importação perde uma clínica | Alto | Contagem, rastreabilidade de linha e teste de todas as abas |
| Duplicidade de clínica ou médico | Médio | Relatório de auditoria sem mesclagem automática |

## 23. Indicadores de sucesso

- Zero ocorrências confirmadas de médico no dia errado.
- Zero horários inventados pelo sistema.
- 100% dos registros com referência de origem.
- 100% das inconsistências ambíguas sinalizadas.
- Agenda ordenada corretamente em todos os dias.
- Tempo reduzido para localizar a próxima visita.
- Aplicação utilizável em celular e desktop.
- Atualizações publicadas somente após validação.
- Nenhuma planilha original ou credencial publicada.

## 24. Rotina de publicação

1. Receber ou atualizar a planilha oficial.
2. Executar o importador.
3. Ler o relatório de inconsistências.
4. Comparar alterações críticas de dia e horário.
5. Validar agenda e cadastro por clínica.
6. Atualizar a versão do cache.
7. Executar verificações de qualidade.
8. Revisar os arquivos que entrarão no commit.
9. Confirmar autorização quando houver novos dados pessoais.
10. Criar commit descritivo.
11. Enviar para a branch `main`.
12. Confirmar sincronização e funcionamento da versão publicada.

## 25. Próxima ação recomendada

Iniciar a **Sprint 6 — Auditoria e saneamento assistido**, começando pelos 16 valores não padronizados já identificados. Essa etapa oferece o maior ganho imediato de confiabilidade antes de adicionar rotas, progresso de visitas ou novas automações.
