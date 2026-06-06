# Diretrizes de UX/UI para IHM DOBOT

Autor: Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>

## Objetivo

Este documento define as diretrizes de UX/UI para a interface IHM do DOBOT CPQD,
seguindo os princípios da ANSI/ISA-101.01-2015 para interfaces homem-máquina em
sistemas de automação.

A ideia aqui é simples: a tela deve ajudar o operador a entender o estado do
sistema com rapidez, perceber anormalidades sem esforço e executar comandos com
segurança. Interface bonita é bem-vinda, mas nunca pode atrapalhar leitura,
diagnóstico, operação ou manutenção.

Estas diretrizes devem orientar novas telas, componentes, cores, alarmes,
navegação, controles e mensagens da aplicação.

## Princípios Gerais

1. A IHM deve priorizar consciência situacional.
2. Condição normal deve ser visualmente calma.
3. Cor forte deve ter significado operacional.
4. Alarmes e condições anormais devem chamar atenção de forma imediata.
5. Comandos devem ter feedback claro.
6. A navegação deve ser previsível e consistente.
7. O operador deve saber sempre onde está, o que está acontecendo e o que pode
   fazer.
8. A interface deve evitar enfeites que confundam com estado, alarme ou ação.
9. Dados críticos devem ser apresentados com unidade, faixa esperada e estado de
   validade.
10. Toda tela deve ser pensada para uso em operação real, não apenas para
    demonstração.

## Filosofia Visual

A interface deve usar aparência limpa, técnica e objetiva. O estilo visual deve
ser de IHM industrial, não de dashboard decorativo.

### Condição normal

Em operação normal, a tela deve ser majoritariamente neutra:

- Fundo claro ou cinza neutro.
- Componentes com baixo contraste visual.
- Linhas, bordas e divisões discretas.
- Texto com boa legibilidade.
- Pouca saturação.

O operador não deve ficar procurando a informação. O desenho da tela deve deixar
o estado do sistema evidente.

### Cores

As cores devem ser usadas com função, não como decoração.

### Paleta padrão

| Uso | HEX | RGB |
| --- | --- | --- |
| Fundo principal | `#f4f6f8` | `rgb(244, 246, 248)` |
| Superfície/painel | `#ffffff` | `rgb(255, 255, 255)` |
| Superfície secundária | `#eef1f4` | `rgb(238, 241, 244)` |
| Borda/divisor | `#cfd6dd` | `rgb(207, 214, 221)` |
| Texto principal | `#1f2933` | `rgb(31, 41, 51)` |
| Texto secundário | `#5f6f7f` | `rgb(95, 111, 127)` |
| Seleção/destaque secundário | `#0b7285` | `rgb(11, 114, 133)` |
| Seleção clara | `#d8f3f6` | `rgb(216, 243, 246)` |
| Estado normal/conectado | `#2f855a` | `rgb(47, 133, 90)` |
| Estado desabilitado | `#8a97a3` | `rgb(138, 151, 163)` |
| Estado indisponível | `#6b7280` | `rgb(107, 114, 128)` |
| Alarme baixo/informativo | `#2563eb` | `rgb(37, 99, 235)` |
| Alarme médio/atenção | `#d97706` | `rgb(217, 119, 6)` |
| Alarme alto/falha crítica | `#dc2626` | `rgb(220, 38, 38)` |
| Alarme reconhecido | `#7c3aed` | `rgb(124, 58, 237)` |
| Vídeo/câmera sem sinal | `#111827` | `rgb(17, 24, 39)` |

### Cores de alarme

| Prioridade | Uso | HEX | RGB |
| --- | --- | --- | --- |
| Alta | Falha crítica, parada, risco ou ação imediata | `#dc2626` | `rgb(220, 38, 38)` |
| Média | Condição anormal que exige atenção | `#d97706` | `rgb(217, 119, 6)` |
| Baixa | Aviso, degradação ou informação operacional | `#2563eb` | `rgb(37, 99, 235)` |
| Reconhecido | Alarme reconhecido ainda ativo | `#7c3aed` | `rgb(124, 58, 237)` |

Uso recomendado:

- Cinza/branco: estrutura, fundo, áreas normais e dados sem anormalidade.
- Preto/cinza escuro: textos principais.
- Azul ou teal discreto: seleção, navegação ou destaque secundário.
- Verde: estado saudável, disponível ou conectado, quando necessário.
- Amarelo: atenção, aviso, condição próxima do limite ou ação pendente.
- Vermelho: alarme, falha, parada, desconexão crítica ou condição perigosa.

Regras:

- Vermelho nunca deve ser usado para decoração.
- Amarelo deve ser reservado para atenção real.
- Verde não deve dominar a tela.
- Cores de marca CPQD podem existir, mas não devem competir com alarmes ou
  estados críticos.
- Se uma cor indica estado, deve haver texto ou símbolo junto. Nunca depender só
  da cor.

## Hierarquia de Telas

A aplicação deve evoluir para uma hierarquia clara de telas.

### Nível 1 - Visão Geral

Tela de entrada operacional. Deve mostrar o estado geral do sistema:

