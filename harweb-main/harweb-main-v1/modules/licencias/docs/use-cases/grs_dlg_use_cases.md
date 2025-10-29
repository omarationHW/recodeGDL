# Casos de Uso - grs_dlg

**Categoría:** Form

## Caso de Uso 1: Búsqueda parcial insensible a mayúsculas/minúsculas en clientes

**Descripción:** El usuario busca todos los clientes cuyo nombre contiene 'juan', sin importar mayúsculas/minúsculas.

**Precondiciones:**
La tabla 'clientes' existe y tiene un campo 'nombre'.

**Pasos a seguir:**
1. Ingresar 'clientes' en el campo Tabla.
2. Ingresar 'nombre' en el campo Campo.
3. Ingresar 'juan' en el campo Valor a buscar.
4. Seleccionar 'No distinguir' en Mayúsculas/Minúsculas.
5. Seleccionar 'Sí' en Búsqueda parcial.
6. Presionar 'Buscar'.

**Resultado esperado:**
Se muestran todos los registros de clientes cuyo nombre contiene 'juan', como 'Juan Pérez', 'JUANITA', 'María Juan'.

**Datos de prueba:**
Tabla: clientes
Campo: nombre
Valor: juan
case_insensitive: true
partial: true

---

## Caso de Uso 2: Búsqueda exacta y sensible a mayúsculas/minúsculas en productos

**Descripción:** El usuario busca productos cuyo código es exactamente 'ABC123', distinguiendo mayúsculas/minúsculas.

**Precondiciones:**
La tabla 'productos' existe y tiene un campo 'codigo'.

**Pasos a seguir:**
1. Ingresar 'productos' en el campo Tabla.
2. Ingresar 'codigo' en el campo Campo.
3. Ingresar 'ABC123' en el campo Valor a buscar.
4. Seleccionar 'Distinguir' en Mayúsculas/Minúsculas.
5. Seleccionar 'No' en Búsqueda parcial.
6. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra solo el producto cuyo código es exactamente 'ABC123'.

**Datos de prueba:**
Tabla: productos
Campo: codigo
Valor: ABC123
case_insensitive: false
partial: false

---

## Caso de Uso 3: Búsqueda sin resultados

**Descripción:** El usuario busca un valor inexistente en la tabla de proveedores.

**Precondiciones:**
La tabla 'proveedores' existe y tiene un campo 'razon_social'.

**Pasos a seguir:**
1. Ingresar 'proveedores' en el campo Tabla.
2. Ingresar 'razon_social' en el campo Campo.
3. Ingresar 'ZZZZZZ' en el campo Valor a buscar.
4. Presionar 'Buscar'.

**Resultado esperado:**
No se muestran resultados y aparece el mensaje 'No se encontraron resultados.'

**Datos de prueba:**
Tabla: proveedores
Campo: razon_social
Valor: ZZZZZZ
case_insensitive: true
partial: true

---

