# Casos de Uso - sQRptZonas

**Categoría:** Form

## Caso de Uso 1: Consulta de zonas clasificadas por Número de Control

**Descripción:** El usuario desea obtener el catálogo de zonas ordenado por el número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_zonas.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Selecciona 'Número de Control' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición al endpoint /api/execute con eRequest 'getZonasReport' y opcion=1.
5. El backend ejecuta el stored procedure y retorna los datos ordenados por ctrol_zona.
6. El frontend muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra la lista de zonas ordenada por el campo ctrol_zona.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 001        | A    | 1        | Centro      |
| 002        | B    | 2        | Norte       |

---

## Caso de Uso 2: Consulta de zonas clasificadas por Zona y Sub-Zona

**Descripción:** El usuario desea ver el catálogo de zonas ordenado primero por zona y luego por sub-zona.

**Precondiciones:**
El usuario tiene acceso y existen zonas con diferentes valores en zona y sub_zona.

**Pasos a seguir:**
1. Accede a la página de reporte de zonas.
2. Selecciona 'Zona' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición con opcion=2.
5. El backend retorna los datos ordenados por zona y sub_zona.

**Resultado esperado:**
La tabla muestra las zonas agrupadas por zona y ordenadas por sub_zona dentro de cada zona.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 003        | A    | 2        | Este        |
| 004        | A    | 1        | Oeste       |
| 005        | B    | 1        | Sur         |

---

## Caso de Uso 3: Consulta de zonas clasificadas por Descripción

**Descripción:** El usuario requiere ver el catálogo de zonas ordenado alfabéticamente por la descripción.

**Precondiciones:**
El usuario tiene acceso y existen descripciones variadas en la tabla.

**Pasos a seguir:**
1. Accede a la página de reporte de zonas.
2. Selecciona 'Descripción' como criterio de clasificación.
3. Hace clic en 'Consultar'.
4. El sistema envía la petición con opcion=4.
5. El backend retorna los datos ordenados por descripcion y ctrol_zona.

**Resultado esperado:**
La tabla muestra las zonas ordenadas alfabéticamente por el campo descripcion.

**Datos de prueba:**
ta_16_zonas:
| ctrol_zona | zona | sub_zona | descripcion |
|------------|------|----------|-------------|
| 006        | C    | 3        | Zafiro      |
| 007        | D    | 4        | Amatista    |
| 008        | E    | 5        | Rubí        |

---

