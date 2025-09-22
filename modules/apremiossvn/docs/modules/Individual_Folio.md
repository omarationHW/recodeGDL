# Documentación Técnica: Migración Formulario Individual Folio (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 SPA (Single Page Application), cada formulario es una página independiente
- **Base de Datos**: PostgreSQL 13+ (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación**: eRequest/eResponse (payload JSON con acción y parámetros)

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "search|history|periods|catalogs", "params": { ... } } }`
- **Salida**: `{ "eResponse": { ... } }`
- **Acciones soportadas**:
  - `search`: Buscar folio individual
  - `history`: Historia del folio
  - `periods`: Periodos asociados
  - `catalogs`: Catálogos auxiliares (aplicaciones, recaudadoras)

## 3. Stored Procedures
- Toda la lógica de consulta y negocio reside en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SP y retorna el resultado.
- Los SP devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## 4. Vue.js Component
- Página independiente (`IndividualFolioPage.vue`)
- Formulario de búsqueda (aplicación, recaudadora, folio)
- Muestra datos del folio, historia y periodos en tablas separadas
- Validación de campos en frontend y backend
- Navegación: cada formulario es una página, no hay tabs

## 5. Seguridad
- Validación de parámetros en backend (Laravel Validator)
- No se exponen queries directos, solo SP
- El endpoint puede protegerse con middleware de autenticación si se requiere

## 6. Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el SP correspondiente
- Los catálogos pueden ampliarse fácilmente

## 7. Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "search",
    "params": {
      "modulo": 11,
      "folio": 12345,
      "recaudadora": 1
    }
  }
}
```

## 8. Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "id_control": 123,
      "folio": 12345,
      ...
    }
  }
}
```

## 9. Flujo de la Página
1. Usuario selecciona aplicación y recaudadora, ingresa folio y presiona Buscar
2. Se llama a `/api/execute` con acción `search`
3. Si existe, se muestran los datos principales
4. Se llaman en paralelo las acciones `history` y `periods` para mostrar historia y periodos
5. El usuario puede buscar otro folio (reset)

## 10. Consideraciones
- El frontend asume que los catálogos de aplicaciones y recaudadoras están disponibles vía API
- El backend puede extenderse para incluir más lógica de negocio o validaciones
- El endpoint es genérico y puede ser usado por otros formularios

---
