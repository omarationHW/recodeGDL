# Documentación Técnica: Migración Formulario IndividualDiversos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **API**: Endpoint único `/api/execute` con patrón eRequest/eResponse
- **Stored Procedures**: Toda la lógica de negocio y reportes SQL se implementa en funciones/procedimientos almacenados de PostgreSQL
- **Autenticación**: Se recomienda JWT o Laravel Sanctum (no incluido aquí)

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { ... } }`
- **Acciones soportadas**:
  - `getConvenio`: Obtiene datos de un convenio por ID
  - `getAdeudos`: Lista de adeudos de un convenio
  - `getPagos`: Lista de pagos de un convenio
  - `buscarConvenio`: Busca convenio por criterios (tipo, subtipo, manzana/lote/letra o letras_exp/numero_exp/axo_exp)
  - `getReferencias`: Referencias asociadas al convenio
  - `getTipos`: Catálogo de tipos
  - `getSubTipos`: Catálogo de subtipos por tipo
  - `getFirma`: Datos de firma por recaudadora
  - `getResumen`: Resumen de adeudos/pagos/intereses

## 3. Stored Procedures
- Toda la lógica de cálculo de adeudos, pagos, intereses, recargos y referencias se implementa en funciones PostgreSQL.
- Ejemplo: `sp_individual_diversos_resumen(id_conv_resto)` devuelve totales de adeudos, recargos, intereses y pagos.
- Los procedimientos pueden ser llamados desde Laravel vía DB::select/DB::selectOne.

## 4. Vue.js Component
- Página independiente (no tab)
- Permite buscar convenio por tipo/subtipo y manzana/lote/letra o letras_exp/numero_exp/axo_exp
- Muestra datos del convenio, lista de adeudos, pagos y referencias
- Usa fetch a `/api/execute` con eRequest/eResponse
- Maneja errores y muestra mensajes amigables
- Usa filtros para formato de moneda

## 5. Validaciones y Seguridad
- Validación de parámetros en backend y frontend
- Manejo de errores y mensajes claros
- No se exponen detalles internos de la base de datos

## 6. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para nuevas acciones
- Los stored procedures pueden ser versionados y optimizados sin afectar la API

## 7. Migración de Lógica Delphi
- Todos los cálculos de intereses, recargos, periodos, etc. se migran a stored procedures
- El frontend Vue.js replica la experiencia de usuario del formulario Delphi, pero como página independiente
- No se usan tabs ni componentes tabulares: cada formulario es una página

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad

---
