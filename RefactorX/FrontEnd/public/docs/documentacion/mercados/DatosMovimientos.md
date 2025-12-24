# DatosMovimientos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de Formulario DatosMovimientos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "DatosMovimientos" permite consultar el historial de movimientos realizados sobre un local específico en el sistema de mercados municipales. Incluye la visualización de los movimientos, cálculo de la descripción de vigencia y cálculo de la renta asociada a cada movimiento.

La migración implementa:
- Backend en Laravel (API RESTful, endpoint único `/api/execute` con patrón eRequest/eResponse)
- Frontend en Vue.js (componente de página independiente)
- Lógica SQL en stored procedures PostgreSQL

## 2. Arquitectura
- **Backend:** Laravel Controller `DatosMovimientosController` con endpoint `/api/execute`.
- **Frontend:** Componente Vue.js `DatosMovimientosPage.vue`.
- **Base de Datos:** PostgreSQL con stored procedures para consultas y lógica de negocio.
- **Comunicación:** El frontend consume el backend vía HTTP POST a `/api/execute` enviando `{ action, params }` y recibiendo `{ success, data, message }`.

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute` (POST)
- **Acciones soportadas:**
  - `get_movimientos_by_local`: Devuelve movimientos de un local.
  - `get_clave_movimientos`: Catálogo de claves de movimiento.
  - `get_cve_cuotas`: Catálogo de claves de cuota.
  - `get_cuota_by_params`: Devuelve cuota según parámetros.
  - `calc_vigencia_descripcion`: Devuelve la descripción textual de la vigencia.
  - `calc_renta`: Calcula la renta según reglas de negocio.

## 4. Frontend (Vue.js)
- Página independiente con búsqueda por ID de local.
- Muestra tabla de movimientos con todos los campos relevantes.
- Calcula y muestra la descripción de vigencia y la renta para cada movimiento.
- Incluye catálogos de claves de movimiento y cuota.
- Navegación breadcrumb y botón de regreso.

## 5. Stored Procedures PostgreSQL
- `sp_get_movimientos_by_local(p_id_local)`
- `sp_get_clave_movimientos()`
- `sp_get_cve_cuotas()`
- `sp_get_cuota_by_params(p_vaxo, p_vcat, p_vsec, p_vcuo)`

## 6. Lógica de Negocio
- **Descripción de Vigencia:**
  - 'B' => 'BAJA'
  - 'C' => 'BAJA POR ACUERDO'
  - 'D' => 'BAJA ADMINISTRATIVA'
  - Otro => 'VIGENTE'
- **Cálculo de Renta:**
  - Si sección = 'PS' y clave_cuota = 4: `superficie * importe_cuota`
  - Si sección = 'PS' y clave_cuota != 4: `(importe_cuota * superficie) * 30`
  - Otro: `superficie * importe_cuota`

## 7. Seguridad
- Todas las acciones requieren autenticación (middleware Laravel).
- Validación de parámetros en backend.

## 8. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

## 9. Consideraciones
- El endpoint es unificado y extensible para futuras acciones.
- El frontend es desacoplado y puede ser integrado en cualquier SPA Vue.js.
- Los stored procedures pueden ser reutilizados por otros módulos.


## Casos de Uso

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



## Casos de Prueba

# Casos de Prueba para DatosMovimientos

## Caso 1: Consulta exitosa de movimientos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'get_movimientos_by_local', params: { id_local: 12345 } }
- **Resultado esperado:** Respuesta success=true, data contiene lista de movimientos, cada uno con campos completos.

## Caso 2: Catálogo de claves de movimiento
- **Entrada:** POST /api/execute { action: 'get_clave_movimientos' }
- **Resultado esperado:** success=true, data contiene lista de claves de movimiento.

## Caso 3: Catálogo de claves de cuota
- **Entrada:** POST /api/execute { action: 'get_cve_cuotas' }
- **Resultado esperado:** success=true, data contiene lista de claves de cuota.

## Caso 4: Cálculo de descripción de vigencia
- **Entrada:** POST /api/execute { action: 'calc_vigencia_descripcion', params: { vigencia: 'C' } }
- **Resultado esperado:** success=true, data='BAJA POR ACUERDO'

## Caso 5: Cálculo de renta sección 'PS', clave_cuota=2
- **Entrada:** POST /api/execute { action: 'calc_renta', params: { superficie: 10, importe_cuota: 100, seccion: 'PS', clave_cuota: 2 } }
- **Resultado esperado:** success=true, data=30000

## Caso 6: Consulta de movimientos para local inexistente
- **Entrada:** id_local = 999999
- **Acción:** POST /api/execute { action: 'get_movimientos_by_local', params: { id_local: 999999 } }
- **Resultado esperado:** success=true, data=[]



