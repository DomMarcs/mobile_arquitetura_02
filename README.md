# Reflexões Arquiteturais - Atividade 2

**1. Em qual camada foi implementado o mecanismo de cache? Explique por que essa decisão é adequada dentro da arquitetura proposta.**
O mecanismo de cache foi implementado na camada **Data** (especificamente em `datasources`). Essa decisão é arquiteturalmente correta porque a camada de dados é responsável por implementar o acesso efetivo às fontes de informação  e concentrar operações de entrada e saída, independentemente de serem requisições de rede ou armazenamento local. Isso mantém os detalhes de infraestrutura isolados das camadas superiores.

**2. Por que o ViewModel não deve realizar chamadas HTTP diretamente?**
O ViewModel atua na lógica de apresentação , possuindo o papel de gerenciar estados e coordenar o fluxo da aplicação. Se ele fizesse chamadas HTTP diretamente, ocorreria uma violação arquitetural: a interface se tornaria dependente de detalhes de rede e infraestrutura. Isso tornaria o código difícil de testar isoladamente e altamente acoplado.

**3. O que poderia acontecer se a interface acessasse diretamente o DataSource?**
A interface (camada Presentation) passaria a manipular os Modelos de Dados (DTOs) que refletem a estrutura técnica da API, em vez de manipular as Entidades do Domínio 322. Isso cria um acoplamento severo: qualquer alteração no formato JSON retornado pela API exigiria mudanças diretas nos arquivos de interface visual , quebrando a regra de que a apresentação deve depender apenas do domínio.

**4. Como essa arquitetura facilitaria a substituição da API por um banco de dados local?**
A arquitetura facilita essa transição baseando-se no Princípio da Inversão de Dependência. O núcleo da aplicação (Domínio) define apenas o contrato (a interface `ProductRepository`). Para substituir a API por um banco local, bastaria criar um novo `LocalDatabaseDatasource` na camada Data e instanciá-lo no `ProductRepositoryImpl`. Nenhuma linha de código nas camadas de Domínio ou Presentation precisaria ser reescrita, pois elas dependem da abstração e não da implementação.

---

## Estrutura de Arquitetura e Organização do Projeto

O projeto está estruturado utilizando conceitos de **Clean Architecture**, dividindo a aplicação em camadas bem definidas e isoladas:

1. **Camada de Domínio (`lib/domain`)**:
   - Contém as regras de negócio puras e as entidades que representam o núcleo da aplicação (ex: `Product`, `User`).
   - Define interfaces abstratas para os repositórios (ex: `AuthRepository`, `ProductRepository`), garantindo que o domínio não dependa de frameworks ou bibliotecas externas.

2. **Camada de Dados (`lib/data`)**:
   - Implementa as interfaces do repositório (ex: `AuthRepositoryImpl`, `ProductRepositoryImpl`).
   - Gerencia fontes de dados externas através de DataSources (`AuthRemoteDatasource`, `ProductRemoteDatasource`, `ProductCacheDatasource`).
   - Modela dados da API usando DTOs/Modelos (ex: `ProductModel`, `AuthResponseModel`) para desserialização JSON (DummyJSON).

3. **Camada de Apresentação (`lib/presentation`)**:
   - Responsável por renderizar a interface do usuário (ex: `LoginPage`, `HomePage`, `ProductPage`, `ProductDetailPage`).
   - Gerencia estados específicos da UI através de ViewModels (`AuthViewModel`, `ProductViewModel`), atuando como ponte entre o domínio e a visualização.

4. **Camada Core (`lib/core`)**:
   - Utilitários globais compartilhados, como o cliente HTTP genérico (`HttpClient`), classes de exceções e erros (`Failure`), e gerenciamento de persistência de sessão de usuário (`SessionManager`).

---

## Justificativa para a Escolha do Gerenciamento de Estado (Provider)

A solução escolhida para o gerenciamento de estado e injeção de dependência neste projeto foi o pacote **Provider**, combinado com **ChangeNotifier**, pelas seguintes razões:

1. **Acoplamento Fraco e Separação de Conceitos (MVVM)**:
   - Permite que a camada de visualização (View) escute e reaja a mudanças de estado nas ViewModels sem misturar lógica de negócio com lógica de interface.
   - As atualizações ocorrem automaticamente por meio do método `notifyListeners()`, garantindo reatividade eficiente.

2. **Simplicidade e Performance**:
   - É uma solução leve e recomendada oficialmente pela equipe do Flutter para projetos de médio porte.
   - Evita rebuilds desnecessários utilizando seletores ou ouvintes pontuais (`context.watch` / `context.read`).

3. **Facilidade de Testes**:
   - A injeção de dependência via `Provider` permite substituir facilmente as implementações reais de repositórios por dublês de teste (Mocks/Fakes), como feito com sucesso no arquivo de testes automatizados `widget_test.dart`.