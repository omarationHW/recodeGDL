# Casos de Uso - conduenosfrm

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo condueño persona física

**Descripción:** Un usuario del área de catastro necesita agregar un nuevo condueño persona física a una cuenta catastral existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición. La cuenta catastral existe y está vigente.

**Pasos a seguir:**
1. El usuario accede a la página de condueños de la cuenta.
2. Hace clic en 'Agregar Condueño'.
3. Llena el formulario con los datos personales, domicilio, RFC, porcentaje (ej. 50), y marca 'Encabeza'.
4. Envía el formulario.
5. El sistema valida que la suma de porcentajes será 100% y que solo hay un encabeza.
6. El sistema guarda el nuevo condueño y actualiza la lista.

**Resultado esperado:**
El nuevo condueño aparece en la lista, la suma de porcentajes es 100%, y el campo 'Encabeza' está correctamente asignado.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "nombre_completo": "JUAN PEREZ LOPEZ",
  "rfc": "PELJ800101XXX",
  "porcentaje": 50,
  "encabeza": "S",
  "exento": "N",
  "usuario": "admin"
}

---

## Caso de Uso 2: Eliminación lógica de un condueño

**Descripción:** Un usuario necesita cancelar (eliminar lógicamente) un condueño que ya no debe figurar en la cuenta.

**Precondiciones:**
El usuario está autenticado. El condueño existe y está vigente.

**Pasos a seguir:**
1. El usuario localiza el condueño en la lista.
2. Hace clic en 'Eliminar'.
3. El sistema solicita confirmación.
4. El usuario confirma.
5. El sistema marca el registro como 'C' (cancelado) y actualiza la lista.

**Resultado esperado:**
El condueño desaparece de la lista principal (o aparece como cancelado), y la suma de porcentajes se ajusta.

**Datos de prueba:**
{ "cvecont": 101 }

---

## Caso de Uso 3: Validación de RFC duplicado

**Descripción:** Al intentar registrar un nuevo condueño, el sistema debe validar que el RFC no esté repetido en otro contribuyente.

**Precondiciones:**
Existe al menos un contribuyente con el RFC 'PELJ800101XXX'.

**Pasos a seguir:**
1. El usuario inicia el alta de un nuevo condueño.
2. Ingresa el RFC 'PELJ800101XXX'.
3. El sistema ejecuta la validación de RFC.
4. Si el RFC ya existe en otro contribuyente, muestra un error.

**Resultado esperado:**
El sistema impide guardar el registro y muestra un mensaje de RFC duplicado.

**Datos de prueba:**
{ "rfc": "PELJ800101XXX", "cvecont": 0 }

---

