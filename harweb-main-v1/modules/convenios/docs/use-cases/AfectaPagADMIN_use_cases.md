# Casos de Uso - AfectaPagADMIN

**Categoría:** Form

## Caso de Uso 1: Afectar todos los pagos de convenios diversos para una fecha

**Descripción:** El usuario desea afectar (procesar) todos los pagos de convenios diversos registrados en una fecha específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de afectación. Existen pagos en estado 'V' para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página 'Afecta Pagos ADMIN'.
2. Selecciona la fecha de pago (ej: 2024-06-01).
3. Presiona 'Consultar' y visualiza la lista de pagos.
4. Presiona el botón 'Afectar' en la tabla.
5. Confirma la operación.
6. El sistema llama a /api/execute con action='afectar', fecha y usuario.
7. El backend ejecuta el SP de afectación y retorna el resultado.

**Resultado esperado:**
Todos los pagos de la fecha son procesados correctamente. Se muestra mensaje de éxito y la tabla se actualiza.

**Datos de prueba:**
fecha: '2024-06-01', usuario: 'admin'

---

## Caso de Uso 2: Cancelar un pago de convenio diverso

**Descripción:** El usuario necesita cancelar un pago específico (por ejemplo, por error de captura).

**Precondiciones:**
El usuario está autenticado y tiene permisos de cancelación. El pago está en estado 'C'.

**Pasos a seguir:**
1. El usuario accede a la página y consulta pagos de una fecha.
2. Identifica el pago a cancelar (estado 'C').
3. Presiona el botón 'Cancelar' en la fila correspondiente.
4. Confirma la operación.
5. El sistema llama a /api/execute con action='cancelar', id_pago y usuario.
6. El backend ejecuta el SP de cancelación y retorna el resultado.

**Resultado esperado:**
El pago es cancelado y el convenio se reactiva si corresponde. Se muestra mensaje de éxito.

**Datos de prueba:**
id_pago: 12345, usuario: 'admin'

---

## Caso de Uso 3: Afectar pago de licencia o anuncio

**Descripción:** El usuario procesa el pago de una licencia o anuncio, cambiando su estado y el del convenio.

**Precondiciones:**
El usuario está autenticado. El pago corresponde a una licencia o anuncio y está en estado 'V'.

**Pasos a seguir:**
1. El usuario consulta pagos de una fecha.
2. Identifica un pago de tipo licencia/anuncio.
3. Presiona 'Afectar'.
4. El sistema llama a /api/execute con action='licencias', id_pago y usuario.
5. El backend ejecuta el SP correspondiente.

**Resultado esperado:**
La licencia/anuncio y el convenio cambian de estado correctamente. Mensaje de éxito.

**Datos de prueba:**
id_pago: 54321, usuario: 'admin'

---

