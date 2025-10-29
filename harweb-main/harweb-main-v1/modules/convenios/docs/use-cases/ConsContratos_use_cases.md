# Casos de Uso - ConsContratos

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Contrato por Colonia, Calle y Folio

**Descripción:** El usuario desea consultar los contratos registrados para una colonia, calle y folio específicos.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de consulta.

**Pasos a seguir:**
- Selecciona la opción 'Contrato'.
- Ingresa el número de colonia, calle y folio.
- Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los contratos que coinciden con los criterios. El usuario puede ver el detalle de cada contrato.

**Datos de prueba:**
{ "colonia": 1, "calle": 2, "folio": 100 }

---

## Caso de Uso 2: Búsqueda de Contrato por Nombre

**Descripción:** El usuario busca contratos por el nombre del titular.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- Selecciona la opción 'Nombre'.
- Ingresa el nombre o parte del nombre.
- Presiona 'Buscar'.

**Resultado esperado:**
Se listan todos los contratos cuyo nombre contiene el texto ingresado.

**Datos de prueba:**
{ "nombre": "JUAN PEREZ" }

---

## Caso de Uso 3: Consulta de Detalle Individual de Contrato

**Descripción:** El usuario desea ver todos los datos de un contrato específico.

**Precondiciones:**
El usuario ha realizado una búsqueda y tiene el id_convenio.

**Pasos a seguir:**
- En la tabla de resultados, presiona 'Ver Detalle' en el contrato deseado.

**Resultado esperado:**
Se muestra un panel con todos los datos del contrato seleccionado.

**Datos de prueba:**
{ "id_convenio": 123 }

---