- Modo atual: Manual, Automático, Configuração, Manutenção ou Falha.
- Estado do DOBOT.
- Estado da câmera.
- Estado do CLP, quando habilitado.
- Estado do PAILOT, quando habilitado.
- Alarmes ativos principais.
- Último comando ou ciclo em execução.
- Indicação clara de sistema pronto, bloqueado, parado ou em falha.

Essa tela não deve ter detalhes demais. Ela deve responder rapidamente: "está
tudo normal ou preciso agir?".

### Nível 2 - Operação

Telas usadas durante operação normal:

- Modo Manual.
- Modo Automático.
- Monitoramento de ciclo.
- Câmera e acompanhamento do processo.

Devem mostrar comandos, feedback e permissivos necessários para operar.

### Nível 3 - Detalhe e Diagnóstico

Telas para investigar uma condição:

- Posição dos eixos.
- Limites.
- Sensores.
- Comunicação.
- Status interno.
- Falhas por subsistema.

### Nível 4 - Configuração e Manutenção

Telas protegidas por perfil de acesso:

- Parâmetros de movimento.
- Integrações.
- Calibração.
- Testes.
- Configurações persistidas.

Essas telas devem ser acessadas apenas por usuário autorizado.

## Navegação

A navegação deve ser consistente em todas as telas.

Regras:

- O menu lateral deve manter sempre a mesma ordem.
- A tela atual deve ser indicada visualmente.
- O operador deve conseguir voltar para a visão geral com um toque.
- Telas protegidas devem indicar que exigem autorização.
- O acesso a configurações não deve interromper operação crítica sem confirmação.
- A saída da aplicação deve exigir confirmação clara.

Ordem recomendada do menu:

1. Visão Geral.
2. Manual.
3. Automático.
4. Alarmes.
5. Diagnóstico.
6. Configurações.
7. Sair.

## Barra Superior

A barra superior deve mostrar informações globais:

- Nome da aplicação.
- Página ou modo atual.
- Estado principal do DOBOT.
- Indicador de alarme ativo, quando existir.
- Acesso ao menu.

Ela não deve ficar visualmente mais chamativa do que os alarmes.

## Barra de Status

A barra inferior deve mostrar estados de conexão e disponibilidade.

Estados recomendados:

- Conectado.
- Desconectado.
- Desabilitado.
- Falha.
- Simulado.
- Indisponível.

Evitar mostrar apenas bolinha vermelha ou verde. Sempre que possível, usar texto
junto:

- DOBOT: Conectado.
- Câmera: Desconectada.
- CLP: Desabilitado.
- PAILOT: Indisponível.

## Alarmes e Eventos

A IHM deve ter uma área dedicada para alarmes.

Cada alarme deve conter:

- Prioridade.
- Estado.
- Data e hora.
- Origem.
- Mensagem objetiva.
- Ação esperada, quando aplicável.
- Reconhecimento, se o processo exigir.

Prioridades recomendadas:

- Alta: risco operacional, parada, falha crítica ou ação imediata.
- Média: condição anormal que exige atenção.
- Baixa: aviso, degradação ou condição informativa.

Regras:

- Alarme ativo deve ser visível em qualquer tela.
- Alarme não reconhecido deve ser distinguível.
- Eventos informativos não devem parecer alarmes.
- Mensagens devem ser específicas. Evitar "Erro" sem contexto.
- Alarmes devem ter histórico.

Exemplos de mensagens boas:

- "DOBOT desconectado. Verifique cabo USB e alimentação."
- "Câmera indisponível. Reconecte o dispositivo ou reinicie captura."
- "Limite superior do eixo Z atingido. Movimento bloqueado."

Exemplos ruins:

- "Falha."
- "Erro geral."
- "Problema no sistema."

## Controles Operacionais

Todo controle deve deixar claro:

- O que será alterado.
- Valor atual.
- Valor desejado.
- Unidade.
- Limite inferior e superior.
- Estado do comando.
- Se o comando foi aceito, recusado ou está em execução.

Para controles de movimento:

- Mostrar unidade, por exemplo mm, grau ou passo configurado.
- Mostrar posição atual e setpoint quando existirem.
- Mostrar limites físicos ou configurados.
- Bloquear comando quando o sistema não estiver pronto.
- Evitar movimento acidental por toque involuntário.
- Comandos perigosos devem exigir confirmação ou gesto intencional.

No caso do eixo Z, a tela deve evoluir para mostrar:

- Posição atual.
- Setpoint.
- Passo configurado.
- Faixa permitida.
- Estado do movimento.
- Permissivo de segurança.

## Entrada de Dados

Campos numéricos devem ter:

- Validação de faixa.
- Unidade visível.
- Formatação consistente.
- Feedback de erro claro.
- Botão ou ação explícita para aplicar quando o valor for crítico.

Regras:

- Nunca salvar valor inválido silenciosamente.
- Nunca alterar parâmetro crítico sem feedback.
- Sempre informar se a configuração foi salva ou apenas editada localmente.
- Usar vírgula decimal para exibição em português quando fizer sentido.

