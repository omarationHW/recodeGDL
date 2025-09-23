# Casos de Uso - Modifcar

**Categoría:** Form

## Caso de Uso 1: Modificar un Folio Vigente de Mercados

**Descripción:** El usuario desea modificar el importe de gastos y observaciones de un folio vigente del módulo Mercados.

**Precondiciones:**
El folio existe, está vigente y el usuario tiene permisos de modificación.

**Pasos a seguir:**
1. El usuario accede a la página de Modificar Folio.
2. Selecciona '11 Mercados', ingresa la recaudadora y el número de folio.
3. Pulsa 'Verificar'.
4. El sistema muestra los datos del folio.
5. El usuario edita el campo 'Imp. Gastos' y 'Observaciones'.
6. Pulsa 'Modificar'.
7. El sistema valida y actualiza el folio, mostrando mensaje de éxito.

**Resultado esperado:**
El folio se actualiza correctamente, se registra el historial y se muestra mensaje de éxito.

**Datos de prueba:**
{ "modulo": 11, "recaudadora": 1, "folio": 12345, "importe_gastos": 500.00, "observaciones": "Actualización de gastos" }

---

## Caso de Uso 2: Intentar Modificar un Folio No Existente

**Descripción:** El usuario intenta modificar un folio que no existe.

**Precondiciones:**
El folio no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Modificar Folio.
2. Ingresa un número de folio inexistente y pulsa 'Verificar'.
3. El sistema muestra mensaje de error.

**Resultado esperado:**
El sistema indica que el folio no existe y no permite modificar.

**Datos de prueba:**
{ "modulo": 11, "recaudadora": 1, "folio": 999999 }

---

## Caso de Uso 3: Ver Historial de Cambios de un Folio

**Descripción:** El usuario consulta el historial de modificaciones de un folio.

**Precondiciones:**
El folio existe y tiene historial de cambios.

**Pasos a seguir:**
1. El usuario accede a la página de Modificar Folio.
2. Ingresa los datos del folio y pulsa 'Verificar'.
3. El sistema muestra la tabla de historial de cambios.

**Resultado esperado:**
Se muestra el historial ordenado por fecha descendente.

**Datos de prueba:**
{ "id_control": 123 }

---

