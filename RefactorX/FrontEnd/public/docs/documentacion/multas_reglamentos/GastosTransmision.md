# Documentación: GastosTransmision

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - GastosTransmision

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio de Transmisión Patrimonial

**Descripción:** El usuario consulta los importes y estado de un folio de transmisión patrimonial.

**Precondiciones:**
El folio de transmisión existe y está vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de folio y selecciona 'Transmisión Patrimonial'.
2. Presiona 'Consultar'.
3. El sistema envía la petición al endpoint /api/execute con action=consulta_foliotransm.
4. El backend ejecuta el SP y devuelve los importes y estado.

**Resultado esperado:**
Se muestran los importes (impuesto, recargos, multas, gastos, total) y el estado del folio.

**Datos de prueba:**
{ "folio": 12345, "opc": "T" }

---

## Caso de Uso 2: Aplicación de Gastos a Folio de Transmisión

**Descripción:** El usuario aplica un gasto capturado a un folio de transmisión patrimonial.

**Precondiciones:**
El folio existe, está vigente y no tiene gastos aplicados.

**Pasos a seguir:**
1. El usuario consulta el folio y visualiza los importes.
2. Ingresa el monto de gastos a aplicar.
3. Presiona 'Aplicar Gastos'.
4. El sistema envía la petición al endpoint /api/execute con action=afecta_gastostransm.
5. El backend ejecuta el SP y actualiza el folio.

**Resultado esperado:**
El gasto es aplicado correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "folio": 12345, "gastos": 500.00, "opc": "T" }

---

## Caso de Uso 3: Intento de Aplicar Gastos a Folio Inexistente

**Descripción:** El usuario intenta aplicar gastos a un folio que no existe.

**Precondiciones:**
El folio no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un folio inexistente y un monto de gastos.
2. Presiona 'Aplicar Gastos'.
3. El sistema envía la petición al endpoint /api/execute con action=afecta_gastostransm.
4. El backend ejecuta el SP y detecta que el folio no existe.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el folio no fue encontrado.

**Datos de prueba:**
{ "folio": 999999, "gastos": 100.00, "opc": "T" }

---

## Casos de Prueba

## Casos de Prueba GastosTransmision

### Caso 1: Consulta de Folio Existente
- **Entrada:** { "action": "consulta_foliotransm", "params": { "folio": 12345, "opc": "T" } }
- **Esperado:** Respuesta success=true, data con importes y estatus=0.

### Caso 2: Consulta de Folio Inexistente
- **Entrada:** { "action": "consulta_foliotransm", "params": { "folio": 999999, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje 'Folio no encontrado', código 404.

### Caso 3: Aplicar Gastos Correctamente
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": 500.00, "opc": "T" } }
- **Esperado:** Respuesta success=true, mensaje 'Gastos aplicados correctamente'.

### Caso 4: Aplicar Gastos a Folio Inexistente
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 999999, "gastos": 100.00, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje 'Folio no encontrado'.

### Caso 5: Aplicar Gastos con Monto Negativo
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": -10.00, "opc": "T" } }
- **Esperado:** Respuesta success=false, mensaje de validación.

### Caso 6: Aplicar Gastos con Tipo de Módulo Inválido
- **Entrada:** { "action": "afecta_gastostransm", "params": { "folio": 12345, "gastos": 100.00, "opc": "X" } }
- **Esperado:** Respuesta success=false, mensaje 'Tipo de módulo inválido'.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

