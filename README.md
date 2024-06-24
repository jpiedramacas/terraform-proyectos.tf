Claro, vamos a detallar cada sección del archivo `main.tf` y explicar su propósito y configuración.

### Proveedor AWS

```hcl
provider "aws" {
  region = var.aws_region
}
```

Esta sección configura el proveedor de Terraform para AWS, especificando la región en la que se desplegarán los recursos. La región se toma de una variable (`var.aws_region`).

### VPC (Virtual Private Cloud)

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my-vpc"
  }
}
```

- **Resource Type:** `aws_vpc`
- **cidr_block:** Define el rango de direcciones IP que utilizará la VPC. Se especifica mediante la variable `var.vpc_cidr_block`.
- **tags:** Etiquetas para identificar el recurso.

### Subnet Pública

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

- **Resource Type:** `aws_subnet`
- **vpc_id:** El ID de la VPC en la que se creará la subnet. Se refiere al ID de la VPC creada anteriormente (`aws_vpc.this.id`).
- **cidr_block:** Define el rango de direcciones IP que utilizará la subnet. Se especifica mediante la variable `var.public_subnet_cidr_block`.
- **availability_zone:** La zona de disponibilidad en la que se creará la subnet. Se especifica mediante la variable `var.availability_zone`.

### Internet Gateway

```hcl
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "my-igw"
  }
}
```

- **Resource Type:** `aws_internet_gateway`
- **vpc_id:** El ID de la VPC a la que se asociará el Internet Gateway.

### Route Table Pública

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

- **Resource Type:** `aws_route_table`
- **vpc_id:** El ID de la VPC para la que se creará la tabla de rutas.
- **route:** Define una ruta dentro de la tabla de rutas.
  - **cidr_block:** Especifica que la ruta es para todo el tráfico (`0.0.0.0/0`).
  - **gateway_id:** Especifica que el tráfico se enruta a través del Internet Gateway (`aws_internet_gateway.this.id`).

### Asociación de Route Table Pública con Subnet Pública

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

- **Resource Type:** `aws_route_table_association`
- **subnet_id:** El ID de la subnet pública (`aws_subnet.public.id`).
- **route_table_id:** El ID de la tabla de rutas pública (`aws_route_table.public.id`).

### Security Group

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

- **Resource Type:** `aws_security_group`
- **vpc_id:** El ID de la VPC en la que se creará el grupo de seguridad.
- **ingress:** Reglas de entrada para el grupo de seguridad.
  - **from_port, to_port:** Especifica el puerto de origen y destino.
  - **protocol:** Especifica el protocolo (en este caso, TCP).
  - **cidr_blocks:** Especifica los bloques CIDR permitidos (en este caso, todo el tráfico `0.0.0.0/0`).
- **egress:** Reglas de salida para el grupo de seguridad.
  - **from_port, to_port:** Especifica los puertos de origen y destino para el tráfico de salida.
  - **protocol:** Especifica el protocolo (en este caso, todo el tráfico `-1`).
  - **cidr_blocks:** Especifica los bloques CIDR permitidos para el tráfico de salida (en este caso, todo el tráfico `0.0.0.0/0`).

### Instancia EC2

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

- **Resource Type:** `aws_instance`
- **ami:** Especifica el ID de la AMI para la instancia EC2. Se toma de la variable `var.ami`.
- **instance_type:** Especifica el tipo de instancia. Se toma de la variable `var.instance_type`.
- **subnet_id:** Especifica el ID de la subnet en la que se lanzará la instancia (`aws_subnet.public.id`).
- **security_groups:** Especifica los grupos de seguridad asociados a la instancia. En este caso, se asocia el grupo de seguridad creado anteriormente (`aws_security_group.ec2_sg.name`).

### Variables

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

Estas variables permiten parametrizar la configuración y hacerla reutilizable y flexible. Pueden ser modificadas sin necesidad de cambiar el resto del archivo `main.tf`.

### Outputs

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

Estos bloques de salida (`outputs`) proporcionan información útil sobre los recursos creados. Se pueden utilizar para verificar las configuraciones o integrarse con otras herramientas de automatización.

Este archivo `main.tf` es una configuración completa y detallada para crear una infraestructura básica en AWS con una VPC, subnet pública, Internet Gateway, tabla de rutas, grupo de seguridad y una instancia EC2. Cada sección está interconectada para asegurar que todos los componentes trabajen juntos correctamente.
