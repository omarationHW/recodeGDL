# Casos de Uso - Rep_Zonas

**Categoría:** Form

## Caso de Uso 1: Visualización del reporte de zonas ordenado por Control

**Descripción:** El usuario desea obtener una vista previa del reporte de zonas ordenado por el número de control.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. El usuario navega a la página 'Reporte de Zonas'.
2. Selecciona la opción 'Control' en el grupo de radio 'Ordenado Por'.
3. Hace clic en el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todas las zonas ordenadas por el campo 'ctrol_zona'.

**Datos de prueba:**
Zonas de ejemplo:
- ctrol_zona: 1, zona: 10, sub_zona: 1, descripcion: 'Centro'
- ctrol_zona: 2, zona: 20, sub_zona: 2, descripcion: 'Norte'

---

## Caso de Uso 2: Visualización del reporte de zonas ordenado por Descripción

**Descripción:** El usuario desea ver el reporte de zonas ordenado alfabéticamente por descripción.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo de reportes.

**Pasos a seguir:**
1. El usuario navega a la página 'Reporte de Zonas'.
2. Selecciona la opción 'Descripción' en el grupo de radio 'Ordenado Por'.
3. Hace clic en el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra una tabla con todas las zonas ordenadas alfabéticamente por el campo 'descripcion'.

**Datos de prueba:**
Zonas de ejemplo:
- ctrol_zona: 3, zona: 30, sub_zona: 1, descripcion: 'Alameda'
- ctrol_zona: 4, zona: 40, sub_zona: 2, descripcion: 'Zaragoza'

---

## Caso de Uso 3: Manejo de error al ejecutar el reporte sin conexión a la base de datos

**Descripción:** El usuario intenta generar el reporte pero la base de datos está caída.

**Precondiciones:**
El usuario está autenticado. La base de datos PostgreSQL está fuera de línea.

**Pasos a seguir:**
1. El usuario navega a la página 'Reporte de Zonas'.
2. Selecciona cualquier opción de orden.
3. Hace clic en el botón 'Vista Previa'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que no se pudo obtener el reporte.

**Datos de prueba:**
No aplica (simulación de caída de base de datos).

---

