# Casos de Uso - frmconstglob

**Categoría:** Form

## Caso de Uso 1: Consulta de construcciones globales por clave catastral

**Descripción:** El usuario ingresa una clave catastral y visualiza todas las construcciones globales asociadas.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Construcciones Globales.
2. Ingresa la clave catastral (ej: D6512345678).
3. Presiona 'Buscar'.
4. El sistema muestra la lista de construcciones globales asociadas.

**Resultado esperado:**
Se muestra una tabla con todas las construcciones globales vigentes para la clave catastral ingresada.

**Datos de prueba:**
cvecatnva: D6512345678

---

## Caso de Uso 2: Alta de una nueva construcción global

**Descripción:** El usuario agrega una nueva construcción global para una clave catastral existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. La clave catastral existe.

**Pasos a seguir:**
1. El usuario busca la clave catastral.
2. Presiona 'Agregar Nueva Construcción'.
3. Llena el formulario con los datos requeridos.
4. Presiona 'Guardar'.
5. El sistema confirma la creación y actualiza la lista.

**Resultado esperado:**
La nueva construcción aparece en la lista y puede ser consultada o editada.

**Datos de prueba:**
{
  "cvecatnva": "D6512345678",
  "subpredio": 0,
  "cvebloque": 5,
  "axoconst": 2015,
  "areaconst": 120.5,
  "cveclasif": 2,
  "cvecuenta": 12345,
  "estructura": 1,
  "factorajus": 1.0,
  "numpisos": 2,
  "importe": 250000.00,
  "cveavaluo": 1001,
  "axovig": 2024,
  "vigente": "V"
}

---

## Caso de Uso 3: Eliminación de una construcción global

**Descripción:** El usuario elimina una construcción global existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación. El registro existe.

**Pasos a seguir:**
1. El usuario busca la clave catastral.
2. En la lista, selecciona el registro a eliminar y presiona 'Eliminar'.
3. Confirma la eliminación.
4. El sistema elimina el registro y actualiza la lista.

**Resultado esperado:**
El registro eliminado ya no aparece en la lista.

**Datos de prueba:**
cvebloque: 5

---

