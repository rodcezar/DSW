--
-- CRIA UM NOVO USUARIO
--

DROP PROCEDURE IF EXISTS UsuarioInsere;
DELIMITER //
CREATE PROCEDURE UsuarioInsere(vNome VARCHAR(80), vEmail VARCHAR(80), vSenha VARCHAR(80), vPapel INT, OUT id INT)
BEGIN
	INSERT INTO Usuario (dataRegistro, dataAtualizacao, nome, email, senha, papel)
	VALUES (NOW(), NOW(), vNome, vEmail, vSenha, vPapel);

	SET id = LAST_INSERT_ID();
END //
DELIMITER ;


--
-- ATUALIZA A SENHA DE UM USUARIO
--

DROP PROCEDURE IF EXISTS UsuarioTrocaSenha;
DELIMITER //
CREATE PROCEDURE UsuarioTrocaSenha(vId INT, vSenha VARCHAR(1024))
BEGIN
	UPDATE Participante
	SET senha = vSenha,
	forcaResetSenha = 0
	WHERE id = VId;
END //
DELIMITER ;


--
-- REGISTRA UM LOGIN BEM SUCEDIDO DE UM USUARIO
--

DROP PROCEDURE IF EXISTS UsuarioRegistraLoginSucesso;
DELIMITER //
CREATE PROCEDURE UsuarioRegistraLoginSucesso(vId INT)
BEGIN
	UPDATE Usuario
	SET dataUltimoLogin = NOW(),
	contadorLoginFalha = 0
	WHERE id = vId;
END //
DELIMITER ;


--
-- REGISTRA UM LOGIN MAL SUCEDIDO DE UM USUARIO
--

DROP PROCEDURE IF EXISTS UsuarioRegistraLoginFalha;
DELIMITER //
CREATE PROCEDURE UsuarioRegistraLoginFalha(vId INT)
BEGIN
	DECLARE lTentativas INT;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION ROLLBACK;
	START TRANSACTION;

	UPDATE Usuario
	SET contadorLoginFalha = contadorLoginFalha + 1
	WHERE id = vId;

	SELECT contadorLoginFalha
	INTO lTentativas
	FROM Usuario
	WHERE id = vId;

	IF @tentativas >= 3 THEN 
		UPDATE Participante
		SET forcaResetSenha = 1
		WHERE id = vId;
	END IF;
	
  	COMMIT;
END //
DELIMITER ;


--
-- REGISTRA UM TOKEN DE LOGIN PARA UM USUARIO
--

DROP PROCEDURE IF EXISTS UsuarioRegistraTokenResetSenha;
DELIMITER //
CREATE PROCEDURE UsuarioRegistraTokenResetSenha(vId INT, vToken VARCHAR(256))
BEGIN
	UPDATE Usuario
	SET dataAtualizacao = NOW(),
	tokenLogin = vToken,
	dataTokenLogin = NOW()
	WHERE id = vId;
END //
DELIMITER ;