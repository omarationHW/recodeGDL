# ConsCapturaFecha

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Consulta de Pagos Capturados por Mercado (ConsCapturaFecha)

## Descripción General
Este módulo permite consultar y administrar los pagos capturados en mercados municipales, filtrando por fecha, oficina, caja y operación. Permite visualizar los pagos, seleccionar uno o varios y eliminarlos, restaurando el adeudo correspondiente si aplica.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute` con patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA (Single Page Application), página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Comunicación:** JSON, API unificada

## Flujo de Datos
1. El usuario accede a la página y selecciona los filtros (fecha, oficina, caja, operación).
2. El frontend consulta las oficinas y cajas disponibles.
3. Al buscar, se llama al endpoint `/api/execute` con acción `getPagosByFecha`.
4. El backend ejecuta el stored procedure `sp_get_pagos_by_fecha` y retorna los pagos.
5. El usuario puede seleccionar pagos y eliminarlos. Al confirmar, se llama a la acción `deletePagos`.
6. El backend ejecuta `sp_delete_pago_local` para cada pago seleccionado, restaurando el adeudo si corresponde.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest.action`: Acción a ejecutar (`getPagosByFecha`, `deletePagos`, `getOficinas`, `getCajasByOficina`)
  - `eRequest.params`: Parámetros específicos de la acción
- **Salida:**
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos de respuesta
  - `eResponse.message`: Mensaje de error o información

## Stored Procedures
- `sp_get_pagos_by_fecha(fecha, oficina, caja, operacion)`
- `sp_delete_pago_local(id_local, axo, periodo, usuario)`
- `sp_get_oficinas()`
- `sp_get_cajas_by_oficina(oficina)`

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel, según configuración).
- El usuario debe tener permisos para eliminar pagos.

## Validaciones
- Todos los campos de filtro son obligatorios.
- Solo se pueden borrar pagos seleccionados.
- Al borrar, se restaura el adeudo si no existe ya para ese periodo/local.

## Manejo de Errores
- Errores de validación y de base de datos se retornan en `eResponse.message`.
- El frontend muestra mensajes amigables al usuario.

## Consideraciones
- El borrado es lógico/físico según la política de la tabla (en este caso, físico, pero puede adaptarse).
- El frontend es reactivo y muestra el estado de carga y errores.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures encapsulan la lógica y pueden ser reutilizados por otros módulos.

## Integración
- El componente Vue puede integrarse en cualquier SPA o router Vue.
- El backend puede ser extendido para auditar operaciones o agregar logs.



## Casos de Uso

# Casos de Uso - ConsCapturaFecha

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos capturados por fecha y oficina

**Descripción:** El usuario desea ver todos los pagos capturados en una fecha específica, para una oficina y caja determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos Capturados.
2. Selecciona la fecha deseada.
3. Selecciona la oficina recaudadora.
4. Selecciona la caja correspondiente.
5. Ingresa el número de operación.
6. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos capturados que cumplen los criterios seleccionados.

**Datos de prueba:**
fecha: '2024-06-01', oficina: 2, caja: 'A', operacion: 12345

---

## Caso de Uso 2: Eliminación de un pago capturado y restauración de adeudo

**Descripción:** El usuario identifica un pago capturado erróneamente y decide eliminarlo, esperando que el adeudo se restaure automáticamente.

**Precondiciones:**
Existe al menos un pago capturado para los criterios seleccionados. El usuario tiene permisos de eliminación.

**Pasos a seguir:**
1. Realiza la consulta de pagos como en el caso anterior.
2. Selecciona el pago a eliminar marcando la casilla correspondiente.
3. Presiona 'Borrar Pago(s)'.
4. Confirma la eliminación.

**Resultado esperado:**
El pago es eliminado y el adeudo correspondiente se restaura en la base de datos.

**Datos de prueba:**
Pago con id_local: 1001, axo: 2024, periodo: 6

---

## Caso de Uso 3: Consulta de oficinas y cajas disponibles

**Descripción:** El usuario necesita seleccionar la oficina y caja antes de consultar pagos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos Capturados.
2. El sistema carga automáticamente la lista de oficinas.
3. Al seleccionar una oficina, el sistema carga las cajas disponibles para esa oficina.

**Resultado esperado:**
Las listas de oficinas y cajas se muestran correctamente y permiten la selección.

**Datos de prueba:**
oficina: 3 (espera ver cajas asociadas a la oficina 3)

---



## Casos de Prueba

# Casos de Prueba: Consulta de Pagos Capturados por Mercado

## Caso 1: Consulta exitosa de pagos
- **Entrada:** fecha = '2024-06-01', oficina = 2, caja = 'A', operacion = 12345
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista de pagos mostrada, sin errores.

## Caso 2: Eliminación de pago y restauración de adeudo
- **Entrada:** Selección de pago con id_local=1001, axo=2024, periodo=6
- **Acción:** Borrar pago
- **Resultado esperado:** El pago desaparece de la lista y el adeudo se restaura en la base de datos.

## Caso 3: Validación de campos obligatorios
- **Entrada:** No seleccionar fecha u oficina
- **Acción:** Buscar pagos
- **Resultado esperado:** Mensaje de error indicando que los campos son obligatorios.

## Caso 4: Consulta de cajas por oficina
- **Entrada:** Selección de oficina 3
- **Acción:** Cargar cajas
- **Resultado esperado:** Se muestran solo las cajas asociadas a la oficina 3.

## Caso 5: Error de base de datos
- **Simulación:** La base de datos está caída
- **Acción:** Buscar pagos
- **Resultado esperado:** Mensaje de error amigable indicando problema de conexión.



