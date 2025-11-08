# Casos de Uso - CuotasEnergiaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de energía eléctrica

**Descripción:** El usuario desea registrar una nueva cuota para el año y periodo actual.

**Precondiciones:**
El usuario está autenticado y tiene permisos de mantenimiento.

**Pasos a seguir:**
1. El usuario accede a la página de Mantenimiento Cuotas de Energía Eléctrica.
2. Hace clic en 'Nuevo' (o deja el formulario en blanco).
3. Ingresa el año (ej: 2024), periodo (ej: 6), y el importe (ej: 150.00).
4. Presiona 'Guardar'.
5. El sistema valida los datos y envía el eRequest al backend.
6. El backend inserta la cuota y responde con éxito.
7. El frontend muestra el mensaje de éxito y actualiza el listado.

**Resultado esperado:**
La cuota se inserta correctamente y aparece en el listado.

**Datos de prueba:**
{ "axo": 2024, "periodo": 6, "importe": 150.00, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de una cuota existente

**Descripción:** El usuario necesita corregir el importe de una cuota ya registrada.

**Precondiciones:**
Existe una cuota para año 2024, periodo 6. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario filtra el listado por año 2024 y periodo 6.
2. Hace clic en 'Editar' sobre la cuota deseada.
3. Cambia el importe a 175.00.
4. Presiona 'Actualizar'.
5. El sistema valida y envía el eRequest al backend.
6. El backend actualiza la cuota y responde con éxito.
7. El frontend muestra el mensaje y actualiza el listado.

**Resultado esperado:**
El importe de la cuota se actualiza correctamente.

**Datos de prueba:**
{ "id_kilowhatts": 10, "axo": 2024, "periodo": 6, "importe": 175.00, "id_usuario": 1 }

---

## Caso de Uso 3: Validación de importe vacío o cero

**Descripción:** El usuario intenta guardar una cuota sin importe o con importe cero.

**Precondiciones:**
El usuario está en el formulario de alta o edición.

**Pasos a seguir:**
1. El usuario deja el campo importe vacío o en cero.
2. Presiona 'Guardar' o 'Actualizar'.
3. El frontend valida y muestra un mensaje de error.
4. Si el frontend no lo bloquea, el backend también valida y rechaza la operación.

**Resultado esperado:**
El sistema no permite guardar cuotas vacías o en cero y muestra un mensaje de error.

**Datos de prueba:**
{ "axo": 2024, "periodo": 6, "importe": 0, "id_usuario": 1 }

---

