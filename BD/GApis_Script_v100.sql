-- DataBase=Gapis;Server=DESKTOP-5DCAQH9\SQLEXPRESS01;user=ti4all;password=123

USE [Master];
GO

IF DB_ID('GAPIs') IS NULL
BEGIN
	CREATE DATABASE GAPIs;
END
GO

USE [GApis];
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1
				FROM SysObjects 
				WHERE name = 'usuario')
BEGIN
	CREATE TABLE [dbo].[usuario](
				 [idUsuario]	[int] IDENTITY(1,1) NOT NULL,
				 [login]		[varchar](100) NOT NULL,
				 [nome]			[varchar](100) NOT NULL,
				 [senhaHash]	[varchar](max) NOT NULL,
				 CONSTRAINT	[PK_usuario] PRIMARY KEY CLUSTERED 
				 (
					[idUsuario] ASC
				 ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
				 UNIQUE NONCLUSTERED 
				 (
					[login] ASC
				 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
				 ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END;
GO 

---------------------------------------------------------------
USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioSave')
BEGIN
	DROP PROCEDURE [dbo].[usuarioSave];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioSave]
				 (@idUsuario		[INT]			= 0
				 ,@login			[VARCHAR](100)	= NULL
				 ,@nome				[VARCHAR](100)	= NULL
				 ,@senhaHash		[VARCHAR](MAX)	= NULL
				 )
AS
BEGIN
	if LEN(RTRIM(@login)) = 0
	BEGIN
		SET @login = NULL;
	END;

	if LEN(RTRIM(@nome)) = 0
	BEGIN
		SET @nome = NULL;
	END;

	if LEN(RTRIM(@senhaHash)) = 0
	BEGIN
		SET @senhaHash = NULL;
	END;

	IF NOT EXISTS(SELECT 1
					FROM [dbo].[usuario] [u] WITH (NOLOCK)
					WHERE [u].[idUsuario] = ISNULL(@idUsuario, 0))
	BEGIN
		INSERT INTO [dbo].[usuario]
					([login]
					,[nome]
					,[senhaHash])
			VALUES	(@login
					,@nome
					,@senhaHash);

		SET @idUsuario = IDENT_CURRENT('usuario');
	END
	ELSE
	BEGIN
		UPDATE [dbo].[usuario]
		   SET [login]		= ISNULL(@login, [login])
			,  [nome]		= ISNULL(@nome, [nome])
			,  [senhaHash]	= ISNULL(@senhaHash, [senhaHash])
		 WHERE [idUsuario]  = @idUsuario;
	END;

	SET @idUsuario = ISNULL(@idUsuario, 0);

	SELECT [idUsuario]
		  ,[login]
		  ,[nome]
		  ,[senhaHash]
	  FROM [dbo].[usuario] WITH (NOLOCK)
	 WHERE [idUsuario] = @idUsuario;
END
GO
-------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioSelectAll')
BEGIN
	DROP PROCEDURE [dbo].[usuarioSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioSelectAll]
						(@idUsuario			[INT]			= NULL
						,@login				[VARCHAR](100)	= NULL
						,@nome				[VARCHAR](100)	= NULL
						,@senhaHash			[VARCHAR](MAX)	= NULL
						)
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	if (@idUsuario = 0)
	BEGIN
		SET @idUsuario = NULL;
	END
	IF (@login = '')
	BEGIN
		SET @login = NULL;
	END
	IF (@nome = '')
	BEGIN
		SET @nome = NULL;
	END
	if (@senhaHash = '')
	BEGIN
		SET @senhaHash = NULL;
	END

	SET @Parameters = N' @idUsuario [INT] ,@login [VARCHAR](100) ,@nome [VARCHAR](100) ,@senhaHash [VARCHAR](MAX) ';
	SET @Msql		= N' SELECT [u].[idUsuario], [u].[login] ,[u].[nome] ,[u].[senhaHash] FROM [dbo].[usuario] [u] WITH (NOLOCK) ';

	SET @Operator = N' WHERE ';

	IF @idUsuario IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [u].[idUsuario] = @idUsuario ';
		SET @Operator = N' AND ';
	END;
	IF @login IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [u].[login] = @login ';
		SET @Operator = N' AND ';
	END;
	IF @nome IS NOT NULL
	BEGIN
		SET @nome = '%' + RTRIM(LTRIM(@nome)) + '%';

		SET @MSql = @MSql + @Operator + N' [u].[nome] LIKE ' + '''' + @nome + '''' + ' '
		SET @Operator = N' AND ';
	END;
	IF @senhaHash IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [u].[senhaHash] = @senhaHash';
		SET @Operator = N' AND ';
	END;

	SET @Msql = @Msql + ' ORDER BY [u].[idUsuario] ';

	EXECUTE sp_executeSql @MSql , @Parameters, @idUsuario ,@login ,@nome ,@senhaHash ;
END

/*
exec usuarioSelectAll @idUsuario=0,@login='Buess',@nome='',@senhaHash=''
exec usuarioSelectAll @idUsuario=0,@login='Buess',@nome=default,@senhaHash=''
exec usuarioSelectAll @idUsuario=0,@login='Buess',@nome=default,@senhaHash=''
exec usuarioSelectAll @idUsuario=0,@login='Buess',@nome=default,@senhaHash=''

select * -- delete 
from usuario

5a-92-3c-9f-83-9b-cc-ee-68-35-f4-da-32-3f-86-e0-a2-fd-91-25-68-bd-70-58-71-56-de-a0-71-78-24-e5
*/

GO
-------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioQtde')
BEGIN
	DROP PROCEDURE [dbo].[usuarioQtde];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioQtde]
AS
BEGIN
	DECLARE @qtde	[INT];

	SET @qtde = ISNULL((SELECT COUNT(1) 
						  FROM [dbo].[usuario] WITH (NOLOCK)), 0);

	SELECT @qtde [usuarioQtde];
END
GO

-------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioSelectStep')
BEGIN
	DROP PROCEDURE [dbo].[usuarioSelectStep];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioSelectStep]
					   (@sinal		[VARCHAR](05)
					   ,@idUsuario  [INT]
					   )
AS
BEGIN
	DECLARE @step	[INT];

	if @sinal = '|<'
	BEGIN
		SELECT TOP 1
			   [idUsuario]
			  ,[login]
			  ,[nome]
			  ,[senhaHash]
		  FROM [dbo].[usuario] WITH (NOLOCK) 
		ORDER BY [idUsuario];
	END;

	if @sinal = '>|'
	BEGIN
		SELECT TOP 1
			   [idUsuario]
			  ,[login]
			  ,[nome]
			  ,[senhaHash]
		  FROM [dbo].[usuario] WITH (NOLOCK) 
		ORDER BY [idUsuario] DESC;
	END

	IF @sinal = '<'
	BEGIN
		SET @step = -1;
	END

	IF @sinal = '>'
	BEGIN
		SET @step = 1;
	END

	DECLARE @idLinhaIdUsuario	[INT];
	DECLARE @idUsuarioMin		[INT];
	DECLARE @idUsuarioMax		[INT];

	SET @idUsuarioMin = (SELECT MIN([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idUsuario]
									FROM (
									SELECT [idUsuario]
											,[login]
											,[nome]
											,[senhaHash]
											,ROW_NUMBER() OVER(ORDER BY [idUsuario]) [idLinha]
										FROM [dbo].[usuario] WITH (NOLOCK)
										) AS [A]
									--WHERE [A].[idUsuario] = @idUsuario
								) AS [B]);

	SET @idUsuarioMax = (SELECT MAX([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idUsuario]
									FROM (
									SELECT [idUsuario]
											,[login]
											,[nome]
											,[senhaHash]
											,ROW_NUMBER() OVER(ORDER BY [idUsuario]) [idLinha]
										FROM [dbo].[usuario] WITH (NOLOCK)
										) AS [A]
									--WHERE [A].[idUsuario] = @idUsuario
								) AS [B]);

	IF @sinal IN ('<', '>')
	BEGIN
		SET @idLinhaIdUsuario = ISNULL((
									SELECT [B].[idLinha]
									  FROM (
											SELECT [A].[idLinha]
												,  [A].[idUsuario]
												FROM (
												SELECT [idUsuario]
														,[login]
														,[nome]
														,[senhaHash]
														,ROW_NUMBER() OVER(ORDER BY [idUsuario]) [idLinha]
													FROM [dbo].[usuario] WITH (NOLOCK)
													) AS [A]
												WHERE [A].[idUsuario] = @idUsuario
											) AS [B]
										), 0);

		SET @idLinhaIdUsuario = @idLinhaIdUsuario + (@step);

		IF @sinal = '<'
		   AND @idLinhaIdUsuario <= 0
		BEGIN
			SET @idLinhaIdUsuario = @idUsuarioMin;
		END

		IF @sinal = '>'
		   AND (@idLinhaIdUsuario = 0
				OR @idLinhaIdUsuario > @idUsuarioMax)
		BEGIN
			SET @idLinhaIdUsuario = @idUsuarioMax;
		END

		IF @idLinhaIdUsuario > 0
		BEGIN
			SELECT [A].[idUsuario]
				  ,[A].[login]
				  ,[A].[nome]
				  ,[A].[senhaHash]
			  FROM (
					SELECT [idUsuario]
						  ,[login]
						  ,[nome]
						  ,[senhaHash]
						  ,ROW_NUMBER() OVER(ORDER BY [idUsuario]) [idLinha]
					  FROM [dbo].[usuario] WITH (NOLOCK) 
					) AS [A] 
			 WHERE [A].[idLinha] = @idLinhaIdUsuario
		END
	END
