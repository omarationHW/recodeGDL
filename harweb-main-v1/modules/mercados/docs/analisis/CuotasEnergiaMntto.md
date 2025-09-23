# Documentación Técnica: Mantenimiento Cuotas de Energía Eléctrica

## Descripción General
Este módulo permite la gestión (alta, modificación, consulta y listado) de las cuotas de energía eléctrica (tabla `ta_11_kilowhatts`) para cada año y periodo. La migración Delphi → Laravel + Vue.js + PostgreSQL se realiza con arquitectura API REST unificada y lógica de negocio en stored procedures.

## Arquitectura
- **Backend:** Laravel Controller (API REST, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (stored procedures para toda la lógica SQL)
- **Patrón API:** eRequest/eResponse (acción y datos en el body)

## Endpoints
- **POST /api/execute**
  - **action:** string (ej: `insertCuota`, `updateCuota`, `getCuota`, `listCuotas`)
  - **data:** objeto con los parámetros requeridos

## Stored Procedures
- `sp_insert_cuota_energia(axo, periodo, importe, id_usuario)`
- `sp_update_cuota_energia(id_kilowhatts, axo, periodo, importe, id_usuario)`
- `sp_get_cuota_energia(id_kilowhatts)`
- `sp_list_cuotas_energia(axo, periodo)`

## Validaciones
- El importe debe ser mayor a cero.
- El año (axo) debe ser >= 2002.
- El periodo debe estar entre 1 y 12.
- No se permite guardar cuotas vacías o en cero.

## Seguridad
- El campo `id_usuario` debe ser validado por el backend (usualmente por sesión/login, aquí simulado).
- Todas las operaciones de inserción y actualización quedan auditadas por usuario y fecha.

## Flujo de la Interfaz
1. El usuario puede agregar una nueva cuota (año, periodo, importe).
2. Puede editar una cuota existente (no puede cambiar año/periodo, sólo importe).
3. Puede filtrar el listado por año y/o periodo.
4. El listado muestra todas las cuotas existentes con sus datos principales.

## Errores y Mensajes
- Todos los errores de validación y de base de datos se devuelven en el campo `message` del eResponse.
- El frontend muestra los mensajes en pantalla.

## Integración
- El frontend y backend se comunican exclusivamente por `/api/execute`.
- El backend sólo expone el controlador `CuotasEnergiaMnttoController` para este formulario.

# Esquema de Tabla (PostgreSQL)
```sql
CREATE TABLE ta_11_kilowhatts (
    id_kilowhatts SERIAL PRIMARY KEY,
    axo INTEGER NOT NULL,
    periodo INTEGER NOT NULL,
    importe NUMERIC(12,2) NOT NULL,
    fecha_alta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INTEGER NOT NULL
);
```

# Ejemplo de eRequest/eResponse
**eRequest:**
```json
{
  "action": "insertCuota",
  "data": {
    "axo": 2024,
    "periodo": 6,
    "importe": 123.45,
    "id_usuario": 1
  }
}
```
**eResponse:**
```json
{
  "success": true,
  "message": "Cuota insertada correctamente.",
  "data": {
    "id_kilowhatts": 10,
    "axo": 2024,
    "periodo": 6,
    "importe": 123.45,
    "fecha_alta": "2024-06-01T12:34:56",
    "id_usuario": 1
  }
}
```

# Notas de Migración
- El control de validación de importe y campos obligatorios se realiza tanto en frontend como en backend.
- El frontend Vue.js es una página independiente, sin tabs ni dependencias de otras vistas.
- El backend sólo expone el endpoint `/api/execute` y toda la lógica se canaliza por el controlador y los stored procedures.
- El listado de cuotas es reactivo y se actualiza tras cada operación.

# Seguridad y Auditoría
- Cada inserción/modificación almacena el usuario y la fecha/hora.
- El endpoint requiere autenticación (simulada en este ejemplo).

# Pruebas y Casos de Uso
Ver sección de casos de uso y casos de prueba.
