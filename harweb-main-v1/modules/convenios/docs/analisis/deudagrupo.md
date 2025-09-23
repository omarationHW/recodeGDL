# Documentación Técnica: Migración Formulario Deuda Grupo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Deuda de Contratos con Recargos" (deudagrupo) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Permite consultar y exportar la relación de adeudos de convenios, calculando recargos a una fecha determinada.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, toda la lógica SQL compleja se encapsula en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute` (POST)
- **Formato:**
  ```json
  {
    "action": "getDeudaGrupo", // o "exportDeudaGrupo"
    "params": {
      "axo": 2024,
      "fecha_recargo": "2024-06-01"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure Principal
- **sp_deuda_grupo(axo integer, fecha_recargo date):**
  - Devuelve la relación de adeudos de convenios, calculando recargos según la fecha indicada.
  - Implementa la lógica de cálculo de recargos replicando el algoritmo Delphi.

## 5. Frontend (Vue.js)
- Página independiente `/deuda-grupo`.
- Filtros: Año de obra, fecha para calcular recargos.
- Tabla de resultados con todos los campos relevantes.
- Botón de exportar (llama a la API, puede devolver base64 o trigger de descarga).
- Breadcrumb de navegación.
- Mensajes de error y loading.

## 6. Backend (Laravel)
- Controlador `DeudaGrupoController` con método `execute`.
- Métodos privados para cada acción (`getDeudaGrupo`, `exportDeudaGrupo`).
- Llama al stored procedure PostgreSQL usando DB::select.
- Validación básica de parámetros.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la política del sistema.
- Validar que los parámetros sean correctos y no permitir SQL injection (al usar parámetros bind en DB::select).

## 8. Exportación
- El método `exportDeudaGrupo` puede ser extendido para generar archivos Excel reales usando PhpSpreadsheet y devolver un enlace de descarga o base64.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- El frontend puede ser extendido para agregar filtros adicionales o paginación.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

---