END
GO
-----------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioValidaSenha')
BEGIN
	DROP PROCEDURE [dbo].[usuarioValidaSenha];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioValidaSenha]
						(@login				[VARCHAR](100)	= NULL
						,@senhaHash			[VARCHAR](MAX)	= NULL
						)
AS
BEGIN
	DECLARE @isValido	[BIT];

	SET @isValido = CAST(0 AS [BIT]);

	IF EXISTS(SELECT 1
				FROM [dbo].[usuario] [U] WITH (NOLOCK)
				WHERE [u].[login] = @login 
				  AND [u].[senhaHash] = @senhaHash)
	BEGIN
		SET @isValido = CAST(1 AS [BIT]);
	END

	SELECT @isValido [isValido];
END
GO
----------------------------------------------------------------------------------------------------------------
USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'usuarioDelete')
BEGIN
	DROP PROCEDURE [dbo].[usuarioDelete];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usuarioDelete]
                       (@idUsuario  [INT]
					   )
AS
BEGIN
	DECLARE @qtdDeletado [TINYINT];

	SET @qtdDeletado = 0;
	DELETE 
	  FROM [dbo].[usuario] 
	 WHERE [idUsuario] = @idUsuario;
	SET @qtdDeletado = @@ROWCOUNT;

	SELECT @qtdDeletado qtdDeletado;
END
----------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1
				FROM SysObjects 
				WHERE name = 'metodo')
BEGIN
	CREATE TABLE [dbo].[metodo] (
				 [idmetodo]			[TINYINT]		NOT NULL IDENTITY(01,01),
				 [metodo]			[VARCHAR](50)	NOT NULL
		CONSTRAINT	[PK_metodo] PRIMARY KEY CLUSTERED 
				 (
					[idmetodo] ASC
				 ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	);
END;
GO

IF NOT EXISTS(SELECT 1 FROM [dbo].[metodo] WHERE [metodo] = 'GET')		INSERT INTO [dbo].[metodo] ([metodo]) VALUES ('GET');
IF NOT EXISTS(SELECT 1 FROM [dbo].[metodo] WHERE [metodo] = 'POST')		INSERT INTO [dbo].[metodo] ([metodo]) VALUES ('POST');
IF NOT EXISTS(SELECT 1 FROM [dbo].[metodo] WHERE [metodo] = 'PUT')		INSERT INTO [dbo].[metodo] ([metodo]) VALUES ('PUT');
IF NOT EXISTS(SELECT 1 FROM [dbo].[metodo] WHERE [metodo] = 'PATH')		INSERT INTO [dbo].[metodo] ([metodo]) VALUES ('PATH');
IF NOT EXISTS(SELECT 1 FROM [dbo].[metodo] WHERE [metodo] = 'DELETE')	INSERT INTO [dbo].[metodo] ([metodo]) VALUES ('DELETE');

GO
----------------------------------------------------------------------------------------------------------------
USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'metodoSelectAll')
BEGIN
	DROP PROCEDURE [dbo].[metodoSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[metodoSelectAll]
						(@idmetodo		[TINYINT]		= NULL
						,@metodo		[VARCHAR](50)	= NULL
						)
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	if @idmetodo = 0 
	BEGIN
		SET @idmetodo = NULL;
	END

	SET @Parameters = N' @idmetodo [TINYINT] ,@metodo [VARCHAR](50) ';
	SET @Msql		= N' SELECT [s].[idmetodo] ,[s].[metodo] FROM [dbo].[metodo] [s] WITH (NOLOCK) ';

	SET @Operator = N' WHERE ';

	IF @idmetodo IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [s].[idmetodo] = @idmetodo ';
		SET @Operator = N' AND ';
	END;
	IF @metodo IS NOT NULL
	BEGIN
		SET @metodo = '%' + RTRIM(LTRIM(@metodo)) + '%';

		SET @MSql = @MSql + @Operator + N' [s].[metodo] LIKE ' + '''' + @metodo + '''' + ' '
		SET @Operator = N' AND ';
	END;

	SET @Msql = @MSql + N' ORDER BY [s].[idmetodo]; ';

	EXECUTE sp_executeSql @MSql , @Parameters, @idmetodo ,@metodo ;
END
GO
----------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1
				FROM SysObjects 
				WHERE name = 'Api')
BEGIN
	CREATE TABLE [dbo].[Api](
				 [idApi]				[INT] IDENTITY(1,1) NOT NULL,
				 [nome]					[VARCHAR](100)		NOT NULL,
				 [idmetodo]				[TINYINT]			NULL,
				 [endPoint]				[VARCHAR](MAX)		NOT NULL,
				 [corpo]				[VARCHAR](MAX),
				 [isConstroiCorpo]		[BIT]				NOT NULL,
				 [ordem]				[TINYINT],
				 [isAtivo]				[BIT]
				 CONSTRAINT	[PK_Api] PRIMARY KEY CLUSTERED 
				 (
					[idApi] ASC
				 ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
				 CONSTRAINT FK_Api__Tipo FOREIGN KEY ([idmetodo])
						REFERENCES [dbo].[metodo] ([idmetodo])
				 ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END;
GO 
-------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiQtde')
BEGIN
	DROP PROCEDURE [dbo].[apiQtde];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiQtde]
AS
BEGIN
	DECLARE @qtde	[INT];

	SET @qtde = 0;

	IF OBJECT_ID('api') IS NOT NULL
	BEGIN
		SET @qtde = ISNULL((SELECT COUNT(1) 
							  FROM [dbo].[api] WITH (NOLOCK)), 0);
	END;

	SELECT @qtde [apiQtde];
END
GO
----------------------------------------------------------------------------------------------------------------
USE [Gapis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
		   WHERE name = 'ApiSave')
BEGIN
	DROP PROCEDURE [dbo].[ApiSave];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiSave] 
					  (@idApi				[INT]			= NULL,
					   @nome				[VARCHAR](100)	= NULL,
					   @idmetodo			[TINYINT]		= NULL,
					   @endPoint			[VARCHAR](MAX)	= NULL,
					   @corpo				[VARCHAR](MAX)	= NULL,
					   @isConstroiCorpo		[BIT]			= NULL,
					   @ordem				[TINYINT]		= NULL,
					   @isAtivo				[BIT]			= NULL
						)
