# Documentación Técnica: Migración de Formulario dictamenfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend**: Laravel API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica SQL encapsulada en stored procedures.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "eRequest": "dictamenfrm.getAnuncio",
    "params": { "anuncio": 12345 }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```
- **eRequest soportados**:
  - `dictamenfrm.getAnuncio`: Consulta de datos de anuncio.
  - `dictamenfrm.printReport`: Simulación de generación de PDF (en producción, integración con servicio de reportes).

## 3. Stored Procedure
- Toda la lógica SQL se encapsula en `dictamenfrm_get_anuncio(anuncio_id integer)`.
- Devuelve todos los campos requeridos para el reporte y la vista.

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todos los eRequest.
- Valida parámetros, ejecuta el SP, y retorna la respuesta estructurada.

## 5. Componente Vue.js
- Página independiente `/dictamenfrm`.
- Permite ingresar el número de anuncio y seleccionar tipo de dictamen.
- Muestra los datos del anuncio y permite "imprimir" (simulado: descarga PDF).
- Maneja errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 7. Extensibilidad
- Nuevos eRequest pueden agregarse fácilmente en el controlador y frontend.
- Los SP pueden evolucionar sin afectar la API.

## 8. Notas de Migración
- El reporte visual (PDF) debe implementarse con una solución de generación de reportes en Laravel (ej: DomPDF, TCPDF, o integración con JasperReports).
- El SP puede adaptarse para devolver datos adicionales si el reporte lo requiere.

## 9. Estructura de Carpetas
- `app/Http/Controllers/Api/ExecuteController.php`
- `resources/js/pages/DictamenFrmPage.vue`
- `database/migrations/` y `database/functions/` para SP

## 10. Pruebas
- Casos de uso y pruebas detallados en las secciones siguientes.
