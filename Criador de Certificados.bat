@echo off

set "windowTitle=Criador de Certificados v1"
title %windowTitle%

REM Verifica se o OpenSSL está instalado
IF NOT EXIST "%ProgramFiles%\OpenSSL-Win64\bin\openssl.exe" (
	title Instalando OpenSSL - %windowTitle%
	cls
	echo OpenSSL nao esta instalado. Instalando OpenSSL...
	winget install -e --id ShiningLight.OpenSSL
	cls
	"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" version
	echo.
	pause
)

REM Verifica se os arquivos RootCA.pem e RootCA.key existem
if not exist RootCA.pem if not exist RootCA.key (
	title Criando Certificado RootCA - %windowTitle%
	cls
	echo Arquivos RootCA nao encontrados. Criando RootCA...
	echo.
	call :createRootCA
	call :addRootCAToRoot
)

:askNewCertificate
REM Pergunta se o usuario pretende criar um novo certificado
title Criador de Certificados v1
cls
set /p createNewCert=Voce deseja criar um novo certificado? (S/N): 
if /i "%createNewCert%"=="N" (
	exit
) else if /i "%createNewCert%"=="S" (
	call :createNewCertificate
) else (
	goto :askNewCertificate
)

exit /b

:createRootCA
REM Prompt para definir os atributos da Root CA
set /p c=Digite o Pais (2 letras, padrao ISO 3166-1 alpha-2): 
set /p st=Digite o Estado ou Provincia: 
set /p l=Digite Cidade ou Localidade: 
set /p o=Digite a Organizacao: 
set /p email=Digite o Email: 

REM Cria a chave privada da Root CA
"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" genpkey -algorithm RSA -out RootCA.key -aes256

REM Cria o certificado da Root CA
"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" req -x509 -new -nodes -key RootCA.key -sha256 -days 3650 -out RootCA.pem -subj "/C=%c%/ST=%st%/L=%l%/O=%o%/emailAddress=%email%"

cls
echo Arquivos RootCA criados com sucesso.
echo.
pause

exit /b

:addRootCAToRoot
REM Adicionando Root CA às Autoridades de Certificação Raiz Confiáveis
"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" x509 -inform PEM -outform DER -in RootCA.pem -out %USERPROFILE%\Downloads\RootCA.cer
echo @echo off> "Instalar Certificado Raiz.bat"
echo certutil -addstore -f "Root" %USERPROFILE%\Downloads\RootCA.cer>> "Instalar Certificado Raiz.bat"
echo del %USERPROFILE%\Downloads\RootCA.cer>> "Instalar Certificado Raiz.bat"
echo echo.>> "Instalar Certificado Raiz.bat"
echo pause>> "Instalar Certificado Raiz.bat"

cls
echo Execute o arquivo "Instalar Certificado Raiz.bat" como administrador.
echo.
pause

exit /b

:createNewCertificate
title Criando Certificado - %windowTitle%
cls
REM Prompt para definir o nome do novo certificado
set /p domain=Digite o nome do dominio para o novo certificado: 

REM Cria o arquivo %domain%.csr.cnf
echo [req]> %domain%.csr.cnf
echo default_bits = 2048>> %domain%.csr.cnf
echo prompt = no>> %domain%.csr.cnf
echo default_md = sha256>> %domain%.csr.cnf
echo distinguished_name = dn>> %domain%.csr.cnf
echo.>> %domain%.csr.cnf
echo [dn]>> %domain%.csr.cnf
set /p c=Digite o Pais (2 letras, padrao ISO 3166-1 alpha-2): 
if not "%c%"=="" echo C = %c%>> %domain%.csr.cnf
set /p st=Digite o Estado ou Provincia: 
if not "%st%"=="" echo ST = %st%>> %domain%.csr.cnf
set /p l=Digite Cidade ou Localidade: 
if not "%l%"=="" echo L = %l%>> %domain%.csr.cnf
set /p o=Digite a Organizacao: 
if not "%o%"=="" echo O = %o%>> %domain%.csr.cnf
set /p ou=Digite a Unidade Organizacional (opcional): 
if not "%ou%"=="" echo OU = %ou%>> %domain%.csr.cnf
set /p email=Digite o Email: 
if not "%email%"=="" echo emailAddress = %email%>> %domain%.csr.cnf
set /p cn1=1 de 3: Digite o dominio principal: 
if not "%cn1%"=="" echo CN = %cn1%>> %domain%.csr.cnf
set /p cn2=2 de 3: Digite um dominio adicional (deixe em branco para continuar): 
if not "%cn2%"=="" echo CN = %cn2%>> %domain%.csr.cnf
set /p cn3=3 de 3: Digite um dominio adicional (deixe em branco para continuar): 
if not "%cn3%"=="" echo CN = %cn3%>> %domain%.csr.cnf

REM Cria o arquivo %domain%.v3.ext
echo authorityKeyIdentifier = keyid,issuer> %domain%.v3.ext
echo basicConstraints = CA:FALSE>> %domain%.v3.ext
echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment>> %domain%.v3.ext
echo subjectAltName = @alt_names>> %domain%.v3.ext
echo.>> %domain%.v3.ext
echo [alt_names]>> %domain%.v3.ext
if not "%cn1%"=="" echo DNS.1 = %cn1%>> %domain%.v3.ext
if not "%cn2%"=="" echo DNS.2 = %cn2%>> %domain%.v3.ext
if not "%cn3%"=="" echo DNS.3 = %cn3%>> %domain%.v3.ext

REM Executa os comandos para criar os arquivos .csr, .key e .crt
"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" req -new -sha256 -nodes -out %domain%.csr -newkey rsa:2048 -keyout %domain%.key -config %domain%.csr.cnf
"%ProgramFiles%/OpenSSL-Win64/bin/openssl.exe" x509 -req -in %domain%.csr -CA RootCA.pem -CAkey RootCA.key -CAcreateserial -out %domain%.crt -days 1095 -sha256 -extfile %domain%.v3.ext

REM Apaga o arquivo de configuração .cnf
del %domain%.csr.cnf
del %domain%.v3.ext
del %domain%.csr

cls
echo Arquivos para o certificado de %domain% criados com sucesso.
echo.
pause

goto :askNewCertificate

exit /b
