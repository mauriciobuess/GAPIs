GAPIs - APIs Manager

TI4All - Strategical Services 55 41 99156 55 22
Developed by Maur�cio Buess
mauriciobuess@gmail.com

Como funciona
GAPIS � uma solu��o customiz�vel para aqueles usu�rios que possuem um ERP MSSQL SERVER sem dom�nio para altera��o ou implementa��o de recursos, fazendo a integra��o de dados de da(s) API(s) cadastradas diretamente no B.D.
Atrav�s de um temporizador configur�vel do pr�prio GAPIs, periodicamente executar� o procedimento apiDemandaComunicaSelectAll do BD GAPIs, procedimento que deve ser customizado para a perfeita integra��o dos dados dos retornados/enviados pelo(s) endpoint(s) cadastrados com a base da dados do ERP. Logo, o objeto BD apiDemandaComunicaSelectAll � o in�cio do processo de customiza��o.

Requisitos:
Sistema operacional Windows 8 ou Superior (preferencialmente Windown 10)
Banco de Dados MSSQL Server

Instala��o:
01) Execute o script GApis_Script_V100.sql diretamente no Microsoft SQL Server Management Studio com usu�rio de perfil dbo.
02) Copie o arquivo GApis.exe que est� na pasta app.publish para uma pasta local qualquer.
03) Execute o arquivo GApis.exe que voc� copiou para sua m�quina local.
04) Na primeira execu��o o GApis ir� pedir a string de conex�o do BD. Informe-a nesse momento;
05) Ap�s sucesso da string de conex�o o GApis pedir� para cadastrar um usu�rio o qual poder� incluir, alterar ou excluir o(s) endpoint(s).
06) Inclua as APIs na aba /APIs\
07) Configure o temporizador de demanda na aba /A��o\ e marque o RadioButton "Execu��o autom�tica" com SIM (a partir desse instante o temporizador entrar� em a��o).
08) Fa�a o logout mas deixe o execut�vel trabalhando.

D�vidas, dificuldades ou sugest�es
Entre em contato atrav�s do telefone/whatapp 55 41 99156 5522 ou pelo e-mail mauriciobuess@gmail.com

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

