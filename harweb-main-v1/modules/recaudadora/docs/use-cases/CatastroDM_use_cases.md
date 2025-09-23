# Casos de Uso - CatastroDM

**Categoría:** Form

## Caso de Uso 1: Alta de Descuento Predial

**Descripción:** El usuario ingresa la clave catastral, consulta la cuenta y registra un nuevo descuento predial.

**Precondiciones:**
El usuario tiene permisos de alta. La cuenta existe y tiene adeudos.

**Pasos a seguir:**
1. El usuario accede a la página de descuentos predial.
2. Ingresa la clave catastral y presiona 'Buscar'.
3. El sistema muestra los datos de la cuenta y los adeudos.
4. El usuario llena el formulario de descuento (tipo, bimestre, solicitante, observaciones).
5. Presiona 'Agregar'.
6. El sistema inserta el descuento y lo muestra en la lista.

**Resultado esperado:**
El descuento aparece en la lista de descuentos vigentes para la cuenta.

**Datos de prueba:**
{ "clave": "D65J1234567", "cvedescuento": 1, "bimini": 1, "bimfin": 6, "solicitante": "Juan Perez", "observaciones": "Descuento por pronto pago" }

---

## Caso de Uso 2: Cancelación de Descuento Predial

**Descripción:** El usuario cancela un descuento vigente.

**Precondiciones:**
El usuario tiene permisos de cancelación. Existe al menos un descuento vigente.

**Pasos a seguir:**
1. El usuario busca la cuenta por clave catastral.
2. Visualiza la lista de descuentos vigentes.
3. Presiona 'Cancelar' en el descuento deseado.
4. El sistema actualiza el status a 'C'.

**Resultado esperado:**
El descuento aparece como cancelado y no puede ser usado para nuevos pagos.

**Datos de prueba:**
{ "id": 123, "usuario": "admin" }

---

## Caso de Uso 3: Consulta de Adeudos y Descuentos

**Descripción:** El usuario consulta los adeudos y descuentos de una cuenta.

**Precondiciones:**
La cuenta existe.

**Pasos a seguir:**
1. El usuario ingresa la clave catastral.
2. El sistema muestra los adeudos y descuentos vigentes.

**Resultado esperado:**
Se visualizan los adeudos y descuentos actuales.

**Datos de prueba:**
{ "clave": "D65J1234567" }

---

