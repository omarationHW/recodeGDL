# Documentación Técnica: Migración de Formulario CveDiferencias (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "Clave de Diferencias" permite la administración de claves de diferencias usadas en el sistema de ingresos municipales. Incluye la visualización, alta y modificación de claves, cada una asociada a una cuenta de ingreso y un usuario responsable.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación y formularios modales para alta/modificación.
- **Base de Datos:** PostgreSQL con lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getCveDiferencias|addCveDiferencia|updateCveDiferencia|getCuentasIngreso",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [...],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- Toda la lógica de negocio y acceso a datos reside en stored procedures PostgreSQL.
- El controlador Laravel solo invoca los SPs y retorna el resultado.

## 5. Vue.js
- Página independiente para CveDiferencias.
- Tabla con selección de fila.
- Modales para alta y edición.
- Navegación breadcrumb.
- Llama a la API unificada para todas las operaciones.

## 6. Seguridad
- El id_usuario se toma del contexto de sesión (ejemplo: Vuex store).
- Validaciones de entrada tanto en frontend como backend.

## 7. Consideraciones
- El endpoint es único para todo el sistema, la acción se determina por el campo `action`.
- Los stored procedures pueden ser reutilizados por otros módulos.
- El frontend es desacoplado y puede ser integrado en cualquier SPA Vue.js.

## 8. Tablas Relacionadas
- `ta_11_catalogo_dif`: Catálogo de claves de diferencias.
- `ta_12_passwords`: Usuarios.
- `ta_12_cuentas_aplicacion`: Catálogo de cuentas de ingreso.

## 9. Extensibilidad
- Para agregar/eliminar acciones, solo se requiere agregar el SP y mapearlo en el controlador.
- El frontend puede extenderse para soportar eliminación, búsqueda avanzada, etc.

## 10. Ejemplo de Request
```json
{
  "eRequest": {
    "action": "addCveDiferencia",
    "params": {
      "descripcion": "DIFERENCIA DE CAJA",
      "cuenta_ingreso": 44501,
      "id_usuario": 1
    }
  }
}
```

# Fin de Documentación
