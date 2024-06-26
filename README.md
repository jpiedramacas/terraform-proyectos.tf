
## Despliegue de una instancia EC2 usando Terraform en AWS Cloud9

Este proyecto detalla el proceso para desplegar una instancia EC2 en AWS utilizando Terraform desde un entorno de desarrollo Cloud9. Se asume que las credenciales de AWS están configuradas correctamente en la carpeta `.aws/` del entorno Cloud9.

### Requisitos previos

1. **AWS CLI** y **Terraform** deben estar instalados en el entorno Cloud9.
2. Credenciales de AWS configuradas en la carpeta `.aws/` en el entorno Cloud9.
3. Permisos necesarios en la cuenta de AWS para crear instancias EC2.

### AWS Provider
El Registro de Proveedores de Terraform para AWS proporciona documentación y recursos necesarios para utilizar Terraform con Amazon Web Services. Permite gestionar y aprovisionar infraestructura AWS mediante código, facilitando la creación, actualización y destrucción de recursos de manera automatizada y repetible. Esto asegura consistencia y eficiencia en la gestión de la infraestructura en la nube.
1. [TERRAFORM](https://registry.terraform.io/providers/tfproviders/aws/latest/docs)

### 1. Configuración del entorno Cloud9

AWS Cloud9 es un entorno de desarrollo integrado (IDE) basado en la nube que permite escribir, ejecutar y depurar código con solo un navegador. Este tutorial asume que ya tienes un entorno Cloud9 configurado. Si no, sigue estos pasos:

1. Navega a la consola de AWS.
2. Ve a **Cloud9** y crea un nuevo entorno.
3. Asigna un nombre y una descripción a tu entorno, y configura los ajustes según tus necesidades.
4. Una vez que el entorno esté listo, abre el IDE de Cloud9.

### 2. Configuración de las credenciales de AWS

Verifica que las credenciales de AWS estén configuradas en el entorno Cloud9. Estas deben estar ubicadas en la carpeta `~/.aws/`:

```bash
cat ~/.aws/credentials
```

Asegúrate de que el archivo `credentials` contenga tus `AWS Access Key ID` y `AWS Secret Access Key`.

### 3. Despliegue del archivo `main.tf`

#### Código del archivo `main.tf`

Crea un archivo llamado `main.tf` y copia el siguiente contenido:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
```

#### Comandos para el despliegue

1. **Inicializa el directorio de trabajo:**

   En la terminal de Cloud9, navega al directorio donde se encuentra `main.tf` y ejecuta:

   ```bash
   terraform init
   ```

   Este comando descarga los plugins necesarios para el proveedor de AWS y prepara el directorio de trabajo.

2. **Revisa el plan de ejecución:**

   ```bash
   terraform plan
   ```

   Este comando muestra un plan de ejecución, permitiéndote ver qué acciones realizará Terraform sin hacer cambios reales.

3. **Aplica la configuración:**

   ```bash
   terraform apply
   ```

   Se te pedirá que confirmes la ejecución. Escribe `yes` para proceder. Terraform desplegará la instancia EC2 según la configuración en `main.tf`.

### 4. Otros archivos y carpetas de interés

#### Carpeta `.terraform/`

Cuando ejecutas `terraform init`, Terraform crea una carpeta llamada `.terraform/` en el directorio de trabajo. Esta carpeta contiene:

- Plugins necesarios para interactuar con el proveedor de AWS.
- Archivos de estado local de Terraform.

#### Carpeta de respaldo (`backup/`)

Es una buena práctica mantener una carpeta de respaldo donde se guarden copias de seguridad de tus archivos de configuración de Terraform y archivos de estado. Puedes crear una carpeta `backup/` y copiar tus archivos importantes allí:

```bash
mkdir backup
cp main.tf backup/
cp terraform.tfstate backup/
```

### 5. Modificaciones y limpieza de recursos

Si agregas más código a tu archivo `main.tf`, simplemente ejecuta `terraform apply` para aplicar los cambios. Por ejemplo, para añadir un recurso de base de datos RDS, añade lo siguiente al final de `main.tf`:

```hcl
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
```

#### Comandos para aplicar cambios

1. **Revisa el plan de ejecución:**

   ```bash
   terraform plan
   ```

   Este comando mostrará el plan de ejecución incluyendo los nuevos recursos que se añadirán.

2. **Aplica la configuración:**

   ```bash
   terraform apply
   ```

   Se te pedirá que confirmes la ejecución. Escribe `yes` para proceder. Terraform desplegará los nuevos recursos especificados.

#### Importante: Borrado de recursos

Si eliminas una parte del código en `main.tf` y luego ejecutas `terraform apply`, Terraform destruirá esos recursos y ya no estarán disponibles. Por ejemplo, si eliminas el recurso de base de datos RDS:

```hcl
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
```

Y luego ejecutas:

```bash
terraform apply
```

Terraform eliminará la base de datos RDS especificada.

### Limpieza de recursos

Para evitar cargos innecesarios en tu cuenta de AWS, asegúrate de destruir los recursos creados cuando ya no los necesites:

```bash
terraform destroy
```

Se te pedirá que confirmes la destrucción. Escribe `yes` para proceder.

### Conclusión

Siguiendo estos pasos, has configurado un entorno Cloud9, creado un archivo de configuración `main.tf` para Terraform, y desplegado una instancia EC2 en AWS. También aprendiste cómo añadir y eliminar recursos en tu archivo de configuración y cómo realizar copias de seguridad de estos archivos importantes.

