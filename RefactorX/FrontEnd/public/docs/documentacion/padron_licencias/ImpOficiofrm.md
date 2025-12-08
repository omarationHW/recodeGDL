# Documentación Técnica: ImpOficiofrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario ImpOficiofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de impresión de oficios para trámites improcedentes. Permite al usuario seleccionar el tipo de oficio a imprimir y registrar la decisión en la base de datos. La migración se realiza a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), siguiendo el patrón eRequest/eResponse con endpoint único.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador API único (`ImpOficioController`), endpoint `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente (`ImpOficioPage.vue`).
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Comunicación:** JSON, patrón eRequest/eResponse.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "registerOficioDecision",
    "params": {
      "tramite_id": 123,
      "oficio_type": 1,
      "usuario_id": 45,
      "observaciones": "Texto opcional"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [{"result": "Oficio registrado: Uno"}],
    "message": "Decisión registrada correctamente."
  }
  ```

## 4. Stored Procedures
- Toda la lógica de registro y consulta se realiza mediante stored procedures (`sp_imp_oficio_register`, `sp_get_tramite_info`).
- La tabla `imp_oficio_bitacora` almacena el historial de decisiones de impresión de oficios.

## 5. Frontend (Vue.js)
- El componente es una página completa, sin tabs, con navegación breadcrumb.
- Permite seleccionar el tipo de oficio, capturar observaciones y enviar la decisión.
- Usa fetch API para comunicarse con `/api/execute`.

## 6. Seguridad
- El backend valida los parámetros y el tipo de oficio.
- El usuario debe estar autenticado (se espera que el `usuario_id` venga del store o JWT).

## 7. Extensibilidad
- Se pueden agregar más tipos de oficios en el futuro modificando el SP y el frontend.
- El endpoint es genérico y puede ser extendido para otros formularios.

## 8. Tabla de Bitácora (Ejemplo)
```sql
CREATE TABLE imp_oficio_bitacora (
    id SERIAL PRIMARY KEY,
    tramite_id INTEGER NOT NULL,
    oficio_type INTEGER NOT NULL,
    oficio_label TEXT NOT NULL,
    usuario_id INTEGER NOT NULL,
    observaciones TEXT,
    fecha TIMESTAMP DEFAULT NOW()
);
```

## 9. Flujo de Trabajo
1. El usuario accede a la página de trámite improcedente.
2. Selecciona el tipo de oficio y opcionalmente escribe observaciones.
3. Al hacer clic en "Aceptar", se envía la petición al backend.
4. El backend registra la decisión y responde con éxito.
5. El frontend muestra el mensaje y puede redirigir o mostrar opciones de impresión.

## 10. Consideraciones
- El componente Vue es autónomo y puede ser usado en cualquier SPA.
- El backend puede ser probado con Postman o curl.
- El SP puede ser extendido para lógica de impresión real (PDF, etc).

## Casos de Prueba

# Casos de Prueba para ImpOficiofrm

## Caso 1: Registro exitoso de oficio
- **Entrada:**
  - tramite_id: 123
  - oficio_type: 2
  - usuario_id: 45
  - observaciones: "Observación de prueba"
- **Acción:** POST /api/execute con action=registerOficioDecision
- **Resultado esperado:**
  - success: true
  - data: [{ result: 'Oficio registrado: Dos' }]
  - message: 'Decisión registrada correctamente.'
  - El registro aparece en imp_oficio_bitacora

## Caso 2: Tipo de oficio inválido
- **Entrada:**
  - tramite_id: 123
  - oficio_type: 99
  - usuario_id: 45
- **Acción:** POST /api/execute con action=registerOficioDecision
- **Resultado esperado:**
  - success: false
  - message: 'Tipo de oficio inválido'

## Caso 3: Consulta de opciones de oficio
- **Acción:** POST /api/execute con action=getOficioOptions
- **Resultado esperado:**
  - success: true
  - data: [ { id: 1, label: 'Uno' }, ... ]

## Caso 4: Consulta de trámite inexistente
- **Entrada:**
  - tramite_id: 999999
- **Acción:** POST /api/execute con action=getTramiteInfo
- **Resultado esperado:**
  - success: true
  - data: []

## Caso 5: Cancelación desde frontend
- **Acción:** Usuario hace clic en 'Cancelar'
- **Resultado esperado:**
  - Redirección a /tramites

## Casos de Uso

# Casos de Uso - ImpOficiofrm

**Categoría:** Form

## Caso de Uso 1: Registrar decisión de impresión de oficio improcedente

**Descripción:** El usuario encuentra un trámite improcedente y decide registrar el tipo de oficio a imprimir.

**Precondiciones:**
El usuario está autenticado y tiene acceso al trámite improcedente.

**Pasos a seguir:**
1. El usuario accede a la página del trámite improcedente.
2. Selecciona 'M24BIS' como tipo de oficio.
3. Escribe 'Falta documentación' en observaciones.
4. Hace clic en 'Aceptar'.

**Resultado esperado:**
La decisión queda registrada en la bitácora y el usuario recibe confirmación.

**Datos de prueba:**
{ "tramite_id": 123, "oficio_type": 3, "usuario_id": 45, "observaciones": "Falta documentación" }

---

## Caso de Uso 2: Cancelar registro de oficio improcedente

**Descripción:** El usuario decide no registrar ningún oficio para el trámite improcedente.

**Precondiciones:**
El usuario está autenticado y en la página del trámite.

**Pasos a seguir:**
1. El usuario accede a la página del trámite improcedente.
2. Hace clic en 'Cancelar'.

**Resultado esperado:**
El usuario es redirigido a la lista de trámites sin registrar ningún oficio.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Consultar información de trámite antes de registrar oficio

**Descripción:** El sistema muestra información básica del trámite antes de registrar la decisión.

**Precondiciones:**
El trámite existe en la base de datos.

**Pasos a seguir:**
1. El frontend solicita la información del trámite usando el ID.
2. El backend responde con los datos del trámite.

**Resultado esperado:**
La información del trámite se muestra correctamente en pantalla.

**Datos de prueba:**
{ "tramite_id": 123 }

---
