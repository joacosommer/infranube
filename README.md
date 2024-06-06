# Infraestructura en la nube

## Correr el proyecto

- Crear una cuenta en AWS
- Se recomienda crear un usuario IAM con permisos de administrador en vez de usar el usuario root para mayor seguridad.
- Crear unas access keys para el usuario IAM yendo a la sección de Security Credentials y luego a Access keys.
- Instalar AWS CLI
- Instalar Terraform
- Ir al servicio EC2 en la consola de AWS y crear un par de llaves para conectarse a las instancias.

#### Configurar AWS CLI

```bash
aws configure
```
Agregar las access keys que se crearon anteriormente.

#### Configurar Terraform
Copiar el archivo terraform.tfvars.example a terraform.tfvars y completar los valores de las variables.

```bash
cp terraform.tfvars.example terraform.tfvars
```
Agrege en key_name el nombre de las llaves de EC2 que creo en la consola de AWS.
Agregue un mail y un nombre del proyecto en las variables. El resto de las variables las puede dejar como estan.

Terraform init

```bash
terraform init
```

Terraform plan

```bash
terraform plan
```

Terraform apply

```bash
terraform apply
```
Luego del comando terraform apply, se le preguntará si desea continuar, escriba "yes" y presione enter. Como output se le mostrará el nombre de los buckets creados y las urls de las paginas.


Cuando desee destruir la infraestructura creada, ejecute el comando. Debera tener el bucket de ordenes vacio para poder destruirlo.
Terraform destroy

```bash
terraform destroy
```