AS
BEGIN
	IF NOT EXISTS(SELECT 1
					FROM [dbo].[Api] WITH (NOLOCK)
				   WHERE [idApi] = ISNULL(@idApi, 0))
	BEGIN
		INSERT INTO [dbo].[Api] 
					([nome]
					,[idMetodo]
					,[endPoint]
					,[corpo]
					,[isConstroiCorpo]
					,[ordem]
					,[isAtivo])
			VALUES	(@nome
					,@idMetodo
					,@endPoint
					,@corpo
					,@isConstroiCorpo
					,@ordem
					,@isAtivo);

		SET @idApi = IDENT_CURRENT('Api');
	END
	ELSE
	BEGIN
		UPDATE [dbo].[Api]
		   SET [nome]			= ISNULL(@nome, [nome])
			,  [idmetodo]		= ISNULL(@idMetodo, [idMetodo])
			,  [endPoint]		= ISNULL(@endPoint, [endPoint])
			,  [corpo]			= ISNULL(@corpo, [corpo])
			,  [isConstroiCorpo]= ISNULL(@isConstroiCorpo, [isConstroiCorpo])
			,  [ordem]			= ISNULL(@ordem, [ordem])
			,  [isAtivo]		= ISNULL(@isAtivo, [isAtivo])
		 WHERE [idApi] = @idApi;
	END

	SELECT @idApi [idApi];
END
GO
----------------------------------------------------------------------------------------------------------------
USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiSelectAll')
BEGIN
	DROP PROCEDURE [dbo].[apiSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiSelectAll]
					  (@idApi				[INT]			= NULL,
					   @nome				[VARCHAR](100)	= NULL,
					   @idmetodo			[TINYINT]		= NULL,
					   @endPoint			[VARCHAR](MAX)	= NULL,
					   @corpo				[VARCHAR](MAX)	= NULL,
					   @isConstroiCorpo		[BIT]			= NULL,
					   @ordem				[TINYINT]		= NULL,
					   @isAtivo				[BIT]			= NULL
						)
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	if @idApi = 0
	BEGIN
		SET @idApi = NULL;
	END
	
	SET @Parameters = N' @idApi [INT] ,@nome [VARCHAR](100) ,@idmetodo [TINYINT] ,@endPoint [VARCHAR](MAX) ,@corpo [VARCHAR](MAX) ,@isConstroiCorpo [BIT] ,@ordem [TINYINT] ,@isAtivo [BIT] ';
	SET @Msql		= N' SELECT [a].[idApi] ,[a].[nome] ,[a].[idmetodo] ,[m].[metodo] ,[a].[endPoint] ,[a].[corpo] ,[a].[isConstroiCorpo] ,[a].[ordem] ,[a].[isAtivo] FROM [dbo].[api] [a] WITH (NOLOCK) LEFT JOIN [dbo].[metodo] [m] WITH (NOLOCK) ON [m].[idMetodo] = [a].[idMetodo] ';

	SET @Operator = N' WHERE ';

	IF @idApi IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idApi] = @idApi ';
		SET @Operator = N' AND ';
	END;
	IF @nome IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[nome] = @nome ';
		SET @Operator = N' AND ';
	END;
	IF @idmetodo IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idmetodo] = @idmetodo ';
		SET @Operator = N' AND ';
	END;
	IF @endPoint IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[endPoint] = @endPoint ';
		SET @Operator = N' AND ';
	END;
	IF @corpo IS NOT NULL
	BEGIN
		SET @corpo = '%' + RTRIM(LTRIM(@corpo)) + '%';

		SET @MSql = @MSql + @Operator + N' [a].[corpo] LIKE ' + '''' + @corpo + '''' + ' '
		SET @Operator = N' AND ';
	END;
	IF @isConstroiCorpo IS NOT NULL
	BEGIN
		IF @isConstroiCorpo = CAST(0 AS BIT)
		BEGIN
			SET @MSql = @Msql + @Operator + N' [a].[isConstroiCorpo] = CAST(0 AS BIT) ';
		END
		ELSE
		BEGIN
			SET @MSql = @Msql + @Operator + N' [a].[isConstroiCorpo] = CAST(1 AS BIT) ';
		END;

		SET @Operator = N' AND ';
	END;
	IF @ordem IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[ordem] = @ordem ';
		SET @Operator = N' AND ';
	END;
	IF @isAtivo IS NOT NULL
	BEGIN
		IF @isAtivo = CAST(0 AS BIT)
		BEGIN
			SET @MSql = @Msql + @Operator + N' [a].[isAtivo] = CAST(0 AS BIT) ';
		END
		ELSE
		BEGIN
			SET @MSql = @Msql + @Operator + N' [a].[isAtivo] = CAST(1 AS BIT) ';
		END;

		SET @Operator = N' AND ';
	END;

	SET @Msql = @Msql + N' ORDER BY [m].[metodo], [A].[nome];';

	EXECUTE sp_executeSql @MSql , @Parameters, @idApi ,@nome ,@idmetodo ,@endPoint ,@corpo ,@isConstroiCorpo ,@ordem ,@isAtivo;
END
/*



exec [dbo].[apiSelectAll]  @idApi				= NULL,
						   @nome				= NULL,
						   @idmetodo			= NULL,
						   @endPoint			= NULL,
						   @corpo				= NULL,
						   @isConstroiCorpo		= NULL,
						   @ordem				= NULL,
						   @isAtivo				= NULL

*/
GO
----------------------------------------------------------------------------------------------------------------

/*
curl --request get \
	--url 'https://{accountname}.{environment}.com.br/api/catalog/pvt/stockkeepingunit' \
	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--header 'X-VTEX-API-AppKey: ' \
	--header 'X-VTEX-API-AppToken: '
*/

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1
				FROM SysObjects 
				WHERE name = 'ApiHeader')
BEGIN
	CREATE TABLE [dbo].[ApiHeader](
				 [idApiHeader]			[INT]			NOT NULL	IDENTITY(01,01),
				 [idApi]				[INT]			NOT NULL,
				 [headerName]			[VARCHAR](250)	NOT NULL,
				 [headerValue]			[VARCHAR](MAX)	NOT NULL,
				 CONSTRAINT	[PK_ApiHeader] PRIMARY KEY CLUSTERED 
				 (
					[idApiHeader] ASC
				 ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
				 )
END
GO

IF OBJECT_ID('FK_ApiHeader_Api__id_Api') IS NULL
BEGIN
   ALTER TABLE [dbo].[ApiHeader]
     ADD CONSTRAINT [FK_ApiHeader_Api__id_Api]
         FOREIGN KEY ([idApi]) REFERENCES [dbo].[Api] ([idApi]);
END
GO

----------------------------------------------------------------------------------------------------------------
USE [Gapis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
		   WHERE name = 'ApiHeaderSave')
BEGIN
	DROP PROCEDURE [dbo].[ApiHeaderSave];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ApiHeaderSave]
					(@idApiHeader			[INT]			= NULL,
					 @idApi					[INT],
					 @headerName			[VARCHAR](250),
					 @headerValue			[VARCHAR](MAX)
					 )
AS
BEGIN
	IF NOT EXISTS(SELECT 1
					FROM [dbo].[ApiHeader] [AH] WITH (NOLOCK)
				   WHERE [AH].[idApiHeader] = ISNULL(@idApiHeader, 0))
	BEGIN
		INSERT INTO [dbo].[ApiHeader]
					([idApi]
					,[headerName]
					,[headerValue])
			VALUES	(@idApi	
					,@headerName
					,@headerValue);

		SET @idApiHeader = IDENT_CURRENT('ApiHeader');
	END
	ELSE
	BEGIN
		UPDATE [dbo].[ApiHeader]
		   SET [idApi]			= @idApi
			  ,[headerName]		= @headerName
			  ,[headerValue]	= @headerValue
		 WHERE [idApiHeader] = @idApiHeader;
	END;

	SELECT @idApi [idApi], @idApiHeader [idApiHeader];
END
GO
-----------------------------------------------------------------------------------------------------------------------------
USE [Gapis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
		   WHERE name = 'ApiHeaderDelete')
BEGIN
	DROP PROCEDURE [dbo].[ApiHeaderDelete];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ApiHeaderDelete]
					(@idApiHeader			[INT]
					,@idApi					[INT]
					 )
AS
BEGIN
    DECLARE @qtde	[INT];

	DELETE 
	  FROM [dbo].[ApiHeader]
	 WHERE [idApi] = @idApi
	   AND [idApiHeader] = @idApiHeader;

	SET @qtde = @@ROWCOUNT;

	SELECT @qtde [qtde];
