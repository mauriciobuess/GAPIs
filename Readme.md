##GAPIs - APIs Manager

##TI4All - Strategical Services 55 41 99156 5522
Developed by Maurício Buess
mauriciobuess@gmail.com

##Como funciona
GAPIS é uma solução customizável para aqueles usuários que possuem um ERP MSSQL SERVER sem domínio para alteração ou implementação de recursos, fazendo a integração de dados da(s) API(s) cadastradas diretamente no banco de dados. Através de um temporizador configurável no próprio GAPIs, periodicamente executará o procedimento apiDemandaComunicaSelectAll do BD GAPIs, procedimento que deve ser customizado para a perfeita integração dos dados retornados/enviados pelo(s) endpoint(s) cadastrados com a base da dados do ERP. Logo, o objeto BD apiDemandaComunicaSelectAll é o início do processo de customização.

##Requisitos:
Sistema operacional Windows 8 ou Superior (preferencialmente Windown 10)
Banco de Dados MSSQL Server

##Instalação:
01) Execute o script GApis_Script_V100.sql diretamente no Microsoft SQL Server Management Studio com usuário de perfil dbo.
02) Copie o arquivo GApis.exe que está na pasta app.publish para uma pasta local qualquer.
03) Execute o arquivo GApis.exe que você copiou para sua máquina local.
04) Na primeira execução o GApis irá pedir a string de conexão do BD. Informe-a nesse momento;
05) Após sucesso da string de conexão o GApis pedirá para cadastrar um usuário o qual poderá incluir, alterar ou excluir o(s) endpoint(s).
06) Inclua as APIs na aba /APIs\
07) Configure o temporizador de demanda na aba /Ação\ e marque o RadioButton "Execução automática" com SIM (a partir desse instante o temporizador entrará em ação).
08) Faça o logout mas deixe o executável trabalhando.

Dúvidas, dificuldades ou sugestões
Entre em contato através do telefone/whatapp 55 41 99156 5522 ou pelo e-mail mauriciobuess@gmail.com

***********************************************************************************

How it works
GAPIS is a customizable solution for those users who have an ERP MSSQL SERVER without a domain to change or implement resources, integrating data from the API(s) registered directly in the DB.
Through a configurable timer from GAPIs itself, the apiDemandaComunicaSelectAll procedure from BD GAPIs will periodically execute, a procedure that must be customized for the perfect integration of the data returned/sent by the endpoint(s) registered with the ERP database. Therefore, the apiDemandaComunicaSelectAll DB object is the beginning of the customization process.

Requirements:
Operating system Windows 8 or higher (preferably Windows 10)
MSSQL Server Database

Installation:
01) Run the GApis_Script_V100.sql script directly in Microsoft SQL Server Management Studio with the dbo profile user.
02) Copy the GApis.exe file that is in the app.publish folder to any local folder.
03) Run the GApis.exe file that you copied to your local machine.
04) On the first run, GApis will ask for the DB connection string. Inform her at this time;
05) After the connection string is successful, GApis will ask to register a user who can include, change or delete the endpoint(s).
06) Include the APIs in the /APIs\ tab
07) Configure the demand timer in the /Action\ tab and select the RadioButton "Automatic execution" with YES (from that moment on the timer will come into action).
08) Log out but leave the executable working.

Questions, difficulties or suggestions
Get in touch via phone/whatapp 55 41 99156 5522 or by email mauriciobuess@gmail.com

