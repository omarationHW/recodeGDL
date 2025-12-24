# Documentación: LicenciaMicrogeneradorEcologia

## Análisis Técnico

# Documentación Técnica: Licencia Microgenerador Ecología

## Descripción General
Este módulo permite autorizar, consultar y cancelar el registro de microgenerador para licencias y trámites de ecología. La migración Delphi → Laravel + Vue.js + PostgreSQL se realiza usando un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller (LicenciaMicrogeneradorEcologiaController)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (Stored Procedures y Vistas)
- **API:** Único endpoint `/api/execute`

## Flujo de Operación
1. El usuario selecciona el tipo (Trámite o Licencia) y captura el número correspondiente.
2. El frontend consulta los datos del trámite/licencia y verifica si ya es microgenerador.
3. El usuario puede autorizar (alta) o cancelar el microgenerador según el estado.
4. Todas las operaciones se ejecutan vía el SP `sp_licencia_microgenerador_ecologia`.

## Endpoints
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "consulta|alta|cancela|tramite|licencia",
      "data": { ... }
    }
    ```
  - **Acciones:**
    - `consulta`: Consulta si el trámite/licencia es microgenerador.
    - `alta`: Da de alta como microgenerador.
    - `cancela`: Cancela el microgenerador.
    - `tramite`: Consulta datos del trámite.
    - `licencia`: Consulta datos de la licencia.

## Stored Procedures y Vistas
- **sp_licencia_microgenerador_ecologia**: Maneja alta, consulta y cancelación.
- **vw_tramite_microgenerador**: Vista para mostrar datos de trámite.
- **vw_licencia_microgenerador**: Vista para mostrar datos de licencia.

## Validaciones
- El tipo debe ser 'L' (licencia) o 'T' (trámite).
- El ID debe existir y ser numérico.
- No se puede dar de alta si ya existe como microgenerador vigente.
- No se puede cancelar si no existe como microgenerador vigente.

## Seguridad
- El usuario se toma del contexto de autenticación o del campo `usuario` en el request.
- Todas las operaciones quedan registradas con usuario y fecha.

## Manejo de Errores
- El SP retorna estatus y mensaje.
- El controlador captura excepciones y las retorna en el campo `message` del eResponse.

## Integración Vue.js
- El componente es una página completa, sin tabs.
- Permite consultar, autorizar y cancelar microgenerador.
- Muestra mensajes claros según el resultado del SP.

## Base de Datos
- Tabla principal: `lic_microgenerador_ecologia`
  - id_licencia (nullable)
  - id_tramite (nullable)
  - anio
  - usuario_alta
  - fecha_alta
  - usuario_baja
  - fecha_baja
  - vigente ('V' o 'C')

## Ejemplo de Request/Response
### Alta
```json
{
  "action": "alta",
  "data": { "tipo": "L", "id": 12345 }
}
```
### Respuesta
```json
{
  "success": true,
  "data": [ { "estatus": 1, "mensaje": "Alta exitosa, Licencia registrada como microgenerador." } ]
}
```

## Notas
- El endpoint es único y centraliza todas las operaciones.
- El frontend es desacoplado y puede ser usado como página independiente.

## Casos de Uso

# Casos de Uso - LicenciaMicrogeneradorEcologia

**Categoría:** Form

## Caso de Uso 1: Autorizar Licencia como Microgenerador

**Descripción:** El usuario desea autorizar una licencia vigente como microgenerador de ecología.

**Precondiciones:**
La licencia existe y no está registrada como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia' en el formulario y captura el número de licencia.
2. Presiona 'Consultar'.
3. El sistema muestra los datos de la licencia y el botón 'Autorizar como Microgenerador'.
4. El usuario presiona 'Autorizar como Microgenerador'.
5. El sistema ejecuta el SP y muestra mensaje de éxito.

**Resultado esperado:**
La licencia queda registrada como microgenerador y el mensaje 'Alta exitosa, Licencia registrada como microgenerador.' se muestra.

**Datos de prueba:**
tipo: 'L', id: 12345

---

## Caso de Uso 2: Cancelar Microgenerador de un Trámite

**Descripción:** El usuario desea cancelar el registro de microgenerador para un trámite.

**Precondiciones:**
El trámite está registrado como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Trámite' y captura el ID de trámite.
2. Presiona 'Consultar'.
3. El sistema muestra los datos y el botón 'Cancelar Microgenerador'.
4. El usuario presiona 'Cancelar Microgenerador'.
5. El sistema ejecuta el SP y muestra mensaje de éxito.

**Resultado esperado:**
El trámite queda cancelado como microgenerador y el mensaje 'Cancelación exitosa, Trámite cancelado como microgenerador.' se muestra.

**Datos de prueba:**
tipo: 'T', id: 54321

---

## Caso de Uso 3: Intentar Autorizar Microgenerador ya Existente

**Descripción:** El usuario intenta autorizar como microgenerador una licencia que ya está vigente como microgenerador.

**Precondiciones:**
La licencia ya está registrada como microgenerador vigente.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia' y captura el número de licencia.
2. Presiona 'Consultar'.
3. El sistema muestra que ya es microgenerador y el botón 'Cancelar Microgenerador'.
4. El usuario presiona 'Autorizar como Microgenerador'.
5. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Licencia ya es microgenerador vigente.' y no realiza ninguna acción.

**Datos de prueba:**
tipo: 'L', id: 12345

---

## Casos de Prueba

# Casos de Prueba: Licencia Microgenerador Ecología

## Caso 1: Alta de Microgenerador (Licencia)
- **Input:**
  - tipo: 'L'
  - id: 12345
- **Acción:** 'alta'
- **Esperado:**
  - success: true
  - data[0].estatus == 1
  - data[0].mensaje contiene 'Alta exitosa'

## Caso 2: Consulta de Microgenerador (Trámite)
- **Input:**
  - tipo: 'T'
  - id: 54321
- **Acción:** 'consulta'
- **Esperado:**
  - success: true
  - data[0].estatus == 1 o 2
  - data[0].mensaje indica si es o no microgenerador

## Caso 3: Cancelación de Microgenerador (Licencia)
- **Input:**
  - tipo: 'L'
  - id: 12345
- **Acción:** 'cancela'
- **Esperado:**
  - success: true
  - data[0].estatus == 1
  - data[0].mensaje contiene 'Cancelación exitosa'

## Caso 4: Error por tipo inválido
- **Input:**
  - tipo: 'X'
  - id: 12345
- **Acción:** 'alta'
- **Esperado:**
  - success: true
  - data[0].estatus == 0
  - data[0].mensaje contiene 'Tipo inválido'

## Caso 5: Error por falta de datos
- **Input:**
  - tipo: 'L'
  - id: null
- **Acción:** 'alta'
- **Esperado:**
  - success: false
  - message contiene 'Tipo y ID requeridos'

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