END
GO
-----------------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiHeaderSelectAll')
BEGIN
	DROP PROCEDURE [dbo].[apiHeaderSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiHeaderSelectAll] 
					  (@idApiHeader			[INT]			= NULL,	
					   @idApi				[INT]			= NULL,
					   @headerName			[VARCHAR](250)	= NULL
						)
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	SET @Parameters = N' @idApiHeader [INT] ,@idApi [INT] ,@headerName [VARCHAR](250) ';
	--SET @Msql		= N' SELECT [a].[idApiHeader] ,[idApi] ,[headerName] ,[headerValue], ROW_NUMBER() OVER (ORDER BY [a].[idApi], [a].[idApiHeader]) [Linha]	FROM [dbo].[apiHeader] [a] WITH (NOLOCK) ';
	SET @Msql		= N' SELECT [a].[idApiHeader] ,[idApi] ,[headerName] ,CASE
	                                                                         WHEN [a].[idApi] = 4 and [a].[idApiHeader]=2
																			     THEN REPLACE([a].[headerValue], ''&CPF'', ''72689234904'')
																			 ELSE
																			    [a].[headerValue]
	                                                                      END
	[headerValue], ROW_NUMBER() OVER (ORDER BY [a].[idApi], [a].[idApiHeader]) [Linha]	FROM [dbo].[apiHeader] [a] WITH (NOLOCK) ';

	SET @Operator = N' WHERE ';

	IF @idApiHeader  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idHeaderApi] = @idApiHeader ';
		SET @Operator = N' AND ';
	END;
	IF @idApi  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idApi] = @idApi ';
		SET @Operator = N' AND ';
	END;

	IF @headerName IS NOT NULL
	BEGIN
		SET @headerName = '%' + RTRIM(LTRIM(@headerName)) + '%';

		SET @MSql = @MSql + @Operator + N' [a].[headerName] LIKE ' + '''' + @headerName + '''' + ' '
		SET @Operator = N' AND ';
	END;


 	EXECUTE sp_executeSql @MSql , @Parameters, @idApiHeader ,@idApi ,@headerName ;
END
GO
-------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiHeaderQtde')
BEGIN
	DROP PROCEDURE [dbo].[apiHeaderQtde];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiHeaderQtde]
                       (@idApi      [INT])
AS
BEGIN
	DECLARE @qtde	[INT];

	SET @qtde = ISNULL((SELECT COUNT(1) 
						  FROM [dbo].[apiHeader] WITH (NOLOCK)
						 WHERE [idApi] = @idApi), 0);

	SELECT @qtde [apiHeaderQtde];
END
GO
-------------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiHeaderSelectStep')
BEGIN
	DROP PROCEDURE [dbo].[apiHeaderSelectStep];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiHeaderSelectStep]
					   (@sinal		  [VARCHAR](05)
					   ,@idApi		  [INT]
					   ,@idApiHeader  [INT]
					   )
AS
BEGIN
	DECLARE @step	[INT];

	if @sinal = '|<'
	BEGIN
		SELECT TOP 1
			   [idApiHeader]
			  ,[idApi]
			  ,[headerName]
			  ,[headerValue]
		  FROM [dbo].[apiHeader] WITH (NOLOCK) 
		 WHERE [idApi] = @idApi
		ORDER BY [idApi], [idApiHeader];
	END;

	if @sinal = '>|'
	BEGIN
		SELECT TOP 1
			   [idApiHeader]
			  ,[idApi]
			  ,[headerName]
			  ,[headerValue]
		  FROM [dbo].[apiHeader] WITH (NOLOCK)
		 WHERE [idApi] = @idApi
		ORDER BY [idApi] DESC, [idApiHeader] DESC;
	END

	IF @sinal = '<'
	BEGIN
		SET @step = -1;
	END

	IF @sinal = '>'
	BEGIN
		SET @step = 1;
	END

	DECLARE @idLinhaIdApiHeader	[INT];
	DECLARE @idApiHeaderMin		[INT];
	DECLARE @idApiHeaderMax		[INT];

	SET @idApiHeaderMin = (SELECT MIN([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idApi]
									,  [A].[idApiHeader]
									FROM (
									SELECT [idApiHeader]
										  ,[idApi]
										  ,[headerName]
										  ,[headerValue]
											,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiHeader]) [idLinha]
										FROM [dbo].[apiHeader] WITH (NOLOCK)
									   WHERE [idApi] = @idApi
										) AS [A]
								) AS [B]);

	SET @idApiHeaderMax = (SELECT MAX([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idApi]
									,  [A].[idApiHeader]
									FROM (
									SELECT [idApiHeader]
										  ,[idApi]
										  ,[headerName]
										  ,[headerValue]
											,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiHeader]) [idLinha]
										FROM [dbo].[apiHeader] WITH (NOLOCK)
									   WHERE [idApi] = @idApi
										) AS [A]
									WHERE [A].[idApi] = @idApi
								) AS [B]);

	IF @sinal IN ('<', '>')
	BEGIN
		SET @idLinhaIdApiHeader = ISNULL((
									SELECT [B].[idLinha]
									  FROM (
											SELECT [A].[idLinha]
												,  [A].[idApi]
												FROM (
												SELECT [idApiHeader]
													  ,[idApi]
													  ,[headerName]
													  ,[headerValue]
													  ,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiHeader]) [idLinha]
													FROM [dbo].[apiHeader] WITH (NOLOCK)
												   WHERE [idApi] = @idApi
													) AS [A]
												WHERE [A].[idApi] = @idApi
												  AND [A].[idApiHeader] = @idApiHeader
											) AS [B]
										), 0);

		SET @idLinhaIdApiHeader = @idLinhaIdApiHeader + (@step);

		IF @sinal = '<'
		   AND @idLinhaIdApiHeader <= 0
		BEGIN
			SET @idLinhaIdApiHeader = @idApiHeaderMin;
		END

		IF @sinal = '>'
		   AND (@idLinhaIdApiHeader = 0
				OR @idLinhaIdApiHeader > @idApiHeaderMax)
		BEGIN
			SET @idLinhaIdApiHeader = @idApiHeaderMax;
		END

		IF @idLinhaIdApiHeader > 0
		BEGIN
			SELECT [A].[idApiHeader]
				  ,[A].[idApi]
				  ,[A].[headerName]
				  ,[A].[headerValue]
			  FROM (
					SELECT [idApiHeader]
						  ,[idApi]
						  ,[headerName]
						  ,[headerValue]
						  ,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiHeader]) [idLinha]
					  FROM [dbo].[apiHeader] WITH (NOLOCK) 
					 WHERE [idApi] = @idApi
					) AS [A] 
			 WHERE [A].[idLinha] = @idLinhaIdApiHeader
			   
		END
	END
END
GO
------------------------------------------------------------------------------------------------------------------------------------
USE GAPIS;
go

IF NOT EXISTS(SELECT 1
                FROM SysObjects 
			   WHERE name = 'ApiParameter')
BEGIN
	CREATE TABLE [dbo].[ApiParameter](
				 [idApiParameter]			[INT]			NOT NULL	IDENTITY(01,01),
				 [idApi]					[INT]			NOT NULL,
				 [contentType]			    [VARCHAR](250)  NOT NULL,
				 [parameterName]			[VARCHAR](250)	NOT NULL,
				 [parameterValue]			[VARCHAR](MAX)	NOT NULL,
				 CONSTRAINT	[PK_ApiParameter] PRIMARY KEY CLUSTERED 
				 (
					[idApiParameter] ASC
				 ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
				 )
END;
GO

IF OBJECT_ID('FK_ApiParameter_Api__id_Api') IS NULL
BEGIN
   ALTER TABLE [dbo].[ApiParameter]
     ADD CONSTRAINT [FK_ApiParameter_Api__id_Api]
         FOREIGN KEY ([idApi]) REFERENCES [dbo].[Api] ([idApi]);
END
GO

----------------------------------------------------------------------------------------------------------------
USE [Gapis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
		   WHERE name = 'ApiParameterSave')
BEGIN
	DROP PROCEDURE [dbo].[ApiParameterSave];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ApiParameterSave]
					(@idApiParameter			[INT]			= NULL,
					 @idApi						[INT],
					 @contentType				[VARCHAR](250),
					 @ParameterName				[VARCHAR](250),
					 @ParameterValue			[VARCHAR](MAX)
					 )
