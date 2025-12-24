# ConsultaDatosEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: ConsultaDatosEnergia

## Descripción General
Este módulo permite consultar la información de energía eléctrica asociada a un local, incluyendo:
- Datos generales de energía
- Requerimientos (multas, gastos)
- Adeudos por mes (con cálculo de recargos)
- Pagos realizados
- Condonaciones

La arquitectura utiliza un endpoint API unificado `/api/execute` bajo el patrón eRequest/eResponse, con stored procedures en PostgreSQL para toda la lógica de negocio y un frontend Vue.js como página independiente.

## Arquitectura
- **Backend**: Laravel Controller (`ConsultaDatosEnergiaController`) que recibe peticiones eRequest y despacha a los stored procedures correspondientes.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y tablas para cada sección.
- **Base de Datos**: PostgreSQL, toda la lógica encapsulada en stored procedures.
- **API**: Endpoint único `/api/execute` que recibe `{ eRequest: { action, params } }` y responde `{ eResponse: { success, data, message } }`.

## Flujo de Datos
1. El usuario ingresa el ID del local y presiona "Buscar".
2. El frontend llama a `/api/execute` con `action: getEnergiaByLocal` y el ID.
3. El backend ejecuta el stored procedure `sp_get_energia_by_local` y retorna los datos.
4. El frontend muestra los datos y, en paralelo, consulta requerimientos y adeudos.
5. El usuario puede ver pagos y condonaciones, que se consultan bajo demanda.

## Seguridad
- Todas las operaciones se validan en el backend.
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí).

## Extensibilidad
- Para agregar nuevas operaciones, basta con crear un nuevo stored procedure y mapearlo en el controlador.
- El frontend puede extenderse para mostrar más detalles o exportar datos.

## Integración
- El componente Vue.js puede integrarse en cualquier SPA Vue Router.
- El backend puede convivir con otros módulos bajo el mismo endpoint `/api/execute`.

## Notas de Migración
- Todos los queries SQL y lógica de recargos se migran a stored procedures.
- El cálculo de recargos es simplificado y debe ajustarse según reglas fiscales reales.
- El frontend asume que los stored procedures retornan los datos en el formato esperado.



## Casos de Uso

# Casos de Uso - ConsultaDatosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Energía de un Local con Adeudos y Requerimientos

**Descripción:** El usuario consulta los datos de energía de un local que tiene adeudos y requerimientos activos.

**Precondiciones:**
El local existe y tiene registros en ta_11_energia, ta_11_adeudo_energ y ta_15_apremios.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta Datos de Energía'.
2. Ingresa el ID del local (por ejemplo, 12345) y presiona 'Buscar'.
3. El sistema muestra los datos generales de energía.
4. El sistema muestra la tabla de requerimientos asociados.
5. El sistema muestra la tabla de adeudos por mes, con recargos calculados.
6. El usuario puede ver el resumen de adeudos, recargos, multas y gastos.

**Resultado esperado:**
Se muestran correctamente los datos de energía, requerimientos, adeudos y el resumen total.

**Datos de prueba:**
{ "id_local": 12345 }

---

## Caso de Uso 2: Visualización de Pagos de Energía

**Descripción:** El usuario consulta los pagos realizados para la energía de un local.

**Precondiciones:**
El local tiene pagos registrados en ta_11_pago_energia.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de energía para un local.
2. Hace clic en 'Ver Pagos'.
3. El sistema consulta y muestra la tabla de pagos realizados.

**Resultado esperado:**
Se muestran todos los pagos de energía asociados al local.

**Datos de prueba:**
{ "id_local": 12345 }

---

## Caso de Uso 3: Consulta de Condonaciones de Energía

**Descripción:** El usuario consulta las condonaciones aplicadas a la energía de un local.

**Precondiciones:**
El local tiene condonaciones registradas en ta_11_ade_ene_canc.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de energía para un local.
2. Hace clic en 'Ver Condonaciones'.
3. El sistema consulta y muestra la tabla de condonaciones.

**Resultado esperado:**
Se muestran todas las condonaciones de energía asociadas al local.

**Datos de prueba:**
{ "id_local": 12345 }

---



## Casos de Prueba

# Casos de Prueba: ConsultaDatosEnergia

## Caso 1: Consulta exitosa de energía
- **Entrada:** id_local = 12345
- **Acción:** Buscar
- **Esperado:**
  - Se muestran los datos generales de energía.
  - Se muestran requerimientos si existen.
  - Se muestran adeudos por mes con recargos.
  - El resumen total es correcto.

## Caso 2: Local sin energía
- **Entrada:** id_local = 99999 (no existe en ta_11_energia)
- **Acción:** Buscar
- **Esperado:**
  - Se muestra mensaje de error: "No se encontró información de energía para el local."

## Caso 3: Visualización de pagos
- **Entrada:** id_local = 12345
- **Acción:** Buscar, luego 'Ver Pagos'
- **Esperado:**
  - Se muestra la tabla de pagos con los campos año, mes, fecha, importe, usuario.

## Caso 4: Visualización de condonaciones
- **Entrada:** id_local = 12345
- **Acción:** Buscar, luego 'Ver Condonaciones'
- **Esperado:**
  - Se muestra la tabla de condonaciones con año, mes, importe, observación, usuario.

## Caso 5: Cálculo de recargos
- **Entrada:** id_local = 12345 (con adeudos en varios años/meses)
- **Acción:** Buscar
- **Esperado:**
  - Los recargos por mes se calculan correctamente según el porcentaje de la tabla ta_12_recargos.



