# Casos de Uso - FrmEje

**Categoría:** Form

## Caso de Uso 1: Alta de nuevo ejecutor

**Descripción:** Un usuario autorizado da de alta un nuevo ejecutor fiscal en el sistema.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta.

**Pasos a seguir:**
1. El usuario accede a la página de ejecutores.
2. Hace clic en 'Nuevo Ejecutor'.
3. Llena el formulario con datos válidos (paterno, materno, nombres, RFC, recaudadora, oficio, fechas).
4. Hace clic en 'Guardar'.
5. El sistema envía un eRequest con action 'createEjecutor' y los datos.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
El ejecutor aparece en la lista y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "paterno": "Gomez",
  "materno": "Lopez",
  "nombres": "Juan Carlos",
  "rfc": "GOLJ800101XXX",
  "recaud": 2,
  "oficio": "OF-2024-001",
  "fecing": "2024-06-01",
  "fecinic": "2024-06-01",
  "fecterm": "2025-06-01"
}

---

## Caso de Uso 2: Edición de ejecutor existente

**Descripción:** Un usuario edita los datos de un ejecutor para corregir el RFC.

**Precondiciones:**
El ejecutor existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario busca el ejecutor en la lista.
2. Hace clic en 'Editar'.
3. Modifica el campo RFC.
4. Hace clic en 'Actualizar'.
5. El sistema envía un eRequest con action 'updateEjecutor' y los datos.
6. El backend ejecuta el SP y retorna éxito.

**Resultado esperado:**
El RFC del ejecutor se actualiza correctamente.

**Datos de prueba:**
{
  "cveejecutor": 5,
  "paterno": "Gomez",
  "materno": "Lopez",
  "nombres": "Juan Carlos",
  "rfc": "GOLJ800101ABC",
  "recaud": 2,
  "oficio": "OF-2024-001",
  "fecing": "2024-06-01",
  "fecinic": "2024-06-01",
  "fecterm": "2025-06-01"
}

---

## Caso de Uso 3: Reporte de ejecutores por recaudadora

**Descripción:** Un usuario genera un reporte de ejecutores filtrando por recaudadora y rango de fechas.

**Precondiciones:**
Existen ejecutores en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de ejecutores.
2. Hace clic en 'Reporte'.
3. El sistema solicita los filtros (fechas, recaudadora).
4. El usuario ingresa los filtros y confirma.
5. El sistema envía un eRequest con action 'reportEjecutores' y los filtros.
6. El backend ejecuta el SP y retorna los datos.

**Resultado esperado:**
Se muestra el reporte con los ejecutores filtrados.

**Datos de prueba:**
{
  "fecha_inicio": "2024-01-01",
  "fecha_fin": "2024-12-31",
  "recaud": 2
}

---

