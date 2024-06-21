
# Configuración de AWS CLI en Windows

Este documento proporciona una guía paso a paso para instalar AWS CLI y configurar las credenciales de AWS en Windows.

## Índice

1. [Instalar AWS CLI](#instalar-aws-cli)
2. [Configurar Credenciales de AWS CLI](#configurar-credenciales-de-aws-cli)
3. [Verificar la Configuración](#verificar-la-configuración)

## 1. Instalar AWS CLI

Sigue estos pasos para instalar AWS CLI en Windows:

1. **Descargar AWS CLI**:
   - Visita la página oficial de descargas de AWS CLI: [AWS CLI Downloads](https://aws.amazon.com/cli/).
   - Descarga el instalador adecuado para Windows (AWS CLI MSI Installer).

2. **Instalar AWS CLI**:
   - Ejecuta el archivo descargado (MSI Installer).
   - Sigue las instrucciones del asistente de instalación.

3. **Verificar la Instalación**:
   - Abre una terminal de Windows (cmd o PowerShell).
   - Ejecuta el siguiente comando para verificar que AWS CLI está instalado correctamente:

     ```sh
     aws --version
     ```

## 2. Configurar Credenciales de AWS CLI

Después de instalar AWS CLI, configura tus credenciales de AWS:

1. **Crear Claves de Acceso en la Consola de AWS**:

   - Inicia sesión en la [Consola de administración de AWS](https://aws.amazon.com/console/).

   - Navega a **IAM (Identity and Access Management)**:
     - En la barra de búsqueda de servicios, escribe `IAM` y selecciona IAM.

   - Crear un Usuario Nuevo (si no tienes uno):
     - En el menú de la izquierda, selecciona `Users` (Usuarios).
     - Haz clic en `Add user` (Agregar usuario).
     - Introduce un nombre de usuario y selecciona `Programmatic access` (Acceso programático).
     - Haz clic en `Next: Permissions` (Siguiente: Permisos).
     - Asigna permisos al usuario. Puedes adjuntar políticas directamente o agregar el usuario a un grupo con las políticas adecuadas.
     - Completa los pasos restantes y haz clic en `Create user` (Crear usuario).

   - Obtener las Claves de Acceso:
     - Después de crear el usuario, verás una pantalla con la `AWS Access Key ID` y `AWS Secret Access Key`. Anota estos valores o descárgalos como un archivo `.csv`. **Este es el único momento en que podrás ver la `Secret Access Key`, así que asegúrate de guardarla en un lugar seguro**.

2. **Abrir una Terminal de Windows (cmd o PowerShell)**:
   - Puedes abrir la terminal buscando "cmd" o "PowerShell" en el menú de inicio.

3. **Ejecutar el Comando de Configuración**:

   ```sh
   aws configure
   ```

4. **Proporcionar los Detalles Solicitados**:
   - **AWS Access Key ID**: Introduce tu ID de clave de acceso.
   - **AWS Secret Access Key**: Introduce tu clave de acceso secreta.
   - **Default region name**: Introduce la región por defecto (por ejemplo, `us-east-1`).
   - **Default output format**: Introduce el formato de salida por defecto (`json`, `text`, o `table`).

   Ejemplo del proceso:

   ```sh
   $ aws configure
   AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
   AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
   Default region name [None]: us-east-1
   Default output format [None]: json
   ```

## 3. Verificar la Configuración

Para asegurarte de que tus credenciales están configuradas correctamente, sigue estos pasos:

1. **Ejecutar un Comando de Prueba**:
   - Abre una terminal de Windows (cmd o PowerShell).
   - Ejecuta el siguiente comando para listar los buckets de S3:

     ```sh
     aws s3 ls
     ```

   - Si tus credenciales están configuradas correctamente, deberías ver una lista de tus buckets de S3.

Sigue estos pasos para instalar y configurar AWS CLI en Windows. Si tienes alguna pregunta o necesitas ayuda, no dudes en consultarnos.

---
