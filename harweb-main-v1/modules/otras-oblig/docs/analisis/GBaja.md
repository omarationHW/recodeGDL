# Documentación Técnica: Migración Formulario GBaja (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación y formularios independientes.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio y validaciones críticas en stored procedures.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "search|getAdeudos|getPagados|aplicaBaja|getEtiquetas|getTablas",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## 3. Acciones Soportadas
- `search`: Buscar concesión por control/expediente/local.
- `getAdeudos`: Obtener detalle y totales de adeudos.
- `getPagados`: Listar pagos realizados.
- `aplicaBaja`: Ejecutar baja/cancelación de concesión.
- `getEtiquetas`: Obtener etiquetas de campos para la tabla.
- `getTablas`: Obtener nombre y descripción de la tabla.

## 4. Stored Procedures
- Toda la lógica de negocio (validaciones, reglas de baja, etc.) está en SPs PostgreSQL.
- Los SPs devuelven tablas (resultsets) compatibles con la estructura esperada por el frontend.

## 5. Frontend (Vue.js)
- Página única para el formulario de baja.
- Permite búsqueda por expediente o local según el tipo de tabla.
- Muestra datos de la concesión, adeudos, totales y pagos realizados.
- Permite aplicar la baja si el registro está vigente y sin adeudos posteriores.
- Modal para ver pagos realizados.

## 6. Seguridad
- El endpoint debe validar autenticación (middleware Laravel, no incluido aquí).
- El usuario que aplica la baja debe ser registrado en la operación.

## 7. Validaciones
- No se permite baja si el registro no está vigente o tiene adeudos posteriores.
- Todos los campos requeridos deben ser validados en frontend y backend.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- Los SPs pueden ser reutilizados por otros módulos.

## 9. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez.

---
