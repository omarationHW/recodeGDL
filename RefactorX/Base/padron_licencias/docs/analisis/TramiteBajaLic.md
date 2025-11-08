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
