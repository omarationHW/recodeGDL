# CuotasEnergiaMntto

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - CuotasEnergiaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de energía eléctrica

**Descripción:** El usuario desea registrar una nueva cuota para el año y periodo actual.

**Precondiciones:**
El usuario está autenticado y tiene permisos de mantenimiento.

**Pasos a seguir:**
1. El usuario accede a la página de Mantenimiento Cuotas de Energía Eléctrica.
2. Hace clic en 'Nuevo' (o deja el formulario en blanco).
3. Ingresa el año (ej: 2024), periodo (ej: 6), y el importe (ej: 150.00).
4. Presiona 'Guardar'.
5. El sistema valida los datos y envía el eRequest al backend.
6. El backend inserta la cuota y responde con éxito.
7. El frontend muestra el mensaje de éxito y actualiza el listado.

**Resultado esperado:**
La cuota se inserta correctamente y aparece en el listado.

**Datos de prueba:**
{ "axo": 2024, "periodo": 6, "importe": 150.00, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de una cuota existente

**Descripción:** El usuario necesita corregir el importe de una cuota ya registrada.

**Precondiciones:**
Existe una cuota para año 2024, periodo 6. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario filtra el listado por año 2024 y periodo 6.
2. Hace clic en 'Editar' sobre la cuota deseada.
3. Cambia el importe a 175.00.
4. Presiona 'Actualizar'.
5. El sistema valida y envía el eRequest al backend.
6. El backend actualiza la cuota y responde con éxito.
7. El frontend muestra el mensaje y actualiza el listado.

**Resultado esperado:**
El importe de la cuota se actualiza correctamente.

**Datos de prueba:**
{ "id_kilowhatts": 10, "axo": 2024, "periodo": 6, "importe": 175.00, "id_usuario": 1 }

---

## Caso de Uso 3: Validación de importe vacío o cero

**Descripción:** El usuario intenta guardar una cuota sin importe o con importe cero.

**Precondiciones:**
El usuario está en el formulario de alta o edición.

**Pasos a seguir:**
1. El usuario deja el campo importe vacío o en cero.
2. Presiona 'Guardar' o 'Actualizar'.
3. El frontend valida y muestra un mensaje de error.
4. Si el frontend no lo bloquea, el backend también valida y rechaza la operación.

**Resultado esperado:**
El sistema no permite guardar cuotas vacías o en cero y muestra un mensaje de error.

**Datos de prueba:**
{ "axo": 2024, "periodo": 6, "importe": 0, "id_usuario": 1 }

---



## Casos de Prueba

# Casos de Prueba: Cuotas de Energía Eléctrica

## Caso 1: Alta exitosa de cuota
- **Entrada:** axo=2024, periodo=6, importe=150.00, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=true, message='Cuota insertada correctamente.'
- **Validación:** La cuota aparece en el listado.

## Caso 2: Modificación exitosa de cuota
- **Entrada:** id_kilowhatts=10, axo=2024, periodo=6, importe=175.00, id_usuario=1
- **Acción:** updateCuota
- **Esperado:** success=true, message='Cuota actualizada correctamente.'
- **Validación:** El importe de la cuota cambia en el listado.

## Caso 3: Validación de importe vacío/cero
- **Entrada:** axo=2024, periodo=6, importe=0, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El importe debe ser mayor a cero.'
- **Validación:** No se inserta la cuota, mensaje de error visible.

## Caso 4: Listado filtrado por año y periodo
- **Entrada:** axo=2024, periodo=6
- **Acción:** listCuotas
- **Esperado:** success=true, data contiene sólo cuotas de ese año y periodo.

## Caso 5: Consulta de cuota por ID
- **Entrada:** id_kilowhatts=10
- **Acción:** getCuota
- **Esperado:** success=true, data contiene los datos de la cuota solicitada.

## Caso 6: Error por año fuera de rango
- **Entrada:** axo=1999, periodo=6, importe=100, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El año debe ser mayor o igual a 2002.'

## Caso 7: Error por periodo fuera de rango
- **Entrada:** axo=2024, periodo=13, importe=100, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El periodo debe estar entre 1 y 12.'