AS
BEGIN
	IF NOT EXISTS(SELECT 1
					FROM [dbo].[ApiParameter] [AH] WITH (NOLOCK)
				   WHERE [AH].[idApiParameter] = ISNULL(@idApiParameter, 0))
	BEGIN
		INSERT INTO [dbo].[ApiParameter]
					([idApi]
					,[contentType]
					,[parameterName]
					,[parameterValue])
			VALUES	(@idApi	
			        ,@contentType
					,@parameterName
					,@parameterValue);

		SET @idApiParameter = IDENT_CURRENT('ApiParameter');
	END
	ELSE
	BEGIN
		UPDATE [dbo].[ApiParameter]
		   SET [idApi]				= @idApi
		      ,[contentType]        = @contentType
			  ,[parameterName]		= @parameterName
			  ,[parameterValue]		= @parameterValue
		 WHERE [idApiParameter]		= @idApiParameter;
	END;

	SELECT @idApi [idApi], @idApiParameter [idApiParameter];
END
GO
-----------------------------------------------------------------------------------------------------------------------------
USE [Gapis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
		   WHERE name = 'ApiParameterDelete')
BEGIN
	DROP PROCEDURE [dbo].[ApiParameterDelete];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ApiParameterDelete]
					(@idApiParameter			[INT]
					,@idApi						[INT]
					 )
AS
BEGIN
    DECLARE @qtde	[INT];

	DELETE 
	  FROM [dbo].[ApiParameter]
	 WHERE [idApi] = @idApi
	   AND [idApiParameter] = @idApiParameter;

	SET @qtde = @@ROWCOUNT;

	SELECT @qtde [qtde];
END
GO
-----------------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiParameterSelectAll')
BEGIN
	DROP PROCEDURE [dbo].[apiParameterSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiParameterSelectAll] 
					  (@idApiParameter			[INT]			= NULL,	
					   @idApi				    [INT]			= NULL,
					   @ParameterName			[VARCHAR](250)	= NULL
						)
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	SET @Parameters = N' @idApiParameter [INT] ,@idApi [INT] ,@ParameterName [VARCHAR](250) ';
	SET @Msql		= N' SELECT [a].[idApiParameter] ,[a].[contentType] ,[idApi] ,[ParameterName] ,[ParameterValue], ROW_NUMBER() OVER (ORDER BY [a].[idApi], [a].[idApiParameter]) [Linha]	FROM [dbo].[apiParameter] [a] WITH (NOLOCK) ';

	SET @Operator = N' WHERE ';

	IF @idApiParameter  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idParameterApi] = @idApiParameter ';
		SET @Operator = N' AND ';
	END;
	IF @idApi  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [a].[idApi] = @idApi ';
		SET @Operator = N' AND ';
	END;

	IF @ParameterName IS NOT NULL
	BEGIN
		SET @ParameterName = '%' + RTRIM(LTRIM(@ParameterName)) + '%';

		SET @MSql = @MSql + @Operator + N' [a].[ParameterName] LIKE ' + '''' + @ParameterName + '''' + ' '
		SET @Operator = N' AND ';
	END;


 	EXECUTE sp_executeSql @MSql , @Parameters, @idApiParameter ,@idApi ,@ParameterName ;
END
GO
-------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiParameterQtde')
BEGIN
	DROP PROCEDURE [dbo].[apiParameterQtde];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiParameterQtde]
                       (@idApi      [INT])
AS
BEGIN
	DECLARE @qtde	[INT];

	SET @qtde = ISNULL((SELECT COUNT(1) 
						  FROM [dbo].[apiParameter] WITH (NOLOCK)
						 WHERE [idApi] = @idApi), 0);

	SELECT @qtde [apiParameterQtde];
END
GO
-------------------------------------------------------------------------------------------------------------------------

USE [GApis];
GO

IF EXISTS(SELECT 1
			FROM SysObjects 
			WHERE name = 'apiParameterSelectStep')
BEGIN
	DROP PROCEDURE [dbo].[apiParameterSelectStep];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiParameterSelectStep]
					   (@sinal		  [VARCHAR](05)
					   ,@idApi		  [INT]
					   ,@idApiParameter  [INT]
					   )
AS
BEGIN
	DECLARE @step	[INT];

	if @sinal = '|<'
	BEGIN
		SELECT TOP 1
			   [idApiParameter]
			  ,[idApi]
			  ,[contentType]
			  ,[ParameterName]
			  ,[ParameterValue]
		  FROM [dbo].[apiParameter] WITH (NOLOCK) 
		 WHERE [idApi] = @idApi
		ORDER BY [idApi], [idApiParameter];
	END;

	if @sinal = '>|'
	BEGIN
		SELECT TOP 1
			   [idApiParameter]
			  ,[idApi]
			  ,[contentType]
			  ,[ParameterName]
			  ,[ParameterValue]
		  FROM [dbo].[apiParameter] WITH (NOLOCK)
		 WHERE [idApi] = @idApi
		ORDER BY [idApi] DESC, [idApiParameter] DESC;
	END

	IF @sinal = '<'
	BEGIN
		SET @step = -1;
	END

	IF @sinal = '>'
	BEGIN
		SET @step = 1;
	END

	DECLARE @idLinhaIdApiParameter	[INT];
	DECLARE @idApiParameterMin		[INT];
	DECLARE @idApiParameterMax		[INT];

	SET @idApiParameterMin = (SELECT MIN([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idApi]
									,  [A].[idApiParameter]
									FROM (
									SELECT [idApiParameter]
										  ,[idApi]
										  ,[ParameterName]
										  ,[ParameterValue]
											,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiParameter]) [idLinha]
										FROM [dbo].[apiParameter] WITH (NOLOCK)
									   WHERE [idApi] = @idApi
										) AS [A]
								) AS [B]);

	SET @idApiParameterMax = (SELECT MAX([B].[idLinha])
							FROM (
								SELECT [A].[idLinha]
									,  [A].[idApi]
									,  [A].[idApiParameter]
									FROM (
									SELECT [idApiParameter]
										  ,[idApi]
										  ,[ParameterName]
										  ,[ParameterValue]
											,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiParameter]) [idLinha]
										FROM [dbo].[apiParameter] WITH (NOLOCK)
									   WHERE [idApi] = @idApi
										) AS [A]
									WHERE [A].[idApi] = @idApi
								) AS [B]);

	IF @sinal IN ('<', '>')
	BEGIN
		SET @idLinhaIdApiParameter = ISNULL((
									SELECT [B].[idLinha]
									  FROM (
											SELECT [A].[idLinha]
												,  [A].[idApi]
												FROM (
												SELECT [idApiParameter]
													  ,[idApi]
													  ,[ParameterName]
													  ,[ParameterValue]
													  ,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiParameter]) [idLinha]
													FROM [dbo].[apiParameter] WITH (NOLOCK)
												   WHERE [idApi] = @idApi
													) AS [A]
												WHERE [A].[idApi] = @idApi
												  AND [A].[idApiParameter] = @idApiParameter
											) AS [B]
										), 0);

		SET @idLinhaIdApiParameter = @idLinhaIdApiParameter + (@step);

		IF @sinal = '<'
		   AND @idLinhaIdApiParameter <= 0
		BEGIN
			SET @idLinhaIdApiParameter = @idApiParameterMin;
		END

		IF @sinal = '>'
		   AND (@idLinhaIdApiParameter = 0
				OR @idLinhaIdApiParameter > @idApiParameterMax)
		BEGIN
			SET @idLinhaIdApiParameter = @idApiParameterMax;
		END

		IF @idLinhaIdApiParameter > 0
		BEGIN
			SELECT [A].[idApiParameter]
				  ,[A].[idApi]
				  ,[A].[contentType]
				  ,[A].[ParameterName]
				  ,[A].[ParameterValue]
			  FROM (
					SELECT [idApiParameter]
						  ,[idApi]
						  ,[contentType]
						  ,[ParameterName]
						  ,[ParameterValue]
						  ,ROW_NUMBER() OVER(ORDER BY [idApi], [idApiParameter]) [idLinha]
					  FROM [dbo].[apiParameter] WITH (NOLOCK) 
					 WHERE [idApi] = @idApi
					) AS [A] 
			 WHERE [A].[idLinha] = @idLinhaIdApiParameter
			   
		END
	END
