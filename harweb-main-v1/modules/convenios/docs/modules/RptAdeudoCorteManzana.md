# Documentación Técnica: Migración Formulario RptAdeudoCorteManzana (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte "Adeudo Corte Manzana" originalmente en Delphi, migrado a una arquitectura moderna con Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El reporte muestra el estado de adeudos agrupados por manzana y subtipo, con totales de costo, pagos, recargos y saldo.

## 2. Arquitectura
- **Backend**: Laravel API, expone un endpoint unificado `/api/execute` que recibe eRequest/eResponse para todas las operaciones.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente, sin tabs.
- **Base de Datos**: PostgreSQL, toda la lógica SQL relevante se encapsula en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Entrada**: `{ eRequest: { operation: string, params: object } }`
- **Salida**: `{ eResponse: { success: bool, data: any, message: string } }`
- **Operaciones soportadas**:
  - `getAdeudoCorteManzana`: Consulta el reporte.
  - `exportAdeudoCorteManzana`: Exporta el reporte (Excel/PDF).

## 4. Stored Procedure Principal
- **Nombre**: `sp_adeudo_corte_manzana`
- **Parámetros**:
  - `p_subtipo`: integer (subtipo de predio)
  - `p_fechadsd`: date (fecha desde, opcional)
  - `p_fechahst`: date (fecha hasta, filtra pagos hasta esta fecha)
  - `p_rep`: integer (tipo de reporte: 1=adeudos, 2=saldos a favor, 3=liquidados)
  - `p_est`: varchar (estado: 'A'=vigente, 'B'=baja, 'P'=pagado)
- **Retorna**: Tabla con los campos requeridos para el reporte.
- **Lógica**: Agrupa por manzana, calcula totales de costo, pagos, recargos y saldo.

## 5. Laravel Controller
- **Clase**: `AdeudoCorteManzanaController`
- **Método principal**: `execute(Request $request)`
- **Llama al SP**: vía `DB::select('CALL sp_adeudo_corte_manzana(?, ?, ?, ?, ?)', [...])`
- **Soporta exportación**: Simula exportación, puede integrarse con Laravel Excel.

## 6. Vue.js Component
- **Nombre**: `AdeudoCorteManzanaPage`
- **Funcionalidad**:
  - Formulario para seleccionar subtipo, fechas, estado y tipo de reporte.
  - Tabla de resultados con totales.
  - Botones para exportar a Excel/PDF.
  - Manejo de errores y loading.
- **Navegación**: Incluye breadcrumb.
- **Independiente**: No usa tabs, es una página completa.

## 7. Seguridad y Validaciones
- **Validación de parámetros**: En frontend y backend.
- **Control de errores**: Mensajes claros en eResponse.
- **Permisos**: Se recomienda integrar middleware de autenticación y autorización según el usuario.

## 8. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

## 9. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas operaciones fácilmente.
- El SP puede extenderse para soportar más filtros o agrupaciones.

## 10. Notas de Migración
- Los nombres de tablas y campos se mantienen fieles al modelo original.
- La lógica de cálculo de letras ('BIS', 'SUB') se implementa en el SP.
- El frontend es responsivo y preparado para integración con sistemas de autenticación modernos.

