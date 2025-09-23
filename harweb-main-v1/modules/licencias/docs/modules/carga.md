# Documentación Técnica: Migración Formulario Cartografía Predial (carga.pas) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8.1+), PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA, router, axios)
- **API:** Unificada, endpoint único `/api/execute` (POST), patrón eRequest/eResponse
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures
- **Cartografía:** La integración GIS se simula vía JSON (en producción, se recomienda microservicio GIS)

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "nombre_accion",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```
- **Acciones soportadas:**
  - `getPredioByClaveCatastral`
  - `getPredioByCuenta`
  - `getCartografia`
  - `getNumerosOficiales`
  - `getCondominio`
  - `getAvaluo`
  - `getConstrucciones`

## 3. Controlador Laravel
- Un solo método `execute(Request $request)`
- Valida acción y parámetros
- Llama al stored procedure correspondiente vía DB::select
- Devuelve resultado en `eResponse` o error

## 4. Componente Vue.js
- Página independiente (NO tabs)
- Formulario para buscar predio por clave catastral/subpredio
- Muestra datos del predio y botones para consultar cartografía, números oficiales, condominio
- Cada consulta llama a `/api/execute` con la acción y parámetros adecuados
- Manejo de errores y estados
- Filtros para formato de moneda

## 5. Stored Procedures PostgreSQL
- Cada consulta relevante encapsulada en una función SQL
- Todas devuelven TABLE o JSON según el caso
- Nombres: `get_predio_by_clave_catastral`, `get_predio_by_cuenta`, etc.
- Simulación de cartografía (en producción, integrar GIS real)

## 6. Seguridad
- Se recomienda proteger `/api/execute` con autenticación JWT o session
- Validar parámetros en backend

## 7. Extensibilidad
- Para agregar nuevas acciones, crear el SP y añadir el case en el controlador
- El frontend puede extenderse con nuevos botones/vistas

## 8. Integración GIS
- Actualmente simulado
- Para producción, se recomienda microservicio GIS (GeoServer, PostGIS, etc.) y consumir vía REST

## 9. Pruebas
- Casos de uso y pruebas incluidas abajo

# Notas de Migración
- El formulario Delphi usaba componentes visuales y lógica de eventos; en Vue.js se traduce a métodos y estados reactivos
- La lógica de acceso a archivos shape/cartografía se simula; en producción debe integrarse con GIS real
- El acceso a la base de datos se realiza exclusivamente vía stored procedures
- El endpoint es único y desacoplado de la UI