END
GO
---------------------------------------------------------------------------------------------------
USE [Gapis]
GO

/****** Object:  Table [dbo].[ApiHeader]    Script Date: 20/08/2023 09:02:14 ******/
SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('ApiDemandaComunica') IS NULL
BEGIN
	CREATE TABLE [dbo].[ApiDemandaComunica] (
	    [idApiDemandaComunica]	[BIGINT]		IDENTITY(01,01) NOT NULL
	   ,[idApi]					[INT]			NOT NULL
	   ,[dataDemanda]			[DATETIME]		NOT NULL
	   ,[nomeApi]               [VARCHAR](100)  NULL
	   ,[endPoint]              [VARCHAR](MAX)  NULL
	   ,[corpo]                 [VARCHAR](MAX)  NULL
	   ,[chaveExterna]		    [VARCHAR](255)  NULL
	   ,[observacao]			[VARCHAR](MAX)  NULL
	   ,[isDemandaAtendida]		[BIT]			NULL
	   ,[dataDemandaAtendida]	[DATETIME]		NULL
	   ,[codigoRetorno]         [VARCHAR](100)  NULL
	   ,[corpoRetorno]          [VARCHAR](MAX)  NULL
	   ,[corpoRetornoXml]       [XML]           NULL
	   ,[isProcessadoExterno]   [BIT]           NULL
	   ,[dataProcessadoExterno] [DATETIME]      NULL
	   ,CONSTRAINT [PK_ApiDemandaComunica] PRIMARY KEY NONCLUSTERED
	      (
		     [idApiDemandaComunica] ASC
		  ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
     ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO

IF OBJECT_ID('FK_ApiDemandaComunica_Api__id_Api') IS NULL
BEGIN
	ALTER TABLE [dbo].[ApiDemandaComunica]  WITH CHECK ADD  
		CONSTRAINT [FK_ApiDemandaComunica_Api__id_Api] FOREIGN KEY([idApi]) REFERENCES [dbo].[Api] ([idApi]);
END
GO

ALTER TABLE [dbo].[ApiDemandaComunica] CHECK CONSTRAINT [FK_ApiDemandaComunica_Api__id_Api];
GO

-------------------------------------------------------------------------------------------------------

USE [Gapis];
GO

IF OBJECT_ID('fncConstroiEndPoint') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[fncConstroiEndPoint];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fncConstroiEndPoint] (@idApi INT
                                           , @chave VARCHAR(100) = NULL)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @newEndPoint	[VARCHAR](MAX);
	DECLARE @endPoint		[VARCHAR](MAX);
	DECLARE @Min			[INT] = 250;
	DECLARE @Max			[INT] = 300;
	DECLARE @RandomNumber	[DECIMAL](20,15);
	DECLARE @numEmpresa		[INT];
	DECLARE @empresa		[VARCHAR](100);

	SET @endPoint = (SELECT [a].[endPoint]
						   FROM [dbo].[Api] [a] WITH (NOLOCK)
						  WHERE [a].[idApi] = @idApi);

	SET @newEndPoint = @endPoint;

	if @idApi = 1 -- Busca endereço por Cep
	BEGIN
		SET @newEndPoint = REPLACE(@endPoint, '&cep', '82600630');
	END

	if @idApi = 2  -- Busca dados de um CNPJ
	BEGIN
		SET @newEndPoint = REPLACE(@endPoint, '&CNPJ', '05576805000100');
	END


    RETURN @newEndPoint;
END;
/*

select [dbo].[fncConstroiEndPoint](2)

*/
GO
-----------------------------------------------------
USE [Gapis];
GO

IF OBJECT_ID('fncConstroiCorpo') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[fncConstroiCorpo];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fncConstroiCorpo] (@idApi INT
                                        , @chave VARCHAR(100) = NULL)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @newCorpo [VARCHAR](MAX);
	DECLARE @Corpo    [VARCHAR](MAX);

	SET @Corpo = ISNULL((SELECT [a].[corpo]
						   FROM [dbo].[Api] [a] WITH (NOLOCK)
						  WHERE [a].[idApi] = @idApi), '');

	SET @newCorpo = @corpo;

	RETURN @newCorpo;
END;
/*

select [dbo].[fncConstroiCorpo](4, null)

*/

GO
-----------------------------------------------------
USE [Gapis];
GO

IF OBJECT_ID('fncConstroiChaveExterna') IS NOT NULL
BEGIN
	DROP FUNCTION [dbo].[fncConstroiChaveExterna];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fncConstroiChaveExterna] (@idApi INT
											   , @chave VARCHAR(100) = NULL)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @newChave [VARCHAR](255);

	SET @newChave = RIGHT(REPLICATE('0',5) + CAST(@idApi AS VARCHAR), 5) + '_EXTERNAL_KEY' ;

	RETURN @newChave;   
END;
/*

select [dbo].[fncConstroiChaveExterna](3, null)

*/

GO

--------------------------------------------------------------------------------------------------------
USE [Gapis]
GO

IF OBJECT_ID('ApiDemandaComunicaSave') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[ApiDemandaComunicaSave];
END
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApiDemandaComunicaSave]
					 (@idApiDemandaComunica			[BIGINT]		= NULL
					 ,@idApi						[INT]
					 ,@endPoint						[VARCHAR](MAX)  = NULL
					 ,@corpo                        [VARCHAR](MAX)  = NULL
				     ,@chaveExterna					[VARCHAR](255)  = NULL
					 ,@observacao			        [VARCHAR](MAX)  = NULL
					 ,@isDemandaAtendida            [BIT]           = 0
					 ,@codigoRetorno                [VARCHAR](100)  = NULL
					 ,@corpoRetorno                 [VARCHAR](MAX)  = NULL
					 ,@corpoRetornoXml              [XML]			= NULL
					 ,@isProcessadoExterno          [BIT]           = 0
					)
