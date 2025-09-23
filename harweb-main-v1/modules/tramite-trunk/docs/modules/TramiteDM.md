# Documentación Técnica: Migración Formulario TramiteDM (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio crítica en stored procedures.
- **Comunicación**: Patrón eRequest/eResponse, todos los requests POST a `/api/execute`.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "nombre_accion", "params": { ... } } }`
- **Salida**: `{ "eResponse": { "success": bool, "message": string, "data": any } }`
- **Acciones soportadas**:
  - `getActosTransm`, `saveAdquiriente`, `calcImptoTransPat`, `getPorcentajeTotal`, `getEncabeza`, `getContribByRFC`, `getAvaluoExterno`, `getValfiscal`, `getMunicipios`, etc.

## 3. Controlador Laravel
- Un solo controlador (`TramiteDMController`) maneja todas las acciones.
- Cada acción es un método privado.
- Validación de entrada con `Validator`.
- Llama a stored procedures de PostgreSQL usando `DB::select`.
- Maneja errores y excepciones, siempre responde con `eResponse`.

## 4. Vue.js Component
- Cada formulario es una página Vue independiente (no tabs).
- Usa rutas tipo `/tramite-dm`.
- Formulario reactivo, validación básica en frontend.
- Llama a `/api/execute` con eRequest.
- Muestra mensajes de éxito/error y resultados de cálculo.
- Carga catálogos (naturalezas, municipios, etc) vía API.

## 5. Stored Procedures PostgreSQL
- Toda la lógica de cálculo fiscal, reglas históricas y actuales, se implementa en SPs.
- Ejemplo: `calc_impto_transpat` encapsula toda la lógica de cálculo de impuesto patrimonial.
- SPs CRUD para inserción/actualización de adquirientes.
- SPs de reporte para sumatorias y validaciones.

## 6. Seguridad
- Validación de datos en backend y frontend.
- Solo se exponen los endpoints necesarios.
- Uso de prepared statements y parámetros para evitar SQL Injection.

## 7. Pruebas y Casos de Uso
- Casos de uso y pruebas cubren:
  - Registro de adquiriente
  - Cálculo de impuesto
  - Validación de porcentaje de copropiedad
  - Validación de encabeza

## 8. Consideraciones de Migración
- Los triggers y lógica de Delphi se migran a SPs y lógica de backend.
- Los formularios Delphi se convierten en páginas Vue independientes.
- El endpoint único permite desacoplar el frontend del backend.

## 9. Extensibilidad
- Para agregar nuevas acciones, basta con agregar un método en el controlador y/o un nuevo SP.
- El frontend puede agregar nuevas páginas para otros formularios.

## 10. Ejemplo de Request/Response

### Request
```json
{
  "eRequest": {
    "action": "saveAdquiriente",
    "params": {
      "folio": 123,
      "cvecont": 456,
      "porccoprop": 50.0,
      ...
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Adquiriente guardado",
    "data": null
  }
}
```
