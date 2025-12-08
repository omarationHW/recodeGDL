# Documentación Técnica: TramiteBajaLic

## Análisis Técnico

# Documentación Técnica: Migración Formulario TramiteBajaLic (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (toda la lógica de negocio SQL en stored procedures)
- **Patrón de Comunicación**: eRequest/eResponse (entrada y salida JSON)

## 2. API Backend
- **Endpoint único**: `/api/execute` (POST)
- **Payload de entrada**:
  ```json
  {
    "eRequest": {
      "action": "consultar|agregar|tramitar_baja|recalcular|imprimir_orden",
      "params": { ... }
    }
  }
  ```
- **Payload de salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```
- **Controlador**: `TramiteBajaLicController`
  - Métodos: consultarLicencia, agregarTramite, tramitarBaja, recalcularProporcional, imprimirOrdenPago
  - Cada método llama a un stored procedure en PostgreSQL y retorna el resultado como JSON

## 3. Frontend Vue.js
- **Componente**: `TramiteBajaLic.vue`
- **Características**:
  - Página independiente (no usa tabs)
  - Formulario de búsqueda de licencia
  - Visualización de datos de licencia, adeudos, trámites realizados
  - Formulario para tramitar baja (motivo, fecha baja administrativa)
  - Botones para agregar trámite, recalcular, imprimir orden de pago
  - Mensajes de error y éxito
  - Navegación breadcrumb opcional

## 4. Stored Procedures PostgreSQL
- Toda la lógica de negocio (consultas, inserciones, cálculos) está en SPs:
  - `sp_tramite_baja_lic_consulta`: Consulta datos de licencia, adeudos y trámites
  - `sp_tramite_baja_lic_tramitar`: Realiza el trámite de baja, calcula importes y guarda registro
  - `sp_tramite_baja_lic_recalcula`: Recalcula saldos proporcionales
- Los SPs devuelven JSON para facilitar la integración con Laravel

## 5. Seguridad y Validaciones
- Validación de campos obligatorios en frontend y backend
- Control de errores y mensajes claros al usuario
- El usuario que tramita la baja se registra en el SP

## 6. Flujo de Uso
1. El usuario ingresa el número de licencia y consulta
2. El sistema muestra los datos de la licencia, adeudos y trámites previos
3. El usuario llena el motivo y fecha de baja y tramita la baja
4. El sistema calcula importes, guarda el trámite y muestra el folio
5. El usuario puede recalcular proporcionales o imprimir la orden de pago

## 7. Integración
- El frontend se comunica solo con `/api/execute` usando eRequest/eResponse
- El backend traduce la acción a una llamada al SP correspondiente
- Los SPs encapsulan toda la lógica de negocio y devuelven JSON

## 8. Extensibilidad
- Para agregar nuevas acciones, solo se agregan nuevos SPs y métodos en el controlador
- El frontend puede extenderse fácilmente para nuevos campos o validaciones

## 9. Pruebas
- Casos de uso y pruebas detalladas en las secciones siguientes

## Casos de Prueba

# Casos de Prueba TramiteBajaLic

## Caso 1: Consulta de Licencia Existente
- **Entrada**: { "eRequest": { "action": "consultar", "params": { "licencia": 123456 } } }
- **Esperado**: eResponse.success = true, eResponse.data.propietarionvo no vacío, eResponse.adeudos es array

## Caso 2: Consulta de Licencia Inexistente
- **Entrada**: { "eRequest": { "action": "consultar", "params": { "licencia": 999999 } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Licencia no encontrada'

## Caso 3: Tramitar Baja con Datos Completos
- **Entrada**: { "eRequest": { "action": "tramitar_baja", "params": { "licencia": 123456, "motivo": "Cierre", "baja_admva": "2024-07-01", "usuario": "jlopezv" } } }
- **Esperado**: eResponse.success = true, eResponse.folio > 0, eResponse.total > 0

## Caso 4: Tramitar Baja con Datos Incompletos
- **Entrada**: { "eRequest": { "action": "tramitar_baja", "params": { "licencia": 123456, "motivo": "", "baja_admva": "", "usuario": "" } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Datos incompletos para tramitar baja'

## Caso 5: Recalcular Proporcional
- **Entrada**: { "eRequest": { "action": "recalcular", "params": { "licencia": 123456 } } }
- **Esperado**: eResponse.success = true, eResponse.message = 'Recalculo realizado'

## Caso 6: Imprimir Orden de Pago sin Folio
- **Entrada**: { "eRequest": { "action": "imprimir_orden", "params": { "folio": null } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Folio requerido para impresión'

## Casos de Uso

# Casos de Uso - TramiteBajaLic

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia para Baja

**Descripción:** El usuario busca una licencia para iniciar el trámite de baja.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia en el formulario.
2. Presiona el botón 'Buscar'.
3. El sistema consulta la base de datos y muestra los datos de la licencia, adeudos y trámites realizados.

**Resultado esperado:**
Se muestran correctamente los datos de la licencia, los adeudos actuales y los trámites de baja previos.

**Datos de prueba:**
{ "licencia": 123456 }

---

## Caso de Uso 2: Tramitar Baja de Licencia

**Descripción:** El usuario realiza el trámite de baja de una licencia vigente.

**Precondiciones:**
La licencia existe, está vigente y no tiene bloqueos que impidan la baja.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Llena el motivo de la baja y la fecha administrativa.
3. Presiona el botón 'Tramitar Baja'.
4. El sistema valida los datos, calcula importes y registra el trámite.

**Resultado esperado:**
El trámite de baja se registra, se genera un folio y se actualiza la lista de trámites realizados.

**Datos de prueba:**
{ "licencia": 123456, "motivo": "Cierre de negocio", "baja_admva": "2024-07-01", "usuario": "jlopezv" }

---

## Caso de Uso 3: Recalcular Proporcional de Adeudos

**Descripción:** El usuario solicita el recálculo de los saldos proporcionales de la licencia antes de tramitar la baja.

**Precondiciones:**
La licencia existe y tiene adeudos calculados.

**Pasos a seguir:**
1. El usuario consulta la licencia.
2. Presiona el botón 'Recalcular Proporcional'.
3. El sistema ejecuta el SP de recálculo y actualiza los importes.

**Resultado esperado:**
Los saldos proporcionales se recalculan y se muestran los nuevos importes en pantalla.

**Datos de prueba:**
{ "licencia": 123456 }

---