AS
BEGIN
	DECLARE @dataAgora			[DATETIME];
	DECLARE @mensagem			[VARCHAR](255);
	DECLARE @RowCount			[INT]
	DECLARE @nomeApi			[VARCHAR](100);

	SET @dataAgora = GETDATE();
	SET @nomeApi   = (SELECT RTRIM([A].[nome])
	                    FROM [dbo].[Api] [A] WITH (NOLOCK)
				       WHERE [A].[idApi] = @idApi);

	IF ISNULL(@nomeApi, '') = ''
	BEGIN
		SET @mensagem = 'ERRO -> API não existente - por favor verifique!';
		RAISERROR(20002, 16, 10, @mensagem);
		RETURN;
	END;

	IF EXISTS(SELECT 1
				FROM [dbo].[Api] [A] WITH (NOLOCK)
			   WHERE [A].[idApi] = @idApi
			     AND [isAtivo] = CAST(0 AS BIT))
	BEGIN
		SET @mensagem = 'ATENÇÃO -> API desativada - por favor verifique!';
		RAISERROR(20002, -1, -1, @mensagem);
		RETURN;
	END

    SET @isDemandaAtendida = CASE
                                WHEN UPPER(RTRIM(LTRIM(@codigoRetorno))) = 'OK'
                                   THEN CAST(1 AS bit)
                                ELSE
                                   CAST(1 AS bit)
                             END;

	IF ISNULL(@idApiDemandaComunica, 0) = 0
	   OR NOT EXISTS(SELECT 1  -- select *
					   FROM [dbo].[ApiDemandaComunica] [AD] WITH (NOLOCK)
					  WHERE [AD].[idApiDemandaComunica] = @idApiDemandaComunica)
	BEGIN
        
		INSERT INTO [dbo].[ApiDemandaComunica] 
					([idApi]
					,[dataDemanda]
					,[nomeAPi]
					,[endPoint]
					,[corpo]
					,[chaveExterna]
					,[observacao]
					,[isDemandaAtendida]
					,[dataDemandaAtendida]
					,[codigoRetorno]
					,[corpoRetorno]
					,[corpoRetornoXml]
					,[isProcessadoExterno]
					,[dataProcessadoExterno])
			VALUES	(@idApi
					,@dataAgora
					,@nomeApi
					,@endPoint
					,@corpo
					,@chaveExterna
					,@observacao
					,@isDemandaAtendida
					,CASE 
						WHEN @isDemandaAtendida = CAST(1 AS BIT)
						   THEN @dataAgora
						ELSE
						   NULL
					 END
					,@codigoRetorno
					,@corpoRetorno
					,@corpoRetornoXml
					,@isProcessadoExterno
					,CASE 
						WHEN @isProcessadoExterno = CAST(1 AS BIT)
						   THEN @dataAgora
						ELSE
						   NULL
					 END
					);

		SET @rowCount = @@ROWCOUNT;
		SET @idApiDemandaComunica = IDENT_CURRENT('ApiDemandaComunica');
	END
	ELSE
	BEGIN
		UPDATE [dbo].[ApiDemandaComunica]
		   SET [nomeApi]				= ISNULL(@nomeApi, [nomeApi])
			  ,[endPoint]				= ISNULL(@endPoint,[endPoint])
			  ,[corpo]                  = ISNULL(@corpo, [corpo])
			  ,[chaveExterna]           = ISNULL(@chaveExterna, [chaveExterna])
			  ,[observacao]             = ISNULL(@observacao, [observacao])
			  ,[isDemandaAtendida]      = ISNULL(@isDemandaAtendida, [isDemandaAtendida])
			  ,[dataDemandaAtendida]    = CASE
				                              WHEN [dataDemandaAtendida] IS NULL 
											       AND @isDemandaAtendida = CAST(1 AS BIT)
												   THEN @dataAgora
											  ELSE
											       [dataDemandaAtendida]
			                              END
			  ,[codigoRetorno]          = ISNULL(@codigoRetorno, [codigoRetorno])
			  ,[corpoRetorno]           = ISNULL(@corpoRetorno, [corpoRetorno])
			  ,[corpoRetornoXml]        = ISNULL(@corpoRetornoXml, [corpoRetornoXml])
			  ,[isProcessadoExterno]    = ISNULL(@isProcessadoExterno, [isProcessadoExterno])
			  ,[dataProcessadoExterno]  = CASE
				                              WHEN [dataProcessadoExterno] IS NULL 
											       AND @isProcessadoExterno = CAST(1 AS BIT)
												   THEN @dataAgora
											  ELSE
											       [dataProcessadoExterno]
			                              END
		WHERE [idApiDemandaComunica] = @idApiDemandaComunica;

		SET @rowCount = @@ROWCOUNT;
	END

	SELECT [idApiDemandaComunica]					,[idApi]					,[dataDemanda]
		  ,[nomeAPi]						        ,[endPoint]                 ,[corpo]
		  ,[chaveExterna]							,[observacao]               ,[isDemandaAtendida]
		  ,[dataDemandaAtendida]					,[codigoRetorno]            ,[corpoRetorno]
		  ,[corpoRetornoXml]					    ,[isProcessadoExterno]      ,[dataProcessadoExterno]
	 FROM [ApiDemandaComunica] WITH (NOLOCK)
	WHERE [idApiDemandaComunica] = @idApiDemandaComunica;
END

/*
select  * from APIDemandaComunica
BEGIN TRANSACTION
declare @p9 xml
set @p9=convert(xml,N'<root type="object"><cpf_disponivel type="boolean">false</cpf_disponivel><cnh type="object"/><filiacao type="object"/><documento type="object"/><endereco type="object"/></root>')
exec ApiDemandaComunicaSave @idApiDemandaComunica=13
                           ,@idApi=4
                           ,@endPoint='https://gateway.apiserpro.serpro.gov.br/datavalid-demonstracao/v3/validate/pf-basica'
                           ,@corpo='{    "key": {      "cpf": "72689234904"    },    "answer": {      "nome": "MAURICIO BUESS",      "data_nascimento": "1968-08-02",      "situacao_cpf": "regular",      "sexo": "M",      "nacionalidade": 1,      "filiacao": {        "nome_mae": "MAURICIO BUESSMae",        "nome_pai": "MAURICIO BUESSPai"      },      "documento": {        "tipo": 1,        "numero": "3224915",        "orgao_expedidor": "SSP" },      "endereco": {        "logradouro": "R EVARISTO BERLEZE                   ",        "numero": "23",        "complemento": "",        "bairro": "BACACHERI",        "cep": "82600630",        "municipio": "CURITIBA",        "uf": "PR"      }    }  }'
                           ,@observacao='Chave externa é [idLinha] da tabela [Everest1].[dbo].[GAPIS_PessoaFisica]'
                           ,@isDemandaAtendida=1
                           ,@codigoRetorno='OK'
                           ,@corpoRetorno='{"cpf_disponivel":false,"cnh":{},"filiacao":{},"documento":{},"endereco":{}}'
                           ,@corpoRetornoXml=@p9
                           ,@isProcessadoExterno=0
ROLLBACK TRANSACTION

*/
GO

/*

-- delete from ApiDemandaComunica
select * from ApiDemandaComunica

*/
GO
------------------------------------------------------------------------------------------

USE [GApis];
GO

IF OBJECT_ID('apiDemandaComunicaSelectAll') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[apiDemandaComunicaSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiDemandaComunicaSelectAll] 
					  (@idApiDemandaComunica		[BIGINT]	= NULL
					  ,@idApi						[INT]		= NULL
					  ,@isDemandaAtendida			[BIT]		= NULL
					  )
