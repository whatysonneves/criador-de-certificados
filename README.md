# Criador de Certificados SSL/TLS

Este projeto facilita a criação de certificados usando o OpenSSL no Windows. O objetivo principal é simplificar o processo de criação de Certificados de Autoridade Raiz (Root CA) e Certificados SSL/TLS para uso em desenvolvimento local ou em redes internas.

## Funcionalidades:

1. Verificação e instalação do OpenSSL:
   - O script verifica se o OpenSSL está instalado no sistema.
   - Se o OpenSSL não estiver instalado, ele é baixado e instalado automaticamente usando o pacote `ShiningLight.OpenSSL` do Winget.

2. Criação da Autoridade Raiz (Root CA):
   - Se os arquivos `RootCA.pem` e `RootCA.key` não existirem, o script solicitará que você defina os atributos da Root CA, como país, estado, cidade, organização e email.
   - Em seguida, uma chave privada e um certificado autoassinado da Root CA serão gerados usando o OpenSSL.
   - Os arquivos `RootCA.pem` e `RootCA.key` serão criados para serem usados na assinatura dos certificados SSL/TLS.

3. Adição da Root CA às Autoridades de Certificação Raiz Confiáveis:
   - O script criará um arquivo de certificado DER `RootCA.cer` a partir do arquivo `RootCA.pem`.
   - Em seguida, ele criará um arquivo em lote `Instalar Certificado Raiz.bat` que instalará o certificado "Autoridades de Certificação Raiz Confiáveis" do Windows.
   - Você precisará executar o arquivo `Instalar Certificado Raiz.bat` como administrador para adicionar a Root CA como uma autoridade de certificação confiável.

4. Criação de Novos Certificados:
   - O script permite que você crie novos certificados SSL/TLS para domínios específicos.
   - Você será solicitado a fornecer informações sobre o certificado, como país, estado, cidade, organização, email e domínios.
   - Com base nessas informações, o script criará um arquivo de configuração `[domain].csr.cnf` e um arquivo de extensão `v3.ext`.
   - O OpenSSL será usado para gerar a chave privada, a solicitação de certificado (CSR) e o certificado assinado usando a Root CA.
   - Os arquivos resultantes serão salvos com base no nome do domínio fornecido.

## Instruções de Uso:

1. Certifique-se de ter o OpenSSL instalado no sistema.
2. Execute o arquivo de lote `Criador de Certificados.bat` para iniciar o script.
3. Siga as instruções apresentadas pelo script para criar certificados e configurar a Root CA.
4. Ao criar um novo certificado, os arquivos resultantes serão salvos no diretório atual.

## Observações:

- Os certificados gerados por este script são adequados apenas para uso em ambientes de desenvolvimento ou em redes internas. Eles não são adequados para implantação em um ambiente de produção real.

## Importante:

- O uso de certificados SSL/TLS autoassinados ou emitidos por uma Autoridade de Certificação interna pode não ser reconhecido por todos os clientes/browsers. Portanto, ao utilizar esses certificados em um ambiente de produção ou em aplicações acessíveis publicamente, é recomendável obter um certificado de uma Autoridade de Certificação confiável.
