# Documentación Técnica: Mannto_Gastos

## Análisis

# Documentación Técnica: Mantenimiento de Gastos (Mannto_Gastos)

## Descripción General
Este módulo permite la administración de los parámetros de gastos (Salario Diario ZMG, % Requerimiento, % Embargo, % Secuestro) que se utilizan en el cálculo de apremios y recargos en el sistema. Solo puede existir un registro vigente en la tabla `ta_16_gastos`.

## Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## API
### Endpoint
- **POST** `/api/execute`

#### Request
```json
{
  "action": "gastos.create|gastos.update|gastos.delete|gastos.list",
  "payload": {
    "sdzmg": 123.45,
    "porc1_req": 10.0,
    "porc2_embargo": 15.0,
    "porc3_secuestro": 20.0
  }
}
```

#### Response
```json
{
  "success": true,
  "message": "Gastos creados correctamente.",
  "data": [ ... ]
}
```

### Acciones
- `gastos.list`: Lista el registro actual de gastos
- `gastos.create`: Elimina todos los registros y crea uno nuevo
- `gastos.update`: Igual que create (por la lógica del sistema)
- `gastos.delete`: Elimina todos los registros

## Validaciones
- Ningún campo puede ser cero o vacío
- Solo puede existir un registro

## Stored Procedures
- `sp_gastos_insert`: Inserta un registro
- `sp_gastos_delete_all`: Borra todos los registros

## Seguridad
- Validar que el usuario tenga permisos de administración
- Validar que los valores sean numéricos y mayores a cero

## Frontend
- Página Vue.js independiente
- Formulario con validación en cliente y servidor
- Tabla de consulta de gastos actual
- Acciones: Crear, Editar, Eliminar
- Navegación breadcrumb

## Integración
- El componente Vue llama a `/api/execute` con la acción correspondiente
- El backend ejecuta el stored procedure adecuado
- El frontend refresca la tabla tras cada operación

## Errores
- Mensajes claros en caso de error de validación o de base de datos

## Pruebas
- Casos de uso y pruebas unitarias incluidas abajo


## Casos de Uso

# Casos de Uso - Mannto_Gastos

**Categoría:** Form

## Caso de Uso 1: Alta de Gastos

**Descripción:** El usuario administrador ingresa los parámetros de gastos para el ejercicio actual.

**Precondiciones:**
El usuario tiene permisos de administrador y no existe un registro previo en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Nuevo Gasto'.
3. Llena los campos: Salario Diario ZMG, % Requerimiento, % Embargo, % Secuestro.
4. Da clic en 'Crear'.

**Resultado esperado:**
Se crea un registro en ta_16_gastos y se muestra en la tabla. Mensaje: 'Gastos creados correctamente.'

**Datos de prueba:**
{ "sdzmg": 150.00, "porc1_req": 10.5, "porc2_embargo": 15.0, "porc3_secuestro": 20.0 }

---

## Caso de Uso 2: Modificación de Gastos

**Descripción:** El usuario actualiza los parámetros de gastos existentes.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Editar' sobre el registro.
3. Modifica los valores requeridos.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
El registro es reemplazado por los nuevos valores. Mensaje: 'Gastos actualizados correctamente.'

**Datos de prueba:**
{ "sdzmg": 160.00, "porc1_req": 12.0, "porc2_embargo": 18.0, "porc3_secuestro": 22.0 }

---

## Caso de Uso 3: Eliminación de Gastos

**Descripción:** El usuario elimina todos los parámetros de gastos.

**Precondiciones:**
Existe al menos un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Gastos.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
No quedan registros en ta_16_gastos. Mensaje: 'Todos los gastos eliminados.'

**Datos de prueba:**
N/A

---



## Casos de Prueba

## Casos de Prueba para Mannto_Gastos

### Caso 1: Alta de Gastos
- **Input:** sdzmg=150.00, porc1_req=10.5, porc2_embargo=15.0, porc3_secuestro=20.0
- **Acción:** POST /api/execute { action: 'gastos.create', payload: { ... } }
- **Esperado:** HTTP 200, success=true, mensaje 'Gastos creados correctamente.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver un registro con los valores ingresados

### Caso 2: Modificación de Gastos
- **Input:** sdzmg=160.00, porc1_req=12.0, porc2_embargo=18.0, porc3_secuestro=22.0
- **Acción:** POST /api/execute { action: 'gastos.update', payload: { ... } }
- **Esperado:** HTTP 200, success=true, mensaje 'Gastos actualizados correctamente.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver el registro actualizado

### Caso 3: Eliminación de Gastos
- **Input:** N/A
- **Acción:** POST /api/execute { action: 'gastos.delete' }
- **Esperado:** HTTP 200, success=true, mensaje 'Todos los gastos eliminados.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver cero registros

### Caso 4: Validación de Ceros
- **Input:** sdzmg=0, porc1_req=0, porc2_embargo=0, porc3_secuestro=0
- **Acción:** POST /api/execute { action: 'gastos.create', payload: { ... } }
- **Esperado:** HTTP 200, success=false, mensaje de error de validación
- **Verificación:** No se inserta ningún registro

### Caso 5: Consulta de Gastos
- **Input:** N/A
- **Acción:** POST /api/execute { action: 'gastos.list' }
- **Esperado:** HTTP 200, success=true, data con los registros actuales


