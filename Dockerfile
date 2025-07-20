# Use uma imagem base compatível com PHP e Apache para ARM64
FROM arm64v8/php:8.1-apache

# Instale dependências do sistema e extensões PHP necessárias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    nodejs \
    npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo_mysql intl calendar \
    && rm -rf /var/lib/apt/lists/*

# Instale o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configure o timezone
RUN echo "date.timezone=America/Sao_Paulo" > /usr/local/etc/php/conf.d/timezone.ini

# Copie o código do Krayin CRM
WORKDIR /var/www/html
COPY ../laravel-crm/ .

# Instale as dependências do PHP
RUN composer install --no-dev

# Gere os arquivos estáticos do frontend
RUN npm install --legacy-peer-deps \
    && npm run build

# Configure permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Exponha a porta do servidor web
EXPOSE 80

# Configure o entrypoint
CMD ["apache2-foreground"]
