# DocumentaciÃ³n TÃ©cnica: ABC_Gastos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Gastos (ABC_Gastos)

## Descripción General
Este módulo permite la administración del catálogo de gastos (tabla `ta_16_gastos`) que contiene los parámetros globales de gastos para requerimiento, embargo y secuestro, así como el salario diario de la zona metropolitana de Guadalajara. Solo debe existir un registro vigente.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL con stored procedures para inserción y borrado.
- **API:** Todas las operaciones (listar, crear, actualizar, eliminar) se realizan mediante el endpoint `/api/execute`.

## Endpoints y Acciones
- **gastos.list**: Obtiene el registro actual de gastos.
- **gastos.create**: Crea un nuevo registro (elimina el anterior si existe).
- **gastos.update**: Actualiza el registro (elimina el anterior y crea uno nuevo).
- **gastos.delete**: Elimina todos los registros de gastos.

## Validaciones
- Todos los campos son obligatorios y deben ser numéricos mayores a cero.
- Solo puede existir un registro en la tabla.

## Stored Procedures
- `sp_gastos_insert`: Inserta un registro.
- `sp_gastos_delete_all`: Elimina todos los registros.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Validar que solo usuarios autorizados puedan modificar el catálogo.

## Integración Vue.js
- El componente Vue.js es una página completa, no usa tabs ni subcomponentes.
- Permite ver, crear, actualizar y eliminar el registro de gastos.
- Muestra mensajes de éxito/error y el registro actual.

## Flujo de Datos
1. El frontend solicita el registro actual (`gastos.list`).
2. El usuario puede crear/actualizar/eliminar el registro.
3. Cada acción se envía como un objeto `{ action: 'gastos.create', payload: { ... } }` al endpoint `/api/execute`.
4. El backend ejecuta el stored procedure correspondiente y responde con eResponse.

## Ejemplo de Request
```json
{
  "action": "gastos.create",
  "payload": {
    "sdzmg": 250.00,
    "porc1_req": 10.0,
    "porc2_embargo": 20.0,
    "porc3_secuestro": 30.0
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": null,
  "message": "Gastos creados correctamente"
}
```

## Notas
- El catálogo de gastos es global y afecta a todo el sistema.
- No se permite tener más de un registro.
- El borrado elimina todos los registros.


## Casos de Prueba

# Casos de Prueba: Catálogo de Gastos

## Caso 1: Crear registro válido
- Ingresar valores positivos en todos los campos.
- Presionar 'Crear'.
- Verificar que el registro se crea y se muestra correctamente.

## Caso 2: Crear registro con valores cero o negativos
- Ingresar 0 o valores negativos en cualquier campo.
- Presionar 'Crear'.
- El sistema debe mostrar un mensaje de error y no permitir la operación.

## Caso 3: Actualizar registro existente
- Modificar uno o más campos del registro actual.
- Presionar 'Actualizar'.
- Verificar que los cambios se reflejan correctamente.

## Caso 4: Eliminar registro
- Presionar 'Eliminar'.
- Confirmar la acción.
- Verificar que la tabla queda vacía.

## Caso 5: Acceso concurrente
- Dos usuarios intentan crear o actualizar el registro al mismo tiempo.
- El sistema debe mantener la integridad y solo permitir un registro.

## Caso 6: Validación de autenticación
- Intentar acceder al endpoint sin autenticación.
- El sistema debe rechazar la petición.


## Casos de Uso

# Casos de Uso - ABC_Gastos

**Categoría:** Form

## Caso de Uso 1: Registrar nuevo catálogo de gastos

**Descripción:** El usuario desea registrar los parámetros de gastos para el año actual.

**Precondiciones:**
No existe ningún registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Gastos.
2. Llena los campos: Salario Diario, % Req., % Embargo, % Secuestro.
3. Presiona 'Crear'.
4. El sistema envía la petición 'gastos.create' al backend.

**Resultado esperado:**
El registro se crea correctamente y se muestra en la tabla de valores actuales.

**Datos de prueba:**
{ "sdzmg": 250.00, "porc1_req": 10.0, "porc2_embargo": 20.0, "porc3_secuestro": 30.0 }

---

## Caso de Uso 2: Actualizar el catálogo de gastos existente

**Descripción:** El usuario necesita modificar los porcentajes de embargo y secuestro.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página y ve los valores actuales.
2. Modifica los campos % Embargo y % Secuestro.
3. Presiona 'Actualizar'.
4. El sistema envía la petición 'gastos.update' al backend.

**Resultado esperado:**
El registro se actualiza y los nuevos valores se muestran en la tabla.

**Datos de prueba:**
{ "sdzmg": 250.00, "porc1_req": 10.0, "porc2_embargo": 25.0, "porc3_secuestro": 35.0 }

---

## Caso de Uso 3: Eliminar el catálogo de gastos

**Descripción:** El usuario desea eliminar el registro de gastos para reiniciar el catálogo.

**Precondiciones:**
Existe un registro en ta_16_gastos.

**Pasos a seguir:**
1. El usuario accede a la página y presiona 'Eliminar'.
2. Confirma la acción.
3. El sistema envía la petición 'gastos.delete' al backend.

**Resultado esperado:**
El registro es eliminado y la tabla muestra 'Sin datos registrados'.

**Datos de prueba:**
No aplica

---



---
**Componente:** `ABC_Gastos.vue`
**MÃ³dulo:** `aseo_contratado`

