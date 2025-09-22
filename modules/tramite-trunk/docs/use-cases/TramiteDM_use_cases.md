# Casos de Uso - TramiteDM

**Categoría:** Form

## Caso de Uso 1: Registro de un nuevo adquiriente

**Descripción:** El usuario registra un nuevo adquiriente para un folio de transmisión patrimonial.

**Precondiciones:**
El folio de transmisión ya existe y está en estado válido.

**Pasos a seguir:**
- El usuario ingresa al formulario TramiteDM.
- Llena los datos del adquiriente (RFC, porcentaje, datos personales, etc).
- Presiona 'Guardar'.
- El sistema valida los datos y guarda el adquiriente.

**Resultado esperado:**
El adquiriente queda registrado y aparece en la lista de adquirientes del folio.

**Datos de prueba:**
{ "folio": 1001, "cvecont": 2002, "porccoprop": 50.0, "rfc": "XAXX010101000", ... }

---

## Caso de Uso 2: Cálculo del impuesto de transmisión patrimonial

**Descripción:** El usuario solicita el cálculo del impuesto para un folio.

**Precondiciones:**
El folio tiene todos los datos requeridos (valores, fechas, porcentaje, etc).

**Pasos a seguir:**
- El usuario ingresa el folio y presiona 'Calcular Impuesto'.
- El sistema llama al SP de cálculo y muestra el resultado.

**Resultado esperado:**
Se muestra el monto del impuesto, recargos, multas y total.

**Datos de prueba:**
{ "folio": 1001 }

---

## Caso de Uso 3: Validación de porcentaje de copropiedad

**Descripción:** El sistema valida que la suma de porcentajes de copropiedad de todos los adquirientes de un folio sea 100%.

**Precondiciones:**
Existen varios adquirientes registrados para el folio.

**Pasos a seguir:**
- El usuario guarda varios adquirientes con diferentes porcentajes.
- El sistema suma los porcentajes y valida que sea 100%.

**Resultado esperado:**
Si la suma es diferente de 100%, el sistema muestra un error.

**Datos de prueba:**
[ { "folio": 1001, "cvecont": 2002, "porccoprop": 60.0 }, { "folio": 1001, "cvecont": 2003, "porccoprop": 40.0 } ]

---

