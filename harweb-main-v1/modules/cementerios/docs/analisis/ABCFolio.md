# Documentación Técnica: Migración ABCFolio Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL 13+ (todas las operaciones críticas en stored procedures)
- **Patrón API:** eRequest/eResponse (un solo endpoint, acción por parámetro `action`)

## 2. Endpoints y Acciones
- **/api/execute** (POST)
  - `action: getFolio` — Consulta datos completos de un folio
  - `action: updateFolio` — Modifica datos de un folio (incluye adicional)
  - `action: deleteFolio` — Da de baja lógica un folio
  - `action: getCementerios` — Lista de cementerios

## 3. Seguridad
- Autenticación Laravel Sanctum/JWT recomendada
- El controlador usa `$request->user()` para obtener el usuario actual
- Validación de datos estricta en backend

## 4. Stored Procedures
- **sp_13_historia:** Guarda histórico de cambios de folio
- **spd_abc_adercm:** Recalcula adeudos según operación (alta, baja, modificación)

## 5. Flujo de Modificación
1. El usuario busca un folio por número
2. El backend retorna datos principales, adicional, pagos y adeudos
3. El usuario edita y guarda
4. El backend:
   - Llama SP de histórico
   - Actualiza datos principales
   - Inserta/actualiza adicional
   - Llama SP de adeudos

## 6. Baja de Folio
- Marca el folio como `vigencia = 'B'`
- Llama SP para marcar adeudos como baja

## 7. Frontend
- Cada formulario es una página Vue.js independiente
- No se usan tabs ni componentes tabulares
- Navegación por rutas (ejemplo: `/abcf/folio`)
- Breadcrumbs para navegación
- Validación en frontend y backend

## 8. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba detallados

## 9. Consideraciones
- Todas las operaciones de modificación/baja usan transacciones
- El endpoint responde siempre con `{ success, message, data }`
- Los errores se devuelven en `message`

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los stored procedures pueden evolucionar sin cambiar el frontend
