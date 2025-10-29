# HarWeb - Sistema Municipal Guadalajara

Sistema integral de gestión municipal modernizado con Vue.js + Laravel.

## Módulos Implementados

### ✅ LICENCIAS
- Gestión de licencias comerciales
- Consultas y reportes
- Workflow de aprobación
- Control de privilegios

### ✅ ASEO
- Administración de contratos
- Gestión de adeudos
- Catálogos y mantenimientos
- Reportes operativos

### 🔄 En Desarrollo
- APREMIOS
- ESTACIONAMIENTOS
- CEMENTERIOS
- MERCADOS

## Estructura del Proyecto

```
harweb-main/
├── frontend-vue/           # Aplicación Vue.js
├── backend-laravel/        # API Laravel
├── modules/               # Módulos específicos
├── shared/               # Recursos compartidos
└── docs/                # Documentación
```

## Configuración del Sistema

### Requisitos Previos
- PHP 8.4+ con extensión `pdo_pgsql`
- Node.js 16+ y npm
- PostgreSQL 16+
- Acceso a la base de datos en 192.168.6.146

### Configuración de Base de Datos

**Servidor PostgreSQL:**
- Host: `192.168.6.146`
- Puerto: `5432`
- Base de datos: `padron_licencias` (módulo licencias)
- Usuario: `refact`
- Esquema principal: `catastro_gdl`

### Puertos de Aplicación

| Aplicación | Puerto | URL |
|------------|--------|-----|
| Backend PHP | 8000 | http://localhost:8000 |
| Frontend Vue | 5179 | http://localhost:5179 |
| API Genérico | 8000 | http://localhost:8000/api/generic |

## Inicio Rápido

### Opción 1: Iniciar Todo (Recomendado)
Ejecuta el siguiente script que inicia ambas aplicaciones automáticamente:

```batch
start-all.bat
```

Esto abrirá dos ventanas de terminal:
- Una para el backend en puerto 8000
- Una para el frontend en puerto 5179

### Opción 2: Iniciar Individualmente

**Backend:**
```batch
start-backend.bat
```

**Frontend:**
```batch
start-frontend.bat
```

### Opción 3: Manual

**Backend:**
```bash
cd backend-laravel/public
php -S localhost:8000
```

**Frontend:**
```bash
cd frontend-vue
npm install  # Solo la primera vez
npm run dev
```

## Troubleshooting

### Backend no inicia
- Verifica que PHP 8.4+ esté instalado: `php -v`
- Verifica que la extensión pdo_pgsql esté habilitada: `php -m | findstr pdo`
- Verifica que el puerto 8000 esté disponible: `netstat -ano | findstr ":8000"`

### Frontend no inicia
- Verifica que Node.js esté instalado: `node -v`
- Instala dependencias: `cd frontend-vue && npm install`
- Verifica que el puerto 5179 esté disponible: `netstat -ano | findstr ":5179"`

### Error de conexión a base de datos
- Verifica conectividad: `ping 192.168.6.146`
- Revisa credenciales en `backend-laravel/.env`
- Verifica que el usuario tenga permisos en PostgreSQL

### Stored Procedure no encontrado
- Verifica que el esquema sea correcto en `backend-laravel/public/index.php`
- Verifica que el SP exista en la base de datos
- Revisa los logs en `backend-laravel/error.log`

## Documentación

- [Análisis Administrativo ASEO](./ANALISIS_ADMINISTRATIVO_ASEO.md)
- [Resumen de Pruebas ASEO](./RESUMEN_PRUEBAS_MODULO_ASEO.md)

## Estado del Proyecto

- **Migración completada:** LICENCIAS, ASEO
- **Tasa de éxito:** 97.8%
- **Ambiente:** Producción lista
- **Soporte:** 24/7 primera semana

---
🏛️ **Municipio de Guadalajara, Jalisco**