# CargaTCultural

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Carga de Pagos del Tianguis Cultural

## Descripción General
Este módulo permite la carga masiva y validación de pagos del Tianguis Cultural (Mercado 214) en el sistema de mercados municipales. Incluye la consulta de adeudos, validación de folios contra ingresos, aplicación de descuentos, y registro de pagos, eliminando los adeudos correspondientes.

## Arquitectura
- **Backend**: Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js SPA (Single Page Application), componente de página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures
- **Patrón API**: eRequest/eResponse (todas las operaciones usan el endpoint `/api/execute` con un campo `eRequest` y un `payload`)

## Flujo de Trabajo
1. **Consulta de Adeudos**: El usuario ingresa un rango de folios, periodo y año. El sistema consulta los adeudos pendientes para ese rango.
2. **Edición de Pagos**: El usuario ingresa los datos de pago (fecha, recaudadora, caja, operación, partida) para cada folio.
3. **Validación**: El sistema valida que los folios y operaciones existan en ingresos y no estén duplicados.
4. **Carga de Pagos**: Si la validación es exitosa, los pagos se registran y los adeudos correspondientes se eliminan. Se aplica descuento si corresponde.

## Detalle de Componentes
### Laravel Controller
- **Método principal**: `execute(Request $request)`
- **eRequest soportados**:
    - `getAdeudosTCultural`: Consulta de adeudos
    - `validatePagosTCultural`: Validación de folios de pago
    - `savePagosTCultural`: Registro de pagos y eliminación de adeudos
    - `getTianguisInfo`: Consulta de información de folio en Tianguis
- **Seguridad**: Usa el usuario autenticado para auditoría
- **Transacciones**: Las operaciones de guardado son atómicas

### Vue.js Component
- Página independiente `/carga-tcultural`
- Formulario para búsqueda de adeudos
- Tabla editable para captura de pagos
- Botones para validar y guardar
- Mensajes de error y éxito
- Navegación breadcrumb

### Stored Procedures PostgreSQL
- Toda la lógica de negocio y validación reside en SPs
- Uso de JSON para manejo de lotes de pagos
- Validación de existencia en ingresos y duplicidad
- Aplicación de descuentos
- Auditoría por usuario

### API Unificada
- Todas las operaciones usan `/api/execute` con un JSON:
    - `eRequest`: nombre de la acción
    - `payload`: parámetros
- La respuesta siempre es `{ eResponse: { success, data, message } }`

## Seguridad y Validaciones
- Validación de campos obligatorios en backend y frontend
- Validación de existencia de folios en ingresos
- Validación de duplicidad de pagos
- Aplicación de descuentos sólo si corresponde
- Auditoría de usuario en todos los movimientos

## Manejo de Errores
- Todos los errores se devuelven en el campo `message` de la respuesta
- El frontend muestra mensajes claros al usuario

## Integración
- El frontend consume el endpoint `/api/execute` usando Axios
- El backend ejecuta los SPs según el eRequest
- El frontend espera siempre la estructura eResponse

## Consideraciones de Migración
- El proceso Delphi usaba componentes visuales y lógica procedural; aquí todo es desacoplado y API-driven
- El acceso a la base de datos es a través de SPs, no de SQL embebido en la aplicación
- El frontend es completamente desacoplado y puede ser integrado en cualquier SPA

# Endpoints y Parámetros
- `/api/execute` (POST)
    - `eRequest: getAdeudosTCultural` + `payload: { local_desde, local_hasta, periodo, axo }`
    - `eRequest: validatePagosTCultural` + `payload: { pagos: [...] }`
    - `eRequest: savePagosTCultural` + `payload: { pagos: [...] }`
    - `eRequest: getTianguisInfo` + `payload: { folio }`

# Seguridad
- Requiere autenticación JWT o session para identificar al usuario
- Todos los movimientos quedan auditados con el id_usuario

# Pruebas y Validación
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad


## Casos de Uso

# Casos de Uso - CargaTCultural

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos Correcta para Rango de Folios

