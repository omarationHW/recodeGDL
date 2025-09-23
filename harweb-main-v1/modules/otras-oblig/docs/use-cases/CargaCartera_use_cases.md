# Casos de Uso - CargaCartera

**Categoría:** Form

## Caso de Uso 1: Carga exitosa de cartera para tabla y ejercicio existente

**Descripción:** El usuario selecciona una tabla y un ejercicio con unidades asociadas y ejecuta la carga de cartera.

**Precondiciones:**
El usuario tiene acceso al sistema y existen unidades para la tabla y ejercicio seleccionados.

**Pasos a seguir:**
1. Ingresar a la página de Carga de Carteras.
2. Seleccionar una tabla de la lista.
3. Seleccionar un ejercicio disponible.
4. Verificar que se muestran unidades en la tabla.
5. Presionar el botón 'Aplicar'.
6. Confirmar la operación en el diálogo de confirmación.

**Resultado esperado:**
Se muestra un mensaje de éxito indicando que la cartera fue generada correctamente.

**Datos de prueba:**
Tabla: '3' (Rastro), Ejercicio: 2024 (con unidades cargadas)

---

## Caso de Uso 2: Intento de carga de cartera sin unidades

**Descripción:** El usuario selecciona una tabla y ejercicio para los cuales no existen unidades.

**Precondiciones:**
El usuario tiene acceso al sistema. No existen unidades para la tabla y ejercicio seleccionados.

**Pasos a seguir:**
1. Ingresar a la página de Carga de Carteras.
2. Seleccionar una tabla.
3. Seleccionar un ejercicio sin unidades.
4. Observar que la tabla de unidades está vacía.
5. El botón 'Aplicar' está deshabilitado.

**Resultado esperado:**
No se puede ejecutar la carga. Se muestra mensaje indicando que no existen unidades.

**Datos de prueba:**
Tabla: '5' (sin unidades para ejercicio 2022)

---

## Caso de Uso 3: Error en el proceso de generación de cartera

**Descripción:** Se simula un error en el stored procedure (por ejemplo, error de base de datos).

**Precondiciones:**
El usuario tiene acceso al sistema. El stored procedure lanza una excepción.

**Pasos a seguir:**
1. Ingresar a la página de Carga de Carteras.
2. Seleccionar una tabla y ejercicio válidos.
3. Presionar 'Aplicar'.
4. El stored procedure falla internamente.

**Resultado esperado:**
Se muestra un mensaje de error con la descripción del problema.

**Datos de prueba:**
Forzar error en SP (ejemplo: tabla bloqueada, error de permisos, etc.)

---

