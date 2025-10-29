# Casos de Uso - sQRptTipos_Empresas

**Categoría:** Form

## Caso de Uso 1: Visualizar catálogo de tipos de empresas ordenado por número de control

**Descripción:** El usuario accede a la página del catálogo y visualiza la lista de tipos de empresas ordenada por el campo 'ctrol_emp'.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_16_tipos_emp.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Empresas'.
2. El sistema carga automáticamente la lista ordenada por número de control (opcion=1).
3. El usuario visualiza la tabla con los campos: Control, Tipo, Descripción.

**Resultado esperado:**
La tabla muestra todos los registros de tipos de empresas ordenados ascendentemente por el campo 'ctrol_emp'.

**Datos de prueba:**
ta_16_tipos_emp:
| ctrol_emp | tipo_empresa | descripcion         |
|-----------|--------------|--------------------|
| 1         | A            | Empresa Industrial |
| 2         | B            | Empresa Comercial  |

---

## Caso de Uso 2: Cambiar criterio de ordenamiento a 'Tipo'

**Descripción:** El usuario selecciona 'Tipo' en el selector de clasificación y la tabla se actualiza ordenada por el campo 'tipo_empresa'.

**Precondiciones:**
El usuario está en la página del catálogo y existen registros con diferentes valores en 'tipo_empresa'.

**Pasos a seguir:**
1. El usuario selecciona 'Tipo' en el selector de clasificación.
2. El sistema envía la petición con opcion=2.
3. La tabla se actualiza mostrando los registros ordenados por 'tipo_empresa'.

**Resultado esperado:**
La tabla muestra los registros ordenados ascendentemente por el campo 'tipo_empresa'.

**Datos de prueba:**
ta_16_tipos_emp:
| ctrol_emp | tipo_empresa | descripcion         |
|-----------|--------------|--------------------|
| 2         | B            | Empresa Comercial  |
| 1         | A            | Empresa Industrial |

---

## Caso de Uso 3: Manejo de tabla vacía

**Descripción:** El usuario accede a la página cuando no existen registros en la tabla ta_16_tipos_emp.

**Precondiciones:**
La tabla ta_16_tipos_emp está vacía.

**Pasos a seguir:**
1. El usuario navega a la página 'Catálogo de Tipos de Empresas'.
2. El sistema consulta la base de datos y no encuentra registros.
3. Se muestra un mensaje indicando que no hay registros.

**Resultado esperado:**
La tabla muestra una fila con el mensaje 'No hay registros para mostrar.'

**Datos de prueba:**
ta_16_tipos_emp: (sin registros)

---

