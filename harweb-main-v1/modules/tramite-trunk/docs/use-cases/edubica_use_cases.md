# Casos de Uso - edubica

**Categoría:** Form

## Caso de Uso 1: Registrar nueva ubicación para una cuenta catastral

**Descripción:** El usuario desea actualizar la ubicación de un predio, cambiando calle, colonia y número exterior/interior.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La cuenta catastral existe y está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de Edición de Ubicación.
2. Ingresa el número de cuenta catastral.
3. Selecciona la nueva calle y colonia del catálogo.
4. Ingresa el nuevo número exterior (máximo 6 dígitos) y, si aplica, el interior.
5. Ingresa observaciones adicionales si es necesario.
6. Selecciona el año y bimestre de efectos.
7. Ingresa su usuario.
8. Presiona 'Guardar Cambios'.

**Resultado esperado:**
La ubicación anterior se cierra (vigencia 'C'), se registra la nueva ubicación como vigente ('V'), y se actualiza el registro de catastro con el nuevo cveubic, año y bimestre de efectos, y observaciones. El usuario recibe un mensaje de éxito.

**Datos de prueba:**
{
  "cvecuenta": 123456,
  "cvecalle": 101,
  "cvecolonia": 55,
  "noexterior": "000123",
  "interior": "A",
  "obsinter": "Cambio por subdivisión",
  "axoefec": 2024,
  "bimefec": 2,
  "usuario": "jlopez",
  "catastro_asiento": 10,
  "catastro_cvemov": 40
}

---

## Caso de Uso 2: Validación de campos obligatorios y reglas de negocio

**Descripción:** El usuario intenta guardar una ubicación sin completar todos los campos requeridos o con datos inválidos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede al formulario.
2. Deja vacío el campo 'No. Exterior' o ingresa un año de efectos menor a 1900.
3. Presiona 'Guardar Cambios'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando el campo faltante o inválido y no guarda la información.

**Datos de prueba:**
{
  "cvecuenta": 123456,
  "cvecalle": 101,
  "cvecolonia": 55,
  "noexterior": "",
  "interior": "",
  "obsinter": "",
  "axoefec": 1899,
  "bimefec": 2,
  "usuario": "jlopez"
}

---

## Caso de Uso 3: Consulta de catálogo de calles y colonias

**Descripción:** El usuario necesita seleccionar una calle y colonia del catálogo para registrar la ubicación.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede al formulario de Edición de Ubicación.
2. El sistema carga automáticamente el catálogo de calles y colonias.
3. El usuario selecciona los valores deseados.

**Resultado esperado:**
El sistema muestra los catálogos completos y actualizados de calles y colonias para su selección.

**Datos de prueba:**
N/A (solo consulta, sin datos de entrada)

---

