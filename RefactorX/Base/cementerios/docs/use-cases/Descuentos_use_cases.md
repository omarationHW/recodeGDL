# Casos de Uso - Descuentos

**Categoría:** Form

## Caso de Uso 1: Aplicar un nuevo descuento a un adeudo vigente

**Descripción:** El usuario busca un folio de fosa, selecciona un adeudo vigente y aplica un descuento del 10%.

**Precondiciones:**
El folio existe y tiene al menos un adeudo vigente sin descuento.

**Pasos a seguir:**
1. Ingresar el folio en el formulario y buscar.
2. Seleccionar el adeudo vigente deseado.
3. Hacer clic en 'Aplicar Descuento'.
4. Seleccionar el tipo de descuento (10%).
5. Confirmar la operación.

**Resultado esperado:**
El descuento se registra correctamente y aparece en la lista de descuentos registrados.

**Datos de prueba:**
folio: 1234, adeudo: axo_adeudo=2024, tipo_descto='A', porcentaje=10

---

## Caso de Uso 2: Borrar un descuento existente

**Descripción:** El usuario elimina un descuento previamente aplicado a un adeudo.

**Precondiciones:**
El folio tiene al menos un descuento registrado y vigente.

**Pasos a seguir:**
1. Buscar el folio.
2. En la tabla de descuentos registrados, hacer clic en 'Borrar' sobre el descuento deseado.
3. Confirmar la eliminación.

**Resultado esperado:**
El descuento desaparece de la lista y el adeudo queda sin descuento.

**Datos de prueba:**
folio: 1234, descuento: axo_descto=2024, tipo_descto='A'

---

## Caso de Uso 3: Reactivar descuento para el siguiente año

**Descripción:** El usuario reactiva el descuento para el año siguiente en curso.

**Precondiciones:**
El folio tiene un descuento anterior con opción de reactivación.

**Pasos a seguir:**
1. Buscar el folio.
2. Hacer clic en 'Reactivar Descuento'.
3. Confirmar la operación.

**Resultado esperado:**
El descuento se reactiva para el siguiente año y aparece en la lista.

**Datos de prueba:**
folio: 1234, tipo_descto='A', axo=2025

---

