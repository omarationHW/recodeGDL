# Sistema Municipal Digital - Guadalajara

Sistema integral de gestión municipal para el Gobierno de Guadalajara, Jalisco. Una aplicación web moderna que digitaliza y centraliza los procesos administrativos municipales.

## 🏛️ Descripción

Este sistema permite la gestión completa de servicios municipales incluyendo recaudación, estacionamientos, licencias, aseo urbano, mercados, cementerios, convenios, apremios y otras obligaciones fiscales.

## 🚀 Tecnologías

### Frontend
- **Vue.js 3** - Framework JavaScript progresivo
- **Vite** - Build tool y servidor de desarrollo
- **Vue Router** - Enrutamiento SPA
- **Tailwind CSS** - Framework de CSS utilitario
- **FontAwesome** - Iconografía

### Backend
- **Laravel** - Framework PHP
- **PostgreSQL** - Base de datos principal
- **API RESTful** - Arquitectura de servicios

## 📁 Estructura del Proyecto

```
harweb-main/
├── frontend-vue/          # Aplicación Vue.js
│   ├── src/
│   │   ├── components/    # Componentes reutilizables
│   │   ├── views/         # Páginas principales
│   │   ├── layouts/       # Layouts de la aplicación
│   │   ├── router/        # Configuración de rutas
│   │   ├── assets/        # Recursos estáticos
│   │   └── config/        # Configuraciones
│   ├── public/            # Archivos públicos
│   └── package.json       # Dependencias Node.js
└── backend-laravel/       # API Laravel
    ├── database/          # Migraciones y seeds
    ├── public/            # Punto de entrada web
    └── .env               # Variables de entorno
```

## 🏗️ Módulos del Sistema

El sistema incluye **10 módulos principales**:

1. **Licencias** (97 componentes) - Permisos y trámites comerciales
2. **Aseo Urbano** (103 componentes) - Gestión de limpieza municipal
3. **Apremios** (61 componentes) - Cobranza coactiva
4. **Cementerios** (36 componentes) - Servicios funerarios
5. **Convenios** (94 componentes) - Acuerdos de pago
6. **Estacionamientos** (61 componentes) - Control vehicular
7. **Mercados** (107 componentes) - Gestión comercial
8. **Otras Obligaciones** (3 componentes) - Gestión diversa
9. **Recaudadora** (106 componentes) - Padrón de recaudación
10. **Trámite Trunk** (68 componentes) - Padrón catastral

**Total: 739 componentes**

## ⚡ Instalación y Configuración

### Requisitos Previos
- Node.js 16+
- PHP 8.1+
- PostgreSQL 13+
- Composer

### Frontend (Vue.js)
```bash
cd harweb-main/frontend-vue
npm install
npm run dev
```

### Backend (Laravel)
```bash
cd harweb-main/backend-laravel
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Base de Datos
Configurar las variables de entorno en `.env`:
```env
DB_CONNECTION=pgsql
DB_HOST=68.155.217.137
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=R3c0d325
DB_SCHEMA=pavimentacion
```

## 👥 Usuarios del Sistema

- **Administrador** - ElChampion (Acceso completo)
- **Operadores** - Personal municipal especializado
- **Supervisores** - Gestión y reportes

## 🔧 Scripts Disponibles

### Frontend
```bash
npm run dev      # Servidor de desarrollo
npm run build    # Build de producción
npm run preview  # Vista previa del build
```

### Backend
```bash
php artisan serve          # Servidor de desarrollo
php artisan migrate        # Ejecutar migraciones
php artisan db:seed        # Poblar base de datos
```

## 📝 Versión

**v1.0.570** - Sistema Municipal Digital

---