## Modo Manual

A tela manual deve ser objetiva e segura.

Deve conter:

- Câmera ou visualização principal.
- Estado do DOBOT.
- Estado de habilitação para movimento.
- Controles de eixo.
- Feedback de posição.
- Indicação de limite.
- Botão de parada ou comando seguro, se disponível no projeto.

Não deve conter:

- Informação decorativa.
- Cor sem significado.
- Controle sem feedback.
- Comando que execute movimento sem indicar resultado.

## Modo Automático

O modo automático não deve ficar como placeholder em versão operacional.

Deve conter:

- Estado do ciclo.
- Etapa atual.
- Próxima etapa.
- Tempo ou progresso, quando aplicável.
- Condições de bloqueio.
- Alarmes associados.
- Comandos iniciar, pausar, retomar e parar, se previstos.

Cada comando precisa de feedback visível.

## Configurações

Configurações devem ser tratadas como área de manutenção.

Regras:

- Acesso protegido por perfil.
- Indicar claramente valores atuais.
- Separar alteração local de valor salvo.
- Mostrar mensagem de sucesso ou erro.
- Validar dependências entre campos.
- Registrar alteração crítica, quando possível.

Senha hardcoded na interface deve ser evitada. O ideal é mover autenticação para
o backend, com perfis como:

- Operador.
- Técnico.
- Engenharia.
- Administrador.

## Texto e Linguagem

A linguagem deve ser curta, direta e em português.

Usar:

- "Conectado".
- "Desconectado".
- "Desabilitado".
- "Falha".
- "Pronto".
- "Movendo".
- "Bloqueado".
- "Aguardando".

Evitar:

- Termos vagos.
- Mensagens longas em telas operacionais.
- Siglas sem contexto, quando o operador puder não conhecer.
- Traduções misturadas com inglês.

## Legibilidade e Ergonomia

Diretrizes mínimas:

- Texto operacional principal deve ter tamanho confortável para touch screen.
- Botões devem ter área de toque suficiente.
- Elementos clicáveis devem parecer clicáveis.
- Dados críticos devem ter contraste adequado.
- Não sobrepor texto em vídeo ou imagem sem fundo adequado.
- Evitar fontes pequenas em Raspberry Pi/tela embarcada.
- Evitar animações que chamem atenção sem motivo operacional.

## Performance

A IHM deve responder rápido o suficiente para operação.

Critérios recomendados:

- Abertura de tela sem atraso perceptível.
- Mudança de status visível rapidamente.
- Feedback imediato após toque.
- Indicação de carregamento quando uma ação demorar.
- Atualização confiável de estados de conexão.

Se um dado estiver atrasado, inválido ou indisponível, a tela deve mostrar isso.
Não mascarar dado velho como se fosse atual.

## Estados de Comunicação

Conexões devem ter estados explícitos:

- Não configurado.
- Desabilitado.
- Tentando conectar.
- Conectado.
- Desconectado.
- Falha.
- Simulado.

Isso evita confusão entre um recurso que não existe, um recurso desligado de
propósito e uma falha real.

## Simulação e Desenvolvimento

Quando o sistema estiver usando serviço mockado ou simulado, isso deve aparecer
na IHM.

Exemplo:

- "DOBOT: Simulado".
- "Modo de desenvolvimento".

Simulação nunca deve parecer equipamento real conectado.

## Checklist para Novas Telas

Antes de considerar uma tela pronta, verificar:

- A tela informa claramente seu objetivo?
- O operador sabe o estado atual do sistema?
- Estados anormais aparecem com destaque?
- Cores têm significado consistente?
- Todos os comandos têm feedback?
- Dados numéricos têm unidade?
- Valores críticos têm limite e validação?
- A navegação está consistente?
- A tela funciona em resolução mínima?
- Existe comportamento definido para desconexão?
- Existe mensagem clara para erro?
- A tela evita informação desnecessária?

## Checklist para Componentes

Todo componente reutilizável deve definir:

- Estado normal.
- Estado desabilitado.
- Estado pressionado ou selecionado.
- Estado de erro.
- Texto ou tooltip, quando necessário.
- Tamanho mínimo de toque.
- Cores alinhadas ao tema.
- Comportamento em dados inválidos.

## Aplicação no Projeto Atual

Prioridades para aproximar a interface atual da ISA-101:

1. Criar tela de Visão Geral.
2. Implementar tela de Alarmes.
3. Substituir "Modo Automático" placeholder por tela operacional real.
4. Melhorar barra de status para diferenciar conectado, desconectado,
   desabilitado, falha e simulado.
5. Reduzir uso de cores saturadas em elementos normais.
6. Reservar vermelho/amarelo para falhas, alarmes e atenção.
7. Mostrar unidade, limite e feedback no controle do eixo Z.
8. Mover autenticação para o backend.
9. Indicar claramente quando o DOBOT estiver mockado/simulado.
10. Criar histórico de eventos e alarmes.

## Assinatura

Paulo Henrique Vieira de Souza

phsouza@cpqd.com.br
