#!/bin/bash
# Actualiza los paquetes
sudo apt-get update -y

# Instala Apache y el cliente de AWS CLI
sudo apt-get install -y apache2

sudo snap install aws-cli --classic

# Activa Apache
sudo systemctl start apache2
sudo systemctl enable apache2

cat <<EOT > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pagina dinamica en EC2</title>
</head>
<body>
    <h1>Ejemplo de pagina dinamica en EC2</h1>
</body>
</html>
EOT

# Copia el archivo index.html desde S3
# aws s3 cp s3://obligatorio-2-ec2-site/index.html /var/www/html/index.html --recursive --region us-east-1 ''

# Establece los permisos correctos
sudo chown www-data:www-data /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
