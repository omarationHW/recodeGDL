# Casos de Uso - AutorizaDes

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Autorizado

**Descripción:** Un usuario autorizado da de alta un descuento para un folio de requerimiento vigente y practicado.

**Precondiciones:**
El folio existe, está vigente y practicado. El usuario tiene permiso para dar descuentos.

**Pasos a seguir:**
1. El usuario ingresa a la página de Descuentos Autorizados.
2. Selecciona la oficina, aplicación y digita el folio.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del folio y permite capturar el porcentaje, quién autoriza y la fecha de alta.
5. El usuario ingresa los datos y presiona 'Guardar'.

**Resultado esperado:**
El descuento se registra correctamente, el porcentaje de multa se actualiza en el folio, y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_rec": 1, "id_modulo": 16, "folio": 12345, "porcentaje": 30, "cveaut": 2, "fecha_alta": "2024-06-01", "usuario_id": 1 }

---

## Caso de Uso 2: Modificación de Descuento Autorizado

**Descripción:** Un usuario modifica el porcentaje de un descuento ya existente.

**Precondiciones:**
Existe un descuento vigente para el folio.

**Pasos a seguir:**
1. El usuario busca el folio con descuento vigente.
2. El sistema muestra los datos actuales del descuento.
3. El usuario cambia el porcentaje y/o el autorizador y presiona 'Guardar'.

**Resultado esperado:**
El descuento se actualiza, el porcentaje de multa se modifica en el folio, y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_control": 123, "id_rec": 1, "cveaut": 3, "porcentaje": 40, "fecha_alta": "2024-06-02", "usuario_id": 1 }

---

## Caso de Uso 3: Baja (Cancelación) de Descuento Autorizado

**Descripción:** Un usuario cancela un descuento autorizado vigente.

**Precondiciones:**
Existe un descuento vigente para el folio.

**Pasos a seguir:**
1. El usuario busca el folio con descuento vigente.
2. El sistema muestra la opción de 'Dar de Baja'.
3. El usuario confirma la baja.
4. El sistema marca el descuento como cancelado y actualiza el porcentaje de multa a 100.

**Resultado esperado:**
El descuento queda cancelado, el folio tiene porcentaje de multa 100, y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id_control": 123, "fecha_baja": "2024-06-03", "usuario_id": 1 }

---

