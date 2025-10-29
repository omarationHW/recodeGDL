# Documentación Técnica: Migración de Formulario MetroMeters (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (sin tabs).
- **Backend**: Laravel API con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Integración Externa**: Llamadas SOAP para fotos simuladas en el controlador (reemplazar por integración real si es necesario).

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "eRequest": "getMetrometerByAxoFolio", // o "updateMetrometer", "getMetrometerPhoto"
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | { ... },
      "message": "..."
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de acceso y actualización de datos está en SPs:
  - `sp_get_metrometer_by_axo_folio(axo, folio)`
  - `sp_update_metrometer(axo, folio, direccion, marca, motivo, ...)`

## 4. Vue.js
- Página única para MetroMeters.
- Formulario de búsqueda por año y folio.
- Formulario de edición de datos.
- Visualización de fotos (base64) y mapa de ubicación (Google Maps embed).
- Navegación breadcrumb.

## 5. Controlador Laravel
- Un solo controlador maneja todos los eRequest.
- Validación de parámetros.
- Llamada a SPs vía DB::select.
- Simulación de llamada SOAP para fotos (reemplazar por integración real).

## 6. Seguridad
- Validación de parámetros en backend.
- No se exponen queries directos, solo SPs.

## 7. Integración de Fotos
- El endpoint `getMetrometerPhoto` simula la obtención de la foto vía SOAP y retorna base64.
- En producción, debe integrarse con el servicio real.

## 8. Navegación
- Cada formulario es una página Vue.js independiente, sin tabs.
- Breadcrumb para navegación contextual.

## 9. Pruebas
- Casos de uso y escenarios de prueba incluidos para QA.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevos formularios y operaciones fácilmente.

---
