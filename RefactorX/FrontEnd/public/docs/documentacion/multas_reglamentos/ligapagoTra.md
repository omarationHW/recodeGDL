# Documentación: ligapagoTra

## Análisis Técnico

# Documentación Técnica: Migración Formulario Liga Pago Diverso a Transmisión Patrimonial

## Descripción General
Este módulo permite ligar pagos diversos (pagos de caja) a transmisiones patrimoniales (actostransm), incluyendo la posibilidad de ligar diferencias (diferencias_glosa). El proceso se realiza mediante un endpoint API unificado y stored procedures en PostgreSQL, con una interfaz Vue.js como página independiente.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe eRequest (action, params) y responde eResponse (status, data, message).
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y formularios independientes.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones usan el endpoint `/api/execute`.

## Flujo de Trabajo
1. **Búsqueda de Pago**: El usuario ingresa fecha, recaudadora, caja y folio. El sistema busca el pago en la tabla `pagos`.
2. **Búsqueda de Transmisión**: El usuario ingresa el folio de transmisión. El sistema busca en `actostransm`.
3. **Liga de Pago**: El usuario selecciona el tipo de liga (Completo, Convenio, Diferencia) y ejecuta la liga. El sistema llama el SP `sp_ligar_pago_transmision`.
4. **Diferencias**: Si el tipo es diferencia, se actualiza también la tabla `diferencias_glosa`.

## Seguridad
- Validación de parámetros en backend y frontend.
- Solo usuarios autenticados pueden ejecutar la acción de liga (en producción, el usuario se toma del contexto de sesión).

## API eRequest/eResponse
- **eRequest**: `{ action: string, params: object }`
- **eResponse**: `{ status: 'ok'|'error', data: any, message: string }`

## Stored Procedures
- Toda la lógica de negocio y validación crítica reside en SPs de PostgreSQL.

## Componentes Vue.js
- Página independiente, sin tabs.
- Breadcrumb para navegación.
- Formularios validados y mensajes claros.

## Integración
- El frontend llama a `/api/execute` con la acción y parámetros correspondientes.
- El backend enruta la acción al método y SP adecuado.

## Ejemplo de llamada API
```json
{
  "action": "ligarPagoTransmision",
  "params": {
    "cvepago": 12345,
    "cvecta": 67890,
    "usuario": "usuario_actual",
    "tipo": 22,
    "fecha": "2024-06-01",
    "folio_transmision": 5555
  }
}
```

## Validaciones
- El pago debe existir y ser de tipo diverso (cveconcepto=4).
- El folio de transmisión debe existir.
- No se puede ligar si la cuenta está exenta o cancelada.
- Si es diferencia, debe existir en diferencias_glosa.

## Mensajes de Error
- "No existe el pago a ligar"
- "No existe el folio de transmisión"
- "Pago ligado correctamente"

## Consideraciones
- El usuario debe ser autenticado y autorizado.
- El SP maneja la lógica de actualización de diferencias y transmisión.
- El frontend muestra mensajes claros y actualiza el estado de la UI.

## Casos de Uso

# Casos de Uso - ligapagoTra

**Categoría:** Form

## Caso de Uso 1: Ligar un pago diverso a una transmisión patrimonial (completo)

**Descripción:** El usuario liga un pago de caja a una transmisión patrimonial existente, tipo completo.

**Precondiciones:**
El pago existe en la tabla pagos (cveconcepto=4) y la transmisión existe en actostransm.

**Pasos a seguir:**
1. El usuario ingresa fecha, recaudadora, caja y folio del pago.
2. El sistema busca y muestra el pago.
3. El usuario ingresa el folio de transmisión.
4. El sistema busca y muestra la transmisión.
5. El usuario selecciona tipo 'Completo' y ejecuta la liga.
6. El sistema llama al SP y actualiza la transmisión.

**Resultado esperado:**
El pago queda ligado a la transmisión patrimonial y el usuario recibe confirmación.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 123, "folio_transmision": 5555, "tipo": 22 }

---

## Caso de Uso 2: Ligar un pago diverso a una transmisión patrimonial (diferencia)

**Descripción:** El usuario liga un pago de caja a una transmisión patrimonial como diferencia.

**Precondiciones:**
El pago existe, la transmisión existe, y existe registro en diferencias_glosa.

**Pasos a seguir:**
1. El usuario ingresa los datos del pago y lo busca.
2. El usuario ingresa el folio de transmisión y lo busca.
3. El usuario selecciona tipo 'Diferencia' y ejecuta la liga.
4. El sistema actualiza diferencias_glosa y actostransm.

**Resultado esperado:**
El pago queda ligado como diferencia y se actualizan los registros correspondientes.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 124, "folio_transmision": 5556, "tipo": 2 }

---

## Caso de Uso 3: Error al ligar pago inexistente

**Descripción:** El usuario intenta ligar un pago que no existe.

**Precondiciones:**
No existe el pago con los datos proporcionados.

**Pasos a seguir:**
1. El usuario ingresa datos de pago inexistente.
2. El sistema muestra mensaje de error.

**Resultado esperado:**
El usuario recibe mensaje 'No existe el pago a ligar'.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": 1, "caja": "A", "folio": 99999, "folio_transmision": 5555, "tipo": 22 }

---

## Casos de Prueba

## Casos de Prueba Liga Pago Diverso a Transmisión

### Caso 1: Ligar pago completo exitoso
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=123, folio_transmision=5555, tipo=22
- **Acción:** Buscar pago, buscar transmisión, ligar pago tipo completo
- **Esperado:** status=ok, message='Pago ligado correctamente', transmisión actualizada

### Caso 2: Ligar pago como diferencia
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=124, folio_transmision=5556, tipo=2
- **Acción:** Buscar pago, buscar transmisión, ligar pago tipo diferencia
- **Esperado:** status=ok, message='Pago ligado correctamente', diferencias_glosa y transmisión actualizadas

### Caso 3: Error por pago inexistente
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=99999, folio_transmision=5555, tipo=22
- **Acción:** Buscar pago, intentar ligar
- **Esperado:** status=error, message='No existe el pago a ligar'

### Caso 4: Error por transmisión inexistente
- **Entrada:** fecha=2024-06-01, recaud=1, caja='A', folio=123, folio_transmision=99999, tipo=22
- **Acción:** Buscar pago, buscar transmisión, intentar ligar
- **Esperado:** status=error, message='No existe el folio de transmisión'

### Caso 5: Validación de campos obligatorios
- **Entrada:** falta algún campo requerido
- **Acción:** Intentar ligar
- **Esperado:** status=error, message='El campo X es requerido'

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

