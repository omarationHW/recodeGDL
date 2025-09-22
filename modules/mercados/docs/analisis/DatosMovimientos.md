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
