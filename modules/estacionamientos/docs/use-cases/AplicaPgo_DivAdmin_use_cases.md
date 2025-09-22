# Casos de Uso - AplicaPgo_DivAdmin

**Categoría:** Form

## Caso de Uso 1: Búsqueda de folios por placa

**Descripción:** El usuario busca todos los folios asociados a una placa específica para verificar adeudos.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la placa.

**Pasos a seguir:**
1. Ingresa a la página Aplica Pagos Diversos Admin.
2. Selecciona 'Por Placa'.
3. Ingresa la placa 'ABC1234'.
4. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los folios asociados a la placa 'ABC1234'.

**Datos de prueba:**
placa: 'ABC1234'

---

## Caso de Uso 2: Aplicar pago a varios folios seleccionados

**Descripción:** El usuario selecciona varios folios y aplica el pago de diversos admin.

**Precondiciones:**
Existen folios pendientes de pago para la placa 'XYZ5678'.

**Pasos a seguir:**
1. Busca folios por placa 'XYZ5678'.
2. Selecciona dos folios de la lista.
3. Hace clic en 'Aplicar Pago Diversos'.
4. Ingresa fecha de pago, recaudadora, caja y operación.
5. Hace clic en 'Continuar'.

**Resultado esperado:**
El sistema aplica el pago a los folios seleccionados y muestra mensaje de éxito.

**Datos de prueba:**
placa: 'XYZ5678', folios: [101, 102], fecha: '2024-06-10', recaudadora: 1, caja: '01', oper: '12345'

---

## Caso de Uso 3: Intento de aplicar pago sin seleccionar folios

**Descripción:** El usuario intenta aplicar pago sin seleccionar ningún folio.

**Precondiciones:**
Existen folios listados en la tabla.

**Pasos a seguir:**
1. Busca folios por placa o año+folio.
2. No selecciona ningún folio.
3. Hace clic en 'Aplicar Pago Diversos'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que debe seleccionar al menos un folio.

**Datos de prueba:**
placa: 'LMN4321', folios: []

---

