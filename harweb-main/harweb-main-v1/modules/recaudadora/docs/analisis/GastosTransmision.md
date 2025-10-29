# Documentación Técnica: Gastos de Transmisión Patrimonial

## 1. Descripción General
Este módulo permite la consulta y aplicación de gastos a folios de transmisión patrimonial y diferencias de transmisión. El proceso se realiza mediante una interfaz web (Vue.js) que consume un API RESTful unificado en Laravel, el cual a su vez ejecuta stored procedures en PostgreSQL para toda la lógica de negocio.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, componente independiente, sin tabs.
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos:** PostgreSQL, toda la lógica en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "consulta_foliotransm",
    "params": { "folio": 12345, "opc": "T" }
  }
  ```
  o
  ```json
  {
    "action": "afecta_gastostransm",
    "params": { "folio": 12345, "gastos": 500.00, "opc": "T" }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "message": "Consulta exitosa",
    "data": { ...campos... }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta y afectación de gastos se realiza en los SP `consulta_foliotransm` y `afecta_gastostransm`.
- Los SP validan existencia, tipo de módulo y devuelven mensajes de error o éxito.

## 5. Seguridad
- El controlador Laravel puede validar autenticación y pasar el usuario a los SP para auditoría.
- Los SP pueden registrar el usuario que realiza la afectación.

## 6. Flujo de Usuario
1. El usuario ingresa el folio y elige el módulo (Transmisión o Diferencia).
2. El sistema consulta el folio y muestra los importes y estado.
3. Si el folio es válido y está vigente, el usuario puede capturar el gasto y aplicarlo.
4. El sistema ejecuta el SP de afectación y muestra el mensaje de resultado.

## 7. Validaciones
- El folio debe existir y estar vigente.
- El gasto debe ser un número positivo.
- No se permite aplicar gastos a folios cancelados o pagados.

## 8. Integración
- El frontend Vue.js se comunica exclusivamente con `/api/execute`.
- El backend Laravel enruta la acción al SP correspondiente.
- Los SP devuelven siempre un mensaje y un código de estado.

## 9. Consideraciones de Migración
- Los nombres de tablas y campos pueden variar según el modelo de datos PostgreSQL.
- Se recomienda crear índices en los campos `folio` para eficiencia.
- Los SP pueden ser extendidos para auditar cambios.

## 10. Ejemplo de Request/Response
### Consulta:
```json
{
  "action": "consulta_foliotransm",
  "params": { "folio": 12345, "opc": "T" }
}
```
### Aplicación de Gastos:
```json
{
  "action": "afecta_gastostransm",
  "params": { "folio": 12345, "gastos": 500.00, "opc": "T" }
}
```

## 11. Errores Comunes
- Folio no encontrado: mensaje de error y código 404.
- Tipo de módulo inválido: mensaje de error y código 422.
- Gasto negativo o vacío: mensaje de error y código 422.

## 12. Extensibilidad
- Se pueden agregar más acciones al endpoint unificado siguiendo el patrón eRequest/eResponse.
- Los SP pueden ser versionados y auditados.
