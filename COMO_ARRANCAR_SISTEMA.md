# 🚀 Cómo Arrancar el Sistema - RefactorX Guadalajara

**Fecha:** 2025-11-06
**Estado:** ✅ TODO FUNCIONANDO

---

## 📋 Resumen de Diagnóstico

### ✅ Base de Datos PostgreSQL
- **Host:** 192.168.6.146:5432
- **Database:** padron_licencias
- **Usuario:** refact
- **Esquemas:** comun (36 SPs), public (35 SPs)
- **Tablas:** 1,483 tablas disponibles
- **Estado:** ✅ CONECTADO Y FUNCIONANDO

### ✅ Backend Laravel
- **URL:** http://127.0.0.1:8000
- **API Endpoint:** http://127.0.0.1:8000/api/generic
- **Proceso:** PID 23480
- **Estado:** ✅ CORRIENDO
- **Configuración:** search_path = 'comun,public' ✅ CORREGIDO

### ✅ Frontend Vue.js
- **URL:** http://localhost:3001
- **Framework:** Vue 3 + Vite 7.1.11
- **Tiempo de arranque:** 320ms
- **Estado:** ✅ CORRIENDO

---

## 🔧 Configuración Corregida

### 1. Backend - `config/database.php`
**CAMBIO CRÍTICO:** Se agregó el esquema 'comun' al search_path de PostgreSQL.

```php
'pgsql' => [
    // ... otras configuraciones ...
    'search_path' => 'comun,public',  // ✅ ANTES: 'public'
    'sslmode' => 'prefer',
],
```

**Razón:** Los Stored Procedures optimizados están en el esquema 'comun', no en 'public'.

### 2. Frontend - `.env`
```env
VITE_API_BASE_URL=http://127.0.0.1:8000
```

✅ Configuración correcta, no requiere cambios.

---

## 🚀 Pasos para Arrancar el Sistema

### Opción 1: Arranque Manual (Desarrollo)

#### 1. Backend Laravel
```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\BackEnd
php artisan serve
```

**Salida esperada:**
```
Starting Laravel development server: http://127.0.0.1:8000
Press Ctrl+C to stop the server
```

#### 2. Frontend Vue
```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd
npm run dev
```

**Salida esperada:**
```
VITE v7.1.11  ready in XXX ms
➜  Local:   http://localhost:3001/
```

**Nota:** Si el puerto 3000 está ocupado, Vite usará 3001, 3002, etc.

---

### Opción 2: Arranque Rápido (Scripts)

#### Windows PowerShell
Crear archivo `arrancar.ps1`:
```powershell
# Arrancar Backend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\BackEnd'; php artisan serve"

# Esperar 2 segundos
Start-Sleep -Seconds 2

# Arrancar Frontend
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd'; npm run dev"

Write-Host "✅ Sistema arrancado"
Write-Host "Backend: http://127.0.0.1:8000"
Write-Host "Frontend: http://localhost:3001"
```

Ejecutar:
```powershell
.\arrancar.ps1
```

#### Windows Batch
Crear archivo `arrancar.bat`:
```batch
@echo off
echo Arrancando Backend Laravel...
start cmd /k "cd /d C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\BackEnd && php artisan serve"

timeout /t 2 /nobreak >nul

echo Arrancando Frontend Vue...
start cmd /k "cd /d C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd && npm run dev"

echo.
echo ====================================
echo Sistema arrancado correctamente
echo ====================================
echo Backend:  http://127.0.0.1:8000
echo Frontend: http://localhost:3001
echo.
pause
```

Ejecutar:
```batch
arrancar.bat
```

---

## ✅ Verificación de Funcionamiento

### 1. Verificar Backend (API)
```bash
curl -X POST http://127.0.0.1:8000/api/generic ^
  -H "Content-Type: application/json" ^
  -d "{\"eRequest\":{\"Operacion\":\"consulta_giros_estadisticas\",\"Base\":\"padron_licencias\",\"Esquema\":\"comun\",\"Parametros\":[]}}"
```

