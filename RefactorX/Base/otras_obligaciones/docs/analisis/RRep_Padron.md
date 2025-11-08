# Documentación Técnica: Migración de Formulario RRep_Padron (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte del padrón de concesiones del rastro municipal, permitiendo filtrar por vigencia, periodo de adeudos y visualizar el detalle de adeudos y recargos por concesión.

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica de cálculo de adeudos en stored procedure `con34_1detade_01`.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "get_concesiones_with_adeudos",
      "params": {
        "vigencia": "T|V|C",
        "rep": "V|A",
        "fecha": "YYYY-MM"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        {
          "id_34_datos": 1,
          "control": "0001",
          "concesionario": "Juan Perez",
          ...
          "adeudos": [
            { "expression": "Adeudo periodo 2024-06", "expression_1": 1000, "expression_2": 200 },
            ...
          ]
        },
        ...
      ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `con34_1detade_01`
- **Parámetros:**
  - `par_Control` (integer): ID de la concesión
  - `par_Rep` (varchar): Tipo de reporte ('V' = vencidos, 'A' = otro periodo)
  - `par_Fecha` (varchar): Periodo en formato 'YYYY-MM'
- **Retorna:** Lista de adeudos y recargos por periodo para la concesión

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Permite seleccionar vigencia, tipo de periodo, año y mes.
- Botón "Previa" consulta y muestra el reporte.
- Botón "Salir" regresa a la página anterior.
- Muestra tabla con concesiones y, para cada una, el detalle de adeudos y recargos.

## 6. Validaciones
- Si se selecciona "Otro Periodo", el año es obligatorio y debe ser numérico de 4 dígitos.
- El reporte sólo se muestra si hay datos.

## 7. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej. JWT, Sanctum) según la política de la aplicación.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin crear nuevos endpoints.
- El frontend puede adaptarse fácilmente a nuevos filtros o columnas.

## 9. Pruebas
- Casos de uso y pruebas incluidas para asegurar la funcionalidad y robustez del módulo.
