# Documentación Técnica: Migración de Formulario Firma Electrónica (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Firma Electrónica.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada/salida JSON).

## 2. API Backend
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listarFolios|generarFirma|insertarFirma|listarFirmasGeneradas",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```
- **Controlador:** `FirmaElectronicaController` implementa el endpoint y delega a métodos privados según la acción.
- **Validación:** Laravel Validator para parámetros de entrada.
- **Acceso a datos:** Uso de DB::select para invocar stored procedures PostgreSQL.

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de negocio y reglas de firma electrónica se implementan en SPs.
- **sp_firmaelectronica_listar_folios:** Devuelve los folios a firmar según módulo y fecha.
- **sp_firmaelectronica_generar_firma:** Ejecuta el proceso de firmado (simulado o real).
- **sp_firmaelectronica_insertar_firma:** Inserta la firma electrónica en la tabla de apremios firmados.
- **sp_firmaelectronica_listar_firmas_generadas:** Lista las firmas generadas para un módulo y fecha.
- Todas las funciones devuelven TABLE (estilo recordset) para fácil consumo desde Laravel.

## 4. Frontend (Vue.js)
- **Componente:** `FirmaElectronicaPage.vue` es una página completa, no un tab.
- **Flujo:**
  1. Selección de módulo y fecha.
  2. Listado de folios disponibles (checkbox para seleccionar).
  3. Envío de datos a firma (simulado, en backend real se haría el proceso).
  4. Generación de firma electrónica (llama a backend para cada folio seleccionado).
  5. Estadísticas y mensajes de proceso.
- **API:** Todas las llamadas usan `/api/execute` con el patrón eRequest/eResponse.
- **UX:** Mensajes de error, validación de campos, feedback visual.

## 5. Seguridad
- **Autenticación:** Se recomienda JWT o session token en producción.
- **Validación:** Todos los parámetros son validados en backend.
- **Permisos:** El backend debe validar que el usuario tenga permisos para firmar.

## 6. Consideraciones de Migración
- **Delphi → Laravel:**
  - Los StoredProc y Query se migran a funciones/procedimientos PostgreSQL.
  - La lógica de los botones y eventos se implementa como métodos en el controlador.
  - Los campos calculados (ej: descripción de diligencia) se calculan en el SP o en el frontend.
- **Delphi → Vue.js:**
  - Cada formulario es una página Vue independiente.
  - No se usan tabs ni componentes tabulares.
  - Navegación y breadcrumbs opcionales.

## 7. Pruebas y QA
- **Casos de uso y prueba** incluidos abajo.
- **Pruebas automáticas:** Se recomienda usar PHPUnit y Cypress para pruebas end-to-end.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar el endpoint.
- Los SP pueden evolucionar sin afectar la API.

## 9. Ejemplo de llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "listarFolios",
    "modulo": 14,
    "fecha": "2024-06-01"
  }
}
```

## 10. Notas
- El proceso de firma electrónica real debe integrarse con el motor de firma correspondiente (no incluido aquí).
- El frontend puede adaptarse a diseño institucional.