**Respuesta esperada:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "result": [
        {
          "total": 27204,
          "vigentes": 12052,
          "licencias": 11774,
          "anuncios": 276
        }
      ],
      "count": 1
    }
  }
}
```

### 2. Verificar Frontend
1. Abrir navegador: http://localhost:3001
2. Hacer login
3. Navegar a: **Padrón de Licencias → Búsqueda de Giros**
4. Presionar botón "Buscar"
5. Verificar que se muestren resultados con estadísticas

**Componentes disponibles para probar (19 completados):**
- ✅ Consulta Usuarios
- ✅ Consulta Trámites
- ✅ Consulta Licencias
- ✅ Licencias Vigentes
- ✅ Giros con Adeudo
- ✅ Consulta Anuncios
- ✅ Certificaciones
- ✅ Constancias
- ✅ Búsqueda de Giros
- ✅ Registro de Solicitud
- ✅ Catálogo de Giros
- ✅ Dictámenes
- ✅ Empresas
- ✅ Estatus de Revisión
- ✅ Dependencias
- ✅ Tipos de Bloqueo
- ✅ Requisitos
- ✅ Actividades
- ✅ Documentos

---

## 🔍 Diagnóstico de Problemas

### Problema 1: "No se puede conectar al backend"
**Síntomas:**
- Frontend muestra errores de red
- Componentes no cargan datos

**Solución:**
1. Verificar que Laravel esté corriendo:
   ```bash
   netstat -ano | findstr ":8000"
   ```
2. Si no está corriendo, arrancar:
   ```bash
   cd RefactorX\BackEnd
   php artisan serve
   ```

### Problema 2: "Stored Procedure no encontrado"
**Síntomas:**
- Error: "El Stored Procedure 'xxx' no existe en el esquema 'comun'"

**Solución:**
1. Verificar que el search_path incluya 'comun':
   ```bash
   # Revisar config/database.php línea 97
   'search_path' => 'comun,public',
   ```
2. Limpiar cache de configuración:
   ```bash
   php artisan config:clear
   php artisan cache:clear
   ```

### Problema 3: "Cannot connect to database"
**Síntomas:**
- Error de conexión a PostgreSQL

**Solución:**
1. Verificar que PostgreSQL esté accesible:
   ```bash
   php temp/test_conexion_completa.php
   ```
2. Verificar credenciales en `.env`:
   ```
   DB_HOST=192.168.6.146
   DB_PORT=5432
   DB_DATABASE=padron_licencias
   DB_USERNAME=refact
   DB_PASSWORD="FF)-BQk2"
   ```

### Problema 4: "Puerto ocupado"
**Síntomas:**
- Vite muestra: "Port 3000 is in use, trying another one..."

**Solución:**
- ✅ Normal, Vite automáticamente usará el siguiente puerto disponible (3001, 3002, etc.)
- Actualizar URL en el navegador al puerto mostrado

---

## 📊 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────┐
│                     NAVEGADOR                           │
│              http://localhost:3001                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTP Requests
                     │
┌────────────────────▼────────────────────────────────────┐
│              FRONTEND (Vue 3 + Vite)                    │
│  • Componentes Vue optimizados (19/598)                │
│  • Composables (useApi, useLicenciasErrorHandler)      │
│  • Router (Vue Router 4)                               │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ POST /api/generic
                     │ Content-Type: application/json
                     │
┌────────────────────▼────────────────────────────────────┐
│         BACKEND (Laravel 11 + PHP 8.x)                  │
│  • GenericController (Endpoint único)                  │
│  • Validación de requests                              │
│  • Conexión PDO a PostgreSQL                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ SQL Queries
                     │ SELECT * FROM comun.sp_name(params)
                     │
┌────────────────────▼────────────────────────────────────┐
│      DATABASE (PostgreSQL 16.10)                        │
│  • Esquema 'comun': 36 SPs optimizados                 │
│  • Esquema 'public': 35 SPs legacy                     │
│  • 1,483 tablas                                         │
│  • 29 índices nuevos creados                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Formato de Request al Backend

### Estructura JSON
```json
{
  "eRequest": {
    "Operacion": "nombre_stored_procedure",
    "Base": "padron_licencias",
    "Esquema": "comun",
    "Parametros": [
      {
        "nombre": "param1",
        "valor": "valor1",
        "tipo": "string"
      }
    ],
    "Paginacion": {
      "limit": 10,
      "offset": 0
    }
  }
}
```

### Tipos de Parámetros Soportados
- `string` - Texto
- `integer` / `int` - Enteros
- `numeric` / `decimal` - Decimales
- `boolean` / `bool` - Booleanos
- `json` - JSON

### Esquemas Permitidos
- `comun` - SPs optimizados (RECOMENDADO)
- `public` - SPs legacy

---

## 📝 Checklist de Arranque

- [ ] PostgreSQL accesible (192.168.6.146:5432)
- [ ] Backend Laravel corriendo (puerto 8000)
- [ ] Frontend Vue corriendo (puerto 3001 o similar)
- [ ] API responde correctamente (curl test)
- [ ] Frontend puede cargar datos
- [ ] Componente de prueba funciona (Búsqueda de Giros)

---

## 🛠️ Scripts de Diagnóstico

Los siguientes scripts están disponibles en `temp/`:

1. **test_conexion_completa.php**
   - Verifica conexión a PostgreSQL
   - Lista esquemas y SPs disponibles
   - Prueba ejecución de SP

   ```bash
   php temp/test_conexion_completa.php
   ```

2. **test_api_endpoint.json**
   - Request de prueba para la API
   - Usado con curl para verificar backend

   ```bash
   curl -X POST http://127.0.0.1:8000/api/generic \
     -H "Content-Type: application/json" \
     -d @temp/test_api_endpoint.json
   ```

---

## 📞 Contacto y Soporte

**Proyecto:** RefactorX - Guadalajara
**Módulo:** Sistema Municipal de Licencias
**Progreso:** 19/598 componentes (3.18%)
**Documentación:** COMPONENTES_OPTIMIZADOS.md

**Última actualización:** 2025-11-06 02:03 UTC
**Estado del sistema:** ✅ OPERATIVO

---

## 🎉 ¡TODO ESTÁ FUNCIONANDO!

Si seguiste todos los pasos y los 3 servicios están corriendo:
- ✅ PostgreSQL: 192.168.6.146:5432
- ✅ Laravel Backend: http://127.0.0.1:8000
- ✅ Vue Frontend: http://localhost:3001

**¡Estás listo para desarrollar!** 🚀

Abre tu navegador en http://localhost:3001 y empieza a usar el sistema.
