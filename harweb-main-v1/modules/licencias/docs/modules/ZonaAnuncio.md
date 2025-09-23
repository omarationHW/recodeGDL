# Documentación Técnica: Migración Formulario ZonaAnuncio Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la actualización de la zona, subzona y recaudadora asociada a un anuncio publicitario. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), usando procedimientos almacenados y un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador `ZonaAnuncioController`.
- **Frontend:** Vue.js 3+ (SPA), componente de página independiente `ZonaAnuncioPage.vue`.
- **Base de datos:** PostgreSQL, con procedimientos almacenados para toda la lógica CRUD y catálogos.
- **API:** Endpoint único `/api/execute` que recibe un objeto eRequest con acción y parámetros, y responde con eResponse.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "zonaanuncio.create|update|get|list|delete|catalogs",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "data": { ... },
    "success": true|false,
    "error": "mensaje"
  }
  ```

## 4. Métodos soportados
- `zonaanuncio.list`: Lista zonas de un anuncio
- `zonaanuncio.get`: Obtiene zona de un anuncio
- `zonaanuncio.create`: Crea zona para anuncio
- `zonaanuncio.update`: Actualiza zona de anuncio
- `zonaanuncio.delete`: Elimina zona de anuncio
- `zonaanuncio.catalogs`: Devuelve catálogos de zonas, subzonas y recaudadoras

## 5. Seguridad
- El controlador asume autenticación Laravel (middleware `auth:api` recomendado).
- El campo `capturista` se toma del usuario autenticado (`$user->username`), o 'system' si no hay usuario.

## 6. Validaciones
- Todos los campos requeridos son validados en backend y frontend.
- No se permite duplicar zonas para el mismo anuncio.

## 7. Frontend (Vue.js)
- Página independiente, sin tabs.
- Navegación por rutas (ejemplo: `/anuncios/:anuncio/zona` para edición).
- Catálogos cargados vía API.
- Mensajes de éxito/error amigables.
- Navegación a listado de anuncios tras cancelar.

## 8. Stored Procedures
- Toda la lógica SQL reside en funciones/procedimientos almacenados en PostgreSQL.
- Los catálogos se devuelven como tablas con un campo `tipo` para distinguir zona/subzona/recaudadora.

## 9. Integración
- El frontend llama a `/api/execute` con la acción y parámetros.
- El backend enruta la acción al método correspondiente y ejecuta el SP adecuado.

## 10. Consideraciones
- El formulario es atómico: cada acción es una página/vista completa.
- El endpoint es extensible para otros formularios.
- El código es desacoplado y preparado para pruebas unitarias y de integración.

# Diagrama de Flujo
1. Usuario navega a la página de Zona de Anuncio
2. Vue carga catálogos vía `zonaanuncio.catalogs`
3. Si es edición, carga datos vía `zonaanuncio.get`
4. Usuario edita y guarda (llama `zonaanuncio.update` o `zonaanuncio.create`)
5. Backend ejecuta SP correspondiente y responde
6. Frontend muestra mensaje y navega según resultado

# Ejemplo de eRequest/eResponse
```json
{
  "action": "zonaanuncio.update",
  "params": {
    "anuncio": 1234,
    "zona": 2,
    "subzona": 5,
    "recaud": 3
  }
}
```

## 11. Migración de lógica Delphi
- Los eventos de scroll, afterpost, etc. se traducen a lógica de actualización de combos y validación en frontend.
- El control de inserción/edición se maneja por existencia de registro en la tabla.
- El campo `feccap` se actualiza automáticamente en cada cambio.

# 12. Pruebas y Casos de Uso
Ver secciones siguientes.
