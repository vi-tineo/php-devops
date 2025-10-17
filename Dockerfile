# -------------------------------
# Etapa 1: Build da aplicação PHP
# -------------------------------
FROM php:8.2-apache AS builder

# Instala extensões PHP necessárias (exemplo: mysqli)
RUN docker-php-ext-install mysqli

# Copia os arquivos da aplicação para o container
COPY . /var/www/html/

# Ajusta permissões e remove arquivos desnecessários
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type f -name "*.log" -delete

# -------------------------------
# Etapa 2: Imagem final segura
# -------------------------------
FROM php:8.2-apache

# Cria usuário não-root para execução segura
RUN useradd -m -d /home/appuser -s /bin/bash appuser

# Adiciona ServerName para evitar o warning de FQDN
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copia os arquivos da aplicação da etapa de build
COPY --from=builder /var/www/html /var/www/html

# Ajusta permissões para o novo usuário
RUN chown -R appuser:appuser /var/www/html

# Define o usuário não-root para execução
USER appuser

# Expõe a porta padrão do Apache
EXPOSE 8080

# Comentários explicativos:
# - Multi-stage build reduz o tamanho da imagem e separa responsabilidades.
# - Uso de imagem oficial garante compatibilidade e atualizações.
# - Execução com usuário não-root aumenta a segurança em produção.
# - ServerName evita warnings de FQDN no Apache.
