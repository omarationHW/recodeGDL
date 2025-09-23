# Casos de Uso - Responsivafrm

**Categoría:** Form

## Caso de Uso 1: Alta de Responsiva para Licencia Existente

**Descripción:** El usuario desea emitir una nueva responsiva para una licencia vigente.

**Precondiciones:**
La licencia existe y está vigente. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia y presiona 'Buscar'.
2. El sistema muestra los datos de la licencia.
3. El usuario presiona 'Nueva Responsiva'.
4. El sistema solicita confirmación y crea la responsiva.

**Resultado esperado:**
Se crea una nueva responsiva con folio y año actual, visible en la lista.

**Datos de prueba:**
{ "licencia": 12345, "usuario": "admin" }

---

## Caso de Uso 2: Cancelación de Responsiva Existente

**Descripción:** El usuario cancela una responsiva vigente indicando el motivo.

**Precondiciones:**
Existe una responsiva vigente. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario busca la responsiva por año y folio.
2. El usuario presiona 'Cancelar'.
3. El sistema solicita el motivo de cancelación.
4. El usuario ingresa el motivo y confirma.

**Resultado esperado:**
La responsiva cambia a estado 'C' (cancelada) y el motivo queda registrado.

**Datos de prueba:**
{ "axo": 2024, "folio": 12, "motivo": "Duplicada", "usuario": "admin" }

---

## Caso de Uso 3: Búsqueda de Responsivas por Licencia

**Descripción:** El usuario desea ver todas las responsivas asociadas a una licencia.

**Precondiciones:**
Existen responsivas asociadas a la licencia.

**Pasos a seguir:**
1. El usuario ingresa el número de licencia en el filtro.
2. El usuario presiona 'Buscar'.
3. El sistema muestra todas las responsivas de esa licencia.

**Resultado esperado:**
Se listan todas las responsivas (vigentes y canceladas) de la licencia.

**Datos de prueba:**
{ "licencia": 12345, "tipo": "R" }

---

