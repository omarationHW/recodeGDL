# Casos de Uso - Traslados

**Categoría:** Form

## Caso de Uso 1: Traslado exitoso de pagos entre dos ubicaciones

**Descripción:** Un usuario necesita trasladar todos los pagos de una fosa a otra dentro del mismo cementerio.

**Precondiciones:**
El usuario está autenticado. Existen pagos en la ubicación origen y la ubicación destino existe.

**Pasos a seguir:**
- El usuario accede a la página de Traslados.
- Selecciona el cementerio y llena los datos de la ubicación origen.
- Presiona 'Verificar Origen' y visualiza los pagos encontrados.
- Llena los datos de la ubicación destino.
- Presiona 'Verificar Destino' y visualiza los datos destino.
- Presiona 'Trasladar Pagos'.

**Resultado esperado:**
Los pagos son trasladados correctamente a la ubicación destino. Se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "origen": { "cementerio": "G", "clase": 1, "clase_alfa": "", "seccion": 4, "seccion_alfa": "BIS", "linea": 4, "linea_alfa": "", "fosa": 35, "fosa_alfa": "" },
  "destino": { "cementerio": "G", "clase": 1, "clase_alfa": "", "seccion": 4, "seccion_alfa": "BIS", "linea": 4, "linea_alfa": "", "fosa": 36, "fosa_alfa": "" }
}

---

## Caso de Uso 2: Intento de traslado sin pagos en origen

**Descripción:** El usuario intenta trasladar pagos desde una ubicación donde no existen pagos registrados.

**Precondiciones:**
El usuario está autenticado. No existen pagos en la ubicación origen.

**Pasos a seguir:**
- El usuario accede a la página de Traslados.
- Llena los datos de la ubicación origen sin pagos.
- Presiona 'Verificar Origen'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron pagos en el registro de origen.

**Datos de prueba:**
{
  "origen": { "cementerio": "G", "clase": 2, "clase_alfa": "", "seccion": 10, "seccion_alfa": "", "linea": 5, "linea_alfa": "", "fosa": 99, "fosa_alfa": "" }
}

---

## Caso de Uso 3: Intento de traslado a destino inexistente

**Descripción:** El usuario intenta trasladar pagos a una ubicación destino que no existe en la base de datos.

**Precondiciones:**
El usuario está autenticado. Existen pagos en la ubicación origen. No existen datos en la ubicación destino.

**Pasos a seguir:**
- El usuario accede a la página de Traslados.
- Llena los datos de la ubicación origen con pagos.
- Presiona 'Verificar Origen'.
- Llena los datos de la ubicación destino inexistente.
- Presiona 'Verificar Destino'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron datos en el registro destino.

**Datos de prueba:**
{
  "origen": { "cementerio": "G", "clase": 1, "clase_alfa": "", "seccion": 4, "seccion_alfa": "BIS", "linea": 4, "linea_alfa": "", "fosa": 35, "fosa_alfa": "" },
  "destino": { "cementerio": "G", "clase": 9, "clase_alfa": "", "seccion": 99, "seccion_alfa": "", "linea": 99, "linea_alfa": "", "fosa": 99, "fosa_alfa": "" }
}

---

