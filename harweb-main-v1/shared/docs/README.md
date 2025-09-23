# Sistema Principal Harweb

Sistema modular para gestión de back office empresarial.

## Arquitectura

- **Backend**: Laravel 10+ con PostgreSQL
- **Frontend**: Vue.js 3 con Tailwind CSS  
- **Estructura**: Modular - cada proyecto Delphi migrado se integra como módulo independiente

## Módulos

Los módulos se almacenan en la carpeta `/modules/` y se cargan dinámicamente:

- Cada módulo tiene su propia estructura Laravel + Vue
- Los módulos se registran automáticamente en el sistema principal
- Navegación dinámica basada en módulos disponibles

## Desarrollo

1. Instalar dependencias: `composer install` y `npm install`
2. Configurar base de datos en `.env`
3. Ejecutar migraciones: `php artisan migrate`
4. Desarrollo frontend: `npm run dev`
5. Servidor backend: `php artisan serve`

## Estructura de Módulos

```
modules/
├── nombre-modulo/
│   ├── backend-laravel/
│   ├── frontend-vue/
│   └── docs/
```

Cada módulo es autónomo y se integra al sistema principal.