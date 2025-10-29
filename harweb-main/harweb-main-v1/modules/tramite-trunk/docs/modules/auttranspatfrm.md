# Documentación Técnica: Migración de Formulario Autorización Transmisión Patrimonial (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio crítica en stored procedures.
- **Patrón de integración:** eRequest/eResponse (entrada/salida JSON).

## 2. API Backend
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "get|save|authorize|close|reopen|list|catalog",
      "data": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```
- **Controlador:** `AutTransPatrimonialController` implementa todas las acciones requeridas.
- **Validación:** Laravel Validator, errores devuelven HTTP 400/500 con mensaje.
- **Acciones soportadas:**
  - `get`: Recupera un registro por folio
  - `save`: Inserta/actualiza registro
  - `authorize`: Cambia status a 'P' (autorizado para pago)
  - `close`: Cambia status a 'C' (cerrado)
  - `reopen`: Cambia status a 'A' (activo/abierto)
  - `list`: Lista registros (filtros opcionales)
  - `catalog`: Catálogos auxiliares (ej. tasas preferenciales)

## 3. Stored Procedures PostgreSQL
- Toda la lógica de negocio y reglas de status se implementan en SPs.
- SPs devuelven siempre un `TABLE` para fácil consumo desde Laravel.
- Ejemplo de status:
  - 'A' = Abierto/Activo
  - 'P' = Autorizado para pago
  - 'C' = Cerrado
- Validaciones de integridad y reglas de negocio críticas deben estar en los SPs.

## 4. Frontend Vue.js
- **Página independiente:** `AutTransPatrimonialPage.vue`.
- **Navegación:** Breadcrumb superior.
- **Formulario:**
  - Folio (readonly si status != abierto)
  - Causa Impuesto (checkbox)
  - Tasa Preferencial (select)
  - Justificación Legal (textarea)
  - Observaciones (textarea)
  - Botones: Guardar, Autorizar, Cerrar, Reabrir
- **Historial:** Tabla de registros recientes.
- **Mensajes:** Alertas de éxito/error tras cada acción.
- **Validación:** HTML5 + validación de backend.

## 5. Seguridad
- **Autenticación:** JWT o sesión Laravel (no incluido aquí, pero el controlador espera `usuario` en el payload).
- **Autorización:** Validar permisos en el backend según usuario.
- **Validación de datos:** En backend y frontend.

## 6. Integración y Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otros formularios.
- Los SPs pueden ser versionados y auditados.
- El frontend puede ser adaptado para otros formularios siguiendo el mismo patrón.

## 7. Migración de Lógica Delphi
- La lógica de validación, status, y flujos de autorización se migró a SPs y controlador.
- El formulario Delphi se mapea 1:1 a la página Vue.js.
- El acceso a catálogos (ej. tasas preferenciales) se hace vía acción `catalog`.

## 8. Consideraciones de Pruebas
- Todos los flujos deben ser probados con datos válidos e inválidos.
- Los casos de uso y pruebas cubren los escenarios principales y de error.

## 9. Tablas Requeridas (Ejemplo)
```sql
CREATE TABLE aut_transpatrimonial (
    folio integer PRIMARY KEY,
    exento char(1) NOT NULL DEFAULT 'N',
    documentos_otros text NOT NULL,
    justificacion text,
    tasa_preferencial char(1) NOT NULL DEFAULT 'N',
    usuario varchar(50) NOT NULL,
    fecha timestamp NOT NULL DEFAULT now(),
    status char(1) NOT NULL DEFAULT 'A'
);

CREATE TABLE catalogo_tasa_preferencial (
    id serial PRIMARY KEY,
    descripcion varchar(100),
    valor numeric(8,5),
    vigente boolean DEFAULT true
);
```

## 10. Notas
- El endpoint y los SPs pueden ser adaptados para lógica adicional (ej. auditoría, logs, etc).
- El frontend puede ser extendido para validaciones adicionales o integración con otros módulos.
