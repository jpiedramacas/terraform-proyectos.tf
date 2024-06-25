# Proyecto Terraform para Infraestructura en AWS

Este proyecto de Terraform despliega una infraestructura básica en AWS que incluye una VPC, una subred pública, una tabla de rutas, un gateway de Internet, un grupo de seguridad y una instancia EC2.

## Requisitos Previos

- [Terraform](https://www.terraform.io/downloads.html) instalado en tu máquina.
- Credenciales de AWS configuradas en tu entorno (archivo `~/.aws/credentials` o variables de entorno).

## Contenido

1. [Proveedor](#proveedor)
2. [Recursos](#recursos)
   - [VPC](#vpc)
   - [Subnet Pública](#subnet-pública)
   - [Internet Gateway](#internet-gateway)
   - [Route Table Pública](#route-table-pública)
   - [Asociación de Route Table](#asociación-de-route-table)
   - [Security Group](#security-group)
   - [Instancia EC2](#instancia-ec2)
3. [Variables](#variables)
4. [Outputs](#outputs)
5. [Uso](#uso)

## Proveedor

El proveedor de AWS se configura para especificar la región donde se desplegarán los recursos. Esto permite que Terraform sepa a qué región de AWS conectarse.

```hcl
provider "aws" {
  region = var.aws_region
}
```

## Recursos

### VPC

Una VPC (Virtual Private Cloud) es una red virtual dedicada a tu cuenta de AWS. Definimos una VPC con un bloque CIDR especificado que define el rango de direcciones IP.

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my-vpc"
  }
}
```

**Explicación:**
- `cidr_block`: El rango de direcciones IP asignado a la VPC.
- `tags`: Etiquetas para identificar el recurso en AWS.

### Subnet Pública

Una subred es una subdivisión de una VPC. Aquí, creamos una subred pública dentro de la VPC.

```hcl
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "public-subnet"
  }
}
```

**Explicación:**
- `vpc_id`: ID de la VPC donde se crea la subred.
- `cidr_block`: El rango de direcciones IP para la subred.
- `availability_zone`: La zona de disponibilidad en la que se creará la subred.
- `tags`: Etiquetas para identificar la subred.

### Internet Gateway

Un Internet Gateway permite que las instancias en la VPC se conecten a Internet.

```hcl
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "my-igw"
  }
}
```

**Explicación:**
- `vpc_id`: ID de la VPC a la que se adjunta el Internet Gateway.
- `tags`: Etiquetas para identificar el Internet Gateway.

### Route Table Pública

Una tabla de rutas define cómo se enruta el tráfico dentro de la VPC. Creamos una tabla de rutas pública para permitir el acceso a Internet.

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-route-table"
  }
}
```

**Explicación:**
- `vpc_id`: ID de la VPC a la que pertenece la tabla de rutas.
- `route`: Define una ruta que envía todo el tráfico (`0.0.0.0/0`) al Internet Gateway.
- `tags`: Etiquetas para identificar la tabla de rutas.

### Asociación de Route Table

Asociamos la tabla de rutas pública con la subred pública, permitiendo que el tráfico en la subred utilice la tabla de rutas.

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**Explicación:**
- `subnet_id`: ID de la subred pública.
- `route_table_id`: ID de la tabla de rutas pública.

### Security Group

Un grupo de seguridad actúa como un firewall para controlar el tráfico hacia y desde las instancias EC2. Definimos un grupo de seguridad para permitir el tráfico SSH (puerto 22) y HTTP (puerto 80).

```hcl
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}
```

**Explicación:**
- `vpc_id`: ID de la VPC a la que pertenece el grupo de seguridad.
- `ingress`: Reglas de entrada que permiten tráfico SSH y HTTP desde cualquier IP (`0.0.0.0/0`).
- `egress`: Reglas de salida que permiten todo el tráfico saliente.
- `tags`: Etiquetas para identificar el grupo de seguridad.

### Instancia EC2

Desplegamos una instancia EC2 en la subred pública con el grupo de seguridad configurado.

```hcl
resource "aws_instance" "example" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "example-instance"
  }
}
```

**Explicación:**
- `ami`: ID de la imagen de máquina de Amazon (AMI) que se usará para lanzar la instancia.
- `instance_type`: Tipo de instancia (por ejemplo, `t2.micro`).
- `subnet_id`: ID de la subred pública donde se lanzará la instancia.
- `security_groups`: Grupo de seguridad asociado a la instancia.
- `tags`: Etiquetas para identificar la instancia.

## Variables

Definimos variables para parametrizar el despliegue, facilitando cambios sin modificar el código principal.

```hcl
variable "aws_region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone where the subnet will be created"
  type        = string
  default     = "us-east-1a"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-08a0d1e16fc3f61ea"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
```

## Outputs

Definimos los outputs para obtener información de los recursos desplegados, permitiendo acceder a estos datos fácilmente después del despliegue.

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}
```

