# Casos de Uso - prophologramasfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo propietario de holograma

**Descripción:** El usuario desea registrar un nuevo propietario de holograma en el sistema.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los datos del propietario.

**Pasos a seguir:**
1. El usuario accede a la página de Propietarios de Hologramas.
2. Da clic en el botón 'Agregar'.
3. Llena el formulario con los datos requeridos (nombre, domicilio, capturista, etc).
4. Da clic en 'Aceptar'.

**Resultado esperado:**
El nuevo propietario se agrega a la tabla y aparece en la lista. El formulario se cierra y la tabla se actualiza.

**Datos de prueba:**
{
  "nombre": "JUAN PEREZ",
  "domicilio": "AV. PRINCIPAL 123",
  "colonia": "CENTRO",
  "telefono": "555-1234",
  "rfc": "PEPJ800101XXX",
  "curp": "PEPJ800101HDFRRN09",
  "email": "juan.perez@example.com",
  "capturista": "ADMIN"
}

---

## Caso de Uso 2: Modificar los datos de un propietario existente

**Descripción:** El usuario necesita corregir el domicilio de un propietario ya registrado.

**Precondiciones:**
Existe al menos un propietario registrado.

**Pasos a seguir:**
1. El usuario selecciona un registro en la tabla.
2. Da clic en 'Modificar'.
3. Cambia el campo 'Domicilio'.
4. Da clic en 'Aceptar'.

**Resultado esperado:**
El domicilio del propietario se actualiza y se refleja en la tabla.

**Datos de prueba:**
{
  "idcontrib": 1,
  "nombre": "JUAN PEREZ",
  "domicilio": "AV. REFORMA 456",
  "colonia": "CENTRO",
  "telefono": "555-1234",
  "rfc": "PEPJ800101XXX",
  "curp": "PEPJ800101HDFRRN09",
  "email": "juan.perez@example.com",
  "capturista": "ADMIN"
}

---

## Caso de Uso 3: Eliminar un propietario de holograma

**Descripción:** El usuario desea eliminar un propietario que ya no es válido.

**Precondiciones:**
Existe al menos un propietario registrado.

**Pasos a seguir:**
1. El usuario selecciona un registro en la tabla.
2. Da clic en 'Borrar'.
3. Confirma la eliminación en el diálogo.

**Resultado esperado:**
El registro es eliminado de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{
  "idcontrib": 1
}

---

