# Casos de Uso - ABCEjec

**Categoría:** Form

## Caso de Uso 1: Alta de nuevo ejecutor

**Descripción:** Un usuario administrador desea dar de alta un nuevo ejecutor fiscal en la recaudadora 2.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario accede a la página de ejecutores.
2. Selecciona la recaudadora 2.
3. Hace clic en 'Nuevo Ejecutor'.
4. Llena el formulario con los datos requeridos (cve_eje, nombre, RFC, oficio, fechas).
5. Hace clic en 'Guardar'.

**Resultado esperado:**
El ejecutor es creado, aparece en la lista y su vigencia es 'Activo'.

**Datos de prueba:**
{
  "cve_eje": 123,
  "ini_rfc": "ABCD",
  "fec_rfc": "1990-01-01",
  "hom_rfc": "123",
  "nombre": "Juan Pérez",
  "id_rec": 2,
  "oficio": "OF-2024-01",
  "fecinic": "2024-01-01",
  "fecterm": "2024-12-31"
}

---

## Caso de Uso 2: Modificación de ejecutor existente

**Descripción:** El usuario necesita corregir el nombre y la fecha de término de un ejecutor existente.

**Precondiciones:**
El ejecutor existe y está activo.

**Pasos a seguir:**
1. El usuario busca el ejecutor por número y recaudadora.
2. Hace clic en 'Editar'.
3. Modifica el nombre y la fecha de término.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
Los datos del ejecutor se actualizan correctamente.

**Datos de prueba:**
{
  "cve_eje": 123,
  "id_rec": 2,
  "nombre": "Juan Pérez Modificado",
  "fecterm": "2025-12-31"
}

---

## Caso de Uso 3: Baja y reactivación de ejecutor

**Descripción:** El usuario da de baja un ejecutor y posteriormente lo reactiva.

**Precondiciones:**
El ejecutor existe y está activo.

**Pasos a seguir:**
1. El usuario localiza el ejecutor en la lista.
2. Hace clic en 'Dar de Baja'.
3. Confirma la acción.
4. El ejecutor aparece como 'Baja'.
5. El usuario hace clic en 'Reactivar'.
6. Confirma la acción.

**Resultado esperado:**
El ejecutor cambia de estado correctamente entre 'Activo' y 'Baja'.

**Datos de prueba:**
{
  "cve_eje": 123,
  "id_rec": 2
}

---

