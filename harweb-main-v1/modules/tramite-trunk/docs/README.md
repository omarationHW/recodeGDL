# Proyecto Migrado: tramite trunk

## Estadísticas
- Formularios procesados: 68
- Unidades procesadas: 0
- Stored Procedures generados: 172
- Módulos refactorizados: 64

## Estructura
- `backend-laravel/` - API Laravel con endpoint único
- `frontend-vue/` - Interfaz Vue.js
- `database/` - Scripts PostgreSQL

## Instalación
1. cd backend-laravel && composer install
2. Configurar .env
3. Ejecutar scripts de database/
4. cd frontend-vue && npm install
5. npm run dev