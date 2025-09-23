# Documentación Técnica: Migración Formulario Adeudos_EdoCta (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y validación.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las acciones (init, consulta, procesamiento) se hacen vía `/api/execute` usando el patrón eRequest/eResponse.

## 2. Flujo de Trabajo
1. **Inicialización**: El frontend solicita los catálogos (tipos de aseo, meses, vigencias) usando `action: 'init'`.
2. **Captura de Datos**: El usuario ingresa el número de contrato, selecciona tipo de aseo y vigencia/periodo.
3. **Procesamiento**: Al enviar el formulario, el frontend llama a `action: 'procesarAdeudos'` con los parámetros.
4. **Backend**:
    - Ejecuta los stored procedures necesarios para generar el detalle de pagos y apremios.
    - Consulta los contratos y sus detalles.
    - Devuelve los resultados en `eResponse`.
5. **Visualización**: El frontend muestra los resultados en tablas, con totales.

## 3. API Detallada
### Endpoint
- **POST** `/api/execute`
- **Body**:
  ```json
  {
    "eRequest": {
      "action": "init|getTipoAseo|getContratos|procesarAdeudos|getDetallePagos",
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones Soportadas
- `init`: Devuelve catálogos iniciales.
- `getTipoAseo`: Devuelve tipos de aseo.
- `getContratos`: Devuelve contratos filtrados.
- `procesarAdeudos`: Ejecuta la lógica principal (stored procedures) y devuelve resultados.
- `getDetallePagos`: Devuelve detalle de pagos para un contrato.

## 4. Stored Procedures
- **sp_creadetp**: Limpia y prepara la tabla de detalle de pagos.
- **sp_detpagos**: Genera el detalle de pagos para un contrato y periodo.
- **sp_detapremios**: Genera el detalle de apremios para un contrato.

## 5. Validaciones
- El número de contrato y tipo de aseo son obligatorios.
- Si la vigencia es 'A' (otro periodo), el año y mes son obligatorios.
- El backend valida la existencia de contratos antes de procesar.

## 6. Seguridad
- El endpoint debe estar protegido por autenticación (no incluido aquí).
- Validar y sanitizar todos los parámetros recibidos.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin cambiar el frontend.

## 8. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los de PostgreSQL.
- Los stored procedures deben ser revisados para lógica específica de negocio.
- El frontend puede ser adaptado a cualquier framework SPA.

## 9. Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "procesarAdeudos",
    "params": {
      "contrato": "12345",
      "ctrol_aseo": 9,
      "vigencia": "V",
      "ejercicio": 2024,
      "mes": "06"
    }
  }
}
```

## 10. Respuesta Esperada
```json
{
  "eResponse": {
    "resultados": [
      {
        "contrato": { ... },
        "detPagos": [ ... ],
        "detPagosSum": { ... }
      }
    ]
  }
}
```