AS
BEGIN

	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	------------------------------------------------------------
	-- Customização para geração de demanda das apis cadastradas
	
	-- Fim
	-- Customização para geração de demanda das apis cadastradas

	SET @Parameters = N' @idApiDemandaComunica [BIGINT]  ,@idApi [INT] ,@isDemandaAtendida [BIT] ';

											   
	SET @Msql		= N' INSERT INTO [dbo].[ApiDemandaComunica]
									([idApi]					,[dataDemanda]							,[nomeApi]
									,[endPoint]				    
									,[corpo]								
									,[chaveExterna]
									,[observacao]				
									,[isDemandaAtendida]		,[dataDemandaAtendida]
									,[codigoRetorno]			,[corpoRetorno]							,[corpoRetornoXml]
									,[isProcessadoExterno]		,[dataProcessadoExterno])
							  SELECT [A].[idApi]	            ,[A].[dataDemanda]                      ,[A].[nomeApi]      
									,[A].[endPoint]             
									,[A].[corpo]         
									,[A].[chaveExterna]        
									,[A].[observacao] 
									,[A].[isDemandaAtendida]    ,[A].[dataDemandaAtendida] 
									,[A].[codigoRetorno]		,[A].[corpoRetorno]                     ,[A].[corpoRetornoXml]
								    ,[A].[isProcessadoExterno]  ,[A].[dataProcessadoExterno] 
							FROM (
								SELECT  [API].[idApi]	        ,getdate() [dataDemanda]				,[API].[nome] [nomeApi]       
										,[dbo].[fncConstroiEndPoint]([API].[idApi], null) [endPoint]
										,[dbo].[fncConstroiCorpo]([API].[idApi], null) [corpo]
										,[dbo].[fncConstroiChaveExterna]([API].[idApi], null)  [chaveExterna]
										,NULL [observacao] 
										,CAST(0 AS BIT)  [isDemandaAtendida]    ,NULL [dataDemandaAtendida] 
										,NULL [codigoRetorno]       ,NULL [corpoRetorno]				,NULL [corpoRetornoXml] 
										,CAST(0 AS BIT) [isProcessadoExterno] ,NULL [dataProcessadoExterno] 
									FROM [dbo].[Api] [API] WITH (NOLOCK) 
									WHERE [API].[isConstroiCorpo] = CAST(1 AS BIT) 
									  AND [API].[isAtivo] = CAST(1 AS BIT)
									  ) as [A] ';
	SET @Operator = N' WHERE ';

	IF @idApi  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [A].[idApi] = @idApi ';
		SET @Operator = N' AND ';
	END;

	SET @Msql = @Msql + @Operator + N' NOT EXISTS(SELECT 1 FROM [dbo].[ApiDemandaComunica] [ADC] WITH (NOLOCK) WHERE [ADC].[idApi] = [A].[idApi] AND [ADC].[isDemandaAtendida] = CAST(0 AS BIT));'

 	EXECUTE sp_executeSql @MSql , @Parameters, @idApiDemandaComunica ,@idApi ,@isDemandaAtendida ;

	SET @Msql		= N' SELECT [A].[idApiDemandaComunica] ,[A].[idApi]	              ,[A].[dataDemanda]   ,[A].[nomeApi]      
	                           ,[A].[idMetodo]             ,[A].[metodo] 
	                           ,[A].[endPoint]             
							   ,[A].[isConstroiCorpo]     
							   ,[A].[corpo]         
							   ,[A].[ordem]                ,[A].[chaveExterna]        ,[A].[observacao] 
							   ,[A].[isDemandaAtendida]    ,[A].[dataDemandaAtendida] ,[A].[codigoRetorno] ,[A].[corpoRetorno] 
							   ,[A].[corpoRetornoXml]
							   ,[A].[isProcessadoExterno] 
							   ,[A].[dataProcessadoExterno] 
	                       FROM (SELECT [ADC].[idApiDemandaComunica]     ,[ADC].[idApi]	              ,[ADC].[dataDemanda]         ,[ADC].[nomeApi]       
						               ,[API].[idMetodo]                 ,[M].[metodo] 
						               ,COALESCE([dbo].[fncConstroiEndPoint]([API].[idApi], null),[ADC].[endPoint]) [endPoint]
									   ,[API].[isConstroiCorpo]     
									   ,COALESCE([dbo].[fncConstroiCorpo]([API].[idApi], null), [ADC].[corpo]) [corpo]
									   ,[API].[ordem]                    ,[ADC].[chaveExterna]        ,[ADC].[observacao] 
									   ,[ADC].[isDemandaAtendida]        ,[ADC].[dataDemandaAtendida] ,[ADC].[codigoRetorno]       ,[ADC].[corpoRetorno]  
									   ,[ADC].[corpoRetornoXml]
									   ,[ADC].[isProcessadoExterno] 
									   ,[ADC].[dataProcessadoExterno] 
	                               FROM [dbo].[ApiDemandaComunica] [ADC] WITH (NOLOCK)
			                            INNER JOIN [dbo].[Api] [API] WITH (NOLOCK)
				                           ON [API].[idApi] = [ADC].[idApi] 
										  AND [API].[isAtivo] = CAST(1 AS BIT)
										  AND [API].[isConstroiCorpo] = CAST(1 AS BIT)
										LEFT JOIN [dbo].[metodo] [M] WITH (NOLOCK)
										   ON [M].[idMetodo] = [API].[idMetodo] 
								   ) AS [A]  ';
	SET @Operator = N' WHERE ';

	IF @idApiDemandaComunica  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [A].[idApiDemandaComunica] = @idApiDemandaComunica ';
		SET @Operator = N' AND ';
	END;
	IF @idApi  IS NOT NULL
	BEGIN
		SET @MSql = @Msql + @Operator + N' [A].[idApi] = @idApi ';
		SET @Operator = N' AND ';
	END;

	IF @isDemandaAtendida IS NOT NULL
	BEGIN
		IF @isDemandaAtendida = CAST(1 AS [BIT])
		BEGIN
			SET @Msql = @Msql + @Operator + N' ISNULL([A].[isDemandaAtendida],0) = CAST(1 AS [BIT]) ';
			SET @operator = N' AND ';
		END
		
		IF @isDemandaAtendida = CAST(0 AS [BIT])
		BEGIN
			SET @Msql = @Msql + @Operator + N' ISNULL([A].[isDemandaAtendida],0) = CAST(0 AS [BIT]) ';
			SET @operator = N' AND ';
		END
	END;

 	EXECUTE sp_executeSql @MSql , @Parameters, @idApiDemandaComunica ,@idApi ,@isDemandaAtendida;
END

/*
select *  -- delete
  from APiDemandaComunica order by idApidemandaComunica

--  select * from APi

select '-------------------------'
EXEC [dbo].[apiDemandaComunicaSelectAll] @idApiDemandaComunica		= NULL
					                    ,@idApi						= NULL
					                    ,@isDemandaAtendida			= false



*/
GO
--------------------------------------------------------------------------------------------------------------------

USE [Gapis];
go

IF OBJECT_ID('apiDemandaSelectAll') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[apiDemandaSelectAll];
END;
GO

SET ANSI_NULLS OFF;
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[apiDemandaSelectAll]
AS
BEGIN
	DECLARE @Operator		[NVARCHAR](10);
	DECLARE @Parameters		[NVARCHAR](max);
	DECLARE @MSql			[NVARCHAR](max);

	SET @Msql		= N' SELECT [a].[idApi] ,[a].[nome] ,[a].[idmetodo] ,[m].[metodo] ,[dbo].[fncConstroiEndPoint]([a].[idApi], null) [endPoint] ,[dbo].[fncConstroiCorpo]([a].[idApi], null) [corpo] ,[a].[isConstroiCorpo] ,isnull([a].[ordem],0) [ordem] ,[a].[isAtivo] FROM [dbo].[api] [a] WITH (NOLOCK) LEFT JOIN [dbo].[metodo] [m] WITH (NOLOCK) ON [m].[idMetodo] = [a].[idMetodo] ';

	SET @Operator = N' WHERE ';

	SET @MSql = @Msql + @Operator + N' [a].[isAtivo] = CAST(1 AS BIT) ';
	
	SET @Msql = @Msql + N' ORDER BY isnull([a].[ordem],0), [A].[idApi];';

	EXECUTE sp_executeSql @MSql;;
END
/*

exec [dbo].[apiDemandaSelectAll]


*/
GO
------------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 1
                FROM [dbo].[Api] WITH (NOLOCK)
			   WHERE [endPoint] LIKE 'https://viacep.com.br%')
BEGIN
	INSERT INTO [dbo].[Api]
	            ([nome]
                ,[idmetodo]
                ,[endPoint]
                ,[corpo]
                ,[isConstroiCorpo]
                ,[ordem]
                ,[isAtivo])
		 VALUES ('Busca endereço através do CEP (Viacep)'
		        ,NULL
				,'https://viacep.com.br/ws/&CEP/json/'
				,''
				,CAST(1 AS BIT)
				,10
				,CAST(1 AS BIT));
END
GO

IF NOT EXISTS(SELECT 1
                FROM [dbo].[Api] WITH (NOLOCK)
			   WHERE [endPoint] LIKE 'https://receitaws.com.br/v1/cnpj/%')
BEGIN
	INSERT INTO [dbo].[Api]
	            ([nome]
                ,[idmetodo]
                ,[endPoint]
                ,[corpo]
                ,[isConstroiCorpo]
                ,[ordem]
                ,[isAtivo])
		 VALUES ('Consulta Dados de CNPJ'
		        ,1
				,'https://receitaws.com.br/v1/cnpj/&CNPJ'
				,''
				,CAST(1 AS BIT)
				,20
				,CAST(1 AS BIT));
END
GO

IF NOT EXISTS(SELECT 1
                FROM [dbo].[Api] WITH (NOLOCK)
			   WHERE [endPoint] LIKE 'https://servicodados.ibge.gov.br/api/v1/paises%')
BEGIN
	INSERT INTO [dbo].[Api]
	            ([nome]
                ,[idmetodo]
                ,[endPoint]
                ,[corpo]
                ,[isConstroiCorpo]
                ,[ordem]
                ,[isAtivo])
		 VALUES ('Dados de um país qualquer (fixo Brasil)'
		        ,1
				,'https://servicodados.ibge.gov.br/api/v1/paises/BR'
				,''
				,CAST(1 AS BIT)
				,30
				,CAST(1 AS BIT));
END
GO