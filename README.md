# Reflexões Arquiteturais - Atividade 2

**1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.**
O mecanismo de cache foi implementado na camada **Data** (especificamente em `datasources`). Essa decisão é arquiteturalmente correta porque a camada de dados é responsável por implementar o acesso efetivo às fontes de informação  e concentrar operações de entrada e saída, independentemente de serem requisições de rede ou armazenamento local. Isso mantém os detalhes de infraestrutura isolados das camadas superiores.

**2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?**
O ViewModel atua na lógica de apresentação , possuindo o papel de gerenciar estados e coordenar o fluxo da aplicação. Se ele fizesse chamadas HTTP diretamente, ocorreria uma violação arquitetural: a interface se tornaria dependente de detalhes de rede e infraestrutura. Isso tornaria o código difícil de testar isoladamente e altamente acoplado.

**3. O que poderia acontecer se a interface acessasse diretamente o DataSource?**
A interface (camada Presentation) passaria a manipular os Modelos de Dados (DTOs) que refletem a estrutura técnica da API, em vez de manipular as Entidades do Domínio 322. Isso cria um acoplamento severo: qualquer alteração no formato JSON retornado pela API exigiria mudanças diretas nos arquivos de interface visual , quebrando a regra de que a apresentação deve depender apenas do domínio.

**4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?**
A arquitetura facilita essa transição baseando-se no Princípio da Inversão de Dependência. O núcleo da aplicação (Domínio) define apenas o contrato (a interface `ProductRepository`). Para substituir a API por um banco local, bastaria criar um novo `LocalDatabaseDatasource` na camada Data e instanciá-lo no `ProductRepositoryImpl`. Nenhuma linha de código nas camadas de Domínio ou Presentation precisaria ser reescrita, pois elas dependem da abstração e não da implementação.