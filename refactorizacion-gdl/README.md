# Sistema de Pavimentación - Municipio de Guadalajara

Aplicación web completa para la gestión de contratos de pavimentación, desarrollada con Laravel 11, Vue.js 3.6 y PostgreSQL 17.

## 🚀 Características

- **Backend Laravel 11** con API RESTful
- **Frontend Vue.js 3.6** con Inertia.js 
- **Base de datos PostgreSQL 17** con esquema `pavimentacion`
- **Interfaz moderna** con gradientes y animaciones
- **Gestión completa** de contratos de pavimentación
- **Reportes PDF** y exportación a Excel
- **Responsive design** optimizado para dispositivos móviles

## 📋 Funcionalidades

### ✅ Gestión de Contratos
- Alta de nuevos contratos de pavimentación
- Listado con filtros y búsqueda
- Cálculo automático de costos y mensualidades
- Tipos de pavimento: Asfalto y Concreto Hidráulico

### ✅ Control de Adeudos
- Seguimiento de pagos mensuales
- Registro de números de recibo
- Estados de pago (Vigente/Pagado)
- Resumen de adeudos por proyecto

### ✅ Reportes y Exportación
- Generación de reportes PDF
- Exportación a Excel
- Estadísticas en tiempo real
- Gráficos de inversión total

## 🛠️ Tecnologías

### Backend
- **PHP 8.3+**
- **Laravel 11**
- **PostgreSQL 17**
- **DomPDF** para reportes
- **Maatwebsite Excel** para exportaciones

### Frontend
- **Vue.js 3.6**
- **Inertia.js** para SPA
- **Vite** para build
- **Tailwind CSS** (opcional)

## 📦 Instalación

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd refactorizacion-gdl
```

### 2. Instalar dependencias
```bash
# Backend
composer install

# Frontend
npm install
```

### 3. Configurar entorno
```bash
cp .env.example .env
php artisan key:generate
```

### 4. Configurar base de datos
Editar `.env` con los datos de PostgreSQL:
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=pavimentacion_db
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_SCHEMA=pavimentacion
```

### 5. Ejecutar migraciones
```bash
php artisan migrate
php artisan db:seed
```

### 6. Compilar assets
```bash
npm run dev
# o para producción
npm run build
```

### 7. Iniciar servidor
```bash
php artisan serve
```

## 🐳 Docker (Desarrollo)

```bash
# Levantar contenedores
docker-compose up -d --build

# Instalar dependencias
docker-compose exec app composer install
docker-compose exec app npm install

# Ejecutar migraciones
docker-compose exec app php artisan migrate --seed

# Compilar assets
docker-compose exec app npm run dev
```

## 📁 Estructura del Proyecto

```
refactorizacion-gdl/
├── app/
│   ├── Http/Controllers/
│   │   ├── Api/           # Controladores API
│   │   └── PavimentacionController.php
│   ├── Models/            # Modelos Eloquent
│   └── Services/          # Lógica de negocio
├── resources/
│   ├── js/
│   │   ├── Components/    # Componentes Vue
│   │   ├── Layouts/       # Layouts de página
│   │   ├── Pages/         # Páginas Inertia
│   │   └── Services/      # Servicios API frontend
│   └── views/
│       └── reportes/      # Plantillas PDF
├── database/
│   └── migrations/        # Migraciones PostgreSQL
└── routes/
    ├── api.php           # Rutas API
    └── web.php           # Rutas web
```

## 🔗 Endpoints API

### Proyectos
- `GET /api/v1/proyectos` - Listar proyectos
- `POST /api/v1/proyectos` - Crear proyecto
- `GET /api/v1/proyectos/{id}` - Ver proyecto
- `GET /api/v1/proyectos/{id}/resumen-adeudos` - Resumen de adeudos

### Adeudos
- `GET /api/v1/adeudos/proyecto/{idControl}` - Adeudos por proyecto
- `POST /api/v1/adeudos/{id}/pagar` - Registrar pago

### Reportes
- `GET /api/v1/reportes/pdf` - Generar PDF
- `GET /api/v1/proyectos/export/excel` - Exportar Excel

## 🎨 Componentes Vue

### Layouts
- `AppLayout.vue` - Layout principal con header y estilos

### Componentes
- `StatsCards.vue` - Tarjetas de estadísticas
- `ProyectosTable.vue` - Tabla de proyectos
- `ProyectoModal.vue` - Modal de alta/edición
- `ActionButtons.vue` - Botones de acción
- `AlertMessage.vue` - Mensajes de alerta

### Páginas
- `Pavimentacion/Index.vue` - Página principal del sistema

## 🔧 Comandos Útiles

```bash
# Desarrollo
php artisan serve              # Servidor de desarrollo
npm run dev                    # Compilar assets en modo desarrollo
php artisan migrate:fresh --seed  # Reiniciar BD con datos

# Producción
npm run build                  # Compilar para producción
php artisan optimize          # Optimizar aplicación
php artisan config:cache      # Cache de configuración

# Mantenimiento
php artisan route:list        # Listar rutas
php artisan tinker           # REPL de Laravel
```

## 🚀 Despliegue en Producción

### Servidor Debian 12

1. **Instalar dependencias del sistema:**
```bash
sudo apt update
sudo apt install -y php8.3 php8.3-fpm php8.3-pgsql php8.3-mbstring \
    php8.3-xml php8.3-curl php8.3-zip php8.3-gd php8.3-bcmath \
    postgresql-17 nginx nodejs npm composer
```

2. **Configurar PostgreSQL:**
```bash
sudo -u postgres createdb pavimentacion_db
sudo -u postgres createuser --interactive
```

3. **Configurar Nginx:**
```bash
sudo cp docker/nginx/conf.d/app.conf /etc/nginx/sites-available/pavimentacion
sudo ln -s /etc/nginx/sites-available/pavimentacion /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

4. **Desplegar aplicación:**
```bash
composer install --optimize-autoloader --no-dev
npm install && npm run build
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 📊 Datos de Ejemplo

El sistema incluye datos de ejemplo:
- Contratos de pavimentación con diferentes tipos
- Adeudos mensuales calculados automáticamente
- Estados de pago variados para testing

## 🤝 Contribución

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 📞 Soporte

Para soporte y consultas:
- Crear issue en GitHub
- Documentación en `/docs`
- Wiki del proyecto