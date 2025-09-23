# Casos de Uso - empresasfrm

**Categoría:** Form

## Caso de Uso 1: Alta de nueva empresa

**Descripción:** Un usuario administrativo da de alta una nueva empresa desde la página de Empresas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para crear empresas.

**Pasos a seguir:**
- El usuario accede a la página de Empresas.
- Da clic en 'Nueva Empresa'.
- Llena los campos obligatorios: Propietario, RFC, Ubicación, No. ext., Colonia, Zona, Subzona.
- Da clic en 'Guardar'.

**Resultado esperado:**
La empresa se guarda en la base de datos y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "propietario": "Juan Pérez",
  "rfc": "PEJJ800101XXX",
  "ubicacion": "Av. Juárez 123",
  "numext_ubic": 123,
  "colonia_ubic": "Centro",
  "zona": 1,
  "subzona": 2
}

---

## Caso de Uso 2: Edición de empresa existente

**Descripción:** Un usuario edita los datos de una empresa ya registrada.

**Precondiciones:**
Existe al menos una empresa registrada.

**Pasos a seguir:**
- El usuario busca la empresa por nombre o RFC.
- Da clic en 'Editar'.
- Modifica el campo 'Correo electrónico'.
- Da clic en 'Guardar'.

**Resultado esperado:**
Los cambios se guardan y se reflejan en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "empresa": 1001,
  "email": "nuevo@email.com"
}

---

## Caso de Uso 3: Eliminación de empresa

**Descripción:** Un usuario elimina una empresa del sistema.

**Precondiciones:**
Existe al menos una empresa registrada.

**Pasos a seguir:**
- El usuario busca la empresa.
- Da clic en 'Eliminar'.
- Confirma la eliminación.

**Resultado esperado:**
La empresa desaparece de la lista y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "empresa": 1001
}

---

