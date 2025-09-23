# Casos de Uso - pres

**Categoría:** Form

## Caso de Uso 1: Prescribir adeudos de una cuenta en un rango de años/bimestres

**Descripción:** El usuario busca los saldos de una cuenta en un rango de años y bimestres, revisa el detalle y realiza la prescripción.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de prescripción.

**Pasos a seguir:**
- Ingresar el número de cuenta catastral.
- Ingresar año y bimestre inicial y final.
- Hacer clic en 'Buscar'.
- Revisar los saldos mostrados.
- Ingresar observaciones y usuario.
- Hacer clic en 'Prescribir'.

**Resultado esperado:**
La prescripción se registra, los saldos se actualizan y se recalculan correctamente.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "axoini": 2018,
  "bimini": 1,
  "axofin": 2020,
  "bimfin": 6,
  "observacion": "Prescripción por antigüedad",
  "usuario": "admin"
}

---

## Caso de Uso 2: Intentar prescribir sin completar todos los campos requeridos

**Descripción:** El usuario intenta prescribir sin llenar todos los campos obligatorios.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- Dejar vacío el campo 'usuario'.
- Hacer clic en 'Prescribir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando los campos faltantes.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "axoini": 2018,
  "bimini": 1,
  "axofin": 2020,
  "bimfin": 6,
  "observacion": "Prescripción por antigüedad"
}

---

## Caso de Uso 3: Listar todas las prescripciones de una cuenta

**Descripción:** El usuario consulta el historial de prescripciones de una cuenta.

**Precondiciones:**
La cuenta debe tener al menos una prescripción registrada.

**Pasos a seguir:**
- Ingresar el número de cuenta.
- Seleccionar la acción 'list'.

**Resultado esperado:**
El sistema retorna el listado de prescripciones para la cuenta indicada.

**Datos de prueba:**
{
  "cvecuenta": 12345
}

---

