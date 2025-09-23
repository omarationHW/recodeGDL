# Documentación Técnica: Migración Formulario Modificar Apremio (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Modificar Folio
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Autenticación:** JWT o sesión Laravel (no incluido aquí, pero recomendado)

## Flujo de Trabajo
1. **Usuario accede a la página de Modificar Folio**
2. Ingresa módulo, recaudadora y folio, y pulsa "Verificar"
3. El frontend llama a `/api/execute` con `action: getFolio`
4. El backend ejecuta el SP `sp_get_apremio` y retorna los datos
5. El usuario edita los campos permitidos y pulsa "Modificar"
6. El frontend llama a `/api/execute` con `action: modificarFolio` y los datos
7. El backend ejecuta el SP `sp_modificar_apremio`, actualiza el registro y guarda el historial
8. El frontend muestra mensaje de éxito y recarga el historial con `sp_historial_apremio`

## API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "action": "getFolio|modificarFolio|historialFolio",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "data": [ ... ],
      "errors": [ ... ]
    }
  }
  ```

## Validaciones
- El backend valida los parámetros requeridos para cada acción
- El frontend valida campos numéricos, fechas y requeridos antes de enviar
- El SP de modificación sólo actualiza campos permitidos y registra el historial

## Seguridad
- Todas las acciones requieren usuario autenticado (no incluido aquí)
- Los stored procedures validan existencia del folio antes de modificar

## Manejo de Errores
- Errores de validación y de base de datos se devuelven en `eResponse.errors`
- El frontend muestra los errores en pantalla

## Extensibilidad
- El endpoint `/api/execute` puede crecer para soportar más acciones
- Los stored procedures pueden ampliarse para lógica adicional

## Notas de Migración
- Los combos de claves, ejecutores, etc. deben obtenerse por endpoints adicionales o SPs de catálogo
- El historial se muestra en tabla, ordenado por fecha descendente
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página

## Estructura de la Base de Datos
- `ta_15_apremios`: tabla principal de folios de apremio
- `ta_15_historia`: historial de cambios
- Otros catálogos: claves, ejecutores, recaudadoras, etc.

## Ejemplo de eRequest/eResponse
```json
POST /api/execute
{
  "action": "modificarFolio",
  "params": {
    "id_control": 123,
    "modulo": 11,
    "folio": 456,
    "usuario": 1,
    "zona_apremio": 2,
    "observaciones": "Modificación de prueba",
    ...
  }
}

Respuesta:
{
  "eResponse": {
    "status": "ok",
    "data": ["ok"],
    "errors": []
  }
}
```
