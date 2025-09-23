# Casos de Uso - DatosMovimientos

**Categoría:** Form

## Caso de Uso 1: Consulta de movimientos de un local existente

**Descripción:** El usuario desea consultar el historial de movimientos realizados sobre un local específico.

**Precondiciones:**
El usuario está autenticado y conoce el ID del local.

**Pasos a seguir:**
1. El usuario accede a la página de 'Consulta de Movimientos'.
2. Ingresa el ID del local en el campo correspondiente.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla con los movimientos asociados al local, incluyendo la descripción de vigencia y la renta calculada.

**Resultado esperado:**
Se visualiza correctamente el historial de movimientos del local, con todos los campos calculados.

**Datos de prueba:**
id_local: 12345

---

## Caso de Uso 2: Visualización de catálogos de claves de movimiento y cuota

**Descripción:** El usuario desea consultar los catálogos de claves de movimiento y de cuota para referencia.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de 'Consulta de Movimientos'.
2. Observa las secciones de catálogos en la parte inferior de la página.

**Resultado esperado:**
Se muestran correctamente los catálogos de claves de movimiento y de cuota.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Cálculo correcto de la renta para un movimiento con sección 'PS' y clave_cuota diferente de 4

**Descripción:** El usuario consulta un movimiento de un local con sección 'PS' y clave_cuota = 2, superficie = 10, importe_cuota = 100.

**Precondiciones:**
El usuario está autenticado y existe un movimiento con esos datos.

**Pasos a seguir:**
1. El usuario accede a la página de 'Consulta de Movimientos'.
2. Ingresa el ID del local correspondiente.
3. Presiona 'Buscar'.
4. Observa el valor de la renta en la tabla.

**Resultado esperado:**
La renta mostrada debe ser (100 * 10) * 30 = 30,000.

**Datos de prueba:**
id_local: 54321 (con movimiento sección 'PS', clave_cuota=2, superficie=10, importe_cuota=100)

---

