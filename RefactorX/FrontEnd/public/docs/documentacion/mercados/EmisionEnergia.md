# EmisionEnergia

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Emisión de Recibos de Energía Eléctrica

## Arquitectura General
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` con los parámetros de acción y datos.
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Comunicación:** El frontend consume el endpoint `/api/execute` enviando `{ eRequest: { action, params } }` y recibiendo `{ eResponse: { status, data, message } }`.

## Flujo de la Aplicación
1. El usuario selecciona recaudadora, mercado, año y periodo.
2. Puede:
   - Consultar la emisión (detalle de recibos a emitir)
   - Grabar la emisión (genera adeudos si no existen)
   - Facturar (genera datos para impresión/facturación)
3. Todas las operaciones se ejecutan vía el endpoint `/api/execute`.

## API Backend
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getEmisionEnergia", // o grabarEmisionEnergia, facturarEmisionEnergia, etc.
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## Stored Procedures
- Toda la lógica de negocio y validación reside en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SP y retorna el resultado.

## Seguridad
- El usuario debe estar autenticado (no implementado aquí, pero debe obtenerse el ID de usuario para grabar).
- Validaciones de entrada en frontend y backend.

## Componentes Vue.js
- Página independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo.
- Mensajes de error y éxito.
- Tabla de resultados.

## Consideraciones
- El frontend debe manejar los estados de carga, error y éxito.
- El backend debe manejar excepciones y retornar mensajes claros.
- El endpoint es unificado para facilitar la integración y el mantenimiento.

# Estructura de la Base de Datos (Tablas Clave)
- ta_11_mercados
- ta_11_locales
- ta_11_kilowhatts
- ta_11_energia
- ta_11_adeudo_energ
- ta_12_recaudadoras

# Ejemplo de Llamadas API
- Obtener recaudadoras:
  ```json
  { "eRequest": { "action": "getRecaudadoras" } }
  ```
- Obtener mercados:
  ```json
  { "eRequest": { "action": "getMercadosByRecaudadora", "params": { "oficina": 1 } } }
  ```
- Obtener emisión:
  ```json
  { "eRequest": { "action": "getEmisionEnergia", "params": { "oficina": 1, "mercado": 1, "axo": 2024, "periodo": 6 } } }
  ```
- Grabar emisión:
  ```json
  { "eRequest": { "action": "grabarEmisionEnergia", "params": { "oficina": 1, "mercado": 1, "axo": 2024, "periodo": 6, "usuario": 5 } } }
  ```

# Manejo de Errores
- Si la emisión ya existe, el SP retorna status 'error' y un mensaje.
- Si ocurre un error de base de datos, el controlador retorna status 'error' y el mensaje de excepción.

# Pruebas y Validación
- El frontend debe validar que los campos requeridos estén completos antes de enviar la petición.
- El backend valida duplicidad antes de grabar.

# Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin cambiar el frontend.


## Casos de Uso

# Casos de Uso - EmisionEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Emisión de Energía

**Descripción:** El usuario consulta los recibos de energía a emitir para un mercado y periodo específico.

**Precondiciones:**
El usuario está autenticado y existen locales con energía eléctrica en el mercado seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Energía.
2. Selecciona la recaudadora y el mercado.
3. Selecciona el año y el periodo (mes).
4. Presiona el botón 'Emisión'.
5. El sistema muestra el detalle de la emisión.

**Resultado esperado:**
Se muestra una tabla con los locales, importes y detalles de la emisión de energía.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6 }

---

## Caso de Uso 2: Grabar Emisión de Energía

**Descripción:** El usuario graba la emisión de energía para un mercado y periodo, generando los adeudos correspondientes.

**Precondiciones:**
No existe una emisión previa para ese mercado, año y periodo.

**Pasos a seguir:**
1. El usuario llena el formulario con recaudadora, mercado, año y periodo.
2. Presiona el botón 'Grabar'.
3. El sistema valida que no exista emisión previa.
4. Si no existe, graba los adeudos y muestra mensaje de éxito.

**Resultado esperado:**
Los adeudos de energía se graban correctamente y se muestra un mensaje de confirmación.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }

---

## Caso de Uso 3: Facturación de Emisión de Energía

**Descripción:** El usuario solicita la facturación de la emisión de energía para un mercado y periodo.

**Precondiciones:**
La emisión de energía ya fue grabada para ese mercado, año y periodo.

**Pasos a seguir:**
1. El usuario selecciona recaudadora, mercado, año y periodo.
2. Presiona el botón 'Facturación'.
3. El sistema retorna los datos para la facturación.

**Resultado esperado:**
Se genera la información para la facturación y se muestra mensaje de éxito.

**Datos de prueba:**
{ oficina: 1, mercado: 1, axo: 2024, periodo: 6 }

---



## Casos de Prueba

# Casos de Prueba: Emisión de Recibos de Energía Eléctrica

## Caso 1: Consulta de Emisión
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6 }
- **Acción:** getEmisionEnergia
- **Esperado:** Respuesta status 'ok', data con lista de locales y detalles de emisión.

## Caso 2: Grabar Emisión (Primera vez)
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }
- **Acción:** grabarEmisionEnergia
- **Esperado:** Respuesta status 'ok', message 'La Emisión de Energía Eléctrica se grabó correctamente'.

## Caso 3: Grabar Emisión (Duplicado)
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6, usuario: 5 }
- **Acción:** grabarEmisionEnergia
- **Esperado:** Respuesta status 'error', message 'La Emisión de Energía Eléctrica ya está grabada, NO puedes volver a grabar'.

## Caso 4: Facturación
- **Entrada:** { oficina: 1, mercado: 1, axo: 2024, periodo: 6 }
- **Acción:** facturarEmisionEnergia
- **Esperado:** Respuesta status 'ok', data con información de facturación.

## Caso 5: Validación de Campos Vacíos
- **Entrada:** { oficina: '', mercado: '', axo: '', periodo: '' }
- **Acción:** getEmisionEnergia
- **Esperado:** Respuesta status 'error', message indicando campos requeridos.



