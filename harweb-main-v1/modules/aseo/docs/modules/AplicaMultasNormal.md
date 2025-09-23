# Documentación Técnica: AplicaMultasNormal

## Descripción General
El módulo **AplicaMultasNormal** permite consultar y modificar la configuración global de la aplicación de requerimientos normales para cobro de multas en el sistema. Esta configuración determina si la aplicación es normal (aplica = 'S') o si se aplica un porcentaje de descuento (aplica = 'N', porc > 0).

## Arquitectura
- **Backend**: Laravel Controller expuesto en `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  - `action`: (string) Acción a ejecutar (`get_aplicareq`, `update_aplicareq`)
  - `params`: (object) Parámetros para la acción

### Acciones soportadas
- `get_aplicareq`: Devuelve la configuración actual.
- `update_aplicareq`: Actualiza la configuración. Requiere `aplica` ('S' o 'N') y `porc` (entero).

## Stored Procedures
- `sp_get_aplicareq()`: Devuelve la fila de configuración.
- `sp_update_aplicareq(p_aplica, p_porc)`: Actualiza la configuración.

## Validaciones
- Si `aplica = 'N'`, `porc` debe ser > 0 y <= 100.
- Si `aplica = 'S'`, `porc` debe ser 0.

## Seguridad
- Solo usuarios autenticados con permisos de administración pueden modificar la configuración.
- Todas las operaciones quedan registradas en logs de auditoría (a implementar en el futuro).

## Frontend
- Página Vue.js independiente, sin tabs.
- Muestra los valores actuales y permite modificar la opción y porcentaje.
- Mensajes claros de éxito/error.

## Navegación
- Puede integrarse en el menú principal o accederse directamente por ruta.

## Errores comunes
- Si se intenta guardar con `aplica = 'N'` y `porc <= 0`, se muestra mensaje de error.
- Si la acción no es soportada, se devuelve error desde el backend.

## Ejemplo de eRequest
```json
{
  "action": "update_aplicareq",
  "params": {
    "aplica": "N",
    "porc": 50
  }
}
```

## Ejemplo de eResponse
```json
{
  "success": true,
  "message": "La NO Aplicación Normal CON PORCENTAJE Realizada",
  "data": null
}
```
