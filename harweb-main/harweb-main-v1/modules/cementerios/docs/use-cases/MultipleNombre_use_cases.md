# Casos de Uso - MultipleNombre

**Categoría:** Form

## Caso de Uso 1: Búsqueda de fosas por nombre en todos los cementerios

**Descripción:** El usuario desea encontrar todas las fosas cuyo nombre contiene 'JUAN' en cualquier cementerio.

**Precondiciones:**
El usuario tiene acceso al sistema y la base de datos contiene registros con nombre 'JUAN'.

**Pasos a seguir:**
1. El usuario ingresa 'JUAN' en el campo Nombre.
2. Selecciona la opción 'Todos' en cementerios.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con hasta 100 registros cuyo nombre contiene 'JUAN', de todos los cementerios.

**Datos de prueba:**
Nombre: JUAN
Cementerio: Todos

---

## Caso de Uso 2: Búsqueda de fosas por nombre en un cementerio específico

**Descripción:** El usuario desea buscar registros cuyo nombre contiene 'MARIA' solo en el cementerio 'B'.

**Precondiciones:**
El usuario tiene acceso y existen registros con nombre 'MARIA' en el cementerio 'B'.

**Pasos a seguir:**
1. El usuario ingresa 'MARIA' en el campo Nombre.
2. Selecciona la opción 'Busca en' y elige cementerio 'B'.
3. Presiona 'Buscar'.

**Resultado esperado:**
Se muestran los registros de 'MARIA' solo del cementerio 'B'.

**Datos de prueba:**
Nombre: MARIA
Cementerio: B

---

## Caso de Uso 3: Paginación de resultados (Continuar búsqueda)

**Descripción:** El usuario realiza una búsqueda que retorna más de 100 resultados y desea ver los siguientes registros.

**Precondiciones:**
Existen más de 100 registros para el nombre buscado.

**Pasos a seguir:**
1. El usuario realiza una búsqueda por nombre.
2. Se muestran los primeros 100 resultados y aparece el botón 'Continuar búsqueda'.
3. El usuario presiona 'Continuar búsqueda'.

**Resultado esperado:**
Se muestran los siguientes 100 registros, agregados a la tabla.

**Datos de prueba:**
Nombre: ANA
Cementerio: Todos

---