**Descripción:** El usuario carga pagos para un rango de folios del Tianguis Cultural, todos los folios y operaciones son válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de carga. Existen adeudos para los folios y periodo/año seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el rango de folios (ej: 100 a 110), periodo 2, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos.
5. El usuario ingresa los datos de pago (fecha, rec, caja, operación, partida) para cada folio.
6. Presiona 'Validar Folios'.
7. El sistema indica que todos los folios son válidos.
8. El usuario presiona 'Guardar Pagos'.
9. El sistema registra los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos quedan registrados, los adeudos eliminados, y se muestra mensaje de éxito.

**Datos de prueba:**
local_desde: 100, local_hasta: 110, periodo: 2, axo: 2024, pagos: [{id_local: 100, fecha_pago: '2024-04-15', rec: 1, caja: 'A', operacion: 12345, partida: 'P1', ...}, ...]

---

## Caso de Uso 2: Validación de Folios Erróneos

**Descripción:** El usuario intenta cargar pagos pero algunos folios no existen en ingresos o tienen datos incompletos.

**Precondiciones:**
El usuario está autenticado. Algunos folios del rango no tienen ingresos registrados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el rango de folios (ej: 200 a 205), periodo 3, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos.
5. El usuario deja algunos campos de pago vacíos o ingresa operaciones inexistentes.
6. Presiona 'Validar Folios'.
7. El sistema muestra los folios erróneos en pantalla.

**Resultado esperado:**
Se muestra la lista de folios erróneos y no se permite guardar hasta corregirlos.

**Datos de prueba:**
pagos: [{id_local: 200, fecha_pago: '', rec: '', caja: '', operacion: '', partida: ''}, {id_local: 201, fecha_pago: '2024-05-10', rec: 1, caja: 'B', operacion: 99999, partida: 'P2'}, ...]

---

## Caso de Uso 3: Aplicación de Descuento Automático

**Descripción:** El sistema aplica automáticamente el descuento correspondiente al pago si el folio tiene descuento.

**Precondiciones:**
El folio tiene un porcentaje de descuento registrado en la tabla cobrotrimestral.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el folio con descuento (ej: 150), periodo 1, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra el adeudo y el porcentaje de descuento.
5. El usuario ingresa los datos de pago y valida los folios.
6. Presiona 'Guardar Pagos'.
7. El sistema calcula el importe con descuento y lo registra.

**Resultado esperado:**
El pago se registra con el importe descontado y el adeudo se elimina.

**Datos de prueba:**
pagos: [{id_local: 150, fecha_pago: '2024-03-01', rec: 1, caja: 'C', operacion: 54321, partida: 'P3', descuento: 10, importe: 1000}]

---



## Casos de Prueba

# Casos de Prueba: CargaTCultural

## Caso 1: Consulta de Adeudos
- **Entrada:** local_desde=100, local_hasta=105, periodo=2, axo=2024
- **Acción:** POST /api/execute { eRequest: 'getAdeudosTCultural', payload: { ... } }
- **Esperado:** Respuesta con lista de adeudos para los folios y periodo/año

## Caso 2: Validación de Folios Correctos
- **Entrada:** pagos=[{id_local:100, fecha_pago:'2024-04-10', rec:1, caja:'A', operacion:12345, partida:'P1', ...}, ...]
- **Acción:** POST /api/execute { eRequest: 'validatePagosTCultural', payload: { pagos } }
- **Esperado:** foliosErroneos = []

## Caso 3: Validación de Folios Erróneos
- **Entrada:** pagos=[{id_local:101, fecha_pago:'', rec:'', caja:'', operacion:'', partida:''}, ...]
- **Acción:** POST /api/execute { eRequest: 'validatePagosTCultural', payload: { pagos } }
- **Esperado:** foliosErroneos contiene 101

## Caso 4: Guardado de Pagos Correctos
- **Entrada:** pagos=[{id_local:100, ... todos los campos válidos ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** inserted=1, deleted=1

## Caso 5: Guardado con Folios Erróneos
- **Entrada:** pagos=[{id_local:102, ... campos vacíos ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** inserted=0, deleted=0, error en message

## Caso 6: Aplicación de Descuento
- **Entrada:** pagos=[{id_local:150, descuento:10, importe:1000, ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** importe_pago registrado = 900



