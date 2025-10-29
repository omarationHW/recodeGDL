# Casos de Uso - consultapredial

**Categoría:** Form

## Caso de Uso 1: Consulta de Cuenta Predial Vigente

**Descripción:** El usuario consulta una cuenta predial vigente ingresando recaudadora, tipo y número de cuenta.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los datos de la cuenta.

**Pasos a seguir:**
- Accede a la página de Consulta Predial.
- Ingresa recaudadora: 1, tipo: U, cuenta: 123456.
- Presiona 'Buscar'.
- El sistema muestra los datos de la cuenta, saldos, recibos, requerimientos, régimen de propiedad, valores y ubicación.

**Resultado esperado:**
Se muestran todos los datos relacionados a la cuenta predial consultada.

**Datos de prueba:**
{ recaud: 1, urbrus: 'U', cuenta: 123456 }

---

## Caso de Uso 2: Visualización de Ubicación Cartográfica

**Descripción:** El usuario desea ver la ubicación cartográfica de la cuenta predial consultada.

**Precondiciones:**
El usuario ya consultó una cuenta predial y la clave catastral está disponible.

**Pasos a seguir:**
- En la vista de datos de cuenta, presiona 'Ver Ubicación Cartográfica'.
- El sistema solicita la URL del visor cartográfico.
- Se muestra el visor en un iframe.

**Resultado esperado:**
El visor cartográfico se muestra correctamente con la ubicación de la cuenta.

**Datos de prueba:**
{ clave_cat: 'D6512345678' }

---

## Caso de Uso 3: Consulta de Saldos y Recibos

**Descripción:** El usuario consulta los saldos y recibos de una cuenta predial.

**Precondiciones:**
El usuario ya consultó una cuenta predial.

**Pasos a seguir:**
- En la vista de la cuenta, navega a la sección de Saldos.
- El sistema muestra la tabla de saldos por año.
- Navega a la sección de Recibos.
- El sistema muestra la tabla de recibos.

**Resultado esperado:**
Se muestran correctamente los saldos y recibos asociados a la cuenta.

**Datos de prueba:**
{ cvecuenta: 123456 }

---

