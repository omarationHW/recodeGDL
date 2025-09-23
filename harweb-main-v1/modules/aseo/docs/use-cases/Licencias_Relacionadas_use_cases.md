# Casos de Uso - Licencias_Relacionadas

**Categoría:** Form

## Caso de Uso 1: Consulta de todas las licencias relacionadas

**Descripción:** El usuario desea ver todas las licencias relacionadas a contratos.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo.

**Pasos a seguir:**
1. El usuario accede a la página de Licencias Relacionadas.
2. Selecciona la opción 'Todas'.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todas las licencias relacionadas a contratos.

**Datos de prueba:**
No se requiere dato específico.

---

## Caso de Uso 2: Búsqueda de licencias relacionadas por número de licencia

**Descripción:** El usuario busca las relaciones de una licencia específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario accede a la página de Licencias Relacionadas.
2. Selecciona la opción 'Por Licencia'.
3. Ingresa el número de licencia (ejemplo: 12345).
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestran las relaciones de la licencia 12345 con contratos.

**Datos de prueba:**
num_licencia: 12345

---

## Caso de Uso 3: Desligar una licencia de un contrato

**Descripción:** El usuario desea eliminar la relación entre una licencia y un contrato.

**Precondiciones:**
Existe una relación entre la licencia 12345 y el contrato 3215.

**Pasos a seguir:**
1. El usuario busca por contrato 3215.
2. En la tabla, localiza la fila con licencia 12345.
3. Presiona el botón 'Desligar'.
4. Confirma la acción.

**Resultado esperado:**
La relación es eliminada y la tabla se actualiza.

**Datos de prueba:**
num_licencia: 12345, control_contrato: 3215

---

