# Documentación Técnica: Contratos_Upd_IniObl

## Análisis

# Documentación Técnica: Migración Formulario Contratos_Upd_IniObl (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite actualizar el periodo de inicio de obligación de un contrato vigente, eliminando pagos anteriores, generando nuevos pagos a partir del periodo seleccionado y registrando el documento probatorio del cambio. La solución implementa:

- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: Stored Procedure en PostgreSQL para la lógica de negocio.

## API
### Endpoint
`POST /api/execute`

#### Entrada (eRequest)
- `action`: `catalogs` | `search` | `update` | `validate`
- Parámetros según acción:
  - `catalogs`: sin parámetros
  - `search`: `{ num_contrato, ctrol_aseo }`
  - `update`: `{ num_contrato, ctrol_aseo, ejercicio, mes, documento, descripcion_docto, usuario_id }`
  - `validate`: igual a update

#### Salida (eResponse)
- `success`: boolean
- `message`: string
- `data`: objeto o null

## Stored Procedure
- `sp16_update_inicio_obligacion`: realiza toda la lógica de actualización de inicio de obligación, pagos y registro de documento.

## Frontend
- Página Vue.js independiente, sin tabs, con búsqueda de contrato y formulario de actualización.
- Navegación simple, mensajes de éxito/error.

## Seguridad
- El endpoint requiere autenticación (no implementada aquí, pero debe integrarse en producción).
- Validación de parámetros en backend y frontend.

## Flujo de Trabajo
1. Usuario ingresa número de contrato y tipo de aseo, busca contrato.
2. Si existe y está vigente, se muestran los datos.
3. Usuario selecciona nuevo ejercicio y mes de inicio de obligación, documento y descripción.
4. Al enviar, se ejecuta el stored procedure que:
   - Elimina pagos anteriores al periodo.
   - Inserta pagos del periodo en adelante (año actual y siguiente si aplica).
   - Actualiza el campo `aso_mes_oblig` del contrato.
   - Registra el documento probatorio.
5. Se muestra mensaje de éxito o error.

## Validaciones
- No permite actualizar si el contrato no existe o no está vigente.
- No permite si la fecha de inicio de obligación es igual a la actual.
- No permite si faltan campos obligatorios.

## Integración
- El frontend llama al endpoint `/api/execute` con la acción correspondiente.
- El backend enruta la acción y ejecuta la lógica o el stored procedure.
- El stored procedure realiza toda la lógica transaccional y retorna el resultado.

## Consideraciones
- El usuario debe tener permisos para actualizar contratos.
- El proceso es atómico: si falla algo, no se realizan cambios parciales.
- El frontend debe mostrar mensajes claros según el resultado.

#

## Casos de Uso

# Casos de Uso - Contratos_Upd_IniObl

**Categoría:** Form

## Caso de Uso 1: Actualizar inicio de obligación de un contrato vigente

**Descripción:** El usuario desea cambiar el periodo de inicio de obligación de un contrato vigente, generando los pagos correspondientes y registrando el documento probatorio.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario selecciona el nuevo ejercicio y mes de inicio de obligación, ingresa el documento y descripción.
5. Presiona 'Actualizar'.
6. El sistema ejecuta el proceso y muestra mensaje de éxito.

**Resultado esperado:**
El inicio de obligación del contrato se actualiza, los pagos anteriores se eliminan, se generan nuevos pagos y se registra el documento.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8, "ejercicio": 2024, "mes": 7, "documento": "DR/2024/07/001", "descripcion_docto": "Cambio por resolución administrativa", "usuario_id": 5 }

---

## Caso de Uso 2: Intentar actualizar con contrato inexistente

**Descripción:** El usuario intenta actualizar el inicio de obligación de un contrato que no existe o no está vigente.

**Precondiciones:**
El contrato no existe o está cancelado.

**Pasos a seguir:**
1. El usuario ingresa un número de contrato inexistente y tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema indica que el contrato no existe o no está vigente.

**Datos de prueba:**
{ "num_contrato": 999999, "ctrol_aseo": 8 }

---

## Caso de Uso 3: Validar campos obligatorios antes de actualizar

**Descripción:** El usuario intenta actualizar sin llenar todos los campos requeridos.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato correctamente.
2. Deja vacío el campo 'documento' y presiona 'Actualizar'.
3. El sistema muestra mensaje de validación.

**Resultado esperado:**
El sistema no permite la actualización y muestra mensaje de campo obligatorio.

**Datos de prueba:**
{ "num_contrato": 1803, "ctrol_aseo": 8, "ejercicio": 2024, "mes": 7, "documento": "", "descripcion_docto": "", "usuario_id": 5 }

---



## Casos de Prueba

# Casos de Prueba para Contratos_Upd_IniObl

## 1. Actualización exitosa
- **Entrada:** Contrato vigente, ejercicio y mes válidos, documento y descripción válidos.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=true, mensaje de éxito, pagos actualizados en BD.

## 2. Contrato inexistente o no vigente
- **Entrada:** Contrato no existente o status_vigencia != 'V'.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje 'No existe contrato vigente...'.

## 3. Fecha de inicio igual a la actual
- **Entrada:** Fecha de inicio igual a la ya registrada en el contrato.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje 'La fecha de inicio de obligación es igual a la actual'.

## 4. Campos obligatorios faltantes
- **Entrada:** Falta documento, ejercicio, mes, etc.
- **Acción:** POST /api/execute { action: 'update', ... }
- **Esperado:** Respuesta success=false, mensaje de validación.

## 5. Carga de catálogos
- **Acción:** POST /api/execute { action: 'catalogs' }
- **Esperado:** Respuesta success=true, data con tiposAseo y meses.

## 6. Búsqueda de contrato
- **Entrada:** Contrato y tipo de aseo válidos.
- **Acción:** POST /api/execute { action: 'search', ... }
- **Esperado:** Respuesta success=true, data con detalles del contrato.

## 7. Búsqueda de contrato inexistente
- **Entrada:** Contrato y tipo de aseo no existentes.
- **Acción:** POST /api/execute { action: 'search', ... }
- **Esperado:** Respuesta success=false, mensaje de error.


