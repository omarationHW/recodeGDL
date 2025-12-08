# Documentación Técnica: ReqsCons

## Análisis

# Documentación Técnica: Migración Formulario ReqsCons (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Payload**:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "status": "ok|error|not_found",
    "data": ...,
    "message": "..."
  }
  ```

## 3. Acciones Disponibles
- `getTipoAseo`: Catálogo de tipos de aseo
- `getRecaudadoras`: Catálogo de recaudadoras
- `buscarContrato`: Busca contrato por número y tipo de aseo
- `buscarApremios`: Lista de apremios de un contrato
- `buscarPeriodosApremio`: Periodos de un apremio
- `buscarConvenio`: Convenio relacionado a un contrato
- `ejecutarPagoApremio`: Marca un apremio como pagado

## 4. Seguridad
- Se recomienda implementar autenticación JWT o similar en producción.
- Validar todos los parámetros en backend.

## 5. Vue.js
- Cada formulario es una página independiente (NO tabs)
- Navegación por rutas (ej: `/requerimientos`)
- Uso de fetch para consumir `/api/execute`
- Manejo de errores y mensajes de usuario

## 6. Stored Procedures
- Toda la lógica de negocio y consultas SQL se implementa en stored procedures y funciones PostgreSQL.
- El controlador Laravel solo invoca los SPs y retorna el resultado.

## 7. Flujo de Consulta y Pago de Requerimientos
1. Usuario ingresa contrato y tipo de aseo
2. Se consulta el contrato y su status
3. Se listan los apremios asociados
4. Al seleccionar un apremio, se muestran sus periodos
5. El usuario puede registrar el pago del apremio (si tiene permisos)
6. El pago se ejecuta vía stored procedure y se actualiza la vista

## 8. Consideraciones de Migración
- Los combos Delphi se migran a selects Vue.js
- Los grids Delphi se migran a tablas HTML
- Los procedimientos Delphi se migran a stored procedures y funciones PostgreSQL
- El backend es stateless y desacoplado de la UI

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los stored procedures pueden evolucionar sin afectar la API

## 10. Pruebas y Auditoría
- Todas las acciones relevantes quedan registradas en la base de datos
- Se recomienda agregar triggers de auditoría para cambios críticos


## Casos de Uso

# Casos de Uso - ReqsCons

**Categoría:** Form

## Caso de Uso 1: Consulta de Requerimientos de un Contrato Vigente

**Descripción:** El usuario consulta los requerimientos (apremios) asociados a un contrato vigente.

**Precondiciones:**
El contrato existe y tiene status_vigencia = 'V'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Requerimientos.
2. Ingresa el número de contrato y selecciona el tipo de aseo.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del contrato y la lista de apremios asociados.

**Resultado esperado:**
Se muestran los apremios del contrato, incluyendo folio, importes y fechas.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9 }

---

## Caso de Uso 2: Registro de Pago de un Apremio

**Descripción:** El usuario registra el pago de un apremio seleccionado.

**Precondiciones:**
El apremio está vigente (vigencia = '1') y no ha sido pagado.

**Pasos a seguir:**
1. El usuario busca el contrato y selecciona un apremio de la lista.
2. Presiona 'Pagar'.
3. Completa los datos de pago (fecha, recaudadora, caja, operación, folio).
4. Presiona 'Ejecutar Pago'.

**Resultado esperado:**
El apremio se marca como pagado y se actualiza la lista.

**Datos de prueba:**
{ "contrato": 12345, "ctrol_aseo": 9, "apremio_id": 1001, "pago": { "fecha": "2024-06-01", "id_rec": 1, "caja": "01", "operacion": 123, "folio_rcbo": "RCB123", "importe_gastos": 500.00 } }

---

## Caso de Uso 3: Consulta de Convenio Asociado a un Contrato

**Descripción:** El usuario consulta si un contrato tiene convenio asociado.

**Precondiciones:**
El contrato tiene status_vigencia = 'N' y existe convenio.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. El sistema detecta status_vigencia = 'N' y consulta el convenio.
3. Se muestra el convenio en la interfaz.

**Resultado esperado:**
Se muestra el convenio asociado al contrato.

**Datos de prueba:**
{ "contrato": 54321, "ctrol_aseo": 8 }

---



## Casos de Prueba

# Casos de Prueba para ReqsCons

## Caso 1: Consulta de Requerimientos Existente
- **Input:** contrato=12345, ctrol_aseo=9
- **Acción:** Buscar
- **Esperado:** Lista de apremios mostrada, sin errores

## Caso 2: Consulta de Contrato Inexistente
- **Input:** contrato=99999, ctrol_aseo=9
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'No existe contrato con este dato, intentalo de nuevo'

## Caso 3: Pago de Apremio Correcto
- **Input:** contrato=12345, ctrol_aseo=9, apremio_id=1001, pago={fecha: '2024-06-01', id_rec: 1, caja: '01', operacion: 123, folio_rcbo: 'RCB123', importe_gastos: 500.00}
- **Acción:** Ejecutar Pago
- **Esperado:** Mensaje 'Se dio de PAGADO correctamente el Apremio', apremio actualizado

## Caso 4: Pago de Apremio con Datos Incompletos
- **Input:** Falta campo 'operacion'
- **Acción:** Ejecutar Pago
- **Esperado:** Mensaje de error 'Todos los campos son obligatorios'

## Caso 5: Consulta de Convenio
- **Input:** contrato=54321, ctrol_aseo=8
- **Acción:** Buscar
- **Esperado:** Se muestra convenio si existe, o mensaje 'Convenio de Contrato NO encontrado'


