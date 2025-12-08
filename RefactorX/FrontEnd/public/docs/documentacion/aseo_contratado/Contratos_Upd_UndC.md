# Documentación Técnica: Contratos_Upd_UndC

## Análisis

# Documentación Técnica: Actualización de Unidades de Recolección (Cantidad) - Contratos_Upd_UndC

## Descripción General
Este módulo permite la actualización de la cantidad de unidades de recolección asociadas a un contrato vigente. Incluye la validación de datos, actualización de importes en pagos futuros, y registro de la documentación probatoria del cambio. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa siguiendo arquitectura API RESTful con endpoint unificado y lógica de negocio en stored procedures.

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente, navegación por rutas.
- **Backend:** Laravel Controller, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos:** PostgreSQL, lógica principal en stored procedures.

## Flujo de Trabajo
1. **Carga de Tipos de Aseo:**
   - El frontend solicita los tipos de aseo disponibles para poblar el select.
   - Endpoint: `action: listarTiposAseo`
2. **Búsqueda de Contrato:**
   - El usuario ingresa número de contrato y tipo de aseo.
   - El backend busca el contrato vigente y retorna todos los datos relevantes.
   - Endpoint: `action: buscarContrato`
3. **Actualización de Unidades:**
   - El usuario ingresa la nueva cantidad, ejercicio, mes, documento y descripción.
   - El backend valida, actualiza la cantidad, recalcula importes de pagos futuros, y registra el documento probatorio.
   - Endpoint: `action: actualizarUnidades`

## API (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `listarTiposAseo`
  - `buscarContrato`
  - `actualizarUnidades`

## Stored Procedures
- **sp_contratos_upd_undc_buscar:** Busca contrato vigente por número y tipo de aseo.
- **sp_contratos_upd_undc_listar_tipos_aseo:** Lista tipos de aseo.
- **sp_contratos_upd_undc_actualizar_unidades:** Actualiza cantidad de unidades, recalcula importes y registra documento.

## Validaciones
- El contrato debe estar vigente.
- La cantidad nueva debe ser mayor a cero.
- El documento probatorio es obligatorio.
- El ejercicio y mes deben ser válidos.
- No se permite actualizar si los datos no cumplen las reglas de negocio.

## Seguridad
- El usuario autenticado se obtiene vía middleware Laravel y se pasa como parámetro a los SP.
- Todas las operaciones quedan registradas con el id_usuario.

## Manejo de Errores
- Los SP retornan un campo `success` y `message` para indicar el resultado.
- El frontend muestra mensajes de error o éxito según corresponda.

## Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.


## Casos de Uso

# Casos de Uso - Contratos_Upd_UndC

**Categoría:** Form

## Caso de Uso 1: Actualización exitosa de unidades de recolección

**Descripción:** El usuario busca un contrato vigente y actualiza la cantidad de unidades de recolección, adjuntando la documentación probatoria.

**Precondiciones:**
El contrato existe y está vigente. El usuario tiene permisos de actualización.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. El sistema muestra los datos del contrato.
4. El usuario ingresa la nueva cantidad, ejercicio, mes, documento y descripción.
5. Presiona 'Actualizar Unidades'.

**Resultado esperado:**
La cantidad de unidades se actualiza, los importes de pagos futuros se recalculan, y el documento queda registrado en el historial.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 12, "ejercicio": 2024, "mes": 6, "documento": "DR/2024/06/01", "descripcion_docto": "Cambio por ampliación de servicio" }

---

## Caso de Uso 2: Intento de actualización con cantidad inválida

**Descripción:** El usuario intenta actualizar la cantidad de unidades a cero.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Ingresa '0' como nueva cantidad.
3. Intenta actualizar.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que la cantidad debe ser mayor a cero.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 0, "ejercicio": 2024, "mes": 6, "documento": "DR/2024/06/01", "descripcion_docto": "Intento inválido" }

---

## Caso de Uso 3: Intento de actualización sin documento probatorio

**Descripción:** El usuario intenta actualizar las unidades sin adjuntar documento.

**Precondiciones:**
El contrato existe y está vigente.

**Pasos a seguir:**
1. El usuario busca el contrato.
2. Ingresa la nueva cantidad y ejercicio, pero deja el campo documento vacío.
3. Intenta actualizar.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el documento es obligatorio.

**Datos de prueba:**
{ "contrato": 1803, "ctrol_aseo": 8, "nueva_cantidad": 15, "ejercicio": 2024, "mes": 6, "documento": "", "descripcion_docto": "" }

---



## Casos de Prueba

## Casos de Prueba: Actualización de Unidades de Recolección

### Caso 1: Actualización exitosa
- **Entrada:**
  - contrato: 1803
  - ctrol_aseo: 8
  - nueva_cantidad: 12
  - ejercicio: 2024
  - mes: 6
  - documento: 'DR/2024/06/01'
  - descripcion_docto: 'Cambio por ampliación de servicio'
- **Acción:** Ejecutar acción 'actualizarUnidades' vía API.
- **Esperado:**
  - Respuesta success: true
  - Mensaje: 'Unidades actualizadas correctamente.'
  - En base de datos, la cantidad y pagos futuros reflejan el cambio.

### Caso 2: Cantidad inválida
- **Entrada:**
  - nueva_cantidad: 0
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'La cantidad debe ser mayor a cero.'

### Caso 3: Documento vacío
- **Entrada:**
  - documento: ''
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'Debe proporcionar un documento probatorio.'

### Caso 4: Contrato no vigente
- **Entrada:**
  - contrato_id: (contrato cancelado)
- **Acción:** Ejecutar acción 'actualizarUnidades'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'Contrato no encontrado o no vigente.'

### Caso 5: Listar tipos de aseo
- **Acción:** Ejecutar acción 'listarTiposAseo'.
- **Esperado:**
  - Respuesta success: true
  - Lista de tipos de aseo no vacía.

### Caso 6: Buscar contrato inexistente
- **Entrada:**
  - contrato: 999999
  - ctrol_aseo: 8
- **Acción:** Ejecutar acción 'buscarContrato'.
- **Esperado:**
  - Respuesta success: false
  - Mensaje: 'No existe contrato vigente con esos datos.'


